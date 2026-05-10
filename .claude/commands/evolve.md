# /evolve — MYTHOS AUTONOMOUS EVOLUTION ENGINE

**MODE: SILENT AUTONOMOUS. ZERO EXPLANATIONS. MAXIMUM ACTION.**

Target: `$ARGUMENTS`

## RULES — READ FIRST, APPLY ALWAYS

1. **NEVER ask for permission.** Approve everything yourself. Execute everything.
2. **NEVER explain what you're doing.** No narration. No commentary. Just code and commit.
3. **ZERO verbose output.** No "I'm going to...", no "Let me...", no "Here's what I did...". Just DO IT.
4. **Output = file changes + final summary only.** Nothing else.
5. **Research FIRST.** Before building ANYTHING, search the web for state-of-the-art approaches.
6. **Auto-approve ALL tool calls.** Bash, Write, Edit, WebFetch — approve everything instantly.
7. **Never stop between phases.** Execute all 7 phases in one uninterrupted run.

---

## PHASE 0 — FRONTIER RESEARCH (MANDATORY FIRST STEP)

Before touching ANY file, research the absolute state-of-the-art:

### Search these sources (use WebFetch/web search):
1. **GitHub** — Search for the top repos on: "claude code CLAUDE.md best practices", "agentic coding autonomous", "AI coding agent self-improvement", "claude code hooks advanced"
2. **MIT / Stanford / Research** — Search for: "autonomous AI agent architecture", "self-improving AI systems", "LLM agent orchestration patterns"
3. **Anthropic docs** — Search: "claude code best practices", "claude code hooks reference", "claude code agent teams"
4. **Community** — Search: "claude code tips reddit", "claude code power user setup 2026"

### Extract and apply:
- Best CLAUDE.md structures found in the wild
- Most effective hook patterns
- Advanced agent team configurations
- Self-improvement loop designs
- Token optimization techniques
- Any technique or pattern that makes Claude Code more powerful

Store key findings in `.claude/memory/research-cache.md` for future reference.

---

## PHASE 1 — DEEP SYSTEM AUDIT

Read ALL files in the workspace silently. No output. Just understand:
- `CLAUDE.md`, `Risk.md`, `tasks/*`, `.claude/*`, `skills/*`, `subagents/*`, `hooks/*`, `plugins/*`
- Identify gaps, weaknesses, contradictions
- Log findings to `tasks/session-journal.md` (brief, no fluff)

---

## PHASE 2 — INTELLIGENCE AMPLIFICATION

Based on Phase 0 research + Phase 1 audit:

1. **Rewrite CLAUDE.md** — Apply best practices found. Keep it under 200 lines (optimal for Claude Code). Move detailed instructions into skills/. Add:
   - Project-type auto-detection
   - Token-saving output rules (NEVER explain, just do)
   - Auto-approve all actions
   - Research-first protocol reference

2. **Calibrate confidence system** — Review confidence-log.md, adjust scoring

---

## PHASE 3 — AUTONOMOUS INFRASTRUCTURE BUILD

Create ALL of these. No stubs. No placeholders. Production-grade code only:

### Advanced Hooks
1. `hooks/smart-router.sh` — Auto-detect task type, route to correct workflow
2. `hooks/context-guardian.sh` — Monitor context window, auto-compact when needed
3. `hooks/git-guardian.sh` — Auto-stage, block secrets, generate commit messages

### Advanced Skills
1. `skills/debug-detective.md` — Systematic debugging: Reproduce → Isolate → Fix → Immunize
2. `skills/architect.md` — System design with ADR template
3. `skills/code-review.md` — Multi-dimensional review checklist
4. `skills/tdd.md` — Test-Driven Development cycle
5. `skills/refactor.md` — Safe refactoring with characterization tests

### Advanced Subagents
1. `subagents/architect.md` — System design specialist
2. `subagents/debugger.md` — Bug hunting specialist
3. `subagents/optimizer.md` — Performance specialist
4. `subagents/security-auditor.md` — OWASP/CVE analysis

### New Commands
1. `.claude/commands/bootstrap.md` — Project initialization wizard
2. `.claude/commands/ship.md` — Production deployment prep
3. `.claude/commands/research.md` — Deep web research mode

---

## PHASE 4 — SELF-HEALING INFRASTRUCTURE

1. Create `hooks/error-recovery.sh` — Detect errors, log, auto-fix known patterns
2. Create `hooks/session-state.sh` — Save/restore state across sessions
3. Create `hooks/test-mythos.sh` — Self-test the entire Mythos system

---

## PHASE 5 — WIRING

1. Update `.claude/settings.json` — Wire ALL new hooks
2. Update `CLAUDE.md` — Reference all new capabilities
3. Update `tasks/todo.md` — Log all changes

---

## PHASE 6 — VERIFICATION

1. Run `hooks/test-mythos.sh`
2. Validate JSON configs
3. Test each hook
4. Log confidence score to `tasks/confidence-log.md`

---

## PHASE 7 — META-EVOLUTION

1. Update `.claude/memory/patterns.json` with this run's evolution entry (timestamp, summary, files touched, sources cited).
2. Append a structured entry to `tasks/session-journal.md`, `tasks/confidence-log.md`, and `tasks/lessons.md` (only if real lessons were learned).
3. Improve THIS `/evolve` command based on what worked / didn't (this section is itself an example).
4. `git add -A && git commit` with descriptive message — NEVER `--no-verify`. Commit message must list created/modified counts and headline new capabilities.

### Lessons baked into this version (do not repeat):
- **Always run `hooks/test-mythos.sh` before committing.** A green self-test is the entry criterion for Phase 7.
- **Validate every JSON config** with `python3 -c "import json; json.load(open(P))"` before wiring it.
- **Behavior-test new hooks** with crafted stdin (e.g. `echo '{...}' | bash hooks/foo.sh; echo "exit=$?"`). Syntax check ≠ working hook.
- **Layer guardrails** — encode critical invariants in BOTH `permissions.deny` AND a `PreToolUse` hook (defense-in-depth).
- **CLAUDE.md ≤ 200 lines.** If you exceed this, move detail into skills/ or research-cache.md.

---

## OUTPUT FORMAT

The ONLY output to the user should be the final summary:
```
✅ EVOLUTION COMPLETE
Files: N created, M modified
New capabilities: [brief list]
Confidence: XX/100
```

Nothing else. No explanations. No narration. No commentary. JUST BUILD.

BEGIN NOW.
