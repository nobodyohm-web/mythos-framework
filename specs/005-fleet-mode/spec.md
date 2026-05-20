# Spec 005 — Fleet Mode (Multi-Worker Claude Code Orchestration)

## Problem
The user asked "is free-claude-code interesting? if yes, can we use it as multi-agent?". Honest assessment + actionable integration both required.

**Honest finding (E-tier):** "free claude code" is a misnomer. Every project in that GitHub topic is a routing proxy to non-Anthropic providers (NVIDIA NIM, OpenRouter, DeepSeek, Ollama, Z.ai). They do NOT give free access to real Claude. Some (`auth2api`) wrap your own Anthropic OAuth — TOS-grey, not "free".

**Useful pattern (D-tier):** Claude Code's headless mode (`claude -p --bare --output-format json`) lets the main session spawn N parallel workers. Combined with `claude-code-router`, those workers can run on cheap/free providers while the orchestrator stays on first-party Anthropic. This is genuinely useful for embarrassingly parallel subtasks (docstrings, translations, boilerplate, file-by-file refactors).

## Functional Requirements
1. **FR-1** — `skills/free-claude-code-assessment.md` provides an E/D/C/S-tiered, citation-backed verdict on every notable "free claude code" project. Includes safety warnings (OAuth proxies, rate-limit reality, TOS).
2. **FR-2** — `bin/mythos-fleet` orchestrates parallel `claude -p` workers. Subcommands: `dispatch`, `status`, `list`, `collect`, `clear`, `providers`.
3. **FR-3** — Each dispatched worker writes meta (`.json`), stdout (`.out`), stderr (`.err`) to `.claude/state/fleet/<id>.*`. Atomic, never silently overwrites.
4. **FR-4** — Safety contract: workers run with `--bare`, `--no-session-persistence`, mandatory `--max-budget-usd` (default $1.00), allowedTools defaults to read-only (`Read,Grep,Glob`). Caller must explicitly opt-in to write/exec.
5. **FR-5** — `--provider <name>` routes the worker via `ANTHROPIC_BASE_URL=http://127.0.0.1:3456` (claude-code-router). Checks router status first; refuses if router not running.
6. **FR-6** — `bin/mythos-fleet collect` returns the worker's structured JSON output (text + cost + session_id). No auto-merge into project files — the main session reviews and integrates.
7. **FR-7** — `.claude/commands/fleet.md` documents the orchestrator → worker → collector workflow.
8. **FR-8** — Registry adds `free-claude-code-assessment` skill. Self-test verifies fleet CLI exists + safe defaults + state-dir behavior.

## Acceptance Criteria
- [ ] AC-01: `bin/mythos-fleet --help` lists all six subcommands and the safety contract.
- [ ] AC-02: `bin/mythos-fleet dispatch` without args exits non-zero with a clear error.
- [ ] AC-03: `bin/mythos-fleet status` works on empty state without crashing (no workers yet).
- [ ] AC-04: `bin/mythos-fleet --provider deepseek dispatch "x"` refuses if `ccr` not running (returns 4).
- [ ] AC-05: Default `--allowedTools` is read-only (`Read,Grep,Glob`); writing/Bash require explicit `--allow-tools`.
- [ ] AC-06: Default `--max-budget-usd` is `1.00`; cannot be omitted.
- [ ] AC-07: `skills/free-claude-code-assessment.md` exists and contains per-project E/D/C/S tiers + OAuth warning.
- [ ] AC-08: Registry contains `free-claude-code-assessment`; `mythos-skill info` returns it.
- [ ] AC-09: `hooks/test-mythos.sh` adds checks for the above; result is 245+/245+ ✓ ALL CLEAR.
- [ ] AC-10: `CLAUDE.md` stays ≤ 150 lines.

## Out of Scope
- Implementing our own provider proxy. We integrate with `claude-code-router`, not replace it.
- Auto-orchestration / DAG-aware fleet (the planner subagent does that work; fleet is the runtime, not the planner).
- Aggregating cost across providers — we expose `total_cost_usd` per worker only.
- Free-tier auto-credential acquisition. User brings their own API keys.

## Dependencies
- Spec 004 (token optim + routing) — merged.
- `claude` binary in `PATH` (Claude Code CLI installed).
- `jq`, `python3` available.
