---
name: Bug report
about: Something in Mythos doesn't behave as documented
title: "[bug] "
labels: bug
assignees: ''
---

## What you ran

```bash
# exact command, copy-pasted
```

## What you expected

A short, specific statement. Not "it should work" — what specifically.

## What happened

```
paste stderr + stdout here
```

## Environment

- OS: <macOS 14.x / Ubuntu 22.04 / …>
- `bash --version`:
- `jq --version`:
- `python3 --version`:
- Claude Code version:
- Mythos commit hash: `git rev-parse --short HEAD` →

## Self-test status

```
bash hooks/test-mythos.sh | tail -5
```

paste output here.

## Additional context

- Is this reproducible every time, or intermittent?
- Did this work in a previous Mythos version?
- Anything unusual about your environment (custom hooks, non-default settings, MCP servers)?
