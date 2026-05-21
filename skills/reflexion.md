# skill: reflexion

> Cross-attempt episodic memory. After a failed attempt, write a verbal reflection. Future attempts at the same task recall and prepend it.

## When to use

- **A task is going to be re-attempted** — same goal, second try, after a failure or partial result.
- **Failure mode is non-obvious** — the reflection saves the next attempt from re-discovering it.
- **Long-horizon tasks** — `/mythosrun` retries inside a session benefit most.
- **Coding tasks specifically** — the Reflexion paper shows the largest gain on HumanEval (91% pass@1 vs 80% baseline).

## When NOT to use

- **A task succeeded cleanly on first try** — no failure to reflect on, no signal worth storing.
- **Trivial failures** ("typo, fixed it") — reflection overhead > value.
- **One-shot tasks that will never recur** — Reflexion's value is cross-attempt; no future attempt = wasted write.
- **Failures in the user's request** — Reflexion is for the agent's own root-cause learning, not "the user gave me a bad spec."

## The protocol — Shinn et al., NeurIPS 2023 (arXiv:2303.11366)

```
ATTEMPT N FAILS
    ↓
WRITE REFLECTION:
  - What was the root cause? (1-2 sentences, no rationalization)
  - What changed assumption would have avoided it?
  - What concrete action does attempt N+1 take instead?
    ↓
STORE → .claude/memory/reflexion/<task>.jsonl
    ↓
ATTEMPT N+1 STARTS
    ↓
RECALL last K reflections, prepend to prompt as "Prior attempt notes:"
    ↓
ACT
```

**The key insight (from the paper):** the reflection is *verbal*, not parametric. No weight updates. The gain comes from the LLM reading its own prior failure analysis at the start of the next attempt — pure prompting.

## How Mythos uses it

`bin/mythos-reflexion` is a state machine. The CALLER (Mythos main, or a fresh-context judge) writes the reflection text.

```bash
# After a failed attempt at task "auth-refactor"
cat <<EOF | bin/mythos-reflexion record auth-refactor 1 failure -
Root cause: I assumed the session token store was an in-memory cache
and refactored accordingly. It is actually backed by Redis (saw
config/redis.yml only after the test failed).

What changed assumption: token storage is persistent, not ephemeral.

Attempt 2 action: read config/redis.yml FIRST before touching
token-related code. Trace every token write through the Redis client,
not just the in-memory paths.
EOF

# Before attempting again, recall what we learned
bin/mythos-reflexion recall auth-refactor --last 3

# List all tasks with reflections
bin/mythos-reflexion list
```

## Reflection-writing rules

1. **Be specific about the root cause.** "I made an assumption" is useless; "I assumed X without checking Y" is gold.
2. **No blame, no rationalization.** Don't say "the test was bad"; say "I didn't verify the test pre-conditions."
3. **State the corrective action.** Future-you needs a concrete next step, not a moral lesson.
4. **One reflection per failure attempt.** Compounding multiple failures into one record loses traceability.
5. **Keep it short.** 3-5 sentences. If it's longer, you're rationalizing.

## Tier semantics

- `outcome=failure` → **tier D** (Derived — the failure was observed empirically)
- `outcome=partial` → **tier C** (Conjectured — partial success means partial evidence)
- `outcome=success` → **tier D** (Derived — but consider whether the reflection is even worth storing; only persist non-trivial wins)

## Anti-patterns

- ❌ Reflecting on every attempt regardless of outcome — bloats memory with noise
- ❌ Long philosophical reflections — the LLM can't parse 500 words of regret as easily as 5 actionable sentences
- ❌ Writing the reflection inside the same context that failed — same bias risk as CoVe step 3. If possible, write reflection in a fresh `Task(subagent_type=reviewer)` context.
- ❌ Skipping recall at the start of attempt N+1 — defeats the entire point

## Relationship to other Mythos primitives

- **CoVe** ([[chain-of-verification]]) catches errors *within* a single attempt.
- **Self-Consistency** ([[self-consistency]]) catches errors via *parallel* sampling.
- **Reflexion** (this skill) catches errors *across* attempts of the same task.

These compose: a CoVe-protected single attempt that still failed → write a Reflexion record → the next attempt starts with both CoVe and the recalled reflection.

## References

- Shinn, Cassano, Berman, Gopinath, Narasimhan, Yao. 2023. *Reflexion: Language Agents with Verbal Reinforcement Learning.* arXiv:2303.11366. NeurIPS 2023.
- Related skills: [[chain-of-verification]], [[self-consistency]], [[epistemic-rigor]], [[debug-detective]].
