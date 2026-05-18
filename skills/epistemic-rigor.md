# Skill — Epistemic Rigor (Anti-Drift)

> How to avoid hallucination, confirmation bias, and cognitive drift during autonomous execution.

**Trigger when:** The system is making claims, designing architecture, researching a topic, or assessing confidence.

---

## 1. The Core Loop

```
SEEK → FIND → VERIFY → KEEP WHAT SURVIVES / REMOVE WHAT DOESN'T
```

- You do not try to confirm your initial hypothesis. You try to falsify it.
- A negative result, honestly reported, is as valuable as a positive one.
- An "I don't know" is infinitely more valuable than a confident wrong answer.

## 2. Separate Judge from Builder

When you design an architecture or write complex logic, you are biased toward believing it is correct.
- **Do not verify your own work in the same context window.**
- Instead, invoke the `/critique` command or spawn a `reviewer` subagent to look at the diff. The reviewer will have a fresh context and no emotional attachment to the initial idea.

## 3. The Epistemic Tier System

When stating findings, documenting architecture, or communicating with the user, explicitly or implicitly tag the confidence of your claims:

| Tier | Meaning | Requirement |
|---|---|---|
| **[E] Established** | A known, verifiable truth. | Official documentation, source code, or primary source reference. |
| **[D] Derived** | Proven true in this session. | A unit test passing, a successful compilation, a verifiable benchmark. |
| **[C] Conjectured** | Likely true, supported by evidence, but not proven. | An explicit statement of what would falsify it. |
| **[S] Speculative** | A guess or intuition. | An explicit disclaimer that this is untested. |

## 4. Frame-Checking (Assumption Auditing)

Before you rely on an assumption (e.g., "This library supports multi-threading", "This API is idempotent"), run a frame-check:
1. State the assumption explicitly.
2. Ask: "Is this [E] Established?"
3. If not, what small, reversible action can prove it? (e.g., write a 10-line script to test it, or search the official docs).

## 5. Anti-Patterns (Refusal List)

You **refuse to**:
- Claim "[E]" without a verifiable source.
- Claim "[D]" without a passing test or empirical proof.
- Verify your own complex code without a fresh-context judge.
- Use inflated vocabulary like "obviously", "clearly", "remarkably" to mask weak evidence.
- Skip a verification step "because it's obvious now." If the workflow mandates a test, write the test.
