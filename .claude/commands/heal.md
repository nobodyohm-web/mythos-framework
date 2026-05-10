# /heal — Self-Healing Error Resolution

You are entering **HEAL MODE** — diagnose and fix errors autonomously without human intervention.

## Trigger
This command is invoked when: `$ARGUMENTS`
(If no arguments, scan for any existing errors in the project)

## Protocol

### PHASE 1 — TRIAGE (< 30 seconds)
1. Run diagnostic commands to identify ALL current errors:
   ```bash
   # TypeScript projects
   bun run typecheck 2>&1 || npx tsc --noEmit 2>&1
   bun test 2>&1
   
   # Python projects
   python -m pytest 2>&1
   python -m mypy . 2>&1
   
   # General
   git status --porcelain
   ```
2. Classify each error by severity:
   - 🔴 **CRITICAL**: Build broken, tests failing, security issue
   - 🟡 **WARNING**: Type errors, lint warnings, deprecated usage
   - 🟢 **INFO**: Style issues, missing docs, optimization opportunities

### PHASE 2 — DIAGNOSE (Root Cause Analysis)
For each error, starting with 🔴 CRITICAL:
1. Read the affected file(s)
2. Trace the error to its root cause (not just the symptom)
3. Check `tasks/lessons.md` — has this error type occurred before?
4. Identify if the fix could introduce regressions elsewhere

### PHASE 3 — FIX (Surgical Repair)
1. Apply the minimal fix that resolves the root cause
2. Follow existing code patterns — don't introduce new patterns
3. If the fix touches multiple files, batch all edits
4. NEVER apply a hacky workaround — find the elegant solution

### PHASE 4 — VERIFY (Prove It Works)
1. Re-run ALL diagnostics from Phase 1
2. Verify zero regressions: `git diff` and check all changes
3. If new errors appear → go back to Phase 2 (max 3 iterations)
4. If stuck after 3 iterations → report to user with diagnosis

### PHASE 5 — IMMUNIZE (Prevent Recurrence)
1. If this error type is new, add to `tasks/lessons.md`:
   ```
   ### [DATE] — [ERROR TYPE]
   **Mistake:** [what broke]
   **Root Cause:** [why it broke]
   **Rule:** [how to prevent it permanently]
   ```
2. If applicable, add a test to catch this error in the future
3. Consider if a hook should prevent this class of error

## Self-Healing Loop
If invoked without arguments, run a full health check:
```
1. Typecheck → fix → re-check
2. Tests → fix → re-test
3. Lint → fix → re-lint
4. Security scan → fix → re-scan
5. Report: "🩺 HEALTH CHECK: X issues found, X fixed, X remaining"
```

## Rules
- Fix the ROOT CAUSE, never the symptom
- Minimal changes — touch only what's broken
- Add tests after fixing bugs — prevent regression
- Log everything to confidence-log.md
