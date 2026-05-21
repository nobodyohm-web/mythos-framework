# Contributing to Mythos

Mythos competes on **rigor**, not catalog size. That shapes how we accept changes.

## The bar

Before sending a PR, your change must pass all of the following:

1. **Self-test stays green** — `bash hooks/test-mythos.sh` reports `✓ ALL CLEAR — N/N checks passed`. If you add behavior, add tests for it.
2. **Constitution compliance** — re-read `constitution.md`. Spec-first, verify-before-ship, no skipped phases.
3. **Epistemic tier on every claim** — if your PR says "this fixes X", tag the evidence: `[E]` established, `[D]` derived, `[C]` conjectured, `[S]` speculative. Don't inflate confidence.
4. **No catalog-padding** — adding skills/agents purely to bump a count number is rejected. Each new skill must solve a real problem we can name.
5. **Research-backed primitives prefer paper citations** — if your skill or CLI implements an algorithm from a paper, link the arXiv ID in the file header.
6. **stdout discipline** for any new CLI — query verbs emit machine-readable output only; human messages go to stderr. See `tasks/lessons.md` § 2026-05-20.

## How to contribute

### Bug reports

Use the bug template. Include:
- What you ran (exact command).
- What you expected.
- What happened (paste stderr + stdout).
- Your OS + bash version (`bash --version`).
- Output of `bash hooks/test-mythos.sh | tail -5`.

### Feature requests

Use the feature template. Lead with the *problem*, not the solution. If you can't name one user who hits this problem today, the feature is speculative — file it as a discussion instead.

### New skills

A skill is accepted when:
- It has YAML frontmatter (`name:`, `description:`).
- It's loaded on-demand (referenced from CLAUDE.md or a slash command).
- It cites the source (paper, blog post, internal incident) that motivated it.
- It's added to `registry/skills.json` with HEAD-probe-able URLs.

### New subagents

A subagent is accepted when:
- It lives in `.claude/agents/<name>.md` with `name:`, `description:`, and `tools:` frontmatter.
- Its model choice is justified (Opus for reasoning, Sonnet for I/O-bound).
- It's added to `registry/agents.json`.
- The `/team` and `/swarm` commands know how to invoke it.

### New hooks

Hooks are highest-risk. They run on every tool call. To be accepted:
- The hook must be **idempotent** (running it twice has the same effect as once).
- The hook must **exit 0 on success and stay quiet** unless it has something to say.
- The hook must have a test in `hooks/test-mythos.sh` that crafts an input known to trigger it.
- Performance: the hook must add < 100ms p99 to a typical tool call.

## Style

- **Shell:** `set -euo pipefail`, BSD-portable (no GNU-only flags), `bash 3.2`-compatible.
- **Python:** type hints on public functions, no external deps without auto-bootstrap (see `bin/mythos-research` for the pattern).
- **Markdown:** prefer tables over bullet-lists when there are 4+ items with 2+ attributes.
- **Commits:** Conventional Commits format (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`). Atomic — one concern per commit.

## Trust model

We do not auto-merge. We do not accept PRs that introduce dependencies without a justification. We do not accept PRs that disable hooks (`--no-verify`, etc.).

The Mythos guardrails exist *for the maintainers too*. If your PR would not pass the very hooks Mythos ships, fix the PR — not the hooks.

## Releasing

Release tags are signed and follow SemVer:
- **Major** (X.0.0): breaking change to file layout, CLI flags, or hook contract.
- **Minor** (X.Y.0): new skill, agent, command, CLI, or hook.
- **Patch** (X.Y.Z): bug fix, doc fix, performance fix without behavior change.

Each release bumps the version in `claude.json` and adds a `CHANGELOG.md` entry that follows the Keep-a-Changelog format.

## Questions

File an issue with the `question` label, or open a GitHub Discussion. Don't DM the maintainer — answers in public help the next person.
