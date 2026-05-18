# Skill: Generator-Verifier-Updater (GVU) Triad

**Source:** Chojecki, "Self-Improving AI Agents through Self-Play", arXiv:2512.02731v1 (Dec 2025). `[E]`

The paper proves a **Variance Inequality**: a self-improvement loop has positive learning rate `κ > 0` only when the **combined noise of generation and verification** is bounded. STaR, SPIN, Reflexion, GANs, and AlphaZero are all specific realizations of this same GVU operator.

## Mapping to Mythos

| GVU role  | Mythos implementation                                          |
|-----------|----------------------------------------------------------------|
| Generator | Builder subagent (`implementer`, `architect`) or main session  |
| Verifier  | Judge subagent (`reviewer`, `tester`, `security-auditor`)      |
| Updater   | `bin/mythos-gvu commit-update` → writes lesson + patterns bump |

## CLI

```bash
# 1. Builder records the candidate change.
bin/mythos-gvu record-generation my-task path/to/diff.patch

# 2. Judge (in a fresh subagent context) reads the gen entry and verifies.
bin/mythos-gvu record-verification my-task pass "all tests green; no race conds"

# 3. Updater consolidates outcome, writes lesson if fail.
bin/mythos-gvu commit-update my-task

# Inspect:
bin/mythos-gvu status my-task
```

Storage is three blackboard topics: `gvu-<task>-gen`, `gvu-<task>-verify`, `gvu-<task>-update`. Each is an entry-history JSONL so re-running a step appends, never overwrites.

## When to use

- Any change worth a lesson if it fails (new feature, refactor, behavior change).
- Pre-merge gates where you want the verification artifact stored, not just a pass/fail in the operator's head.
- `/deep-evolve` cycles — each phase is a GVU step, the Kill Gate is the Verifier.

## Anti-patterns

- **Generator == Verifier**: the agent that proposed the change must NOT be the agent that judges it. Always use a fresh-context subagent for verification.
- **Pass without reason**: empty `reason` field on a pass record means we lose the *why* — the Updater needs it to seed a future lesson.
- **Skipping commit-update on pass**: the success path also writes a lesson ("this pattern worked here") so future similar work has prior art.

## Stability condition (Variance Inequality)

Practical implication: if `reviewer` is noisy (e.g., flips between approve/block on the same diff), you can't make progress. Keep verifier prompts deterministic, give it a fresh context, and feed it the **reflection bundle** (`bin/mythos-reflect`) instead of free-form description.
