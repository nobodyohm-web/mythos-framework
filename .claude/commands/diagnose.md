---
description: Run the Mythos self-test and surface recent error/notification logs in one report.
allowed-tools: Bash Read
---

# /diagnose — Mythos Health Check

Execute these steps in order, then summarize:

## 1. Self-test

```bash
bash "${CLAUDE_PROJECT_DIR:-.}/hooks/test-mythos.sh"
```

## 2. Tail recent error-recovery hints

```bash
tail -20 "${CLAUDE_PROJECT_DIR:-.}/.claude/memory/error-recovery.log" 2>/dev/null || echo "(no error-recovery log yet)"
```

## 3. Tail recent notifications

```bash
tail -10 "${CLAUDE_PROJECT_DIR:-.}/.claude/memory/notifications.log" 2>/dev/null || echo "(no notifications log yet)"
```

## 4. Last subagent invocations

```bash
tail -10 "${CLAUDE_PROJECT_DIR:-.}/.claude/memory/subagents.log" 2>/dev/null || echo "(no subagent invocations yet)"
```

## 5. Event-stream tail (structured observability)

```bash
tail -20 "${CLAUDE_PROJECT_DIR:-.}/.claude/memory/events.jsonl" 2>/dev/null || echo "(no events yet)"
```

## 6. Patterns snapshot

```bash
cat "${CLAUDE_PROJECT_DIR:-.}/.claude/memory/patterns.json" 2>/dev/null | head -40
```

## Final Report Format

After running all checks, produce ONE summary block:

```
═══════════════════════════════════════════
  🩺 MYTHOS DIAGNOSE
═══════════════════════════════════════════
SELF-TEST: <PASS / WARN / FAIL>  (N passed, M failed, K warnings)
RECENT ERRORS: <count> patterns logged
NOTIFICATIONS: <count> in last 24h
SUBAGENTS USED: <list>
EVENT STREAM: <count> events / sessions
TOP RECOMMENDATION: <one line>
═══════════════════════════════════════════
```
