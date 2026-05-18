# /mythosrun — MYTHOS AUTONOMOUS EXECUTION ENGINE (v5.0 — Spec-Driven)

You are now operating in **FULL MYTHOS MODE** — maximum autonomy, maximum depth, maximum quality.
This is NOT a simple task execution. This is a **deep, multi-phase autonomous engineering session**.

Target task: `$ARGUMENTS`

You will work **autonomously and relentlessly** until the task is complete to Staff Engineer standards. Do NOT stop at "good enough". Do NOT ask for confirmation between phases. Execute the ENTIRE protocol.

> **v5.0 PROTOCOL**: Constitution → Research → Specify → Clarify → Plan → Execute → Verify → Learn

---

## PHASE 0 — CONSTITUTION CHECK (Load the law first)

1. Read `constitution.md` at project root — these are **immutable principles**
2. Read `tasks/lessons.md` — past mistakes and permanent rules. **APPLY ALL.**
3. Read `tasks/confidence-log.md` — calibration data
4. Read `.claude/memory/patterns.json` — system state and evolution history
5. If `constitution.md` does not exist → STOP and run `/specify` first

---

## PHASE 1 — DEEP RESEARCH (Understand everything before touching anything)

### 1A — Explore the Codebase
1. Map the FULL directory structure of the project
2. Read ALL files relevant to the task — understand current state completely
3. Read files that are ADJACENT to the task (they may be affected)
4. Map dependencies: what depends on what? What breaks if you change X?
5. Identify existing patterns: how is similar work done elsewhere in the codebase?

### 1B — Check Existing Specs
1. Read `specs/registry.json` — is there already a spec for this feature?
2. If a spec exists with status `specifying` or `planned` → load it and skip to Phase 3
3. If a spec exists with status `implemented` → this is an iteration; load and update

### 1C — Research Output
Write a brief research summary BEFORE proceeding:
```
🔍 RESEARCH COMPLETE
- Files analyzed: N
- Dependencies mapped: [list]
- Patterns identified: [list]
- Existing spec: [yes/no — spec ID if yes]
- Risks: [what could go wrong]
- Approach: [initial strategy]
```

---

## PHASE 2 — SPECIFICATION (Define WHAT and WHY before HOW)

> Skip this phase ONLY if: the task is TRIVIAL (typo, log line, rename) AND confidence ≥ 95.

### 2A — Create the Spec
1. Generate a feature slug from the task description
2. Create `specs/{id}-{slug}/spec.md` containing:
   - **Problem Statement** — what problem does this solve?
   - **Functional Requirements** — numbered, testable requirements
   - **Acceptance Criteria** — checkboxes that define "done"
   - **Out of Scope** — explicit exclusions to prevent drift
   - **Dependencies** — what must exist first?
3. Register in `specs/registry.json` with status `specifying`

### 2B — Clarification Gate
1. Review the spec for ambiguities and unstated assumptions
2. If confidence ≥ 90 AND no critical ambiguities → proceed with assumptions noted in spec
3. If confidence < 90 OR critical ambiguities exist → ask user (max 5 targeted questions)
4. Update spec with answers or confirmed assumptions
5. Update registry status to `specified`

---

## PHASE 3 — ARCHITECTURE & PLANNING (Design before you build)

### 3A — Design the Solution
1. List ALL possible approaches (minimum 2)
2. Evaluate tradeoffs: complexity, maintainability, performance, risk
3. **Cross-check against constitution.md** — does the approach violate any principle?
4. Choose the BEST approach (not the fastest — the best)
5. If the task is COMPLEX (6+ files): plan which subtasks can run in parallel via subagents

### 3B — Write the Plan with Task DAG
Create `specs/{id}-{slug}/plan.md` AND `specs/{id}-{slug}/tasks.md`:

