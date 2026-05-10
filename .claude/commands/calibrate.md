---
description: Calibrate confidence — compare predicted confidence against actual outcomes and update patterns.json calibration counters.
allowed-tools: Read Edit Bash
---

# /calibrate — Confidence Calibration

Walk through recent confidence-log entries and classify each as `overconfident`, `underconfident`, or `calibrated` based on what actually happened.

## Steps

1. Read the last 10 entries from `tasks/confidence-log.md`.
2. For each entry that has NOT yet been marked with an `Accuracy:` line, ask the user one of:
   - "Was the action actually as good as the XX/100 confidence suggested?"
   - Accept: `over | under | calibrated | skip`
3. Append `**Accuracy:** <verdict>` to that entry.
4. Update `.claude/memory/patterns.json`:
   - Increment the matching counter under `calibration.{overconfidentCount, underconfidentCount, calibratedCount}`.
5. After processing, summarize:
   ```
   📊 CALIBRATION SUMMARY
   Reviewed: N entries
   Over-confident: X | Under-confident: Y | Calibrated: Z
   Calibration ratio: Z / (X + Y + Z) = NN%
   ```
6. If over-confident outnumbers under-confident by ≥3, suggest tightening the scoring band (e.g. require harder evidence to award 90+).

## Constraints
- Never invent outcomes. If you cannot determine the verdict from context, ask the user.
- One entry at a time. Do NOT batch verdicts without confirmation.
