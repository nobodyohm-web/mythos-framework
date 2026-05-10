---
description: Spawn a multi-agent team for parallel work. Decomposes the task with the planner agent, then runs disjoint sub-tasks across implementer/researcher/reviewer/tester agents and synthesizes results.
allowed-tools: Read Edit Write Bash Task
argument-hint: "<task description>"
---

# /team — Multi-Agent Team Orchestrator

Decompose `$ARGUMENTS` into parallel-safe tasks and dispatch them across specialized agents. Synthesize the merged result.

## Phase 1 — Plan

1. Spawn the **planner** subagent with `$ARGUMENTS` and the constraint: every task's file-set must be disjoint.
2. The planner returns an ordered list with `parallel groups`.
3. Read the plan. If any group has overlapping file-sets → re-plan with stricter scoping.

## Phase 2 — Execute (group by group)

For each parallel group:

1. Spawn one subagent per task in the group, **in parallel** (all `Task` tool calls in a single assistant message).
   - `researcher` task → `subagent_type=researcher`
   - `implementer` task → `subagent_type=implementer`, prompt = the planner's full task spec
   - `reviewer` task → `subagent_type=reviewer`, prompt includes the diff range to review
   - `tester` task → `subagent_type=tester`, prompt = files needing tests + behavior spec

2. Wait for all subagents in the group to return before launching the next group.

3. Merge outputs:
   - Concatenate diffs from disjoint implementers.
   - Union reviewer findings (dedupe by `path:line`, severity = max).
   - Union tester results.

4. Run combined verification: `bun typecheck && bun test` (or project equivalent).

## Phase 3 — Conflict resolution

If any of these surface:
- Two implementers wrote to the same file → **STOP**, re-plan.
- Reviewer says BLOCK on an implementer's diff → spawn an implementer fix-up; re-review.
- Test failures on combined diff → spawn debugger; max 2 iterations then escalate.

Cap at 2 round-trips per conflict. Then escalate to the user.

## Phase 4 — Deliver

```
═══════════════════════════════════════════
  🤝 TEAM COMPLETE — <task>
═══════════════════════════════════════════
📐 PLAN: <N tasks, <M groups>>
🔨 IMPLEMENTED: <files changed>
🔍 REVIEW VERDICT: APPROVE | CHANGES-REQUESTED
🧪 TESTS: <added>, <pass/fail>
📊 CONFIDENCE: <score>/100

🚦 STATUS: SHIP | NEEDS-USER-CALL
═══════════════════════════════════════════
```

## When to escalate to Agent Teams (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`)

`/team` uses subagents (lower token cost, no inter-agent chatter). Escalate to true Agent Teams (full lead + teammate sessions with shared task list) when:
- Teammates need to debate (competing-hypothesis debug).
- Cross-layer work requires sustained coordination beyond one fan-out wave.
- The task is large enough that 5× the token cost is worth it.

For escalation, ask the user explicitly: "This task would benefit from full Agent Teams (≈5× token cost). Spawn?"

## Constraints
- Always use the planner first. Never decompose ad-hoc.
- Never spawn >5 subagents per group.
- Never let subagents write to the same file in the same group.
- Always run combined verification before declaring done.
- Log final confidence to `tasks/confidence-log.md`.

## References
- Skill: `skills/parallel-execution.md` (when to parallelize, how to merge)
- Subagents: `.claude/agents/{planner,researcher,implementer,reviewer,tester}.md`
- Anthropic docs: https://code.claude.com/docs/en/agent-teams
