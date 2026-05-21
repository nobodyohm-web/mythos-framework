# /reflexion — Cross-attempt episodic memory

Thin wrapper around `bin/mythos-reflexion`. Use this command when a task is going to be re-attempted, so attempt N+1 can recall what attempt N learned.

## Quick reference

```bash
bin/mythos-reflexion record <task-id> <attempt-n> <outcome> <file|->
                                                   # outcome ∈ success|failure|partial
bin/mythos-reflexion recall <task-id> [--last N]   # default last 3, markdown out
bin/mythos-reflexion list                          # all tasks + counts
bin/mythos-reflexion clear <task-id>               # wipe (testing only)
```

## The contract

Reflexion writes a *verbal* reflection (root cause + corrective action) to disk after a failure. The next attempt reads it and prepends it to the prompt.

Critical: the reflection should ideally come from a **fresh-context judge** (a `Task(subagent_type=reviewer)` that did NOT participate in the failed attempt), to avoid the same rationalization bias CoVe stage 3 guards against.

## When to invoke

- A task failed and will be retried in the same or future session.
- A long-horizon `/mythosrun` task has a failed sub-phase.
- A coding task fails tests — write what was wrong, retry with the reflection in context.

See `skills/reflexion.md` for the full protocol, anti-patterns, and the paper (Shinn et al. 2023, arXiv:2303.11366, NeurIPS 2023).

## Safety contract

`bin/mythos-reflexion` is a state machine. It NEVER:
- Generates reflections (you generate; it stores)
- Auto-recalls without being asked
- Modifies past reflections (append-only by design)