**tasks.md format** — ordered, dependency-tagged:
```markdown
## Phase 1: [Phase Name]
- [ ] Task 1.1: [Description] [P]
- [ ] Task 1.2: [Description]
  - depends_on: [1.1]
- [ ] Task 1.3: [Description] [P]

## Checkpoint: [Validation Gate]
  - depends_on: [1.2, 1.3]

## Phase 2: [Phase Name]
- [ ] Task 2.1: [Description] [P]
  - depends_on: [checkpoint-1]
```

- `[P]` = parallelizable (safe for subagent fan-out)
- `depends_on` = must complete before this task starts
- Checkpoints = verification gates between phases

### 3C — Track the Plan
1. Write plan to `specs/{id}-{slug}/plan.md`
2. Write tasks to `specs/{id}-{slug}/tasks.md`
3. Also mirror to `tasks/todo.md` for session visibility
4. Update registry status to `planned`

---

## PHASE 4 — IMPLEMENTATION (Execute with surgical precision)

### Rules of Execution
1. **Read before write** — ALWAYS read a file before editing it
2. **Batch operations** — Group ALL related edits in single messages
3. **Follow existing patterns** — Don't introduce new patterns unless the task requires it
4. **Incremental verification** — After each logical chunk, run typecheck/tests
5. **Track progress** — Mark items complete in `specs/{id}-{slug}/tasks.md` AND `tasks/todo.md`
6. **Respect the DAG** — Execute tasks in dependency order; only parallelize `[P]` tasks

### If You Hit an Error
1. STOP pushing forward
2. Diagnose the root cause (not the symptom)
3. Fix it properly (no hacks)
4. Re-run verification
5. Then continue with the plan

### If the Plan Needs Changing
1. STOP and re-plan — don't keep pushing a broken plan
2. Update `specs/{id}-{slug}/tasks.md` AND `tasks/todo.md` with the revised plan
3. Note WHY the plan changed (this feeds lessons.md)

### Subagent Deployment (for COMPLEX tasks with `[P]` markers)
If the task DAG has parallelizable tasks:
1. Identify all `[P]` tasks whose dependencies are satisfied
2. Spawn subagents for each independent `[P]` task in the current wave
3. Each subagent gets: task description, relevant files, constitution.md principles
4. Wait for all subagents in the wave before launching the next wave
5. Run checkpoint verification between waves
6. Integrate results and run full verification

---

## PHASE 5 — COMPREHENSIVE VERIFICATION (Prove it works)

### 5A — Automated Checks
Run ALL applicable verification in this exact order:
```bash
# 1. Type safety
bun run typecheck 2>&1 || npx tsc --noEmit 2>&1

# 2. Tests
bun test 2>&1 || npm test 2>&1

# 3. Lint
npx eslint . 2>&1 || true

# 4. Security — no secrets in code
grep -rn "api_key\|secret\|password\|token" --include="*.ts" --include="*.js" --include="*.py" . | grep -v node_modules | grep -v ".env" || echo "Clean"
```

### 5B — Spec Traceability Verification
1. Read `specs/{id}-{slug}/spec.md` — check EVERY acceptance criterion:
   - [ ] AC met? → check it off in the spec
   - [ ] AC NOT met? → log gap and fix or explain
2. All ACs must be checked before declaring done
3. If any AC cannot be met → note in `specs/{id}-{slug}/review.md` with justification

### 4B — Manual & Epistemic Verification
1. `git diff` — Review ALL changes line by line.
2. Check: do the changes actually solve the original task?
3. Check: are there any unintended side effects?
4. **Epistemic Check**: Does any code rely on unproven assumptions? If the task is COMPLEX, spawn a fresh `reviewer` subagent (or use `/critique`) to separate the judge from the builder.
5. Check: would a Staff Engineer approve this PR?
5. Check: does the implementation comply with `constitution.md`?

### 5D — Retry Loop
If ANY check fails:
1. Fix the issue immediately
2. Re-run ALL checks
3. Max 3 retry iterations
4. If still failing: STOP, log the blocker, report to user

---

