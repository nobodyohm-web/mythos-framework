# /skill-install — Install a skill from the registry

**Purpose:** Quick installer for a single skill (or all matching a filter) from `registry/skills.json`.

## Usage patterns

```bash
# Single skill by id
bin/mythos-skill install <id>

# Force overwrite an existing file
bin/mythos-skill install <id> --force

# Bulk by tag
bin/mythos-skill install-all --tag testing

# Bulk by detected project type
bin/mythos-skill install-all --project-type python
```

## Discovery first

If the id is unknown, list or search:

```bash
bin/mythos-skill list
bin/mythos-skill search <query>
bin/mythos-skill info <id>
```

## Safety guarantees

- HEAD probe before download — fail-fast on broken URLs.
- Frontmatter validation — refuses files that don't look like skills.
- Optional SHA-256 pin — refuses files whose bytes have drifted.
- Atomic write — temp file → rename, no partial installs.

## Output

Confirm: which skills landed where, and any failures with reason.
