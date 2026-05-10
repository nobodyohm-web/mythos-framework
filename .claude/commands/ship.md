# /ship — Production Deployment Preparation

You are entering **SHIP MODE** — verify a branch is production-ready, not assume it.

## Target
Branch / scope: `$ARGUMENTS` (default: current branch vs `main`)

## Pre-Flight Checklist (ALL must pass)

### 1. Code Quality
```bash
bun run typecheck 2>&1 || npx tsc --noEmit 2>&1   # zero errors
bun test 2>&1                                       # all passing
npx eslint . --quiet 2>&1                           # zero warnings
```

### 2. Security Gate
- Invoke `subagents/security-auditor.md` against the diff vs main.
- Required verdict: 🟢 APPROVED (zero Critical/High).

### 3. No Secrets in Diff
```bash
git diff main...HEAD | grep -iE 'sk-[a-zA-Z0-9]{20,}|ghp_|AKIA[0-9A-Z]{16}|-----BEGIN.*PRIVATE KEY' && echo "🔴 SECRET DETECTED" && exit 1
```

### 4. Diff Sanity
```bash
git diff main...HEAD --stat                         # files & line count
git log main..HEAD --oneline                        # commit list
```
- Are all commits intentional?
- Any debug `console.log` / `print` left behind?
- Any `// TODO` / `// FIXME` without ticket?

### 5. Test Coverage on New Code
- Every new branch in changed files has a test?
- Run with coverage if available; require ≥80% on new code.

### 6. Database / Migration Safety
If migrations are part of the diff:
- Migration is reversible (`down` exists)?
- Backwards-compatible (no `DROP COLUMN` on a still-deployed prior version)?
- Tested against a snapshot of prod schema?

### 7. Performance Spot-Check
- Any new N+1 query?
- Any new sync I/O in a request handler?
- Any new unbounded recursion / unbounded loop?

### 8. Rollback Plan
- If this deploy fails, what's the revert command? (`git revert <sha>` is OK.)
- Are there irreversible side-effects (data writes, third-party calls)? Document them.

### 9. Observability
- New code paths emit logs/metrics for diagnosis?
- No PII / secrets in logs?

### 10. CHANGELOG / Release Notes
- User-visible changes documented (if applicable)?

## Output

```
═══════════════════════════════════════════
  🚢 SHIP REPORT — <branch>
═══════════════════════════════════════════

VERDICT: 🟢 SHIP IT | 🟡 SHIP WITH CAVEATS | 🔴 BLOCK

✅ PASSED:
  - typecheck
  - tests
  - lint
  - security audit
  - no secrets
  - coverage ≥80% on new code

🟠 NOTES / CAVEATS:
  1. <item>

🔴 BLOCKERS:
  1. <item with file:line> — <required action>

📊 STATS:
  Commits: N | Files: M | +AAA / -BBB lines
  New tests: K
  Coverage delta: +X.X%

▶️ ROLLBACK: git revert <sha range>
═══════════════════════════════════════════
```

## Constraints
- **Do NOT actually deploy.** This command produces a verified report. Deployment is a separate human-approved action.
- **Never bypass a blocker.** A 🔴 verdict means STOP — fix and re-run.
- **Never commit your own ship-prep changes** (formatting nits, etc.) — those are separate PRs.
