# /deepaudit — Deep Security & Quality Audit

You are entering **DEEP AUDIT MODE** — channel the Mythos-level code analysis capability.

## Purpose
Perform a comprehensive, multi-dimensional audit of the codebase, inspired by Claude Mythos's ability to autonomously discover vulnerabilities and architectural weaknesses.

## Target
Audit scope: `$ARGUMENTS`
(If no arguments, audit the entire project)

## Protocol

### DIMENSION 1 — SECURITY AUDIT
Analyze all code for security vulnerabilities:

1. **Secrets & Credentials**
   - Scan for hardcoded API keys, tokens, passwords
   - Check `.env` files are gitignored
   - Verify no secrets in git history: `git log --all -p | grep -i "api_key\|secret\|password\|token" | head -20`

2. **Input Validation**
   - Check all user inputs are validated/sanitized
   - Look for SQL injection, XSS, path traversal vectors
   - Verify all external data is typed and bounded

3. **Dependency Vulnerabilities**
   - Check `package.json` / `Cargo.toml` / `requirements.txt` for known CVEs
   - Flag outdated dependencies with known security issues
   - Review transitive dependency risks

4. **Network Safety**
   - All HTTP calls use HTTPS
   - Timeouts set on all network requests
   - Rate limiting on outbound API calls
   - Sensitive data not sent to third-party services

### DIMENSION 2 — CODE QUALITY AUDIT
1. **Type Safety**: Zero `any` types, proper generics, exhaustive pattern matching
2. **Error Handling**: All async operations wrapped in try/catch, graceful degradation
3. **Dead Code**: Unused imports, unreachable code, commented-out blocks
4. **Duplication**: DRY violations, copy-pasted logic that should be extracted
5. **Complexity**: Functions > 50 lines, cyclomatic complexity > 10, deep nesting > 3

### DIMENSION 3 — ARCHITECTURE AUDIT
1. **Separation of Concerns**: Are responsibilities clearly divided?
2. **Dependency Direction**: Do lower layers depend on higher layers? (should not)
3. **Interface Stability**: Are public APIs well-defined and stable?
4. **Testability**: Can each module be tested independently?
5. **Scalability**: Are there bottlenecks (single-threaded, unbounded queues, etc.)?

### DIMENSION 4 — RESILIENCE AUDIT
1. **Failure Modes**: What happens when external services are down?
2. **Retry Logic**: Exponential backoff on all network calls?
3. **Timeout Coverage**: Every network call has a timeout?
4. **Graceful Degradation**: Partial results vs complete failure?
5. **Recovery**: Can the system recover from a crash without data loss?

### DIMENSION 5 — EPISTEMIC AUDIT
1. **Unproven Assumptions**: Are there hardcoded assumptions lacking validation?
2. **Missing Tests**: Are there complex code blocks without associated empirical tests?
3. **Overconfidence**: Are errors swallowed silently? Are edge-cases waved away?
4. **Validation Logic**: Does the system actually verify inputs/outputs or just trust them?

## Output Format
```
═══════════════════════════════════════════════
  🔬 DEEP AUDIT REPORT — [PROJECT/SCOPE]
  Generated: [DATETIME]
═══════════════════════════════════════════════

📊 SUMMARY
  Security:     [SCORE/100] — [X critical, Y warnings]
  Quality:      [SCORE/100] — [X issues found]
  Architecture: [SCORE/100] — [X recommendations]
  Resilience:   [SCORE/100] — [X gaps identified]
  Epistemic:    [SCORE/100] — [X unproven assumptions]
  
  OVERALL:      [SCORE/100] — [GRADE: A/B/C/D/F]

🔴 CRITICAL FINDINGS
  1. [finding with file:line reference]
  2. ...

🟡 WARNINGS
  1. [finding with file:line reference]
  2. ...

🟢 STRENGTHS
  1. [what's done well]
  2. ...

🎯 ACTION ITEMS (Priority Order)
  1. [P0] [action] — fixes [finding]
  2. [P1] [action] — fixes [finding]
  3. ...
═══════════════════════════════════════════════
```

## After Audit
1. Save report to `tasks/audit-[date].md`
2. Add critical findings to `tasks/todo.md` as action items
3. If AUTO_FIX mode: attempt to fix P0 items immediately using `/heal`
