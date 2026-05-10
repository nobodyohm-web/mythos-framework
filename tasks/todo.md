# Task Tracker — Agentic Autonomy

> Active task list. Claude Code updates this automatically.
> Format: `- [ ]` pending, `- [x]` completed.

---

## Current Sprint

### Setup & Configuration
- [x] Create CLAUDE.md (L1 Memory Layer)
- [x] Create Risk.md (L1 Risk Rules)
- [x] Create Risk.local.md (L1 Personal Overrides)
- [x] Create skills/ playbooks (L2 Knowledge Layer)
- [x] Create hooks/ scripts (L3 Guardrail Layer)
- [x] Create subagents/ specs (L4 Delegation Layer)
- [x] Create plugins/ structure (L5 Distribution Layer)
- [x] Create .claude/settings.json (Claude Code config)

### Mythos v3.1 — Frontier-Driven Evolution (2026-05-10)
- [x] Research SOTA Claude Code patterns (Anthropic docs + community)
- [x] Compress CLAUDE.md from 268 → ~120 lines (under 200-line budget)
- [x] Add dev skills: debug-detective, architect, code-review, tdd, refactor
- [x] Add dev subagents: architect, debugger, optimizer, security-auditor
- [x] Add advanced hooks: smart-router, context-guardian, git-guardian
- [x] Add self-healing hooks: error-recovery, session-state, test-mythos
- [x] Add new commands: /bootstrap, /ship, /research
- [x] Harden settings.json: scoped Bash allowlist, deny force-push to main
- [x] Wire UserPromptSubmit (smart-router) + PreToolUse (git-guardian)
- [x] Persist research findings to .claude/memory/research-cache.md
- [x] Self-test the system via hooks/test-mythos.sh

### Mythos v3.2 — Native Subagents + Observability + Lifecycle (2026-05-10)
- [x] Frontier-research: 4 searches across Anthropic docs + GitHub power-users + 2026 community + self-improving-agent literature
- [x] Migrate 7 subagents to canonical `.claude/agents/<name>.md` (auto-discovered by Task tool)
- [x] Backfill YAML frontmatter on 3 legacy `subagents/` trading specs
- [x] Add hook: `observability.sh` (JSONL event stream w/ 5MB rotation)
- [x] Add hook: `precompact-snapshot.sh` (markdown snapshot before /compact)
- [x] Add hook: `subagent-tracker.sh` (logs subagent invocations + duration)
- [x] Add hook: `notification-handler.sh` (logs + optional macOS desktop notify)
- [x] Wire 3 new lifecycle events in settings.json: PreCompact, SubagentStop, Notification
- [x] Upgrade smart-router to emit official `hookSpecificOutput` JSON + inject latest lesson
- [x] Add commands: `/diagnose`, `/learn`, `/calibrate`
- [x] Update CLAUDE.md → v3.2 (still 150 lines, under 200 budget)
- [x] Update test-mythos.sh to validate `.claude/agents/` + new hooks + new events (74 checks)
- [x] Update PreMarket.sh to prefer `.claude/agents/` when populated, fall back to `subagents/`
- [x] Behavior-test all 4 new hooks + smart-router JSON output + git-guardian regression
- [x] Update patterns.json → v3.2 entry with full evolution metadata + 10 research sources

### Next Steps
- [ ] First end-to-end session test against a real project
- [ ] Add project-specific skills as needed
- [ ] Configure MCP servers if applicable
- [ ] Set up CI integration via `claude -p` non-interactive mode
- [ ] First `/calibrate` cycle once 5+ confidence entries have verifiable outcomes

---

## Backlog
- [ ] Add more trading playbooks (gap-and-go, earnings play, etc.)
- [ ] Implement alert delivery system (plugins/alerts)
- [ ] Create daily report generator (plugins/reports)
- [ ] Add portfolio tracker integration
- [ ] Build custom MCP tools

---

## Completed
<!-- Completed items will be moved here -->
