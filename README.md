# Claude Mythos — Autonomous Agentic Base + Skill Marketplace

A drop-in upgrade for **Claude Code** that turns it into a rigorous, hallucination-resistant, multi-agent engineering system — and ships with a **verifiable skill & agent marketplace** so any project can pull exactly the capabilities it needs from curated GitHub sources.

> Core principle (load-bearing): **SEEK → FIND → VERIFY → KEEP WHAT SURVIVES**

**v5.5 — Fleet mode + honest free-claude-code assessment.** Spawn parallel `claude -p --bare` workers from the main session (`bin/mythos-fleet` + `/fleet`) with read-only defaults, mandatory budget cap, and zero auto-merge. Workers optionally route through `claude-code-router` to cheap/free providers. Includes `skills/free-claude-code-assessment.md` — E/D/C/S-tiered, citation-backed verdict on every notable "free claude code" project (the short version: they're not free Claude, they're routers).

**v5.4 — Token optimization + multi-provider routing.** Output verbosity reduction (~65% via `skills/terse-mode.md` + `/terse`), task-aware model routing (8 reasoning agents on Opus, `researcher` on Sonnet for fetch+summarize), per-session token accounting (`bin/mythos-tokens`), and read-only guidance for running Claude Code against OpenRouter/DeepSeek/Ollama/Gemini (`bin/mythos-route` + `/route`).

---

## Why this exists

Out of the box, an LLM agent drifts. It guesses. It over-confirms. It forgets what it just decided. Mythos fixes that with five primitives:

1. **Separate the judge from the builder.** The agent that writes the code is never the agent that reviews it (`/critique`, `reviewer` subagent).
2. **Tier every claim.** Established / Derived / Conjectured / Speculative — confidence is structured, not aspirational.
3. **Communicate through files.** Cross-agent state lives on disk (`bin/mythos-blackboard`), not in fragile shared context.
4. **Calibrate relentlessly.** `/calibrate` + `/benchmark` close the loop; predictions are scored against outcomes.
5. **Prefer reversible actions.** Hardened hooks (`git-guardian`, `hallucination-guard`, `prompt-injection-guard`) block irreversible mistakes before they happen.

---

## What's new in this release — the Marketplace

`registry/skills.json` + `registry/agents.json` is a **curated, version-pinned catalog** of skills and subagents you can pull on demand. Every install is:

1. **HEAD-probed** — the GitHub raw URL must respond 200 before download.
2. **Frontmatter-validated** — agents must declare `name:` + `description:`; skills must have a markdown heading or YAML frontmatter.
3. **Optionally SHA-256 pinned** — if a hash is set, the bytes must match exactly.
4. **Atomically written** — temp file → rename, no partial installs.

### Quick start with the marketplace

```bash
# Detect what kind of project you're in
bin/mythos-detect

# Browse the catalog
bin/mythos-skill  list
bin/mythos-agent  list

# Get recommendations for THIS repo's stack
bin/mythos-skill  recommend
bin/mythos-agent  recommend

# Install a skill
bin/mythos-skill  install epistemic-rigor

# Install every "meta" skill in one shot
bin/mythos-skill  install-all --tag meta

# Install every agent tagged "core" for this stack
bin/mythos-agent  install-all --tag core

# Re-verify the entire catalog (HEAD + sha256)
bin/mythos-skill  verify-all
bin/mythos-agent  verify-all

# Register a third-party skill (HEAD-probed before persisting)
bin/mythos-skill  add \
  --id my-skill --name "My Skill" --summary "what it does" \
  --repo myorg/myrepo --ref main --path skills/my-skill.md \
  --tags python,testing

# Pin its sha256 for tamper-detection on future installs
bin/mythos-skill  refresh-sha my-skill
```

See [`registry/README.md`](registry/README.md) for the schema, trust model, and authoring guide.

---

## Installation

