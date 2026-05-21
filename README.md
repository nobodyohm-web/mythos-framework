# Mythos

> **Most Claude Code skill catalogs compete on size. Mythos competes on rigor.**

[![CI](https://github.com/nobodyohm-web/mythos-framework/actions/workflows/ci.yml/badge.svg)](https://github.com/nobodyohm-web/mythos-framework/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Tests](https://img.shields.io/badge/tests-274%2F274-brightgreen.svg)](BENCHMARKS.md)
[![Claude Code](https://img.shields.io/badge/claude-code-orange.svg)](https://docs.anthropic.com/claude/docs/claude-code)
[![Papers](https://img.shields.io/badge/primitives-paper--backed-purple.svg)](PAPERS.md)
[![Conventional Commits](https://img.shields.io/badge/commits-conventional-yellow.svg)](https://www.conventionalcommits.org/)

Every reasoning primitive cites a paper. Every claim has a test. Hallucinations and prompt injections are caught at the shell layer, **before they reach your model.** Confidence is tagged on every output (E/D/C/S). Cross-agent state lives on disk, not in fragile context.

**274/274 self-tests pass.** 18 native CLIs. 9 subagents. 20 skills. 20 hooks. Zero auto-merge.

---

## Why Mythos exists

Out of the box, an LLM agent drifts. It guesses. It over-confirms. It forgets what it just decided. It hallucinates paths, files, and APIs that don't exist. It loops on broken commands. It silently absorbs prompt injection from web pages it fetches.

The dominant Claude Code ecosystem solves none of those problems — it competes on catalog count. Mythos solves them.

### How Mythos compares

| Dimension | VoltAgent / alirezarezvani / etc. | **Mythos** |
|-----------|-----------------------------------|------------|
| Catalog size | 100s–1000s of skills | **20** (each load-bearing, each cited) |
| Hallucination defense | none | **`hooks/hallucination-guard.sh`** scans every Bash command |
| Prompt-injection defense | none | **`hooks/prompt-injection-guard.sh`** on every Read/WebFetch |
| Loop detection | none | **`hooks/agent-guard.sh`** — 20-entry ring buffer, threshold tunable |
| Self-verification primitive | reviewer subagent | **GVU** triad (arXiv:2512.02731) + **CoVe** (arXiv:2309.11495) + **Self-Consistency** (arXiv:2203.11171) |
| Cross-agent state | string handoffs | **Blackboard** CLI, tier-tagged, durable JSONL |
| Confidence calibration | vibes | **E/D/C/S epistemic tier system** + `/calibrate` loop |
| Spec-driven workflow | none | `specs/{id}-{slug}/{spec,plan,tasks,review}.md` mandatory for non-trivial tasks |
| Reproducible test suite | none | **`hooks/test-mythos.sh` — 274/274** |
| Supply-chain trust | curl-and-hope | HEAD-probe + SHA-256 pin + atomic write |

Mythos will never have 1000 skills. That's the wrong axis.

---

## 60-second taste

```bash
# 1. Install into any project
bash <(curl -fsSL https://raw.githubusercontent.com/nobodyohm-web/mythos-framework/master/install.sh) ~/my-project
cd ~/my-project

# 2. Boot Claude Code with Mythos loaded
claude
> /assimilate              # agent scans the host repo + adapts

# 3. Watch the defenses fire
> cat /path/that/doesnt/exist
# [HALLUCINATION-GUARD] command references nonexistent paths: /path/that/doesnt/exist

> # And the reasoning primitives
> /cove "Will my migration handle 50M rows safely under concurrent writes?"
# Drafts the answer → generates 5 verification questions → answers each in a
# FRESH context (no anchoring) → revises. Final answer + state on disk.

> /sc "Should we use Redis or Postgres LISTEN/NOTIFY for this queue?" --n 5
# Samples 5 reasoning paths, majority-votes the answer. arXiv:2203.11171.
```

That's the demo. No mocks, no toy examples — it's the actual surface.

---

## Install

### One-shot remote install (recommended)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/nobodyohm-web/mythos-framework/master/install.sh) /path/to/target
```

### Local install (clone first)

```bash
git clone https://github.com/nobodyohm-web/mythos-framework
cd mythos-framework
./install.sh /path/to/target
```

### Bulk-install skills/agents during install

```bash
./install.sh /path/to/target --with-skills meta,security --with-agents core
```

After install:

```bash
cd /path/to/target
claude
> /assimilate          # agent scans the host repo + adapts
> /marketplace         # browse & install additional skills/agents
> /diagnose            # self-test + log tails
```

**Dependencies:** `bash` (3.2+), `jq`, `git`, `python3`. Mythos auto-bootstraps Python deps via a project `.venv` — no system pollution.

---

## The 5 Anthropic Principles, made concrete

These aren't slogans. Each maps to code you can read.

1. **Separate the judge from the builder.** `/critique`, `reviewer` subagent, and `bin/mythos-gvu` enforce fresh-context verification. The Variance Inequality (arXiv:2512.02731) says self-judging correlates noise — GVU breaks that correlation.
2. **Define success before writing code.** `/specify` and `/mythosrun` refuse to implement without `specs/{slug}/spec.md`. Even a 3-line spec beats zero.
3. **Communicate through files, not shared context.** `bin/mythos-blackboard` (durable, tier-tagged), `tasks/*.md`, and `.claude/state/{cove,sc,tot,gvu,fleet}/*` survive context resets and inter-agent handoffs.
4. **Calibrate your evaluator relentlessly.** Every action logs its `predicted_confidence`. The next session scores it against `actual_outcome`. `patterns.json` tracks calibration error. Two consecutive sub-70 confidences trigger `/evolve`.
5. **Prefer reversible actions over irreversible ones.** `hooks/git-guardian.sh` blocks `--force` to main, `--no-verify`, secret commits, `rm -rf /`. Fleet workers run `--bare` with mandatory `--max-budget-usd` cap and zero auto-merge.

→ Full mapping in [`ARCHITECTURE.md`](ARCHITECTURE.md).

---

## Paper-backed primitives

Every reasoning module in Mythos cites its source. **No "AI-native magic" claims.**

| Primitive | Paper | CLI / Skill |
|-----------|-------|-------------|
| Chain-of-Verification | arXiv:2309.11495 (Dhuliawala et al., 2023) | `bin/mythos-cove` + `/cove` |
| Self-Consistency | arXiv:2203.11171 (Wang et al., 2022) | `bin/mythos-sc` + `/sc` |
| Tree-of-Thoughts | arXiv:2305.10601 (Yao et al., 2023) | `bin/mythos-tot` |
| Generator-Verifier-Updater | arXiv:2512.02731 (Chojecki, 2025) | `bin/mythos-gvu` |
| Tool-hallucination defense | arXiv:2601.12560 (2026) | `hooks/hallucination-guard.sh` |
| Indirect prompt injection | arXiv:2302.12173 (Greshake et al.) | `hooks/prompt-injection-guard.sh` |
| Blackboard / cross-agent state | InfiAgent + Engelmore & Morgan, 1988 | `bin/mythos-blackboard` |

→ Full provenance + what we DON'T cite in [`PAPERS.md`](PAPERS.md).

---

## What you get

```
constitution.md       immutable principles (load-bearing, ≤ 80 lines)
Risk.md               guardrails (epistemic + code + operational)
CLAUDE.md             operating mode + knowledge matrix
README.md             you are here
ARCHITECTURE.md       layer-by-layer diagram + data flow
PAPERS.md             research provenance (every primitive cited)
BENCHMARKS.md         measurable claims + how to reproduce
SECURITY.md           threat model + reporting policy
CHANGELOG.md          SemVer history
CONTRIBUTING.md       the bar for PRs (it's high)
CODE_OF_CONDUCT.md    incl. evidence-fabrication clause

.claude/
├── settings.json     hook wiring, MCP servers, permissions
├── commands/         26 slash commands (/mythosrun, /critique, /team, /cove, /sc…)
├── agents/           9 subagents (planner, reviewer, security-auditor…)
└── state/            durable runtime state (blackboard, cove, sc, tot, gvu, fleet)

bin/                  18 native CLIs (2,754 LOC)
hooks/                20 deterministic shell hooks (2,263 LOC)
skills/               20 loaded-on-demand knowledge files (1,629 LOC)
registry/             marketplace catalog (HEAD-probed, SHA-256 pinned)
specs/                spec-driven dev artifacts
tasks/                lessons.md, confidence-log.md, session-journal.md
```

→ Full directory map in [`ARCHITECTURE.md`](ARCHITECTURE.md).

---

## The 18 native CLIs

| CLI | Purpose |
|-----|---------|
| `bin/mythos-cove` | Chain-of-Verification state machine (`draft / plan / answer / revise`) |
| `bin/mythos-sc` | Self-Consistency: sample N paths, majority-vote |
| `bin/mythos-tot` | Tree-of-Thoughts state (`init / expand / score / best / show`) |
| `bin/mythos-gvu` | Generator-Verifier-Updater triad orchestrator |
| `bin/mythos-blackboard` | Durable cross-agent state — JSONL, tier-tagged |
| `bin/mythos-research` | Token-dense web research (`-q "topic" --fetch`) |
| `bin/mythos-reflect` | Reflection bundle (diff + plan + static) for the Judge |
| `bin/mythos-budget` | Per-session tool-call budget tracker |
| `bin/mythos-calibrate` | Confidence-vs-outcome calibration loop |
| `bin/mythos-epistemic-check` | Tier-tag claims in an artifact |
| `bin/mythos-tokens` | Per-session token accounting from Claude Code transcripts |
| `bin/mythos-observe` | Tail the event stream |
| `bin/mythos-fleet` | Multi-worker orchestrator via `claude -p --bare` (safe defaults) |
| `bin/mythos-route` | Read-only status/guidance for `claude-code-router` |
| `bin/mythos-detect` | Detect project stack → tag list for recommender |
| `bin/mythos-skill` | Marketplace: list/search/info/install/verify/recommend/add |
| `bin/mythos-agent` | Marketplace: same surface for subagents |
| `bin/mythos-market` | Shared engine behind `mythos-skill` / `mythos-agent` |

---

## The 9 subagents

8 on Opus for reasoning. 1 on Sonnet (`researcher`) for fetch+summarize — I/O-bound, doesn't need Opus-grade reasoning.

`planner` · `architect` · `researcher` · `implementer` · `tester` · `reviewer` · `debugger` · `optimizer` · `security-auditor`

Routing rules codified in `specs/004-token-optim-routing/spec.md`.

---

## The 20 hooks

Defenses on every Claude Code lifecycle event. Each has a crafted-input test in `hooks/test-mythos.sh`.

| Event | Hook | What it does |
|-------|------|--------------|
| SessionStart | `restore-session-state`, `load-lessons` | Boot context |
| UserPromptSubmit | `smart-router` | Suggest a skill based on the prompt |
| PreToolUse (Bash) | `git-guardian` | Block irreversible ops |
| PreToolUse (Bash) | `hallucination-guard` | Warn on nonexistent paths |
| PostToolUse | `agent-guard` | Detect command-repeat loops |
| PostToolUse | `context-guardian` | Checkpoint state if context near limit |
| PostToolUse | `error-recovery` | Auto-suggest on common errors |
| PostToolUse (Read, WebFetch) | `prompt-injection-guard` | Scan untrusted content for injection patterns |
| Stop | `verify-completion` | Final typecheck + tests + diff review |
| SessionEnd | `auto-learn`, `self-eval` | Extract lessons + score the session |

---

## Fleet mode — parallel `claude -p` workers, safely

```bash
id1=$(bin/mythos-fleet dispatch "Add JSDoc to every export in src/auth.ts" --allow-tools Read,Edit --budget 0.30)
id2=$(bin/mythos-fleet dispatch "Add JSDoc to every export in src/db.ts"   --allow-tools Read,Edit --budget 0.30)
bin/mythos-fleet status                          # see progress
bin/mythos-fleet collect --id "$id1" --wait      # JSON: result + total_cost_usd
```

Safety contract (enforced; not a suggestion):

| Constraint | Enforced |
|---|---|
| `--bare` mode (no auto-loaded hooks/MCP/CLAUDE.md) | always |
| `--no-session-persistence` | always |
| Default `--allowedTools` = read-only | default |
| `--max-budget-usd` cap | mandatory |
| Auto-merge of worker output | **never** |
| `--provider <non-anthropic>` requires `ccr` running | HEAD probe, exit 4 on failure |

Workers can route through [`claude-code-router`](https://github.com/musistudio/claude-code-router) for cost. Main orchestrator stays on first-party Anthropic for judgment.

---

## Quick reference — slash commands

**Reasoning:** `/cove`, `/sc`, `/critique`, `/research`, `/specify`

**Multi-agent:** `/mythosrun`, `/team`, `/swarm`, `/fleet`

**Self-improvement:** `/evolve`, `/deep-evolve`, `/calibrate`, `/benchmark`, `/learn`, `/reflect`

**Ops:** `/assimilate`, `/marketplace`, `/skill-install`, `/agent-install`, `/diagnose`, `/heal`, `/deepaudit`, `/ship`, `/bootstrap`, `/route`, `/terse`

Each has a `.claude/commands/<name>.md` definition you can read.

---

## Self-test

A single command proves the framework is intact:

```bash
bash hooks/test-mythos.sh
# → ✓ ALL CLEAR — 274/274 checks passed
```

The CI runs this on every push on both Ubuntu and macOS. See [`BENCHMARKS.md`](BENCHMARKS.md) for what's measured (and what we deliberately don't claim).

---

## Trust model

**The framework's safety is your responsibility.** Read `SECURITY.md` before going to production.

- The shipped registry is seeded only from sources we control.
- `mythos-skill add` HEAD-probes URLs before write; it does NOT vouch for content.
- Pin `sha256` on third-party entries to detect post-review tampering.
- Hooks defend the *runtime loop*, not the *supply chain*. Read every third-party file before installing.

---

## FAQ

**Why only 20 skills when other catalogs have 1000+?**
Because each skill in Mythos has to earn its place. Skills are not features — they're *load-bearing knowledge*. A skill that doesn't have a clear failure mode it prevents, doesn't get in. See `CONTRIBUTING.md` § "No catalog-padding".

**Is this a replacement for Claude Code?**
No. Mythos is a *configuration* of Claude Code. You install it into a project, and Claude Code with Mythos active behaves differently — more rigorously, more verifiably, more anti-fragile — than vanilla Claude Code.

**Does Mythos work with other AI agents (Codex, Gemini CLI, Cursor)?**
Partially. The skills and registry catalog are portable (markdown + JSON). The CLIs (`bin/mythos-*`) are portable too. The hooks are Claude-Code-specific — they wire into Claude Code's lifecycle events.

**Can I use Mythos with `claude-code-router` for cheaper providers?**
Yes for fleet workers (boilerplate, refactors). No for the main orchestrator — judgment work degrades materially below Claude. Full breakdown in `skills/free-claude-code-assessment.md`.

**What if I disagree with a constitution principle?**
Open a PR to `constitution.md` with reasoning. The constitution is editable, not sacred — but every change is reviewed against the harm-prevention rationale.

**How is this different from claude-flow / VoltAgent / etc.?**
Those are catalogs and orchestrators. Mythos is a **discipline** — a configured Claude Code with hardened hooks, paper-backed reasoning primitives, and an epistemic tier system. The comparison table at the top of this README is the short answer; `ARCHITECTURE.md` is the long one.

---

## Contributing

The bar is high. Read [`CONTRIBUTING.md`](CONTRIBUTING.md) before opening a PR.

Short version: self-test stays green, claims tagged with epistemic tiers, no catalog-padding, primitives cite papers.

---

## License

[MIT](LICENSE). Use it. Fork it. Publish skills & agents and add them to the registry.

---

## Acknowledgments

Mythos stands on a body of public research:

- Anthropic, for Claude and Claude Code.
- Dhuliawala et al. (CoVe), Wang et al. (Self-Consistency), Yao et al. (Tree-of-Thoughts), Chojecki (GVU), Greshake et al. (indirect prompt injection) for the reasoning + defense primitives.
- The Spec-Driven Development pattern community.
- `musistudio/claude-code-router` for the multi-provider routing layer.

If your work is implemented in Mythos and not credited, open an issue — credit gets fixed fast.
