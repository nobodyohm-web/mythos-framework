# skill: self-consistency

> Sample N diverse reasoning paths, take the majority-vote final answer.

## When to use

- **Discrete final answer** (number, yes/no, multiple choice, short phrase)
- **Reasoning task with a single ground truth** (math, logic, factual lookup)
- **Tasks where temperature > 0 produces meaningfully different paths**
- **High-stakes decisions** where you want robustness, not single-trace luck

## When NOT to use

- Code generation — no meaningful "majority vote" over patches
- Open-ended writing — no extractable discrete answer
- Real-time / cheap tasks — N× cost without N× value
- Already-high-confidence (90+) answers — diminishing returns

## The technique — Wang et al. 2022 (arXiv:2203.11171, ICLR 2023)

```
1. SAMPLE  — generate N=5 (default) diverse reasoning paths with T > 0
2. EXTRACT — pull the final discrete answer from each path
3. VOTE    — majority-vote across the extracted answers
4. REPORT  — return winner, agreement_pct, and ties
```

Published gains: GSM8K +17.9%, SVAMP +11.0%, AQuA +12.2%, StrategyQA +6.4%.

## Recommended N

- **N=3** — minimum viable (cheap; can't break ties cleanly)
- **N=5** — sweet spot (Wang et al. default; majority-of-5 = ≥3)
- **N=10** — for high-stakes (cost goes up linearly, gain plateaus around N=10)
- **N=20+** — research, not production. Cost dominates.

## How Mythos uses it

`bin/mythos-sc` is a state machine; you (Mythos main) sample the traces with
temperature.

```bash
# Stage 1 — declare the question
bin/mythos-sc init payment-calc "If a subscription is \$30/mo and we charge \
  per-day prorated, how much do we charge for 12 days?"

# Stage 2 — sample N traces (typically via fleet workers or repeated Task calls)
for i in 1 2 3 4 5; do
  bin/mythos-fleet dispatch --model claude-opus-4-7 \
    "$(cat prompt.txt)" --temperature 0.7 --budget 0.1
  # ...then for each result, extract the final answer ("$X.XX") and record it:
  bin/mythos-sc record payment-calc trace-$i.txt "$12.00"
done

# Stage 3 — vote
bin/mythos-sc vote payment-calc
# → {"winner":"$12.00","vote_count":4,"total":5,"agreement_pct":80,"tier":"D",...}
```

## Answer extraction (stage 2 detail)

The hardest part is reliably extracting the discrete answer from each trace.
Two patterns:

1. **Prompt the model to box its answer:** "End with `Final answer: <X>`"; then
   `grep "Final answer:"`. Reliable.
2. **Post-process with a small extractor prompt:** dispatch a tiny extractor
   call per trace. Costs more but handles messy traces.

Mythos does NOT enforce extraction format — the caller decides. The CLI just
stores the answer you give it.

## Tier semantics (in `vote` output)

| agreement_pct | tier | interpretation |
|---|---|---|
| ≥ 67%        | D    | Derived — Mythos's reasoning is stable; ship |
| 50-66%       | C    | Conjectured — weak majority; investigate before shipping |
| < 50%        | C    | Conjectured — no real winner; do not ship without /critique |

The threshold `≥ 67%` comes from "2/3 majority" being the standard for stable
agreement in social choice theory. Below 50% is by definition no winner.

## Ties (FR-11)

The `vote` output includes a `ties` array listing all answers within 1 vote of
the winner. In a clean win (e.g., 4-1), `ties` contains only the winner. In a
2-2 tie, `ties` contains both contenders.

If `ties.length > 1`, do NOT auto-ship; escalate to `/critique` or ask for human
guidance. The agreement is too soft to trust.

## CoVe + Self-Consistency combo

For high-stakes factual answers, combine both:

1. Run `bin/mythos-sc` to find the most-voted candidate answer.
2. Run `bin/mythos-cove` on the winner to verify each claim.

This is more expensive (~6× single-shot) but is the highest-confidence pattern
Mythos has. Reserve for: production-bound facts, audit-relevant decisions,
anything where being wrong is worse than being slow.

## Anti-patterns

- ❌ Self-Consistency on code patches — voting doesn't compose for structured output
- ❌ N=1 — that's just chain-of-thought; no consistency check
- ❌ Voting on long-form prose — there is no single answer to vote on
- ❌ Treating < 50% agreement as a winner — by definition, no winner
- ❌ Same trace sampled with temperature=0 N times — diversity is mandatory

## References

- Wang et al. 2022. *Self-Consistency Improves Chain of Thought Reasoning in
  Language Models.* arXiv:2203.11171. ICLR 2023.
- Related: `skills/chain-of-verification.md`, `skills/tot.md`,
  `skills/parallel-execution.md`.
