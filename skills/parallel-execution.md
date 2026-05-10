# Skill — Parallel Execution

> When to parallelize work across teammates/subagents, how to split it, how to merge outputs, and how to resolve conflicts.

**Trigger when:** a task touches ≥3 independent files, ≥3 independent concerns, or has obvious fan-out structure (review-N-PRs, refactor-N-modules, investigate-N-hypotheses).

**Skip when:** work is sequential (each step depends on the previous), files overlap, or the coordination cost exceeds the parallelism gain.

---

## Parallelize vs serialize

```
PARALLELIZE when:                    SERIALIZE when:
✅ tasks own disjoint file sets      ❌ tasks edit the same file
✅ no shared mutable state           ❌ output of A is input of B
✅ ≥3 independent units              ❌ <3 units (overhead > savings)
✅ work is exploratory (research)    ❌ work is hot-path debugging
✅ goals are different angles        ❌ one canonical answer needed
   (review for security AND perf
    AND tests — these are different
    lenses, perfect for parallel)
```

Rule of thumb: **5–6 tasks per teammate**. Below 3 → serialize. Above 8 → batch.

---

## Two execution paths in Claude Code

### Path 1 — Subagents (lightweight, results-only)
- Use the `Task` tool with `subagent_type=<name>`.
- Each subagent runs in its own context window, returns a single message.
- Best for: fan-out research, independent investigations, code review by dimension.
- Cost: lower (results summarize back); no inter-agent chatter.
- **Default to this** unless teammates need to talk to each other.

### Path 2 — Agent Teams (heavy, communicating)
- Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` (already set in `.claude/settings.json`).
- Lead spawns named teammates; they share a task list and message each other.
- Best for: cross-layer features (frontend + backend + tests), competing-hypothesis debugging, design with adversarial review.
- Cost: higher (each teammate is a full Claude session).
- See `.claude/commands/team.md` for the wrapper command.

---

## Splitting work — the Planner contract

Use the `planner` subagent to decompose. It returns tasks tagged with:

```
- id, owner-type, files (disjoint!), deliverable, blockedBy, estimate
```

Then group tasks into **parallel waves**:
- Wave 1: tasks with `blockedBy: []`
- Wave N+1: tasks whose deps are all completed in Wave ≤N

Spawn one subagent (or teammate) per task in the current wave. Wait for the wave to finish before launching the next.

---

## Merging outputs

Pattern by task type:

| Task type | Merge strategy |
|---|---|
| Research (researcher × N) | Lead synthesizes; pick recommendation that ≥2 agree on; cite all |
| Code (implementer × N, disjoint files) | Concatenate diffs; run combined typecheck + tests |
| Review (reviewer × N, different lenses) | Union findings; dedupe by `path:line`; severity = max |
| Tests (tester × N, different files) | Concatenate; run full suite; fail if any flake |

**Hard rule:** if two implementers wrote to the same file (planner failed to enforce disjoint sets), do NOT auto-merge. Re-plan.

---

## Conflict resolution

When agents disagree:

1. **Surface the disagreement explicitly.** "Reviewer says block; implementer says ship. Reason A vs reason B."
2. **Pick the most restrictive default.** Block > ship; deny > allow; rollback > forward-fix.
3. **Cite the rule.** Every disagreement should resolve to a named rule (Risk.md, lessons.md, ADR).
4. **Escalate to user** if rules conflict or the call is judgment-only.

Never let two agents loop on each other — cap at 2 round-trips, then escalate.

---

## When to use `/team` vs `/swarm` vs Task tool

| Need | Use |
|---|---|
| Spawn one subagent for a focused look | `Task` tool directly |
| Spawn 3-5 subagents for fan-out, no chatter | `/swarm` |
| Spawn a team that needs to debate or pass artifacts | `/team` |
| Sequential pipeline (planner → implementer → tester → reviewer) | `/team` with explicit task graph |

---

## Anti-patterns

- ❌ Parallelizing without disjoint file sets → conflicts.
- ❌ Spawning 10 teammates "to be safe" → token cost, coordination chaos.
- ❌ Letting reviewer + implementer ping-pong without a circuit breaker.
- ❌ Merging without re-running the full test suite.
- ❌ Using Agent Teams when subagents would do (5× the tokens for the same answer).

---

## References
- `subagents/` and `.claude/agents/` — agent profiles
- `.claude/commands/team.md` — team wrapper
- `.claude/commands/swarm.md` — fan-out wrapper
- Anthropic docs: https://code.claude.com/docs/en/agent-teams
- Anthropic docs: https://code.claude.com/docs/en/sub-agents
