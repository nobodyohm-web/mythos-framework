# Skill — Self-Improvement Loop

> The closed loop that turns Mythos into a system that compounds: run benchmark → extract failures → write lessons/hooks → re-run → measure delta.

**Trigger when:** the user asks "how can Mythos get better?", after a `/reflect` session, after a benchmark run, or when ≥3 lessons accumulated since the last evolution.

**Skip when:** there is no verifiable signal (subjective tasks). Self-improvement only works in domains where outcomes can be objectively measured.

---

## The core insight (2026 SOTA)

> "AI self-improvement only works where outcomes are verifiable."

The signal that drives improvement must come from a verifiable source:
- ✅ Code passing/failing tests
- ✅ Patch matching gold patch (semantic or exact)
- ✅ Hook exit codes (block / allow correct?)
- ✅ Confidence calibration (predicted vs actual)
- ❌ User satisfaction (subjective, easily reward-hacked)
- ❌ "Did the agent sound confident?" (cosmetic)

If there's no verifiable signal, do not run the self-improvement loop — log a lesson manually instead.

---

## The loop

```
   ┌─────────────────────────────────────────┐
   │                                         │
   ▼                                         │
[1. RUN BENCHMARK]                           │
   │  /benchmark or hooks/test-mythos.sh     │
   │  → score, failure traces                │
   ▼                                         │
[2. EXTRACT FAILURES]                        │
   │  parse traces → group by root cause     │
   ▼                                         │
[3. WRITE LESSON OR HOOK]                    │
   │  recurring? → hook in hooks/ + tests    │
   │  one-off?   → lesson in tasks/lessons.md│
   ▼                                         │
[4. RE-RUN BENCHMARK]                        │
   │  measure delta                          │
   ▼                                         │
[5. SHIP OR LOOP]                            │
      delta > 0 → commit; record in patterns │
      delta = 0 → root-cause again ──────────┘
      delta < 0 → revert, escalate
```

---

## Step-by-step

### 1. Run benchmark
- For Mythos infrastructure: `bash hooks/test-mythos.sh` (current score)
- For coding ability: `/benchmark` (SWE-bench mini, configurable N)
- For confidence calibration: `/calibrate`

Record the baseline score before any change.

### 2. Extract failures
For each failure:
- What was the input?
- What was expected?
- What did Mythos do?
- What's the **smallest** description of why?

Group by root cause. Three failures pointing at "guard didn't block X" are one root cause, not three.

### 3. Write lesson or hook
**Lesson** (in `tasks/lessons.md`) when:
- The failure is about judgment (didn't ask user before doing X).
- The class of error is rare or context-dependent.
- A rule in CLAUDE.md / a skill is enough.

**Hook** (in `hooks/`) when:
- The failure is deterministic (Mythos took an action that should have been blocked).
- The check is cheap to run on every relevant tool call.
- The failure has happened more than once or is high-blast-radius.

Defense in depth: high-stakes invariants get BOTH a lesson AND a hook.

### 4. Re-run benchmark
- Same N, same seed if possible.
- Measure: did the score go up? Did the specific failure cases now pass?

### 5. Ship or loop
- **Score up + targeted failures fixed:** commit. Record in `.claude/memory/patterns.json` under `evolutionHistory`.
- **Score same:** the change didn't help. Re-investigate the root cause; the hypothesis was wrong.
- **Score down:** revert. The fix introduced a regression. Add a regression test before retrying.

Three consecutive iterations with no improvement → escalate to user. The system has hit a local max.

---

## Output format

```
═══════════════════════════════════════════
  ♻️  SELF-IMPROVE — iteration <N>
═══════════════════════════════════════════
📊 BASELINE:  <score>/100  (<timestamp>)
🔬 FAILURES:  <count>
   - <root cause 1> (<frequency>)
   - <root cause 2> (<frequency>)

🛠️  CHANGE:    <hook | lesson | both>
   - <file> — <description>

📈 NEW SCORE: <score>/100  (Δ +<n>)
🎯 TARGETED FAILURES NOW PASSING: <list>

🚦 VERDICT: SHIP | RETRY | REVERT
═══════════════════════════════════════════
```

---

## Calibration sub-loop

Run `/calibrate` after every ~10 confidence-logged actions. The output adjusts how aggressively the system trusts its own scores:

- **Over-confident**: tighten 90+ band — require harder evidence.
- **Under-confident**: loosen 70+ band — current bar wastes runway on certainties.
- **Calibrated**: bands stay; loop runs again next cycle.

---

## Anti-patterns

- ❌ Optimizing for benchmark score directly without verifying the underlying behavior changed (Goodhart's law).
- ❌ Adding hooks/lessons without measuring delta — looks busy, isn't improving.
- ❌ Adding a hook that fires on every tool call to fix a once-a-week failure (cost > benefit).
- ❌ Treating user satisfaction as a metric (not verifiable).
- ❌ Skipping the regression test when the change "obviously" works.

---

## References
- Loop driver: `.claude/commands/benchmark.md`
- Failure metrics: `.claude/memory/eval-metrics.jsonl`
- Lessons: `tasks/lessons.md`
- Patterns: `.claude/memory/patterns.json`
- Calibration: `.claude/commands/calibrate.md`
