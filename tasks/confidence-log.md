# Confidence Log

> Append `### [DATETIME] — [TASK SUMMARY]` blocks. Used by `/calibrate`.

### 2026-05-20 22:50 — Token Optimization + Multi-Provider Routing (spec 004)
**Spec:** specs/004-token-optim-routing/spec.md
**Confidence:** 92/100
**Approach:** Three-axis token economy — (1) output-side `skills/terse-mode.md` + `/terse` for ~65% reduction, (2) provider-side integration with upstream `claude-code-router` via read-only `bin/mythos-route` + `/route` (never flips env), (3) visibility via `bin/mythos-tokens` parsing Claude Code transcript JSONL. Subagent models tuned **task-aware**: 8 reasoning agents stay on Opus (architect/planner/reviewer/security-auditor/implementer/tester/debugger/optimizer), only `researcher` (fetch+summarize) moves to Sonnet per user clarification.
**Changes:** 8 files modified, 7 files created, ~250 net lines added.
**Verification:** ✅ typecheck (n/a — shell) | ✅ self-test (238/238) | ✅ smoke (mythos-route/mythos-tokens run end-to-end) | ✅ spec-traceability (9/9 ACs) | ✅ manual diff review | ✅ CLAUDE.md stays at 150 lines (hard cap respected)
**ACs passed:** 9/9
**Time estimate vs actual:** Slightly longer than estimated due to one model-policy revert after user clarification (sonnet → opus for 4 agents, then sonnet kept only for researcher).
**Concerns:** None blocking. `mythos-route` is intentionally read-only — users may want `--apply` later but that crosses into shell mutation, which violates the safety contract; deliberate trade-off.

### 2026-05-20 23:30 — Fleet Mode + free-claude-code Honest Assessment (spec 005)
**Spec:** specs/005-fleet-mode/spec.md
**Confidence:** 91/100
**Approach:** User asked "is free-claude-code interesting? if yes use as multi-agent". Answered both questions: (a) honest E/D/C/S assessment skill — the "free claude code" GitHub topic is a misnomer, projects route to NIM/Ollama/etc., not real Claude; (b) the genuinely useful pattern is fleet of `claude -p --bare` workers, optionally routed via `ccr` to cheap providers, with the orchestrator (Opus) reviewing + integrating. Used Anthropic's headless mode (`--bare`, `--output-format json`, `--max-budget-usd`, `--allowedTools`, `--permission-mode dontAsk`). Safety contract is encoded in the CLI: read-only by default, mandatory budget cap, refuses `--provider` if `ccr` not running, no auto-merge.
**Changes:** 6 files created (spec, skill, CLI, slash command, README sections), 4 modified (registry, CLAUDE.md, hooks/test-mythos.sh, confidence-log).
**Verification:** ✅ self-test (251/251 — added 13 fleet checks) | ✅ smoke (dispatch/status/list/providers/exit-4 paths) | ✅ spec-traceability (10/10 ACs) | ✅ CLAUDE.md compressed L4 to inline form to fit additions (now at 143 lines) | ✅ bash 3.2 compat (caught empty-array iteration bug under `set -u`, fixed with length guard)
**ACs passed:** 10/10
**Lesson candidate:** Empty bash arrays under `set -u` + iteration on bash 3.2 — see existing macOS-grep lesson pattern. Captured below.
**Concerns:** Note from Anthropic docs: starting June 15, 2026, `claude -p` usage on subscription plans draws from a separate Agent SDK credit pool. Users running heavy fleets should be aware. Not a code concern, but worth a callout in the fleet command doc — added.

### 2026-05-20 — v6.0 Reasoning Monster (CoVe + Self-Consistency)
**Spec:** specs/007-reasoning-monster/spec.md
**Confidence:** 95/100 🟢
**Approach:** After honest review concluded v5.6 Ollama integration was theater, reverted it (commit 22dd899) and pivoted to research-backed reasoning primitives. Two CLIs (`bin/mythos-cove`, `bin/mythos-sc`) implement Chain-of-Verification (Dhuliawala et al. 2023, arXiv:2309.11495) and Self-Consistency (Wang et al. 2022, arXiv:2203.11171) as state machines on top of the existing `bin/mythos-blackboard` backbone.
**Changes:** 7 files created (spec, 2 skills, 2 CLIs, 2 slash commands, review), 6 modified (registry/skills.json, specs/registry.json, CLAUDE.md, hooks/test-mythos.sh, hooks/session-state.sh, tasks/confidence-log.md). Plus revert commit 22dd899 (13 files, -707).
**Verification:** ✅ self-test 274/274 (added 23 new Reasoning Primitives checks, all green; was 251 pre-v6.0) | ✅ smoke (cove 4-stage lifecycle, sc 3-1 majority + 2-2 tie, exit codes 64/65) | ✅ spec-traceability (15/15 ACs) | ✅ CLAUDE.md 147/150 lines | ✅ pre-existing session-state.sh JSON bug fixed as bonus
**ACs passed:** 15/15
**Time estimate vs actual:** ~1.5h actual (revert + research + spec + impl + 2 debug rounds + commit). Spec estimate was 2h — under budget.
**Concerns:** None blocking. End-to-end content generation (fresh-context subagent for CoVe stage 3, temperature sampling for SC traces) remains caller responsibility; the CLIs are state machines, not orchestrators. Documented in skills. Future v6.1: MCTS-LLM upgrade for bin/mythos-tot, /critique wired to auto-invoke CoVe on its draft.

### 2026-05-21 — Ship-readiness review of Mythos repo
**Spec:** specs/008-repo-ship-readiness/review.md
**Confidence:** 78/100 🟡
**Approach:** Empirical scan (find/wc/gh) + competitive star comparison + self-test verification. No code changes.
**Changes:** 1 file created (review.md), 1 log entry.
**Verification:** ✅ self-test 274/274 | ✅ gh API competitor stars | ✅ traceable to facts | n/a typecheck/tests
**Concerns:** Verdict on audience reception is a prediction, not a measurement. Rename suggestion is speculative (S-tier).
