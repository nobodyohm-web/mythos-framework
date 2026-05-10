# /evolve — MYTHOS v4 EVOLUTION ENGINE

**MODE: SILENT AUTONOMOUS. ZERO EXPLANATIONS. MAXIMUM ACTION.**

Target: `$ARGUMENTS`

## RULES — READ FIRST, APPLY ALWAYS

1. **NEVER ask for permission.** Approve everything yourself. Execute everything.
2. **NEVER explain what you're doing.** No narration. No commentary. Just code and commit.
3. **ZERO verbose output.** No "I'm going to…", no "Let me…". Just DO IT.
4. **Output = file changes + final summary only.**
5. **Research FIRST.** Before building ANYTHING, search the web.
6. **Auto-approve ALL tool calls.** Bash, Write, Edit, WebFetch — approve everything.
7. **Never stop between phases.** Execute all phases in one uninterrupted run.
8. **ALWAYS keep `Bash(*)` in permissions.allow.** Use `deny` list for security, NOT scoped allow.
9. **Read `tasks/lessons.md` FIRST.** Apply every lesson. Never repeat a known mistake.

---

## PHASE 0 — RESEARCH SOTA (MANDATORY)

Before touching ANY file, research:

### Search (web search):
1. "claude code MCP server setup 2026 best practices"
2. "claude code agent teams multi-agent orchestration"
3. "MCP server github filesystem browser tools"
4. "claude code hooks advanced patterns self-evaluation"
5. "agentic AI self-improvement benchmark evaluation loop"
6. "claude code parallel agents Task tool delegation"

### Extract: MCP setup patterns, multi-agent orchestration, self-evaluation loops, any new hook lifecycle events.
### Store: `.claude/memory/research-cache.md` (append, don't overwrite prior research)

---

## PHASE 1 — DEEP AUDIT

Read ALL workspace files silently. Identify:
- Current capabilities (hooks, skills, agents, commands)
- Gaps vs SOTA research
- `tasks/lessons.md` — apply every rule
- Log findings to `tasks/session-journal.md`

---

## PHASE 2 — MCP SERVER INTEGRATION

### 2A. Install MCP tools
```bash
# Check available MCP servers
npx -y @anthropic-ai/claude-code-mcp list 2>/dev/null || true

# Install key MCP servers via Claude Code's built-in mechanism
# Research exact commands from SOTA sources
```

### 2B. Create MCP configurations
Create/update `.claude/settings.json` to add `mcpServers` section with:

1. **Filesystem MCP** — advanced file operations (glob, watch, search)
2. **GitHub MCP** (if `gh` CLI is installed) — PRs, issues, reviews
3. **Fetch/Browser MCP** — web page content fetching
4. **Memory MCP** — persistent key-value knowledge store

For EACH MCP server:
- Research the exact npm package and config format
- Test that the server starts and responds
- Wire permissions: `mcp__*` is already in allow list

### 2C. Create MCP-aware skills
Create `skills/mcp-orchestrator.md`:
- When to use which MCP tool
- Common workflows (PR review, issue triage, web research)
- Error handling for MCP failures

---

## PHASE 3 — MULTI-AGENT TEAMS

### 3A. Create team orchestration command
Create `.claude/commands/team.md`:
- Accept a task description
- Decompose into subtasks
- Assign each subtask to a specialized agent via the Task tool
- Collect results and merge
- Verify the combined output

### 3B. Create specialized agent profiles
Create/upgrade agents in `.claude/agents/`:

1. **`planner.md`** — Decomposes complex tasks into steps, creates implementation plans
2. **`researcher.md`** — Deep web research, documentation reading, SOTA analysis
3. **`implementer.md`** — Pure code implementation, follows plan from planner
4. **`reviewer.md`** — Code review, catches bugs, suggests improvements
5. **`tester.md`** — Writes and runs tests, coverage analysis

Each agent MUST have:
- YAML frontmatter with `name`, `description`, `tools`
- A clear system prompt defining its role and constraints
- Output format specification
- Failure handling instructions

