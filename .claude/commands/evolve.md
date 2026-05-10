# /evolve — Self-Improvement & CLAUDE.md Evolution

You are entering **EVOLUTION MODE** — analyze your own performance and upgrade your operating system.

## Purpose
Analyze patterns from past sessions and improve the CLAUDE.md configuration, skills, and workflows to prevent recurring mistakes and amplify what works.

## Protocol

### STEP 1 — Gather Evidence
1. Read `tasks/lessons.md` — extract ALL lessons
2. Read `tasks/confidence-log.md` — identify low-confidence patterns
3. Read `tasks/session-journal.md` — review recent sessions
4. Read `.claude/memory/patterns.json` — load saved patterns (if exists)

### STEP 2 — Pattern Analysis
For each lesson and low-confidence entry, classify:

| Pattern Type | Description | Action |
|-------------|-------------|--------|
| 🔴 RECURRING MISTAKE | Same error happens 2+ times | Add explicit rule to CLAUDE.md |
| 🟡 LOW CONFIDENCE | Confidence < 70 on similar tasks | Add skill/playbook for this task type |
| 🟢 HIGH SUCCESS | Confidence > 90 consistently | Document as best practice |
| 🔵 NEW CAPABILITY | User requested something we couldn't do | Propose new tool/skill |

### STEP 3 — Generate Upgrades
Based on the analysis, propose concrete changes:

1. **CLAUDE.md Rules**: Add/modify rules that prevent recurring mistakes
2. **New Skills**: Create playbook files for task types with low confidence
3. **Hook Improvements**: Strengthen guardrails where failures occurred
4. **Subagent Specs**: Update subagent instructions based on performance

### STEP 4 — Apply Upgrades
1. Edit the files with proposed changes
2. Log all changes to `tasks/session-journal.md`:
   ```
   ### [DATETIME] — EVOLUTION CYCLE
   **Trigger:** [what prompted this evolution]
   **Changes:**
   - [file]: [what changed and why]
   **Expected Impact:** [how this improves future performance]
   ```

### STEP 5 — Update Pattern Memory
Write/update `.claude/memory/patterns.json`:
```json
{
  "lastEvolution": "[datetime]",
  "rulesAdded": N,
  "skillsCreated": N,
  "confidenceTrend": "[improving/stable/declining]",
  "topMistakes": ["...", "..."],
  "topStrengths": ["...", "..."]
}
```

## Evolution Principles
- **Never remove working rules** — only add, refine, or clarify
- **Be specific** — "always check for null" is better than "be careful"
- **Measure impact** — track if confidence scores improve after changes
- **Compound gains** — small improvements that stack over sessions
