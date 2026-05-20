# /sc — Self-Consistency

Thin wrapper around `bin/mythos-sc`. Use when you want Mythos to sample N
reasoning paths and majority-vote the answer.

## Quick reference

```bash
bin/mythos-sc init    <task-id> "<question>"           # stage 1 — declare the question
bin/mythos-sc record  <task-id> <trace-file|-> <answer>   # stage 2 — append a trace + extracted answer
bin/mythos-sc vote    <task-id>                        # stage 3 — majority vote, write outcome
bin/mythos-sc status  <task-id>                        # N traces, unique answers
bin/mythos-sc show    <task-id>                        # render all artifacts
```

## When to invoke

- Discrete final answer (number, yes/no, multiple choice, short phrase)
- Reasoning task with a single ground truth
- High-stakes decision where you want robustness, not single-trace luck

## When NOT to invoke

- Code generation (no meaningful "majority vote" over patches)
- Open-ended writing (no extractable discrete answer)
- Already-high-confidence answers (90+)

Use `/cove` instead for open-ended factual outputs.

## Recommended N

| N  | Use case |
|----|----------|
| 3  | Cheap; can't break ties well |
| 5  | Sweet spot (Wang et al. default) |
| 10 | High-stakes |
| 20+| Research only — cost dominates |

## Reading the output

`vote` returns JSON:

```json
{
  "winner": "...",
  "vote_count": 4,
  "total": 5,
  "agreement_pct": 80,
  "tier": "D",
  "ties": ["..."]
}
```

| agreement_pct | tier | what to do |
|---|---|---|
| ≥ 67%        | D    | ship |
| 50-66%       | C    | investigate first |
| < 50%        | C    | do not ship without `/critique` |

If `ties.length > 1`, escalate — agreement too soft to trust.

See `skills/self-consistency.md` for the protocol, answer-extraction patterns,
and the paper (Wang et al. 2022, arXiv:2203.11171, ICLR 2023).
