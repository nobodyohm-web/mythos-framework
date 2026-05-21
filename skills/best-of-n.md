# skill: best-of-n

> Adaptive test-time compute. Don't waste tokens uniformly — route easy tasks to a single sample, hard tasks to N parallel samples with verifier scoring.

## When to use

- **The output is scorable** — code (does it pass tests?), math (does it produce a number?), structured output (does it match a schema?), short factual answers.
- **A verifier exists or can be written** — even a "score this 0-100" prompt is enough.
- **You have a fleet** or budget to sample N times.
- **Difficulty varies across tasks** — uniformly hard or uniformly easy → use SC or a single shot instead.

## When NOT to use

- **Open-ended writing** — there's no monotonic verifier for "the best paragraph."
- **All-or-nothing tasks** — if the agent either gets it right or fails entirely, BoN gains nothing over a single attempt.
- **No verifier available** — without scoring, BoN degrades to SC majority vote (which we already have).
- **Token-budget critical** — BoN multiplies cost; only use when accuracy gain is worth the spend.

## The protocol — Snell et al. 2024 (arXiv:2408.03314)

The paper's headline result: at **matched FLOPs**, adaptive Best-of-N is ~4× more efficient than naive uniform-N. A smaller model with adaptive TTC can beat a 14× larger model on MATH.

```
1. CLASSIFY difficulty (1-5 zero-shot prompt: "rate this task's difficulty 1-5")
2. ROUTE:
     difficulty=1 → N=1   (single shot — no waste)
     difficulty=2 → N=2
     difficulty=3 → N=4   (default if difficulty unknown)
     difficulty=4 → N=8
     difficulty=5 → N=16
3. SAMPLE N candidates (temperature > 0; use fleet or repeated calls)
4. SCORE each candidate via a verifier prompt (0-100)
5. SELECT highest-scoring candidate
6. Tier the result: D if winner beats runner-up by 10+, else C
```

## How Mythos uses it

`bin/mythos-bestofn` is a state machine. The caller does steps 3 and 4 (sampling + scoring); the CLI handles 1-2-5-6.

```bash
# Step 1+2 — init with difficulty estimate
echo "What is the average of the first 100 prime numbers?" \
  | bin/mythos-bestofn init prime-avg - --difficulty=3

# Steps 3+4 — caller samples N candidates (via /fleet, /sc, repeated tasks)
# and records each with a verifier score
echo "The 100th prime is 541, average is ~241.4" | bin/mythos-bestofn record prime-avg - 65
echo "Sum/100 of primes up to 541 = 24133/100 = 241.33" | bin/mythos-bestofn record prime-avg - 92
echo "Approximately 250" | bin/mythos-bestofn record prime-avg - 40
echo "241.39" | bin/mythos-bestofn record prime-avg - 88

# Step 5+6 — pick the winner
bin/mythos-bestofn choose prime-avg
# → {"id": 2, "score": 92, "margin": 4, "tier": "C", "total_candidates": 4, ...}
```

## Difficulty classification

The difficulty estimate doesn't need to be perfect — Snell shows the routing dominates the cost savings. A simple zero-shot prompt:

```
Rate this task's difficulty 1-5:
  1 = trivial (deterministic, single-step)
  2 = easy (well-known pattern, low ambiguity)
  3 = moderate (default)
  4 = hard (requires multi-step reasoning OR domain knowledge)
  5 = expert (research-grade, ambiguous, or requires external verification)

Task: <prompt>

Return only the integer.
```

## Verifier scoring

The verifier is task-specific. Examples:
- **Code:** run the tests; score = % passing.
- **Math:** parse the final answer; score = 100 if numerically correct vs ground truth, else 0.
- **Factual:** run [[chain-of-verification]] on the candidate; score = 100 - (# Qs that disagree with the answer × 25).
- **Open-ended:** ask a fresh-context judge "rate 0-100 against criteria X, Y, Z."

The verifier MUST be in a fresh context that did not generate the candidates (same bias-killer rule as CoVe stage 3).

## Tier semantics

- `margin >= 10` between winner and runner-up → **tier D** (high confidence)
- `margin < 10` → **tier C** (ambiguous — consider re-sampling or escalating to CoVe)

## Anti-patterns

- ❌ Using BoN with no verifier — degrades to "pick a random one of N"
- ❌ Scoring with the same context that generated each candidate — same bias as CoVe step 3
- ❌ Using BoN on N=16 for trivial tasks — wastes 15 tokens for no gain
- ❌ Treating margin < 10 as a confident answer — those need escalation, not commitment

## Composition with other primitives

- **BoN vs SC** ([[self-consistency]]): SC counts votes, BoN scores quality. SC is right when answers are discrete; BoN is right when quality varies continuously.
- **BoN + CoVe** ([[chain-of-verification]]): use CoVe as the verifier inside BoN — each candidate gets a CoVe-derived score.
- **BoN + /fleet**: fleet dispatches the N parallel samples; BoN aggregates.
- **BoN + Reflexion** ([[reflexion]]): if BoN picks a low-margin winner, write a reflection so attempt N+1 starts with higher difficulty estimate.

## References

- Snell, Lee, Xu, Kumar. 2024. *Scaling LLM Test-Time Compute Optimally Can Be More Effective than Scaling Model Parameters.* arXiv:2408.03314. Aug 2024.
- Related: Cobbe et al. 2021 (verifier scaling, arXiv:2110.14168), Lightman et al. 2023 (PRM, arXiv:2305.20050 — Process Reward Models, NOT implemented in Mythos because no training pipeline).
