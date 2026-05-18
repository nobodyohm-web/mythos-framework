# Skill: Blackboard — Durable Inter-Agent Handoff

**Auto-load triggers:** "blackboard", "share state across agents", "agent coordination", "parallel handoff", "cross-agent memory".

---

## Why this exists

Subagents run in **isolated context windows**. The only data that returns to the main thread is a single summary string. For multi-step parallel work, that loses too much: planners can't see what researchers actually fetched, reviewers can't audit raw findings, and the main thread has to re-derive context.

The **Blackboard** pattern (InfiAgent / classical multi-agent systems) solves this by externalizing state to disk. Agents write findings to topic files; subsequent agents read them. No agent talks directly to another — they communicate through a shared, append-only ledger.

> The blackboard is where claims become facts. Always tag with the Epistemic Tier (`--tier=E|D|C|S`).

---

## Tooling

`bin/mythos-blackboard` — CLI on disk. Storage: `.claude/state/blackboard/<topic>.jsonl`.

```bash
# Write a finding (payload must be valid JSON; stdin or argv).
./bin/mythos-blackboard write research-sota '{"finding":"InfiAgent uses file-centric state","src":"arxiv:..."}' --tier=E

# Read the latest entry on a topic.
./bin/mythos-blackboard read research-sota

# Tail the last 5 entries (history).
./bin/mythos-blackboard tail research-sota --n 5

# List all topics.
./bin/mythos-blackboard list

# Clear a topic when work is done.
./bin/mythos-blackboard clear research-sota
```

Each entry on disk: `{"ts","agent","topic","tier","payload"}`.

---

## When to use

- **Parallel research** — fan out 3 `researcher` subagents on different sub-topics; each writes to its own topic; the planner reads all three. (Replaces stuffing 3 summaries back into the main context.)
- **Multi-phase plan** — `architect` writes the plan to `topic=plan`; `implementer` reads it; `reviewer` reads both the plan and the diff.
- **Long-running handoff** — if a session ends mid-task, the next session starts by `tail`-ing the active topics.
- **Calibration evidence** — write predictions to `topic=predictions` before action; the next `/calibrate` reads them against actual outcomes.

## When NOT to use

- Ephemeral in-session state — use TaskCreate / tasks/todo.md.
- Settings or configuration — those live in `.claude/settings.json`.
- Code or specs — those go in their proper files in the repo.

---

## Conventions

- **Topic names**: kebab-case, semantic (`research-sota`, `plan-current`, `review-findings`). Allowed chars: `A-Za-z0-9._-`.
- **Tier required**: every write should pass `--tier=...`. If omitted, defaults to `C` (Conjectured) so callers notice.
- **Agent identity**: subagents should `export MYTHOS_AGENT=<role>` before writing — defaults to `main`.
- **Append, don't mutate**: JSONL means each entry is preserved. Use `tail` to see history.
- **One topic per workstream**: do not write unrelated findings under the same topic.

## Anti-patterns

- Writing prose-only `"payload": "long text..."` — wrap structured fields. JSON is parseable; prose isn't.
- Treating the blackboard as a database — it's a log. Limit ≤ ~1k entries per topic before `clear`-ing.
- Ignoring the tier — untagged claims slowly poison the calibration loop.
