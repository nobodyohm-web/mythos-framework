# /bestofn — Adaptive Best-of-N test-time compute

Thin wrapper around `bin/mythos-bestofn`. Use this command when you can sample multiple candidates AND score them (verifier exists).

## Quick reference

```bash
bin/mythos-bestofn init   <task-id> <prompt|-> --difficulty=1-5
bin/mythos-bestofn record <task-id> <candidate|-> <score-0-100>
bin/mythos-bestofn choose <task-id>      # JSON winner with margin + tier
bin/mythos-bestofn status <task-id>      # progress vs recommended_n
bin/mythos-bestofn show   <task-id>      # full state JSON
bin/mythos-bestofn clear  <task-id>      # remove state (testing only)
```

## The contract

BoN is compute-optimal **only when difficulty is classified first**. Naive uniform-N wastes tokens on easy prompts.

Difficulty → N mapping (Snell §4.2):
- 1 (trivial) → N=1
- 2 (easy)    → N=2
- 3 (moderate)→ N=4 (default)
- 4 (hard)    → N=8
- 5 (expert)  → N=16

## When to invoke

- The output is scorable (code, math, structured, short-factual).
- A verifier is available (or can be written as a "rate 0-100" prompt).
- You have a fleet or budget to sample N candidates.

See `skills/best-of-n.md` for the full protocol, verifier-design guidance, and composition with CoVe/SC/Reflexion. Paper: Snell et al. 2024, arXiv:2408.03314.

## Safety contract

`bin/mythos-bestofn` is a state machine. It NEVER:
- Generates candidates (you generate via /fleet/sc/repeated calls)
- Scores candidates (you score via verifier, fresh-context)
- Picks a winner without scores being recorded
