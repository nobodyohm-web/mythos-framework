---
description: Capture an explicit lesson into tasks/lessons.md after a correction or insight.
argument-hint: "<short title> :: <what went wrong> :: <root cause> :: <rule>"
allowed-tools: Read Edit Write Bash
---

# /learn — Explicit Lesson Capture

Append a new lesson to `tasks/lessons.md` in the canonical format.

## Input parsing

The user will pass `$ARGUMENTS` shaped roughly as:
```
<title> :: <mistake> :: <root cause> :: <rule>
```

If `$ARGUMENTS` is missing one of the four fields, ASK ONE focused question to fill it (no narration, no "let me…" — just the question). When all four exist, write the entry.

## Append format

```
### YYYY-MM-DD — <title>
**Mistake:** <mistake>
**Root Cause:** <root cause>
**Rule:** <rule>
```

## After appending
1. Read the last 3 lessons and verify the new entry parses correctly.
2. Print:
   ```
   📚 LESSON LOGGED: <title>
   Total lessons: N
   ```
3. If the lesson describes a class of error that could be enforced deterministically, suggest (don't implement) a follow-up: "Consider encoding this as a hook in `hooks/`."
