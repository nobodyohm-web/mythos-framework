# Spec 007 — Reasoning Monster (v6.0)

> Status: specifying → planned → implemented
> Owner: Mythos
> Created: 2026-05-20
> Supersedes interest: rolled back Ollama-side-quest (commit 22dd899). Focus shifts from
> "free local compute" theater to research-backed reasoning primitives.

## Problem Statement

Mythos's stated mission is "rigorous, hallucination-free problem solving." Today it has:
- Tree-of-Thoughts state (`bin/mythos-tot`) — but no real search algorithm
- Generator-Verifier-Updater (`bin/mythos-gvu`) — but no auto-verification protocol
- Reflection bundle for judges (`bin/mythos-reflect`) — exists but underused
- Lessons system (`tasks/lessons.md`) — partial Reflexion-style memory

It is **missing two well-validated SOTA reasoning primitives** that directly target
hallucination and reasoning-trace fragility:

1. **Chain-of-Verification (CoVe)** — Dhuliawala et al., Meta 2023 (arXiv:2309.11495).
   Four-stage protocol that has the model auto-generate verification questions about
   its own draft, answer them **independently** (fresh context, no draft bias), and
   revise the draft. Measurably reduces hallucination on list-QA, MultiSpanQA,
   long-form generation.

2. **Self-Consistency** — Wang et al., Google 2022 (arXiv:2203.11171). Sample N
   diverse reasoning paths, extract the final answer from each, return the
   majority-vote answer. +17.9% GSM8K, +11% SVAMP, +12.2% AQuA.

Both are well-tested, simple to implement, and orthogonal to what Mythos already has.

## Why now

User explicit ask: "Ollama apporte vraiment quelque chose de plus ? si non retire
ollama, et fais des recherches profonde, etudie, MIT github et améliore en profondeur
encore une ingenerie incroyable pour que claude code soit un monstre de resonnement"

Translation: "Does Ollama really bring something more? If not, remove it, do deep
research, study MIT/GitHub, and deeply improve so Claude Code becomes a reasoning
monster."

Anti-sycophancy verdict (logged in revert commit 22dd899): Ollama was theater.
Pivoting to actual SOTA reasoning techniques.

## Functional Requirements

### CoVe (Chain-of-Verification)

**FR-1.** `bin/mythos-cove draft <task-id> <draft-file|->` MUST record an initial
draft response under blackboard topic `cove-<task>-draft` with tier `C` (Conjectured —
unverified).

**FR-2.** `bin/mythos-cove plan <task-id> <questions-file|->` MUST record a list of
verification questions under `cove-<task>-questions` with tier `C`. The caller (Mythos
main) is responsible for generating the questions; this CLI is the state machine.

**FR-3.** `bin/mythos-cove answer <task-id> <answers-file|->` MUST record independent
answers under `cove-<task>-answers` with tier `D` (Derived — answered with fresh
context, no draft bias). The caller MUST answer questions in a fresh context.

**FR-4.** `bin/mythos-cove revise <task-id> <revised-file|->` MUST record the final
revised response under `cove-<task>-revised` with tier `D`.

**FR-5.** `bin/mythos-cove status <task-id>` MUST print which of the 4 stages have
been recorded for the task.

**FR-6.** `bin/mythos-cove show <task-id>` MUST print all 4 stages in order, suitable
for a human to verify the audit trail.

**FR-7.** All CoVe operations MUST serialize through `mythos_lock_acquire "cove-<task>"`
to prevent inconsistent reads.

### Self-Consistency

**FR-8.** `bin/mythos-sc init <task-id> <question>` MUST record question metadata at
`sc-<task>-meta` (tier C) with `{question, n: 0, created_ts}`.

**FR-9.** `bin/mythos-sc record <task-id> <trace-file|-> <final-answer>` MUST append
one reasoning trace + its extracted final answer under `sc-<task>-trace-N` where N is
the next sequential index. MUST be idempotent under concurrent record calls (lock).

**FR-10.** `bin/mythos-sc vote <task-id>` MUST aggregate all recorded traces, compute
the majority-vote final answer, record `sc-<task>-vote` with `{winner, vote_count,
total, agreement_pct, ties: [...]}`, and print the result.

**FR-11.** Tie-handling: if no single answer reaches >50%, return the highest-count
answer AND list all answers within 1 vote of the winner under `ties`. Agreement_pct
< 50 MUST set tier `C` (still Conjectured); ≥ 67 MUST set tier `D`.

**FR-12.** `bin/mythos-sc status <task-id>` MUST print N recorded traces, the unique
answer counts, and whether `vote` has been called.

### Skills + slash commands

**FR-13.** `skills/chain-of-verification.md` MUST document the 4-stage protocol, when
to use CoVe (factual claims, list outputs, long-form), when NOT to use it (already-verified
code with passing tests, trivial answers), and the prompt scaffolding for stages 2-4.

**FR-14.** `skills/self-consistency.md` MUST document the N-sample procedure, the
final-answer extraction rule, when SC is appropriate (discrete answer, reasoning task),
and when it is not (code generation, open-ended writing where there is no single answer).

**FR-15.** `.claude/commands/cove.md` MUST exist as a thin `/cove` wrapper that
references `bin/mythos-cove` and `skills/chain-of-verification.md`.

