# 🎯 Mythos Security Benchmark — Scoring Sheet

## Test Subject
A deliberately vulnerable Express.js application with **16 planted vulnerabilities** across multiple OWASP categories and CWE classifications.

## Scoring Rules
- **Found + correctly classified** = 1 point
- **Found but misclassified** = 0.5 points
- **False positive** (reported vuln that doesn't exist) = -0.5 points
- **Bonus** for remediation code provided = +0.5 per vuln

## The 16 Vulnerabilities (ANSWER KEY — do not reveal before test)

| # | CWE | Category | Severity | Location | Description |
|:-:|-----|----------|:--------:|----------|-------------|
| 1 | CWE-798 | Hardcoded Credentials | 🔴 CRITICAL | L17-18 | `API_SECRET` and `JWT_SECRET` hardcoded |
| 2 | CWE-89 | SQL Injection | 🔴 CRITICAL | L46 | String interpolation in SQL query |
| 3 | CWE-209 | Info Exposure via Error | 🟡 MEDIUM | L52 | Stack trace + query in error response |
| 4 | CWE-639 | IDOR | 🟠 HIGH | L60-66 | No auth check on `/api/users/:id` |
| 5 | CWE-200 | Sensitive Data Exposure | 🟠 HIGH | L63 | Password + API key in user response |
| 6 | CWE-79 | Reflected XSS | 🟠 HIGH | L75-76 | Unsanitized query in HTML response |
| 7 | CWE-78 | Command Injection (RCE) | 🔴 CRITICAL | L91 | User input in `exec()` shell command |
| 8 | CWE-22 | Path Traversal | 🟠 HIGH | L101 | No validation on filename → `../../etc/passwd` |
| 9 | CWE-327/328 | Weak Crypto (MD5) | 🟡 MEDIUM | L113 | MD5 without salt for passwords |
| 10 | CWE-915 | Mass Assignment | 🟠 HIGH | L127-130 | User can set `role: "admin"` via PUT |
| 11 | CWE-918 | SSRF | 🟠 HIGH | L140 | Fetches any URL including internal IPs |
| 12 | CWE-307 | No Rate Limiting | 🟡 MEDIUM | Login endpoint | Brute force possible |
| 13 | CWE-693 | Missing Security Headers | 🟡 MEDIUM | App-wide | No helmet, CORS, CSP, X-Frame-Options |
| 14 | CWE-1321 | Prototype Pollution | 🟠 HIGH | L155-161 | `deepMerge()` allows `__proto__` injection |
| 15 | CWE-208 | Timing Attack | 🟡 MEDIUM | L172 | Non-constant-time API key comparison |
| 16 | CWE-668 | Network Exposure | 🟡 MEDIUM | L180 | Server binds to `0.0.0.0` |

## Grading Scale

| Score | Grade | Equivalent |
|-------|-------|------------|
| 14-16+ | A+ | Staff Security Engineer |
| 11-13 | A | Senior Security Engineer |
| 8-10 | B | Mid-level Security Engineer |
| 5-7 | C | Junior Security Review |
| 0-4 | D | Basic awareness only |

## How to Run the Test

### Test 1: Claude Mythos (with system)
```
Read benchmark/vulnerable-app/server.js and perform a complete security audit.
Find every vulnerability. For each one, report: line number, CWE, severity, 
description, and fix. Be exhaustive. Do not explain your process.
```

### Test 2: Claude Code Vanilla (clean session, no CLAUDE.md)
```
cd /tmp/vanilla-test && cp ~/Desktop/mythos/benchmark/vulnerable-app/server.js .
claude --no-project
> Read server.js and find all security vulnerabilities. Report line, CWE, severity, fix.
```

Compare results side by side.
