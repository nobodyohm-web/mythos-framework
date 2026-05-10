---
description: Calibrate confidence — compare predicted confidence against actual outcomes, update patterns.json calibration counters, and adjust the scoring band recommendation.
allowed-tools: Read Edit Bash
---

# /calibrate — Confidence Calibration

Walk through recent confidence-log entries and classify each as `overconfident`, `underconfident`, or `calibrated` based on what actually happened. Then recommend whether the scoring band needs to widen, tighten, or hold.

## Steps

1. Read the last 10 entries from `tasks/confidence-log.md`.
2. For each entry that has NOT yet been marked with an `Accuracy:` line, ask the user one of:
   - "Was the action actually as good as the XX/100 confidence suggested?"
   - Accept: `over | under | calibrated | skip`
3. Append `**Accuracy:** <verdict>` to that entry.
4. Update `.claude/memory/patterns.json`:
   - Increment the matching counter under `calibration.{overconfidentCount, underconfidentCount, calibratedCount}`.
   - Append a row to `calibration.history` with `{ts, over, under, calibrated, ratio}`.
5. After processing, summarize:
   ```
   📊 CALIBRATION SUMMARY
   Reviewed: N entries
   Over-confident: X | Under-confident: Y | Calibrated: Z
   Calibration ratio: Z / (X + Y + Z) = NN%
   Cumulative ratio: <from patterns.json>
   ```
6. **Recommend a band adjustment**:
   - If over-confident outnumbers under-confident by ≥3 → tighten the 90+ band (require harder evidence).
   - If under-confident outnumbers over-confident by ≥3 → loosen the 70+ band (current bar wastes runway on certainties).
   - Otherwise → hold; bands look right for now.
7. Write the recommendation to `tasks/confidence-log.md` as a dated `## Calibration adjustment YYYY-MM-DD` heading and to `patterns.json` under `calibration.lastAdjustment`.

## Append metric (one row to `.claude/memory/eval-metrics.jsonl`)

```json
{"ts":"...","mode":"calibrate","reviewed":N,"over":X,"under":Y,"calibrated":Z,"ratio":NN,"adjustment":"tighten|loosen|hold"}
```

## Constraints
- Never invent outcomes. If you cannot determine the verdict from context, ask the user.
- One entry at a time. Do NOT batch verdicts without confirmation.
- Never adjust a band on a single calibration session — require ≥3 sessions of consistent signal before changing the bands referenced in `CLAUDE.md` / `Risk.md`.

## References
- Self-improvement skill: `skills/self-improve.md`
- Confidence log: `tasks/confidence-log.md`
- Patterns: `.claude/memory/patterns.json`
