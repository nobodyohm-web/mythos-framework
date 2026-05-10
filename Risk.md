# Risk Rules — Agentic Autonomy Kit

## Data Integrity Rules

### Never Trust a Single Source
- Cross-reference data from multiple sources before making decisions
- When sources disagree, flag the discrepancy explicitly in the analysis
- If a data point cannot be verified from at least 2 sources, mark it as "unconfirmed"

### API & External Call Safety
- Every external API call MUST use retry logic with exponential backoff
- Every tool function MUST wrap logic in try/catch — NEVER let a throw crash the agent
- If a data source fails, degrade gracefully — produce partial analysis, never crash
- Set explicit timeouts on ALL network calls (default: 10-15s)

### Context & Token Safety
- Monitor context window usage — stay within model limits
- Auto-compact or summarize when context exceeds threshold
- Never remove graceful degradation patterns (`.catch(() => [])` on optional fetches)

## Code Safety Rules

### Before ANY Edit
1. Read the file first — understand current state
2. Run typecheck/lint after changes — zero errors tolerated
3. Run tests after logic changes — all tests must pass
4. Never introduce `any` types (TypeScript) or untyped variables

### Before ANY Commit
1. Verify no `.env` files or API keys are staged
2. Verify no test files or scratch files in root directory
3. Verify typecheck/lint passes cleanly
4. Verify all tests pass

### Destructive Operations — NEVER
- Never delete or overwrite existing implementations without explicit user confirmation
- Never modify core routing or orchestration without understanding implications
- Never change compaction/summarization thresholds without load testing
- Never alter hook execution order without testing the full chain

## Analysis Quality Rules

### Scoring Must Be Auditable
- Every score must include justification with traceable data
- No black box scores — every number traceable to source data
- When data is insufficient, explicitly state "DATA INSUFFICIENT" — never guess

### Final Output Must Be Actionable
- Every analysis ends with a clear recommendation
- Include confidence level and key assumptions
- Catalysts/triggers must be specific and time-bound

## Risk Escalation Protocol

### Severity Levels
| Level | Trigger | Action |
|-------|---------|--------|
| 🟢 LOW | Minor data gaps | Proceed with caveat noted |
| 🟡 MEDIUM | Source disagreement | Flag in output, user decides |
| 🔴 HIGH | Critical data failure | STOP, notify user, await instructions |
| ⛔ CRITICAL | Security/credential exposure risk | ABORT immediately, alert user |
