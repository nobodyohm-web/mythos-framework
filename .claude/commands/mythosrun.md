# /mythosrun — Autonomous Execution Orchestrator

You are now operating in **MYTHOS MODE** — maximum autonomy, maximum depth, maximum quality.

## Protocol

Execute the following 5-phase autonomous loop for the task: `$ARGUMENTS`

### PHASE 1 — RESEARCH (Read-Only Exploration)
1. Read ALL files relevant to the task — understand current state completely
2. Map dependencies between affected modules
3. Identify patterns used in existing code
4. Check `tasks/lessons.md` for relevant past mistakes
5. **DO NOT edit anything in this phase**

Output a brief `🔍 RESEARCH SUMMARY` before proceeding.

### PHASE 2 — PLAN (Architecture & Specs)
1. Write a detailed implementation plan with numbered steps
2. For each step: identify files to create/modify, risks, and verification criteria
3. Estimate complexity: TRIVIAL (1 file) / MODERATE (2-5 files) / COMPLEX (6+ files)
4. If COMPLEX: identify which steps can be parallelized via subagents
5. Write the plan to `tasks/todo.md` under a new section

Output the plan and **wait 3 seconds** for the user to abort if needed, then proceed.

### PHASE 3 — EXECUTE (Implementation)
1. Follow the plan step by step — mark each item in `tasks/todo.md` as you complete it
2. Batch ALL related file edits in single messages (minimize round-trips)
3. For each file: read first, then edit — NEVER edit blind
4. After each logical chunk: run verification (typecheck, tests, lint)
5. If a step fails: STOP, diagnose the root cause, fix it, then continue
6. Use subagents for independent parallel work when complexity is COMPLEX

### PHASE 4 — VERIFY (Quality Gate)
Run ALL applicable verification:
1. `typecheck` / `lint` — zero errors
2. `test` — all tests pass
3. `git diff` — review all changes for correctness
4. Security check — no secrets, no vulnerabilities introduced
5. Architecture check — changes follow existing patterns

If ANY verification fails:
- Fix the issue immediately
- Re-run verification
- Repeat until ALL checks pass (max 3 iterations)
- If still failing after 3 attempts: STOP and report to user

### PHASE 5 — REFLECT (Learning & Confidence)
1. Rate your confidence in the changes: 0-100
   - 90-100: Ship it. Production-ready.
   - 70-89: Good but review recommended.
   - 50-69: Works but has concerns.
   - Below 50: Needs human review.
2. Log to `tasks/confidence-log.md`:
   ```
   ### [DATETIME] — [TASK SUMMARY]
   **Confidence:** XX/100
   **Changes:** N files modified, M files created
   **Verification:** ✅ typecheck | ✅ tests | ✅ security
   **Concerns:** [any remaining concerns]
   ```
3. If any mistakes were made during execution, add a lesson to `tasks/lessons.md`
4. Update `tasks/todo.md` with completion status

## Escalation Rules
- **Act autonomously** for: code edits, refactoring, bug fixes, test writing
- **Ask the user** for: architectural decisions with multiple valid approaches, deleting significant code, changing public APIs
- **Never** for: committing secrets, force-pushing to main, deleting user data

## Quality Bar
Ask yourself: "Would a Staff Engineer at Anthropic approve this PR?"
If no → iterate until yes.
