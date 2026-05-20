# skill: chain-of-verification

> Reduce hallucination by making Mythos auto-verify its own draft before answering.

## When to use

- **Factual claims with discoverable answers** (dates, names, numbers, citations)
- **List outputs** ("name the 5 X" — CoVe paper shows list-QA is the strongest win)
- **Long-form generation** where multiple facts are interleaved
- **Anything the user might fact-check** — better to catch it now than ship it

## When NOT to use

- Code that has passing tests (the tests already verify it)
- Trivial questions ("what is 2+2?") — verification overhead > value
- Opinions, design choices, recommendations — no ground truth to verify against
- Subjective writing — verification would just re-litigate style

## The protocol — Dhuliawala et al. 2023 (arXiv:2309.11495)

```
1. DRAFT     — generate the initial response, no verification yet (tier C)
2. PLAN      — auto-generate factual verification questions about the draft (tier C)
3. ANSWER    — answer each question INDEPENDENTLY, in a FRESH context, with no
               access to the draft (tier D — the bias-killer step)
4. REVISE    — produce the final answer, correcting the draft using the
               independent answers as ground truth (tier D)
```

**The key insight:** step 3 must happen with NO sight of step 1. If the same
context generates both the draft and the verifications, it will rationalize its
hallucinations. The CoVe paper shows the "factored" variant (independent
verification) materially beats the "joint" variant.

## How Mythos uses it

`bin/mythos-cove` is a state machine; you (Mythos main) generate the content.

```bash
# Stage 1 — write your draft
echo "Marie Curie discovered radium in 1898 alongside Pierre Curie." \
  | bin/mythos-cove draft curie-claim -

# Stage 2 — generate verification questions ABOUT the draft
cat <<EOF | bin/mythos-cove plan curie-claim -
Q1: Who discovered radium?
Q2: When was radium discovered?
Q3: Was Marie Curie's collaborator Pierre Curie?
Q4: Was anyone else involved?
EOF

# Stage 3 — answer each question in a FRESH context.
# Use a fresh-context judge: bin/mythos-fleet dispatch (or Task subagent_type=researcher)
# DO NOT answer them yourself with the draft visible.
cat fresh-answers.txt | bin/mythos-cove answer curie-claim -

# Stage 4 — revise the draft using the independent answers as ground truth
bin/mythos-cove revise curie-claim revised.txt

bin/mythos-cove show curie-claim   # full audit trail
```

## Question template (stage 2)

When generating verification questions, follow these rules:

1. **One claim per question.** Don't combine ("Who and when?") — independent.
2. **No leading questions.** Bad: "Did Marie Curie really discover radium?".
   Good: "Who is credited with the discovery of radium?".
3. **Cover every factual claim in the draft.** Numbers, names, dates, places,
   relationships, attributions.
4. **Prefer atomic questions over compound ones.** A draft with N facts → ≥ N
   questions.

## Fresh-context answering (stage 3)

The bias-killer. Three viable mechanisms:

1. **Fresh-context subagent** via `Task(subagent_type=researcher)` — researcher
   doesn't see the draft, only the questions.
2. **Fleet worker** via `bin/mythos-fleet dispatch` — separate Claude process.
3. **`/critique` slash command** — also produces a fresh-context verdict.

NEVER answer the verification questions in the same context as the draft —
the model will rationalize.

## Tier semantics

- `draft`     → **tier C** (Conjectured — unverified)
- `questions` → **tier C** (Conjectured — also unverified)
- `answers`   → **tier D** (Derived — fresh context proved them)
- `revised`   → **tier D** (Derived — incorporates ground truth)

If the revised answer contradicts the draft on N facts, log that as a hallucination
catch in `tasks/lessons.md` — that's the compounding intelligence.

## Anti-patterns

- ❌ Skipping stage 3 ("I already know the answers") — defeats CoVe's purpose
- ❌ Asking verification questions to the same Claude context as the draft
- ❌ Using CoVe on code outputs (use tests or `/critique` instead)
- ❌ Stopping after stage 2 ("I have questions, looks fine") — the value is in answering them

## References

- Dhuliawala et al. 2023. *Chain-of-Verification Reduces Hallucination in Large
  Language Models.* arXiv:2309.11495. ACL Findings 2024.
- Related: `skills/epistemic-rigor.md`, `skills/anti-sycophancy.md`,
  `skills/self-consistency.md`.
