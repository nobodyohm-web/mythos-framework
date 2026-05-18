# /swarm — DAG-Aware Multi-Agent Orchestration (v5.0)

You are entering **SWARM MODE** — deploy a coordinated team of specialist agents with **dependency-aware scheduling**.

## Task
Decompose and execute: `$ARGUMENTS`

## Protocol

### STEP 1 — Load or Create Task DAG

1. Check if `specs/*/tasks.md` exists for this task
   - If yes → load the task DAG with `[P]` markers and `depends_on` declarations
   - If no → decompose the task into a DAG:
2. Analyze the task for natural boundaries (files, modules, concerns)
3. Identify dependencies between subtasks (what must finish before what)
4. Write the task DAG in standard format:
   ```markdown
   ## Phase 1: [Phase Name]
   - [ ] Task 1.1: [Description] [P]  ← parallelizable
   - [ ] Task 1.2: [Description] [P]  ← parallelizable  
   - [ ] Task 1.3: [Description]
     - depends_on: [1.1, 1.2]        ← waits for both
   
   ## Checkpoint: [Validation Gate]
     - depends_on: [1.3]
   
   ## Phase 2: [Phase Name]
   - [ ] Task 2.1: [Description] [P]
     - depends_on: [checkpoint-1]
   ```
5. `[P]` = safe for parallel subagent execution
6. Tasks without `[P]` are sequential within their phase

### STEP 2 — Agent Assignment
Assign each subtask to the best-fit agent role:

| Role | Specialty | Use For |
|------|-----------|---------|
| 🏗️ **Architect** | System design, API design, data modeling | New features, refactors |
| 💻 **Implementer** | Code writing, following patterns | Standard implementation |
| 🧪 **Tester** | Test writing, coverage analysis | Quality assurance |
| 🔍 **Researcher** | Code reading, pattern analysis | Understanding existing code |
| 🔒 **Auditor** | Security review, vulnerability analysis | Security checks |
| 📝 **Documenter** | README, API docs, code comments | Documentation |

### STEP 3 — DAG-Ordered Execution
For each wave (group of `[P]` tasks whose dependencies are ALL satisfied):

1. **Identify the frontier** — all `[P]` tasks whose `depends_on` are complete
2. **Spawn subagents** for each frontier task, **in parallel**
3. Each subagent receives:
   - Its specific task description
   - Relevant file context  
   - The `constitution.md` principles
   - The specific role instructions
   - **Babel Protocol:** ALL claims in the prompt must be tagged with Epistemic Tiers ([E], [D], [C], [S]). Do not pass assumptions as facts.
4. Subagents work independently — no cross-talk during execution
5. Lead agent (you) coordinates and monitors progress
6. **Mark completed tasks** in the DAG as `[x]`

### STEP 4 — Checkpoint Validation
After each wave completes:

1. **Review** all subagent outputs for consistency
2. **Check Epistemic Returns:** Subagents must return their confidence. Reject or manually verify any `[C]` (Conjectured) or `[S]` (Speculative) returns.
3. **Resolve conflicts** if multiple agents modified overlapping areas
3. **Run checkpoint verification**: typecheck + tests + lint
4. If a **Checkpoint** exists in the DAG → run its validation criteria
5. **Update the DAG** — mark wave tasks as `[x]`, advance to next frontier
6. **Proceed to next wave** or report completion

### STEP 5 — Synthesis
1. Merge all results into a coherent whole
2. Run final verification (full test suite)
3. Write summary of what each agent accomplished
4. Log to session journal with confidence score

## Swarm Rules
- **Max 3 concurrent subagents** — avoid context window exhaustion
- **Independent work only** — never have two agents editing the same file
- **Lead decides conflicts** — if agents disagree, the lead agent chooses
- **Fail fast** — if a subagent is stuck, terminate and reassign
- **Always verify** — run full checks after integration

## When NOT to Swarm
- Simple, sequential tasks (use `/mythosrun` instead)
- Tasks with heavy interdependencies (serialize them)
- When the codebase is unfamiliar (research first with a single agent)