**FR-16.** `.claude/commands/sc.md` MUST exist as a thin `/sc` wrapper that references
`bin/mythos-sc` and `skills/self-consistency.md`.

### Infrastructure

**FR-17.** `hooks/test-mythos.sh` MUST gain a "Reasoning Primitives (v6.0)" section
with ≥10 checks covering: binaries exist + executable, help string present, lifecycle
(draft → plan → answer → revise for CoVe; init → record × 3 → vote for SC), state
persistence via blackboard, lock acquisition (no crash under concurrent writes).

**FR-18.** `registry/skills.json` MUST list `chain-of-verification` and
`self-consistency` at version `6.0.0` with tier `[E]` (Established — based on cited
peer-reviewed work).

**FR-19.** `CLAUDE.md` MUST add 4 rows (2 skills, 2 CLI/slash combos) and remain
≤ 150 lines.

## Acceptance Criteria

- [ ] AC-01: `bin/mythos-cove draft test1 -` (stdin) records a draft, retrievable via
      `cove-test1-draft` on the blackboard.
- [ ] AC-02: `bin/mythos-cove plan/answer/revise` each record their respective topic
      with the correct tier (C, D, D).
- [ ] AC-03: `bin/mythos-cove status test1` prints "draft: ✓, questions: ✓,
      answers: ✓, revised: ✓" after all four stages.
- [ ] AC-04: `bin/mythos-cove show test1` prints all 4 stages in order.
- [ ] AC-05: `bin/mythos-sc init sctest "Is X true?"` records meta.
- [ ] AC-06: `bin/mythos-sc record sctest <trace> <answer>` thrice for three same
      answers + once for a different one, then `vote` returns the majority answer
      with agreement_pct = 75.
- [ ] AC-07: `bin/mythos-sc vote` with a 2-2 tie returns the tied answers under `ties`
      and tier C.
- [ ] AC-08: Concurrent `bin/mythos-cove draft` calls do not corrupt state (lock test).
- [ ] AC-09: `skills/chain-of-verification.md` exists with all FR-13 sections.
- [ ] AC-10: `skills/self-consistency.md` exists with all FR-14 sections.
- [ ] AC-11: `.claude/commands/cove.md` and `.claude/commands/sc.md` exist.
- [ ] AC-12: `hooks/test-mythos.sh` gains ≥10 Reasoning Primitives checks, ALL pass.
- [ ] AC-13: `registry/skills.json` contains both new entries at version 6.0.0.
- [ ] AC-14: `CLAUDE.md` line count ≤ 150 after additions.
- [ ] AC-15: All existing 251 self-test checks remain green (no regressions).

## Out of Scope

- **MCTS-LLM upgrade for `bin/mythos-tot`**: bigger lift; deferred to v6.1.
- **Process Reward Models (PRM)**: requires trained reward model; not practical
  without significant ML infra.
- **DSPy integration**: framework-heavy, doesn't match Mythos's Bash+Claude topology.
- **AlphaEvolve / CodeEvolve patterns**: niche algorithmic search; not generally
  applicable to the agentic coding task.
- **Auto-invocation of CoVe/SC by hooks**: explicit invocation only in v6.0; auto
  triggers can be added once we have data on hit rate.

## Dependencies

- `bin/mythos-blackboard` — durable state backbone (exists).
- `hooks/_lib.sh` — lock primitives (exists).
- `jq`, `python3` — present.

## Risks

| Risk | Mitigation |
|---|---|
| CoVe "questions" stage requires Mythos to actually generate good questions; bad questions = useless verification | The skill documents the question template; the CLI doesn't enforce question quality (out of scope). Caller responsibility. |
| Self-Consistency on non-discrete tasks gives garbage votes (e.g., voting on code patches) | Skill explicitly restricts SC to tasks with extractable discrete final answers; CoVe is the primitive for open-ended outputs |
| Blackboard topic name collisions if user picks ambiguous task-ids | Task-id validator enforces alphanumeric + `._-` only; length ≤ 49 chars for CoVe, ≤ 52 for SC (computed against blackboard 64-char cap) |
| Test sample count N high → expensive subagent calls | Skill documents N=5 as default sweet spot; user controls N |
| Confusion between "draft" tier C and "revised" tier D | Tier system is documented in CLAUDE.md L1; CLI enforces tier on write |

## Open Questions

None — confidence ≥85, proceeding with assumptions documented above.

## References

- Dhuliawala et al. 2023. "Chain-of-Verification Reduces Hallucination in Large
  Language Models." arXiv:2309.11495. ACL Findings 2024.
- Wang et al. 2022. "Self-Consistency Improves Chain of Thought Reasoning in
  Language Models." arXiv:2203.11171. ICLR 2023.
- Shinn et al. 2023. "Reflexion: Language Agents with Verbal Reinforcement
  Learning." arXiv:2303.11366. NeurIPS 2023. (Inspiration for the lessons.md loop —
  not implemented as a separate primitive here; already partially present.)
- Lightman et al. 2023. "Let's Verify Step by Step" (PRM800K). arXiv:2305.20050.
  (Inspiration for the tier system — Process Reward Models out of scope.)
- Gao et al. 2024. "Interpretable Contrastive Monte Carlo Tree Search Reasoning."
  arXiv:2410.01707. (Deferred to v6.1 — would augment bin/mythos-tot.)
