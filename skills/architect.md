---
name: architect
description: System design and ADR generation. Use for new features ≥3 components, breaking schema/API changes, or any decision worth recording for future readers.
allowed-tools: Read Grep Glob Bash Write
---

# 🏗️ Architect — System Design with Decision Records

> Design before you build. Write down WHY, not just WHAT.

## Phase 1 — Frame the Problem

1. **What problem are we solving?** (one sentence)
2. **For whom?** (user / system / integration)
3. **Constraints:** performance, security, compatibility, deadline, team size.
4. **Non-goals:** what we are explicitly NOT solving (prevents scope creep).

## Phase 2 — Survey the Landscape

1. Read existing code in adjacent areas — how is similar work done?
2. Search the web (only if novel domain) for canonical patterns.
3. Check `tasks/lessons.md` for past architectural mistakes in this repo.

## Phase 3 — Generate Options (minimum 2)

For each option:

| Field | Content |
|---|---|
| Approach | One-paragraph sketch |
| Pros | 2-4 bullets |
| Cons | 2-4 bullets |
| Cost | Effort (hours/days) |
| Risk | What could go wrong |
| Reversibility | How hard is it to undo? |

**Single-option ADRs are a smell.** If you only see one path, you haven't thought hard enough.

## Phase 4 — Decide

Pick the option. Document WHY in the ADR.

## Phase 5 — Write the ADR

Save to `docs/adr/NNNN-<slug>.md` (create `docs/adr/` if absent — this is the ONE allowed exception to "no new dirs"):

```markdown
# ADR-NNNN: <Title>

- Status: Proposed | Accepted | Deprecated | Superseded by ADR-MMMM
- Date: YYYY-MM-DD
- Deciders: <names>

## Context
What problem are we solving and why now?

## Decision
The chosen approach in 2-4 sentences. Active voice. "We will…"

## Consequences
- Positive: what gets better
- Negative: what gets worse / what we accept as cost
- Neutral: side effects worth noting

## Options Considered
1. **<Option A>** — chosen because…
2. **<Option B>** — rejected because…
3. **<Option C>** — rejected because…

## Implementation Notes
Files affected, migration steps, rollout sequence.
```

## Output Template

```
═══════════════════════════════════════════
  🏗️ ARCHITECTURE DECISION — <feature>
═══════════════════════════════════════════

📋 PROBLEM: <one sentence>
✅ DECISION: <one sentence>
📁 ADR: docs/adr/NNNN-<slug>.md
🎯 NEXT STEPS:
  1. <step>
  2. <step>

CONFIDENCE: XX/100
═══════════════════════════════════════════
```

## Anti-Patterns

- ❌ Building before designing on >5-file changes
- ❌ ADRs written *after* implementation to justify decisions retroactively
- ❌ Choosing a framework because it's trendy (cite a benchmark or use case)
- ❌ Designing for hypothetical future scale (YAGNI)
