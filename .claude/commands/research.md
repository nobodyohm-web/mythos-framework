# /research — Deep Web Research Mode

You are entering **RESEARCH MODE** — produce a structured, citation-backed brief on the requested topic before any code is written.

## Topic
`$ARGUMENTS`

If no arguments provided, ask once: "What should I research?" — then execute.

## Phase 1 — Scope (≤30 seconds)

State in 1-2 sentences:
- The decision the research will inform
- The depth required: SHALLOW (5 min, top 3 sources) / MODERATE (15 min, ≥6 sources, comparison) / DEEP (45 min, primary sources + benchmarks + tradeoffs)

## Phase 2 — Source Triage

Search across these categories. Prefer authoritative over popular:

| Category | Examples |
|---|---|
| **Official docs** | vendor docs, language references, RFCs, IETF, W3C |
| **Primary sources** | papers (arXiv, ACM, IEEE), source code, design docs |
| **High-signal community** | popular GitHub repos (≥1k stars), eng blogs from large teams |
| **Benchmark / comparison** | independent benchmarks, trip-reports, "X vs Y" head-to-heads |

Avoid: low-effort listicles, AI-generated summary blogs, content farms, outdated tutorials.

## Phase 3 — Extract & Compare

Produce a comparison matrix when ≥2 options exist:

| Option | What it is | Strengths | Weaknesses | Cost | Maturity | Use when |
|---|---|---|---|---|---|---|

Cite every claim with `[Title](url)`.

## Phase 4 — Synthesize

Write a brief in this format:

```markdown
# Research: <topic>
> Decision context: <one sentence>
> Depth: SHALLOW / MODERATE / DEEP
> Sources reviewed: N

## TL;DR
3-bullet executive summary.

## Findings
### <Finding 1 title>
<Paragraph with [citations](url).>

### <Finding 2 title>
…

## Comparison
<Table when applicable>

## Recommendation
What to do, with the trade-off accepted.

## Open Questions
What we still don't know — would require <X> to resolve.

## Sources
1. [Title](url) — what we used it for
2. ...
```

Save to `tasks/research/<YYYY-MM-DD>-<slug>.md` (create `tasks/research/` if absent).

## Phase 5 — Update Cache

Append the most reusable insights to `.claude/memory/research-cache.md` so future sessions inherit the knowledge without re-searching.

## Output Template

```
═══════════════════════════════════════════
  🔎 RESEARCH COMPLETE — <topic>
═══════════════════════════════════════════

📄 BRIEF: tasks/research/<file>.md
📚 SOURCES: N (official: X, primary: Y, community: Z)
✅ TL;DR:
  - <bullet 1>
  - <bullet 2>
  - <bullet 3>

🎯 RECOMMENDATION: <one sentence>
❓ OPEN QUESTIONS: N (see brief)

CONFIDENCE: XX/100
═══════════════════════════════════════════
```

## Constraints
- **Cite or don't claim.** Uncited assertions are guesses.
- **Never trust a single source** for a decision-grade fact — cross-reference.
- **Disclose recency** — if the topic moves fast (LLMs, JS frameworks), flag any source older than 12 months.
- **No code in the brief** unless it's a verbatim API example pulled from an authoritative doc.
