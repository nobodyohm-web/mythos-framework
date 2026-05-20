# Spec 006 — Ollama Integration During /assimilate

> Status: specifying → planned → implemented
> Owner: Mythos
> Created: 2026-05-20

## Problem Statement

When Mythos is injected into a new host repo (`/assimilate`), it has no awareness of locally-available compute beyond the Anthropic API. If the host machine has **Ollama** installed, Mythos can dispatch parallel grunt-work to local models for free — boilerplate, refactor passes, docstring generation, test scaffolding — while the orchestrator stays on Anthropic for judgment. If Ollama is NOT installed, Mythos should know whether installing it would meaningfully help the host (and if so, advise the user — never auto-install).

Today: `/assimilate` does a 5-phase DNA scan but skips the local-compute axis entirely. `bin/mythos-fleet` supports providers via `ccr`, but Ollama since v0.14 has **native** Anthropic Messages API compatibility — `ccr` is unnecessary and adds a moving part.

## Why now

User explicitly asked to wire Ollama into `/assimilate`: detect → propose install if missing → connect + deploy fleet workers if interesting. This is a force-multiplier: local Ollama = free, private, parallel — keeps Anthropic spend for what only Anthropic can do.

## Functional Requirements

**FR-1.** `bin/mythos-ollama status` MUST detect: (a) `ollama` binary in PATH, (b) endpoint `http://localhost:11434` reachable, (c) version string, (d) installed model count.

**FR-2.** `bin/mythos-ollama models` MUST list locally installed models with size and a `--json` mode for CI/scripting.

**FR-3.** `bin/mythos-ollama install` MUST print install commands (macOS Homebrew + curl one-liner + Linux script) **without executing them**. Pure advisory.

**FR-4.** `bin/mythos-ollama enable` MUST print the three env-var exports the user copies into their shell. NEVER `eval`s, NEVER modifies rc files.

**FR-5.** `bin/mythos-ollama pull <model>` MUST print the `ollama pull <model>` instruction. NEVER executes.

**FR-6.** `bin/mythos-ollama recommend` MUST suggest models that meet Claude Code's ≥64k context requirement and have proven code performance (qwen3.6, qwen3.5, glm-5, kimi-k2.5).

**FR-7.** `/assimilate` MUST gain a **Phase 1.5 — Local Compute Probe** that runs `bin/mythos-ollama status` and either: (a) if installed → adds a fleet-deployment suggestion to the assimilation summary, OR (b) if missing → adds a `/ollama install` hint to the summary. Phase 1.5 NEVER auto-installs.

**FR-8.** `bin/mythos-fleet dispatch --ollama` MUST set `ANTHROPIC_BASE_URL=http://localhost:11434` + `ANTHROPIC_AUTH_TOKEN=ollama` for the worker — bypassing the `ccr`-required path. MUST refuse with exit 4 if the endpoint is not reachable.

**FR-9.** Worker safety contract (existing) MUST be preserved: `--bare`, `--no-session-persistence`, mandatory `--max-budget-usd`, default `--allowedTools Read,Grep,Glob`, no auto-merge.

**FR-10.** `skills/ollama-integration.md` MUST document the native v0.14+ Anthropic-API compatibility, when Ollama workers are appropriate (boilerplate, refactor passes, summarization) vs. inappropriate (architecture, security audits, long-horizon planning), and the 64k context floor.

**FR-11.** Self-test MUST include an Ollama-Integration section: binary exists + is executable, help string contains safety terms, exit-4 path is wired, registry/skills.json contains the new skill, slash command file exists.

**FR-12.** `/ollama` slash command MUST exist as a thin wrapper around `bin/mythos-ollama`.

## Acceptance Criteria

- [x] AC-01: `bin/mythos-ollama status` runs end-to-end and reports binary + endpoint + model count when Ollama is installed.
- [x] AC-02: `bin/mythos-ollama install` prints macOS + Linux instructions and exits 0 without executing anything.
- [x] AC-03: `bin/mythos-ollama enable` prints the three required env vars with the literal value `ollama` for the token.
- [x] AC-04: `bin/mythos-ollama models --json` produces parseable JSON when Ollama is up.
- [x] AC-05: `bin/mythos-ollama recommend` returns at least 3 model names with the 64k-context note.
- [x] AC-06: `/assimilate` Phase 1.5 section exists in `.claude/commands/assimilate.md` and references `bin/mythos-ollama status`.
- [x] AC-07: `bin/mythos-fleet dispatch --ollama "<task>" --model qwen3.6:latest --budget 0` (budget required) returns an id when endpoint is up.
- [x] AC-08: `bin/mythos-fleet dispatch --ollama ...` exits **4** when Ollama endpoint is not reachable (simulated by stopping Ollama or pointing OLLAMA_HOST elsewhere).
- [x] AC-09: `skills/ollama-integration.md` exists with all sections from FR-10.
- [x] AC-10: `hooks/test-mythos.sh` gains ≥8 Ollama-Integration checks and ALL pass.
- [x] AC-11: `registry/skills.json` lists `ollama-integration` with version `5.6.0` and tier `[E]`.
- [x] AC-12: `CLAUDE.md` references `bin/mythos-ollama` and `skills/ollama-integration.md`; total lines ≤150.
- [x] AC-13: `/ollama` slash command at `.claude/commands/ollama.md` exists.

## Out of Scope

- Auto-installing Ollama (violates Risk.md "ask before consequential operations").
- Auto-pulling models (large downloads — user-controlled).
- Implementing the Ollama daemon supervision / restart logic.
- Multi-host Ollama (load-balancing across a LAN of Ollama instances).
- Cloud-Ollama (Turbo, kimi-k2.5:cloud routing) — out of scope for v5.6, may revisit if the user asks.

## Dependencies

- `bin/mythos-fleet` (v5.5) — exists.
- `claude` CLI in PATH with `--bare` + `--model` support — exists (v2.1.145).
- `ollama` v0.14+ for native Anthropic-API compat (host has 0.24.0 — exceeds).
- `curl`, `jq`, `python3` — present.

## Risks

| Risk | Mitigation |
|---|---|
| User confuses advisory output with an auto-install | Every print-only command explicitly says "DOES NOT EXECUTE" + matches the existing `mythos-route` pattern user has already vetted |
| Small Ollama models fail Claude Code's 64k context requirement | `recommend` subcommand only surfaces ≥64k-capable models; skill documents this floor |
| Worker on Ollama produces lower-quality output and the user doesn't know | Skill documents the quality boundary; `--ollama` is opt-in per dispatch, never default |
| Endpoint check false-positive (reachable but model unloaded) | Probe `/api/version` not `/api/tags` for status, model presence checked separately in `models` subcommand |
| Fleet worker on local Ollama still hits `--max-budget-usd` check unnecessarily | Cap is still enforced for symmetry; on Ollama the dollar value is effectively decorative but keeps the safety contract uniform |

## Open Questions

None — confidence ≥90, proceeding with assumptions documented above.