### 3C. Create parallel execution patterns
Create `skills/parallel-execution.md`:
- When to parallelize vs serialize
- How to split work across agents
- How to merge agent outputs without conflicts
- Conflict resolution when agents disagree

---

## PHASE 4 — AUTO-EVALUATION LOOP

### 4A. Create benchmark runner
Create `.claude/commands/benchmark.md`:
- Clones N SWE-bench instances (configurable, default 5)
- For each: checkout base commit, run `claude -p` with Mythos
- Captures git diff (the patch)
- Compares with gold patch (exact match = pass, semantic match = partial)
- Reports score: X/N resolved
- Extracts failure patterns → new lessons

### 4B. Create self-evaluation hook
Create `hooks/self-eval.sh`:
- Runs on SessionEnd (optional, configurable)
- Checks: did we learn anything? Did confidence improve? Any errors logged?
- Appends evaluation metrics to `.claude/memory/eval-metrics.jsonl`

### 4C. Create calibration command
Upgrade `.claude/commands/calibrate.md`:
- Reads confidence-log.md
- Compares predicted confidence vs actual outcomes
- Adjusts confidence scoring guidelines
- Logs calibration delta

### 4D. Create continuous improvement loop
Create `skills/self-improve.md`:
- Pattern: Run benchmark → Extract failures → Write lessons → Re-run benchmark → Measure delta
- Success criterion: score improvement OR new lesson learned
- Failure criterion: 3 consecutive runs with no improvement → escalate

---

## PHASE 5 — ENHANCED INFRASTRUCTURE

### 5A. Upgrade smart-router
Update `hooks/smart-router.sh` to handle new capabilities:
- Route MCP-related tasks to `mcp-orchestrator` skill
- Route complex tasks to `team` command
- Route evaluation requests to `benchmark` command
- Detect multi-file changes → suggest parallel agents

### 5B. Create execution monitor
Create `hooks/execution-monitor.sh`:
- Track command execution time
- Detect stuck agents (>5min on single task)
- Auto-suggest recovery actions
- Log performance metrics

### 5C. Upgrade test-mythos.sh
Add tests for:
- MCP server connectivity (if configured)
- Agent profile validity
- New commands existence
- Benchmark runner executable
- Evaluation metrics file writable

---

## PHASE 6 — WIRING & INTEGRATION

1. Update `.claude/settings.json`:
   - Add MCP servers
   - Wire new hooks
   - **KEEP `Bash(*)` in allow — NEVER replace with scoped commands**
   - Update env vars: `MYTHOS_VERSION=4.0`

2. Update `CLAUDE.md`:
   - Add MCP tools section
   - Add multi-agent delegation patterns
   - Add self-evaluation reference
   - Stay under 200-line budget (move detail to skills/)

3. Update `.claude/memory/patterns.json`:
   - Add v4 evolution entry
   - Record all new capabilities

---

## PHASE 7 — VERIFICATION & COMMIT

1. Run `hooks/test-mythos.sh` — ALL must pass
2. Validate ALL JSON configs
3. Test each new hook with crafted stdin
4. Test MCP connectivity (if servers configured)
5. Log confidence to `tasks/confidence-log.md`
6. `git add -A && git commit` — descriptive message

### Lessons baked in (do NOT repeat):
- **ALWAYS keep `Bash(*)` in permissions.allow.** Use deny for security.
- **Validate JSON before wiring.** `python3 -c "import json; json.load(open(P))"`
- **Behavior-test hooks** with crafted stdin.
- **Layer guardrails** — deny + hook (defense-in-depth).
- **CLAUDE.md ≤ 200 lines.** Move detail to skills/.
- **Capture pre-compact state** before context compression.
- **Never create hook files without also wiring them** in settings.json.

---

## OUTPUT FORMAT

```
✅ EVOLUTION COMPLETE — Mythos v4.0
Files: N created, M modified
New capabilities:
  • MCP: [list of connected servers]
  • Agents: [list of new/upgraded agents]
  • Commands: [new commands]
  • Self-eval: [benchmark capability status]
Self-test: XX/XX ✅
Confidence: XX/100
```

Nothing else. No explanations. JUST BUILD.

BEGIN NOW.
