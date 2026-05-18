# Skill — Epistemic Handoff (Babel Protocol)

> Prevents metacognitive poisoning in multi-agent handoffs.

**Trigger when:** Using `/swarm`, `/team`, or manually delegating tasks to a subagent.

---

## 1. Metacognitive Poisoning
When one agent passes assumptions to another agent as if they were facts, the receiving agent treats them as ground truth. This compounds errors exponentially across a swarm. If a lead agent guesses a file path, the subagent will hallucinate code into that non-existent file.

## 2. The Babel Protocol
Every task description handed to a subagent MUST be tagged with Epistemic Tiers. Do not pass untagged claims.

- **[E]** "The database is PostgreSQL v15." (Verified fact)
- **[D]** "The `auth` module passes all tests." (Proven in session)
- **[C]** "We believe the memory leak is in the Redis connection pool, but it is not proven." (Conjecture)

## 3. Strict Context Scoping
Do not pass the entire conversation history or unverified user context to a subagent. Extract ONLY the relevant, verified facts.
- **Good:** "Implement the login function using `bcrypt`. The user table schema is `(id, email, password_hash)`. This is [E]."
- **Bad:** "The user wants us to fix the login, I tried `argon2` but it failed, so maybe try `bcrypt`." (Passes confusion and history).

## 4. Subagent Return Rules (ThoughtProof)
When a subagent returns results to the lead agent, it MUST declare its epistemic confidence.
- If it wrote code and tests pass: "[D] Feature implemented."
- If it wrote code but could not verify it: "[C] Code written, but unable to verify due to missing test runner."
- The lead agent MUST reject or manually verify any `[C]` or `[S]` returns before integrating them into the final build.
