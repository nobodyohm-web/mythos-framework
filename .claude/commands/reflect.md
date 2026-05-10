# /reflect — Session Retrospective & Knowledge Extraction

You are entering **REFLECT MODE** — look back at this session, extract wisdom, and prepare for the next.

## Protocol

### STEP 1 — Session Inventory
List everything that happened in this session:
1. Tasks attempted (and their outcomes)
2. Files created, modified, or deleted
3. Errors encountered (and how they were resolved)
4. Decisions made (and their rationale)
5. User corrections received

### STEP 2 — Performance Assessment
Rate the session across dimensions:

| Dimension | Score (1-10) | Notes |
|-----------|-------------|-------|
| **Speed** | X | How quickly were tasks completed? |
| **Accuracy** | X | How many errors or corrections? |
| **Elegance** | X | How clean and maintainable is the code? |
| **Autonomy** | X | How much user intervention was needed? |
| **Learning** | X | Were past lessons applied? Were new ones captured? |

**Overall Session Score:** X/50

### STEP 3 — Lesson Extraction
For each mistake or correction in this session:
```
### [DATE] — [SHORT TITLE]
**Mistake:** What went wrong
**Root Cause:** Why it happened  
**Rule:** What to do instead (permanently)
**Confidence Impact:** How this affected output quality
```
Append ALL new lessons to `tasks/lessons.md`.

### STEP 4 — Confidence Calibration
Review all confidence scores logged during this session:
1. Were high-confidence predictions accurate? (calibration check)
2. Were low-confidence predictions justified?
3. Adjust future scoring thresholds if systematically over/under-confident

### STEP 5 — Session Journal Entry
Write to `tasks/session-journal.md`:
```markdown
## Session — [DATE TIME]

### Summary
[2-3 sentence overview of what was accomplished]

### Tasks Completed
- [x] Task 1 — confidence: XX/100
- [x] Task 2 — confidence: XX/100
- [ ] Task 3 — blocked/deferred

### Key Decisions
1. [Decision]: [Rationale]

### Errors & Fixes
1. [Error]: [Root cause] → [Fix applied]

### Lessons Learned
1. [New lesson added to lessons.md]

### Evolution Recommendations
- [ ] [Suggested improvement for CLAUDE.md]
- [ ] [Suggested new skill/hook]

### Session Score: X/50
```

### STEP 6 — Evolution Trigger
If session score < 35/50 OR more than 2 new lessons were added:
- Suggest running `/evolve` to upgrade the system
- Highlight the specific areas that need improvement

## Reflection Principles
- **Brutal honesty** — don't sugar-coat poor performance
- **Actionable insights** — every observation must lead to a specific improvement
- **Compound growth** — small gains per session stack into massive improvement over time
- **Anti-fragility** — failures should make the system stronger, not just patched
