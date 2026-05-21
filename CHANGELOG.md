# Changelog

All notable changes to Mythos are documented here. Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versioning: [SemVer](https://semver.org/).

## [6.1.0] — 2026-05-21 — Reasoning Revolution

### Added
- **Reflexion** — `bin/mythos-reflexion` + `skills/reflexion.md` + `/reflexion`. Cross-attempt episodic memory loop. After a failed attempt, write a verbal reflection; future attempts recall it and prepend to prompt. Implements Shinn et al. NeurIPS 2023 (arXiv:2303.11366). +22% HumanEval pass@1 reported in paper.
- **Adaptive Best-of-N** — `bin/mythos-bestofn` + `skills/best-of-n.md` + `/bestofn`. Compute-optimal routing: classify difficulty (1-5), sample N candidates accordingly, score with a verifier, pick highest. Implements Snell et al. 2024 (arXiv:2408.03314). 4× efficiency vs naive Best-of-N.
- **Self-Refine via `--iterations N` on `mythos-cove revise`** — Iterative critique-revise loop with convergence detection (stops when consecutive revisions are identical). Implements Madaan et al. NeurIPS 2023 (arXiv:2303.17651). Backward-compatible: no flag → single-shot behavior unchanged.
- **Env-var helpers in `hooks/_lib.sh`** — `mythos_session_id` and `mythos_effort` read `$CLAUDE_CODE_SESSION_ID` / `$CLAUDE_EFFORT` exposed by Claude Code 2.x. Safe defaults: empty / "default" if unset.
- **CLAUDE.md**: new section "Claude Code 2.x platform primitives" referencing `/goal`, `/ultrareview`, `/effort xhigh`. Marked `[C]` — composable, not reimplemented.

### Stats
- 309/309 self-tests pass (35 new for v6.1).
- 3 new arXiv-cited primitives, 2 new CLIs, 1 modified CLI, 2 new skills, 2 new slash commands.

### Out of scope (explicit, with reasons)
- MCTS upgrade to `mythos-tot` — researcher recommended spike-first; deferred to v6.2.
- Process Reward Models (PRM, arXiv:2305.20050) — requires training pipeline; zero-shot version under-performs by ~15pp per the literature.
- Multi-Agent Debate (arXiv:2305.14325) — gain over existing SC is not quantified in available sources; L effort; revisit if a Mythos use case shows correlated SC failures.
- Claude Code plugin manifest packaging — L effort, defer.
- New Claude Code hook types (mcp_tool / http / args:[] exec / continueOnBlock / terminalSequence) — unverified by direct check; defer until independently confirmed.

## [6.0.0] — 2026-05-21 — Reasoning Monster

### Added
- **Chain-of-Verification (CoVe)** — `bin/mythos-cove` + `/cove`. Draft → verification questions → fresh-context answers → revise. Implements arXiv:2309.11495.
- **Self-Consistency** — `bin/mythos-sc` + `/sc`. Sample N reasoning paths, majority-vote final answer. Implements arXiv:2203.11171. +17.9% reported on GSM8K-style tasks.
- **stdout discipline** for composable CLIs — query verbs emit machine-readable JSON only; human "✓" messages go to stderr (lesson #12, 2026-05-20).

### Fixed
- `bin/mythos-fleet` empty-glob iteration under `set -u` on bash 3.2 (lesson #11).

### Stats
- 274/274 self-tests pass.

## [5.5.0] — 2026-05-20 — Fleet Mode + free-claude-code Assessment

### Added
- **Fleet mode** — `bin/mythos-fleet` + `/fleet`. Spawn N parallel `claude -p --bare` workers with read-only defaults, mandatory budget cap, no auto-merge. Workers can route through `claude-code-router` to cheap/free providers.
- **Safety contract**: `--bare`, `--no-session-persistence`, default `--allowedTools=Read,Grep,Glob`, `--max-budget-usd $1.00` cap, no auto-merge.
- `skills/free-claude-code-assessment.md` — E/D/C/S verdict on "free Claude Code" projects (they're routing proxies, not free Claude).

## [5.4.0] — 2026-05-20 — Token Optimization + Multi-Provider Routing

### Added
- **Terse mode** — `skills/terse-mode.md` + `/terse`. ~65% output-token reduction with no correctness loss.
- **Task-aware model routing**: 8 reasoning agents on Opus, `researcher` on Sonnet (I/O-bound).
- `bin/mythos-tokens` — per-session token accounting from Claude Code transcripts.
- `bin/mythos-route` + `/route` — read-only status/guidance for `claude-code-router` (multi-provider).

## [5.3.0] — 2026-05-19 — Skills & Agents Marketplace

### Added
- `registry/skills.json` + `registry/agents.json` — curated, version-pinned catalog.
- `bin/mythos-skill` + `bin/mythos-agent` — list/search/info/install/verify/recommend/add.
- Every install: HEAD-probed, frontmatter-validated, optionally SHA-256 pinned, atomically written.
- `/marketplace`, `/skill-install`, `/agent-install` slash commands.

## [5.2.0] — 2026-05-18 — Hallucination Guard + Injection Guard + GVU + ToT + Budget

### Added
- `hooks/hallucination-guard.sh` — PreToolUse defense against nonexistent paths in Bash commands (arXiv:2601.12560).
- `hooks/prompt-injection-guard.sh` — PostToolUse scan on Read/WebFetch responses for injection patterns.
- `bin/mythos-gvu` — Generator-Verifier-Updater triad orchestrator (arXiv:2512.02731).
- `bin/mythos-tot` — Tree-of-Thoughts state CLI (init/expand/score/best/show).
- `bin/mythos-budget` — Per-session tool-call budget tracker.

## [5.1.0] — 2026-05-18 — Blackboard + AgentGuard + Calibration + Research v2

### Added
- `bin/mythos-blackboard` — durable cross-agent state. InfiAgent pattern.
- `hooks/agent-guard.sh` — loop detection via 20-entry ring buffer of Bash commands.
- `bin/mythos-calibrate` — confidence-vs-outcome calibration.
- `bin/mythos-research` v2 — uses `ddgs` (new package) with legacy fallback.

## [4.0.0] — 2026-05-18 — MCP + Multi-Agent Teams + Self-Evaluation Loop

### Added
- 9 subagent roster (planner, architect, researcher, implementer, tester, reviewer, debugger, optimizer, security-auditor).
- MCP server integration scaffolding.
- Self-evaluation loop via `/benchmark` + `/calibrate`.

## [3.x] — 2026-05-17 and earlier

- `hooks/git-guardian.sh` — blocks force-push to main, secret commits, `rm -rf /`.
- Frontier-driven rebuild: skills + subagents + lifecycle hooks.
- Native subagents + observability + lifecycle expansion.

[6.0.0]: https://github.com/nobodyohm-web/mythos-framework/releases/tag/v6.0.0
[5.5.0]: https://github.com/nobodyohm-web/mythos-framework/releases/tag/v5.5.0
[5.4.0]: https://github.com/nobodyohm-web/mythos-framework/releases/tag/v5.4.0
[5.3.0]: https://github.com/nobodyohm-web/mythos-framework/releases/tag/v5.3.0
[5.2.0]: https://github.com/nobodyohm-web/mythos-framework/releases/tag/v5.2.0
[5.1.0]: https://github.com/nobodyohm-web/mythos-framework/releases/tag/v5.1.0
[4.0.0]: https://github.com/nobodyohm-web/mythos-framework/releases/tag/v4.0.0