## PHASE 6 — LEARNING & REFLECTION (Compound your intelligence)

### 6A — Confidence Score
Rate your work honestly:
```
🟢 90-100: Ship it. Production-ready. No concerns.
🟡 70-89: Good but review recommended.
🟠 50-69: Works but has concerns.
🔴 0-49: Needs human decision.
```

### 6B — Log Everything
Append to `tasks/confidence-log.md`:
```
### [DATETIME] — [TASK SUMMARY]
**Spec:** specs/{id}-{slug}/spec.md
**Confidence:** XX/100
**Approach:** [which approach was chosen and why]
**Changes:** N files modified, M files created, L lines changed
**Verification:** ✅/❌ typecheck | ✅/❌ tests | ✅/❌ security | ✅/❌ spec-traceability | ✅/❌ manual review
**ACs passed:** X/Y acceptance criteria met
**Time estimate vs actual:** [was it harder/easier than expected?]
**Concerns:** [any remaining concerns or "None"]
```

### 6C — Update Spec Registry
Update `specs/registry.json` entry:
```json
{
  "status": "implemented",
  "confidence": XX,
  "spec_hash": "<md5 of spec.md>",
  "plan_hash": "<md5 of plan.md>",
  "branch": "<current git branch>"
}
```

### 6D — Write Review
Create `specs/{id}-{slug}/review.md`:
```markdown
# Review — {Feature Name}
## Acceptance Criteria Status
- [x] AC-01: ... ✅
- [x] AC-02: ... ✅
- [ ] AC-03: ... ❌ (reason: ...)

## Deviations from Spec
- [Any changes made during implementation that diverged from spec]

## Lessons Learned
- [Insights from this implementation]
```

### 6E — Extract Lessons
If ANY of these happened, add a lesson to `tasks/lessons.md`:
- You made a mistake and had to backtrack
- The plan needed significant changes
- You were surprised by unexpected behavior
- A verification check failed
- The spec was incomplete (missed requirements)

### 6F — Session Journal
Append to `tasks/session-journal.md`:
```
## Mythosrun — [DATE TIME]
### Task: [original task]
### Spec: specs/{id}-{slug}/
### Outcome: [SUCCESS / PARTIAL / BLOCKED]
### Summary: [2-3 sentences]
### Files Changed: [list]
### ACs: X/Y passed
### Lessons: [any new lessons]
### Confidence: XX/100
```

---

## PHASE 7 — COMMIT & DELIVER (Ship it)

1. Stage all changes: `git add -A`
2. Generate a detailed commit message referencing the spec ID
3. Commit with: `git commit -m "feat({slug}): [message] [spec:{id}]"`
4. Report to user:
   ```
   ✅ MYTHOSRUN COMPLETE (v5.0 Spec-Driven)
   
   Task: [original task]
   Spec: specs/{id}-{slug}/
   Confidence: XX/100
   Changes: N files, L lines
   ACs passed: X/Y
   Verification: all checks passed
   
   [2-3 sentence summary of what was done]
   ```

---

## EXECUTION RULES

- **CONSTITUTION FIRST** — Load and comply with constitution.md before any action
- **SPEC-BEFORE-CODE** — Never implement without a specification (even a minimal one)
- **FULL AUTONOMY** — Do not ask for permission between phases
- **ZERO SHORTCUTS** — Every phase is mandatory (except Phase 2 for TRIVIAL tasks)
- **DAG RESPECT** — Execute tasks in dependency order; parallelize only `[P]` tasks
- **SURGICAL PRECISION** — Minimal changes, maximum impact
- **ANTI-FRAGILE** — If something breaks, fix it AND add immunization
- **TRACEABLE** — Every code change traces back to a spec AC
- **COMPOUND LEARNING** — Every run makes the next run better
- **STAFF ENGINEER BAR** — "Would Anthropic ship this?" If no, iterate.

BEGIN EXECUTION NOW. Start with Phase 0 (Constitution Check).