### One-shot remote install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/nobodyohm-web/mythos-framework/master/install.sh) /path/to/target
```

### Local install (already cloned)

```bash
./install.sh /path/to/target
```

The installer copies `.claude/`, `bin/`, `hooks/`, `skills/`, `registry/`, plus `CLAUDE.md`, `Risk.md`, and `claude.json` into the target. After install:

```bash
cd /path/to/target
claude
> /assimilate          # the agent scans the host and adapts
> /marketplace         # browse & install additional skills/agents
```

---

## System architecture

| Layer                 | Purpose                                                             |
|-----------------------|---------------------------------------------------------------------|
| `CLAUDE.md`           | Root brain — operating mode + knowledge matrix                       |
| `Risk.md`             | Guardrails (epistemic + code + operational)                          |
| `.claude/settings.json` | Hook wiring, MCP servers, permissions                              |
| `.claude/commands/`   | Slash commands (`/marketplace`, `/mythosrun`, `/critique`, `/team`…) |
| `.claude/agents/`     | Subagent roster (`planner`, `implementer`, `reviewer`, …)            |
| `skills/`             | Loaded-on-demand knowledge files                                     |
| `registry/`           | **Marketplace** catalog + schema docs                                |
| `bin/`                | Native CLIs (research, reflect, blackboard, budget, skill, agent…)   |
| `hooks/`              | Deterministic shell hooks for every lifecycle event                  |

### Native CLIs

| CLI                       | Purpose                                                             |
|---------------------------|---------------------------------------------------------------------|
| `bin/mythos-detect`       | Detect project stack → emit tags for the recommender                |
| `bin/mythos-skill`        | Marketplace: list/search/info/install/verify/recommend/add (skills) |
| `bin/mythos-agent`        | Marketplace: same surface for subagents                             |
| `bin/mythos-market`       | Shared engine behind `mythos-skill` / `mythos-agent`                |
| `bin/mythos-research`     | Token-dense web research (`-q "topic" --fetch`)                     |
| `bin/mythos-reflect`      | Deterministic reflection bundle (diff + plan + static)              |
| `bin/mythos-blackboard`   | Durable cross-agent state (write/read/tail)                         |
| `bin/mythos-budget`       | Per-session tool-call budget tracking                               |
| `bin/mythos-gvu`          | Generator-Verifier-Updater triad orchestrator                       |
| `bin/mythos-tot`          | Tree-of-Thoughts state CLI                                          |
| `bin/mythos-calibrate`    | Confidence-vs-outcome calibration                                   |
| `bin/mythos-epistemic-check` | Tier-tag claims in artifacts                                     |
| `bin/mythos-observe`      | Tail the event stream                                               |
| `bin/mythos-route`        | Status/guidance for `claude-code-router` (multi-provider) — read-only |
| `bin/mythos-tokens`       | Per-session token accounting (`session` / `all` / `list`, `--json`)  |
| `bin/mythos-fleet`        | Multi-worker orchestrator via `claude -p --bare` (read-only defaults, budget cap) |

### Key slash commands

`/marketplace`, `/skill-install`, `/agent-install`, `/terse`, `/route`, `/fleet`, `/mythosrun`, `/assimilate`, `/critique`, `/team`, `/swarm`, `/evolve`, `/deep-evolve`, `/benchmark`, `/calibrate`, `/reflect`, `/heal`, `/deepaudit`, `/research`, `/specify`, `/ship`, `/bootstrap`, `/diagnose`, `/learn`.

---

## Fleet mode — parallel `claude -p` workers

A main Claude Code session is serial by design. **Fleet mode** spawns N parallel worker subprocesses for genuinely independent subtasks while the orchestrator (you, on Opus) stays in charge of judgment and integration.

```bash
# Three independent docstring jobs, all read-only by default
id1=$(bin/mythos-fleet dispatch "Add JSDoc to every export in src/auth.ts" --allow-tools Read,Edit --budget 0.30)
id2=$(bin/mythos-fleet dispatch "Add JSDoc to every export in src/db.ts"   --allow-tools Read,Edit --budget 0.30)
id3=$(bin/mythos-fleet dispatch "Add JSDoc to every export in src/api.ts"  --allow-tools Read,Edit --budget 0.30)

bin/mythos-fleet status                          # see them progress
bin/mythos-fleet collect --id "$id1" --wait      # read output (JSON: result + total_cost_usd)
bin/mythos-fleet clear --all                     # cleanup
```

### Optional: route workers through `claude-code-router`

If `ccr` is running, workers can be routed to OpenRouter/DeepSeek/Ollama/etc. for cost. The main orchestrator stays on first-party Anthropic for reasoning.

```bash
bin/mythos-fleet dispatch "Generate boilerplate getters/setters for src/models/*.go" \
  --provider openrouter --model deepseek/deepseek-chat --budget 0.10 --allow-tools Read,Edit
