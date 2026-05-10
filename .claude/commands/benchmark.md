---
description: Run a benchmark suite against the Mythos system. Measures self-test health, optionally runs SWE-bench-style coding tasks, and feeds metrics into the self-improvement loop.
allowed-tools: Read Edit Write Bash Task
argument-hint: "[--n=5] [--mode=infra|swe-mini|both]"
---

# /benchmark — Mythos Evaluation Runner

Run verifiable evaluations and append metrics to `.claude/memory/eval-metrics.jsonl`. Default mode runs the cheap infra suite; pass `--mode=swe-mini` to run a small SWE-bench-style coding suite (requires `benchmark/cases/` to be populated).

## Modes

### `--mode=infra` (default, fast, no external deps)

Runs `bash hooks/test-mythos.sh` and parses the result.

**Pass criteria:** every check green (FAIL count = 0).

**Output:**
- Total / passed / failed counts
- List of failing checks with their diagnostic line
- Score = `passed / total * 100`

### `--mode=swe-mini` (slower, needs `benchmark/cases/`)

For each case in `benchmark/cases/*.json` (limit to `--n` cases, default 5):

1. Read `instance.json` → `{problem_statement, base_commit, golden_diff, repo}`.
2. Stage the working dir at `base_commit` (in a `git worktree` if `repo` differs).
3. Run a fresh Mythos session: `claude -p "$problem_statement" --output-format=json --max-turns 30`.
4. Capture the produced diff (`git diff`).
5. Compare with `golden_diff`:
   - **Exact match** → 1.0
   - **Tests-pass + diff touches same files** → 0.5 (partial credit)
   - **Otherwise** → 0.0
6. Record per-case result + extract failure pattern.

Aggregate: `score = sum / N`.

### `--mode=both`

Run infra first; only run swe-mini if infra is 100%.

## Output schema (appended to `.claude/memory/eval-metrics.jsonl`)

```json
{"ts":"2026-05-10T18:00:00Z","mode":"infra","score":1.0,"passed":107,"failed":0,"version":"4.0"}
{"ts":"2026-05-10T18:05:00Z","mode":"swe-mini","score":0.6,"n":5,"resolved":["case-001","case-003","case-005"],"failed":["case-002","case-004"],"failure_patterns":["wrong file modified","missing edge case"],"version":"4.0"}
```

## Failure-pattern extraction (swe-mini)

For each failed case, classify the failure:

| Pattern | Detection |
|---|---|
| `missed-file` | The agent didn't edit a file that the golden diff did |
| `wrong-fix` | Edited the right file but the change differs semantically |
| `regressed-test` | Made test pass at the cost of another test |
| `incomplete` | Stopped before finishing (max-turns hit) |
| `over-engineered` | Made unrelated changes beyond the golden scope |

Each pattern → a candidate lesson in `tasks/lessons.md` (review before appending).

## Self-improvement hand-off

After a benchmark run with `failed > 0`:

1. Display top failure patterns.
2. Ask: "Run the self-improvement loop? (`skills/self-improve.md`)"
3. If yes → for each pattern, decide: hook (deterministic) or lesson (judgment).
4. Apply the change.
5. Re-run benchmark; record the delta.

## Display format

```
═══════════════════════════════════════════
  📊 BENCHMARK — Mythos v<X>
═══════════════════════════════════════════
🧪 Mode: <infra|swe-mini|both>
📈 Score: <0-100>%

✅ Passed: <N>
❌ Failed: <M>
   - <case-id>: <failure pattern>

📂 Eval log: .claude/memory/eval-metrics.jsonl
🔄 Δ from last run: <+N | same | -N>

🚦 Next: <ship | self-improve loop | escalate>
═══════════════════════════════════════════
```

## Constraints

- Never run `swe-mini` without `--n` capped at ≤10 (token budget).
- Never modify the cases directory during a run.
- Always append (never overwrite) `eval-metrics.jsonl`.
- If benchmark fails to start, log to `.claude/memory/eval-metrics.jsonl` with `"error":"..."` and exit clean.

## References
- Self-improvement skill: `skills/self-improve.md`
- Calibration: `.claude/commands/calibrate.md`
- Self-test: `hooks/test-mythos.sh`
- Cases (populate as needed): `benchmark/cases/`
