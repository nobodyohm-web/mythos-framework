# Claude Mythos — Autonomous Agentic Base + Skill Marketplace

A drop-in upgrade for **Claude Code** that turns it into a rigorous, hallucination-resistant, multi-agent engineering system — and ships with a **verifiable skill & agent marketplace** so any project can pull exactly the capabilities it needs from curated GitHub sources.

> Core principle (load-bearing): **SEEK → FIND → VERIFY → KEEP WHAT SURVIVES**

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

### Key slash commands

`/marketplace`, `/skill-install`, `/agent-install`, `/mythosrun`, `/assimilate`, `/critique`, `/team`, `/swarm`, `/evolve`, `/deep-evolve`, `/benchmark`, `/calibrate`, `/reflect`, `/heal`, `/deepaudit`, `/research`, `/specify`, `/ship`, `/bootstrap`, `/diagnose`, `/learn`.

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
# → ✓ ALL CLEAR — 222/222 checks passed
```

Tests cover: file layout, hook wiring, JSON validity, frontmatter on every agent, guard behavior under crafted inputs, marketplace CLIs, registry shape, and dry-run install safety.

---

## License

MIT. Use it, fork it, publish skills & agents and add them to the registry.