```

If `ccr` isn't running, dispatch refuses with exit 4 — **never silently runs on first-party billing when you asked for routing.**

### Safety contract

| Constraint | Enforced |
|---|---|
| `--bare` mode (no hooks/MCP/CLAUDE.md auto-load) | always |
| `--no-session-persistence` | always |
| Default `--allowedTools` is read-only (`Read,Grep,Glob`) | default |
| `--max-budget-usd $1.00` cap | mandatory (default; user can lower or raise) |
| No auto-merge of worker output | by design — orchestrator reviews + integrates |
| `--provider` requires `ccr` running | HEAD probe; exit 4 on failure |

### Is "free claude code" interesting?

Short answer: **no, but the idea works** — see `skills/free-claude-code-assessment.md` for the full E/D/C/S-tiered breakdown. The projects under that name are routing proxies to non-Anthropic providers (NVIDIA NIM, DeepSeek, Ollama, etc.). Some providers have real free tiers (NIM: 40 req/min, Ollama: local), but the model quality is materially below Claude on architecture, debugging, and security work. Use cheap workers for boilerplate; keep judgment on Anthropic.

---

## Token economy

Token cost has two axes: **how much you write** (output) and **what you pay per token** (provider). Mythos addresses both — without ever sacrificing reasoning power.

### Output side — `/terse` + `skills/terse-mode.md`

The "caveman pattern" cuts output tokens by 60–75% with no loss of correctness:

- No preamble ("I'll…", "Let me…").
- No recap of the user's request.
- No tool-call narration.
- Final state, not journey.
- End on substance, no closing remark.

Type `/terse` once and the rule applies for the rest of the session. CLAUDE.md's OPERATING MODE item 1 enforces the same rule by default.

### Provider side — `/route` + `skills/multi-provider-routing.md`

Mythos integrates with [`musistudio/claude-code-router`](https://github.com/musistudio/claude-code-router) (MIT, 26k★), the de-facto upstream proxy that lets you point Claude Code at OpenRouter, DeepSeek, Ollama, Gemini, SiliconFlow, Volcengine, Groq, and more.

`bin/mythos-route` is **strictly read-only**. It tells you what to paste, it never mutates your shell, your rc files, or your packages:

```bash
bin/mythos-route status      # detect ccr install, current ANTHROPIC_BASE_URL, config presence
bin/mythos-route providers   # list configured provider names
bin/mythos-route install     # print install commands (no execution)
bin/mythos-route enable      # print the activation line (user pastes themselves)
bin/mythos-route disable     # print the deactivation line
```

### Reasoning power preserved

Model routing is **task-aware**, not blanket downgrade:

- **Opus (8 agents)**: `architect`, `planner`, `reviewer`, `security-auditor`, `implementer`, `tester`, `debugger`, `optimizer` — anything requiring design judgment, code generation, root-cause analysis, or critical review.
- **Sonnet (1 agent)**: `researcher` only — its job is WebSearch + WebFetch + summarize, which is I/O-bound and benefits less from Opus-grade reasoning.

This rule is codified in `specs/004-token-optim-routing/spec.md`: downgrade ONLY when the task is fetch-and-summarize, never when judgment or design is involved.

### Visibility — `bin/mythos-tokens`

Parse Claude Code's own transcripts to know exactly what you spent:

```bash
bin/mythos-tokens session            # latest session (input/output/cache_create/cache_read/total)
bin/mythos-tokens all                # totals across every session in this project
bin/mythos-tokens list               # session IDs found
bin/mythos-tokens --json all         # machine-readable for CI
```

---

## Trust model (read this before adding third-party entries)

- The shipped registry is **small and seeded only with sources we control** (the `mythos-framework` repo).
- `mythos-skill add` HEAD-probes the URL before writing, but it does **not** vouch for the *content* — added entries are marked `verified:false`.
- Read every third-party file before installing. Pin `sha256` to detect post-review tampering.
- The git-guardian, hallucination-guard, and prompt-injection-guard hooks protect runtime, not supply chain. The supply chain is your responsibility.

---

## Self-test

A single command verifies the whole system end-to-end:

```bash
bash hooks/test-mythos.sh
# → ✓ ALL CLEAR — 251/251 checks passed
```

Tests cover: file layout, hook wiring, JSON validity, frontmatter on every agent, guard behavior under crafted inputs, marketplace CLIs, registry shape, dry-run install safety, token-optim CLIs (`mythos-route`, `mythos-tokens`), the subagent model policy (8 on Opus, 1 on Sonnet), and the fleet safety contract (help text, dispatch error paths, exit codes, env isolation, state-dir lifecycle).

---

## License

MIT. Use it, fork it, publish skills & agents and add them to the registry.
