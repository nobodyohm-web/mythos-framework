# /agent-install — Install a subagent from the registry

**Purpose:** Quick installer for a single subagent (or all matching a filter) from `registry/agents.json`.

## Usage patterns

```bash
# Single agent by id
bin/mythos-agent install <id>

# Force overwrite an existing file
bin/mythos-agent install <id> --force

# Bulk by tag
bin/mythos-agent install-all --tag review

# Bulk by detected project type
bin/mythos-agent install-all --project-type python
```

## Discovery first

```bash
bin/mythos-agent list
bin/mythos-agent search <query>
bin/mythos-agent info <id>
```

## Validation specifics for agents

Agents must be valid Claude Code subagents:
- YAML frontmatter on the first line.
- `name:` and `description:` keys present in the frontmatter.
- Body describes operating principles.

If a downloaded file fails this check, the install aborts and nothing is written.

## After install

Agents land in `.claude/agents/<id>.md` and become callable via the `Task` tool with `subagent_type=<id>` immediately — no restart needed.
