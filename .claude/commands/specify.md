---
description: Spec-Driven Development — create or update a feature specification before implementation. Ensures the WHAT and WHY are defined before the HOW.
allowed-tools: Read Edit Write Bash WebFetch Task
argument-hint: "<feature description or name>"
---

# /specify — Spec-Driven Development Engine

You are entering **SPEC MODE** — structured specification before any code is written.

Feature request: `$ARGUMENTS`

---

## PHASE 1 — Constitution Check

1. Read `constitution.md` at project root
   - If it doesn't exist → create it interactively using the template from the constitution skill
   - If it exists → load it and reference its principles throughout this process

2. Confirm you understand the project's non-negotiable principles before proceeding.

---

## PHASE 2 — Feature Registration

1. Generate a feature slug from the description (e.g., `mcp-orchestrator-v2`)
2. Assign the next sequential ID by reading `specs/registry.json`
   - If `specs/registry.json` doesn't exist → create it with an empty features array
3. Create the feature directory: `specs/{id}-{slug}/`
4. Register in `specs/registry.json`:
   ```json
   {
     "id": "<next-id>",
     "slug": "<feature-slug>",
     "status": "specifying",
     "created": "<ISO date>",
     "spec_hash": null,
     "plan_hash": null,
     "branch": null,
     "confidence": null
   }
   ```

---

## PHASE 3 — Specification Authoring

Create `specs/{id}-{slug}/spec.md` with this structure:

```markdown
# Feature: {Feature Name}
ID: {id} | Status: Draft | Created: {date}

## Problem Statement
[What problem does this solve? Why does it matter?]

## User Stories
- As a [role], I want [capability] so that [benefit]

## Functional Requirements
1. [FR-01] ...
2. [FR-02] ...

## Non-Functional Requirements
- [NFR-01] Performance: ...
- [NFR-02] Security: ...

## Acceptance Criteria
- [ ] AC-01: ...
- [ ] AC-02: ...

## Out of Scope
- [Explicit exclusions to prevent scope creep]

## Dependencies
- [What must exist before this can be built?]

## Review Checklist
- [ ] All user stories have acceptance criteria
- [ ] No ambiguous requirements remain
- [ ] Constitution principles are respected
- [ ] Dependencies are identified and available
```

Fill it based on:
- The user's `$ARGUMENTS` description
- Codebase analysis (read relevant existing files)
- Constitution principles

---

## PHASE 4 — Clarification Pass

1. Review the spec for ambiguities, unstated assumptions, and edge cases
2. List up to 5 targeted questions for the user:
   ```
   🔍 CLARIFICATION NEEDED
   
   1. [Question about scope/behavior]
   2. [Question about edge case]
   3. [Question about priority/tradeoff]
   
   Answer these or type "skip" to proceed with assumptions listed below.
   
   📋 ASSUMPTIONS (if skipping):
   - [Assumption 1]
   - [Assumption 2]
   ```
3. If the user answers → update the spec with their answers
4. If the user says "skip" → proceed with stated assumptions noted in the spec

---

## PHASE 5 — Spec Validation

1. Cross-check the spec against `constitution.md`:
   - Any forbidden patterns referenced? → Remove them
   - Naming conventions followed? → Fix if needed
   - Quality gates addressed? → Ensure acceptance criteria cover them

2. Check off items in the Review Checklist

3. Compute a spec-completeness score:
   - All user stories have ACs → +25
   - No ambiguous requirements → +25
   - Dependencies identified → +25
   - Out of scope defined → +25
   
   Score < 75 → Warn user and suggest refinement

---

## PHASE 6 — Handoff

Output:
```
✅ SPEC COMPLETE — {feature-name}

📄 Spec: specs/{id}-{slug}/spec.md
📋 Completeness: XX/100
🔗 Registry: specs/registry.json (entry #{id})

Next steps:
  → /mythosrun {feature-name}  — Plan + implement + verify
  → /specify {feature-name}    — Refine the spec further
  → Edit specs/{id}-{slug}/spec.md manually
```

---

## Rules
- **Never write code in /specify** — this is SPECIFICATION only
- **Always create the spec file** — even for simple tasks (a 3-line spec is valid)
- **Always register in registry.json** — traceability is non-negotiable
- **Constitution is the law** — every spec must comply with constitution.md
