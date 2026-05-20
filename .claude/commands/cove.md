# /cove — Chain-of-Verification

Thin wrapper around `bin/mythos-cove`. Use this command when you want Mythos to
auto-verify a factual claim or list output before committing to it.

## Quick reference

```bash
bin/mythos-cove draft   <task-id> <file|->     # stage 1 — record initial draft
bin/mythos-cove plan    <task-id> <file|->     # stage 2 — record verification Qs
bin/mythos-cove answer  <task-id> <file|->     # stage 3 — record FRESH-CONTEXT answers
bin/mythos-cove revise  <task-id> <file|->     # stage 4 — record revised final answer
bin/mythos-cove status  <task-id>              # which stages exist
bin/mythos-cove show    <task-id>              # print all 4 stages
```

## The contract

CoVe matters because of stage 3: the verification answers must come from a
**fresh context** that has NOT seen the original draft. Otherwise the model
will rationalize its hallucinations.

Practical recipes for the fresh context:

1. Spawn a `Task(subagent_type=researcher)` and pass it ONLY the verification
   questions (no draft).
2. Use `bin/mythos-fleet dispatch` to spawn a bare-context worker.
3. Use `/critique` — also a fresh-context judge.

## When to invoke

- Factual claims (names, dates, numbers, citations)
- List outputs (e.g., "name 5 X")
- Long-form generation with multiple factual claims interleaved
- High-stakes answers where the user will fact-check

See `skills/chain-of-verification.md` for the full protocol, anti-patterns,
and the paper (Dhuliawala et al. 2023, arXiv:2309.11495, ACL Findings 2024).

## Safety contract

`bin/mythos-cove` is a state machine. It NEVER:

- Generates content (you generate; it stores)
- Calls models (you decide when to spawn fresh contexts)
- Auto-revises (you produce the revision; it records the audit trail)
