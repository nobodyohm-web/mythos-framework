# Mythos Research Cache — Frontier Patterns (2026)

> Distilled findings from Anthropic docs, GitHub power-user repos, and 2026 community best practices.
> Updated: 2026-05-10 by `/evolve`

---

## CORE PRINCIPLE: Context is the bottleneck

LLM performance degrades as context fills. Every token costs latency, money, and adherence quality.
**Implication:** ruthless concision in CLAUDE.md, lazy-loaded skills, subagent fan-out for exploration.

---

## CLAUDE.md — the constitution

- Hard cap: **~200 lines**. Bloat causes Claude to ignore rules buried in noise.
- Test for every line: *"Would removing this cause Claude to make mistakes?"* If no → cut.
- ✅ INCLUDE: Bash commands Claude can't guess, code style that differs from defaults, repo etiquette, env quirks, non-obvious gotchas.
- ❌ EXCLUDE: things derivable from code, language conventions, file-by-file descriptions, self-evident practices, long tutorials.
- Use `@path/to/file.md` imports for nested context.
- Layer locations: `~/.claude/CLAUDE.md` (global), `./CLAUDE.md` (team), `./CLAUDE.local.md` (personal).
- Tune adherence with `IMPORTANT` / `YOU MUST` markers sparingly.

---

## Skills — lazy-loaded knowledge

**Schema** (Agent Skills v1 standard):
- Path: `.claude/skills/<name>/SKILL.md` (project) or `~/.claude/skills/<name>/SKILL.md` (global)
- Frontmatter required:
  ```yaml
  ---
  name: skill-name              # lowercase, hyphens, ≤64 chars
  description: <when to use>    # Claude reads this to decide when to load
  allowed-tools: Read Grep Bash # space-separated; pre-approved while skill active
  disable-model-invocation: false  # true = manual /invoke only
  argument-hint: "[issue-number]"
  context: fork                 # optional: run in subagent
  agent: Explore                # which subagent type for fork
  paths: src/**/*.ts            # auto-load only when matching files
  ---
  ```
- Body: standing instructions; loaded once per invocation, persists across turns.
- **Dynamic context injection**: `` !`shell command` `` runs BEFORE Claude sees content; output replaces placeholder. Multi-line: ```` ```! ``` ```` blocks.
- **String substitution**: `$ARGUMENTS`, `$0`/`$1`/`$N`, `${CLAUDE_SKILL_DIR}`, `${CLAUDE_SESSION_ID}`, `${CLAUDE_EFFORT}`.
- Keep SKILL.md ≤500 lines; offload reference material to sibling files referenced from SKILL.md.

---

## Subagents — context isolation

- Path: `.claude/agents/<name>.md`
- Frontmatter:
  ```yaml
  ---
  name: security-reviewer
  description: When to delegate to this agent
  tools: Read Grep Glob Bash    # restrict tool surface
  model: opus                   # or sonnet, haiku, inherit
  ---
  ```
- Body = system prompt for the subagent.
- Subagents run in their **own context window** → use them aggressively for codebase exploration to keep main context clean.
- Pattern: Writer/Reviewer (one writes, fresh subagent reviews — no bias).
- Pattern: Fan-out (loop `claude -p` over file list with `--allowedTools`).

---

## Hooks — deterministic enforcement

- Path: `.claude/settings.json` → `hooks.<event>[].hooks[]`
- Events: `SessionStart`, `SessionEnd`, `Stop`, `PreToolUse`, `PostToolUse`, `PermissionRequest`, `UserPromptSubmit`.
- `matcher`: tool name (`Bash`, `Write|Edit`, `Write|Edit|MultiEdit`).
- `command`: shell snippet; access `${CLAUDE_PROJECT_DIR}`.
- `timeout`: ms; default 60000.
- Use hooks (NOT prompts) for anything that MUST happen every time:
  - Auto-format on Write/Edit
  - Block writes to `migrations/`, `.env`
  - Inject context at session start
  - Verify completion at Stop

---

## Permission Modes

- **default**: prompt for risky tools.
- **auto**: classifier model auto-approves safe commands (best for autonomy).
- **plan**: read-only exploration before execution.
- Allowlist via `permissions.allow`: prefer specific patterns (`Bash(npm run lint)`) over wildcards (`Bash(*)`) — wildcards defeat the safety classifier.

---

## Plan / Explore / Implement / Commit Workflow

The Anthropic-canonical loop:
1. **Explore** (plan mode) — read, ask questions, no edits.
2. **Plan** — Claude writes implementation plan; user edits with Ctrl+G.
3. **Implement** — switch out of plan mode, execute against plan.
4. **Commit** — descriptive message, open PR.

Skip planning for sub-5-minute changes (typos, single-line fixes).

---

## Verification = highest-leverage practice

> "The single highest-leverage thing you can do is give Claude a way to verify its work."

- Tests, screenshots (Claude in Chrome), linters, type-checkers.
- Always specify success criteria up front.
- Stop hooks that re-run typecheck/tests prevent premature "done".

---

## Failure Patterns to Avoid

| Anti-pattern | Fix |
|---|---|
| Kitchen-sink session (mixed tasks) | `/clear` between unrelated tasks |
| Correction spiral (>2 corrections on same issue) | `/clear` and rewrite prompt with what you learned |
| Over-specified CLAUDE.md | Prune; convert rules to hooks |
| Trust without verify | Provide tests/scripts as success gates |
| Infinite exploration | Scope investigations OR delegate to subagent |

---

## Multi-Agent Orchestration (2026 SOTA)

- **Sequential** — A → B → C, output threads through.
- **Concurrent** — fan-out independent work, lead synthesizes.
- **Group chat / maker-checker** — Writer + Reviewer in alternating sessions.
- **Dynamic handoff** — orchestrator routes based on classification.
- LangGraph / CrewAI dominate OSS; Claude Code does this natively via `Agent Teams` + `Task` tool.

---

## Key Token-Saving Levers

1. CLAUDE.md ≤200 lines.
2. Skills lazy-load; reference docs in skill subdirectories load only when needed.
3. Subagents for exploration (separate context window).
4. `/clear` between tasks; `/compact` for long sessions.
5. Use `gh`, `aws`, `gcloud` CLIs — orders of magnitude more efficient than reading docs.
6. Hooks eliminate repeated instructions.

---

## What Mythos Already Does Right

- Layered architecture (L1–L5).
- Self-improvement loop with `lessons.md`.
- Confidence scoring discipline.
- Dedicated `/heal`, `/evolve`, `/reflect` workflows.

## What Mythos Was Missing (fixed in this evolution)

- CLAUDE.md was 268 lines (over budget).
- No skills for general dev work (debug, architect, review, TDD, refactor).
- No subagents for general dev (debugger, optimizer, security).
- No PreToolUse guard against secret writes.
- No smart-routing or context-guardian hooks.
- No self-test harness.
