# Skill: Plan-Act-Correct-Verify (PACV) Cycle

**Source:** MIT thesis "Stairway to Autonomy" — LLaMAR's plan-act-correct-verify loop for long-horizon planning. `[E]`

## When to use

- Any task that crosses ≥3 tool calls and could fail partway.
- Long-horizon work where the cheap shortcut is to barrel ahead and the expensive failure is finishing the wrong thing.
- Inside `/mythosrun` after `/team` returns a plan but before the implementer commits.

## The cycle

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│   PLAN   │ →  │   ACT    │ →  │ CORRECT  │ →  │  VERIFY  │ → done | retry
└──────────┘    └──────────┘    └──────────┘    └──────────┘
   write          do exactly       inspect          run tests/
   acceptance     one step         diff,            checks; if
   criteria       at a time        compare to       red, loop back
   to disk                         plan; fix         to CORRECT
                                   drift            (not PLAN)
```

## Rules

1. **PLAN to disk, not to memory.** Use `bin/mythos-blackboard write <task>-plan` or write to `specs/`. The plan must survive context compaction.
2. **ACT one step at a time.** If the plan has 5 steps, do step 1, then return to CORRECT — do not chain 5 actions.
3. **CORRECT compares actual diff to planned diff.** Use `bin/mythos-reflect` to get the actual change-set. Diverged = correct here.
4. **VERIFY = a deterministic check.** Tests, lint, smoke run. If you can't write a check that fails when the work is wrong, you don't have a verifier — you have hope.
5. **On VERIFY fail, loop to CORRECT, not PLAN.** Re-plan only after 2 consecutive CORRECT cycles fail to converge — that's evidence the plan itself is wrong.

## Anti-patterns

- Skipping VERIFY because "the code looks right" — this is exactly the moment hallucinations slip through.
- Editing the plan during ACT to match what you actually did — the plan is the contract, not the chronicle.
- Running VERIFY against the same harness that produced ACT (no independent check). Use `/critique` or a `reviewer` subagent.

## Integration points

- Pairs with `skills/gvu.md` — the GVU triad operationalizes ACT + VERIFY as Generator + Verifier.
- Pairs with `skills/tot.md` — when PLAN itself is ambiguous, use Tree-of-Thoughts to branch-and-score candidates before committing.
- `bin/mythos-budget` should be checked between cycles to detect runaway loops.
