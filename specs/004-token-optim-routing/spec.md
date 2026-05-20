# Spec 004 — Token Optimization + Multi-Provider Routing

## Problem
1. Claude Code is verbose by default. Output tokens dominate cost on long sessions; the 2026 community has documented 65–90% reduction patterns that Mythos has not codified.
2. Claude Code is hard-locked to Anthropic's billing. The open-source ecosystem (`musistudio/claude-code-router`, 26.4k★) provides a drop-in proxy that routes to OpenRouter/DeepSeek/Ollama/Gemini/SiliconFlow — Mythos should make this trivially adoptable, but never silently change the user's billing path.

## Functional Requirements
1. **FR-1** — A `skills/terse-mode.md` skill encodes the verbosity-reduction rules ("caveman pattern": no preamble, no recap, action + result only). Loadable on demand.
2. **FR-2** — A `/terse` slash command activates terse mode for the current session.
3. **FR-3** — A `skills/multi-provider-routing.md` skill documents the integration with `musistudio/claude-code-router`: install, config, activate/deactivate, supported providers, when to use.
4. **FR-4** — A `bin/mythos-route` CLI: `status` / `enable` / `disable` / `providers` / `install` subcommands. Never sets `ANTHROPIC_BASE_URL` without explicit user invocation.
5. **FR-5** — A `bin/mythos-tokens` CLI: parses Claude Code transcript JSONL to report input/output token totals per session, with `--json` for CI.
6. **FR-6** — Task-aware model routing: reasoning-heavy agents (architect, planner, reviewer, security-auditor, implementer, tester, debugger, optimizer) stay on `opus` for maximum thinking power. Only `researcher` (WebSearch + WebFetch + summarize — low-reasoning I/O) moves to `sonnet`. Rule: downgrade ONLY when the task is fetch-and-summarize, never when it requires judgment or design.
7. **FR-7** — `CLAUDE.md` adds one explicit terseness rule under OPERATING MODE. File stays ≤150 lines.
8. **FR-8** — `registry/skills.json` lists `terse-mode` and `multi-provider-routing`.
9. **FR-9** — `hooks/test-mythos.sh` extended: verifies new CLIs (+x, runnable), skill files exist + valid, slash commands present. Target 232+/232+.
10. **FR-10** — `README.md` documents both features. Local commit only — no push.

## Acceptance Criteria
- [ ] AC-01: `bin/mythos-route status` exits 0 and prints a status block (no actual proxy activation).
- [ ] AC-02: `bin/mythos-tokens --help` exits 0 and lists subcommands.
- [ ] AC-03: `skills/terse-mode.md` and `skills/multi-provider-routing.md` exist and parse as markdown with H1.
- [ ] AC-04: `/terse` and `/route` slash commands exist as `.claude/commands/*.md`.
- [ ] AC-05: 5 subagent YAML files have `model: sonnet`; 4 stay on `model: opus`.
- [ ] AC-06: Registry contains both new skills, `jq` confirms shape.
- [ ] AC-07: Self-test runs end-to-end and reports `✓ ALL CLEAR` with new check count.
- [ ] AC-08: `CLAUDE.md` ≤ 150 lines and contains the new terseness directive.
- [ ] AC-09: `git status` clean after commit; commit message references spec 004.

## Out of Scope
- Implementing our own proxy server (we use `claude-code-router` upstream).
- Auto-installing `claude-code-router` globally (npm install is the user's choice).
- Token-cost dollar conversion (provider-dependent; we report token counts only).

## Dependencies
- Spec 003 (Marketplace v5.3) already merged — registry exists.
- `jq`, `curl`, `python3`, `awk` available (already required by Mythos).
