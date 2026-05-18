# Deep Evolution Plan — v2 (Mythos 5.1 → 5.2)

> Generated 2026-05-18 from `/deep-evolve` v2 (Theory → Application research split).
> Inputs: 6 `bin/mythos-research --fetch` queries + `bin/mythos-reflect` introspection of v5.1.

---

## North Star

v5.1 closed three failure modes: agent loops, lossy cross-agent handoff, unfiltered confidence inflation. **v5.2 closes the next three** that the SOTA literature explicitly calls out:

1. **Hallucination in action** — tool calls referencing identifiers/paths that don't exist.
   Source: arXiv:2601.12560 §"open challenges" + arXiv:2504.19678 v2 "failure modes in multi-agent LLM systems". `[E]`
2. **Prompt injection via untrusted content channels** — fetched web pages or read files containing role-tags or "ignore previous" payloads.
   Source: same papers. `[E]`
3. **Unbounded tool burn** — agents quietly consume hundreds of tool calls per session with no budget visibility.
   Source: medium.com/@sovannaro 2026 — "self-correction attempts, continuous prompting, API calls" without a budget cap. `[C]`

In parallel, v5.2 **formalizes** two patterns the literature established but Mythos was implementing only implicitly:

4. **Generator-Verifier-Updater (GVU) triad** as the unit of self-improvement, with the Variance Inequality as its stability condition.
   Source: arXiv:2512.02731v1 (Chojecki, Dec 2025). `[E]` for the math, `[C]` for our mapping.
5. **Tree-of-Thoughts state** — explicit branching+scoring on disk, not just inline.
   Source: arXiv:2601.12560 §"cognitive architecture dimension". `[E]`

---

## Inventory (don't duplicate — already in v5.1)

| Capability | File |
|---|---|
| Loop detection | `hooks/agent-guard.sh` |
| Cross-agent state | `bin/mythos-blackboard` + `.claude/state/blackboard/` |
| Calibration scoring | `bin/mythos-calibrate` |
| Observability dashboard | `bin/mythos-observe` |
| Epistemic-tier presence check | `bin/mythos-epistemic-check` |
| Lock primitive | `hooks/_lib.sh:mythos_lock_acquire` |

## New surface (v5.2)

| File | Type | Closes |
|---|---|---|
| `hooks/hallucination-guard.sh` | PreToolUse Bash | (1) hallucination-in-action |
| `hooks/prompt-injection-guard.sh` | PostToolUse Read\|WebFetch | (2) prompt injection |
| `bin/mythos-budget` | CLI | (3) tool burn visibility |
| `bin/mythos-gvu` | CLI | (4) GVU formalization |
| `bin/mythos-tot` | CLI | (5) Tree-of-Thoughts state |
| `skills/pacv.md` | Skill | Plan-Act-Correct-Verify (MIT LLaMAR) |
| `skills/gvu.md` | Skill | GVU usage guide |
| `skills/tot.md` | Skill | Tree-of-Thoughts usage |

## Acceptance criteria (test before commit)

- `hooks/test-mythos.sh` green (≥180 checks).
- `hallucination-guard.sh` flags `cat /nonexistent/file` but ignores `mkdir /tmp/new`.
- `prompt-injection-guard.sh` flags a Read result containing "ignore previous instructions".
- `mythos-budget --json` returns valid JSON shape `{session,counts,total,limit,status}`.
- `mythos-gvu record-generation/verification/commit-update` round-trips through blackboard.
- `mythos-tot init/expand/score/best` produces a valid tree at `.claude/state/tot/<task>.json`.
- All new hooks exit 0 on no-match (never break the tool pipeline).
- Kill-Gate (reviewer subagent) returns APPROVE.

## Phases (v5.2)

- **4.A** — Write new CLIs (mythos-budget, mythos-gvu, mythos-tot). `[C]`
- **4.B** — Write new hooks (hallucination-guard, prompt-injection-guard). `[C]`
- **4.C** — Wire hooks in `.claude/settings.json`. Bump `MYTHOS_VERSION` 5.1 → 5.2. `[D]`
- **4.D** — Write skills + research cache (`sota-2026-05-18b.md`). `[E]` for cites.
- **4.E** — Update `patterns.json` (evolutionHistory[1]) + `tasks/lessons.md` (4 new). `[D]`
- **4.F** — Extend `hooks/test-mythos.sh` with v5.2 checks. `[D]`
- **5** — Kill Gate. `[D]`
- **6** — Commit `feat(evolution): deep-evolve v5.2`. `[D]`

## Risks / non-goals

- **No** Microsoft Trace (autodiff for agents). Heavy, requires Python deep-integration; deferred to v5.3.
- **No** ACP (Agent Client Protocol). Mythos already speaks MCP; not adding a parallel stdio protocol now.
- **No** Perplexity API integration. mythos-research v2 with `ddgs` + WebSearch fallback is sufficient.
- **No** rebuild of v5.1 components.
