# /swarm — Multi-Agent Team Orchestration

You are entering **SWARM MODE** — deploy a coordinated team of specialist agents.

## Task
Decompose and execute: `$ARGUMENTS`

## Protocol

### STEP 1 — Task Decomposition
Break the task into independent, parallelizable subtasks:

1. Analyze the task for natural boundaries (files, modules, concerns)
2. Identify dependencies between subtasks (what must finish before what)
3. Create a task dependency graph:
   ```
   Task A (no deps) ──┐
   Task B (no deps) ──┤── Task D (depends on A, B)
   Task C (no deps) ──┘
   ```

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

### STEP 3 — Parallel Execution
For each wave of independent tasks:

1. **Spawn subagents** for each independent task in the wave
2. Each subagent receives:
   - Its specific task description
   - Relevant file context
   - The coding standards from CLAUDE.md
   - The specific role instructions
3. Subagents work independently — no cross-talk during execution
4. Lead agent (you) coordinates and monitors progress

### STEP 4 — Integration
After each wave completes:

1. **Review** all subagent outputs for consistency
2. **Resolve conflicts** if multiple agents modified overlapping areas
3. **Run verification**: typecheck + tests + lint
4. **Proceed to next wave** or report completion

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
