#!/usr/bin/env bash
# Mythos Universal Installer
# Usage:
#   Local:   ./install.sh /path/to/target [--with-skills tag1,tag2] [--with-agents tag1,tag2]
#   Remote:  bash <(curl -fsSL https://raw.githubusercontent.com/nobodyohm-web/mythos-framework/master/install.sh) /path/to/target
#
# Flags:
#   --with-skills <tags>   After install, run `mythos-skill install-all --tag <t>` for each tag.
#   --with-agents <tags>   After install, run `mythos-agent install-all --tag <t>` for each tag.
#   --branch <ref>         GitHub ref to clone when running remotely (default: master).

set -euo pipefail

TARGET=""
SKILL_TAGS=""
AGENT_TAGS=""
BRANCH="master"
REPO_URL="https://github.com/nobodyohm-web/mythos-framework.git"

while [ $# -gt 0 ]; do
  case "$1" in
    --with-skills) SKILL_TAGS="$2"; shift 2 ;;
    --with-agents) AGENT_TAGS="$2"; shift 2 ;;
    --branch)      BRANCH="$2";     shift 2 ;;
    -h|--help)
      sed -n '2,12p' "$0"; exit 0 ;;
    *)
      [ -z "$TARGET" ] && TARGET="$1" || { echo "unknown arg: $1" >&2; exit 1; }
      shift ;;
  esac
done

if [ -z "$TARGET" ]; then
  echo "Usage: install.sh /path/to/target [--with-skills tag1,tag2] [--with-agents tag1,tag2]" >&2
  exit 1
fi

# Robust local-vs-remote detection: ${BASH_SOURCE[0]} may be unset under process
# substitution; fall back to $0; if neither resolves to a real file → remote.
SRC="${BASH_SOURCE[0]:-$0}"
if [ -f "$SRC" ]; then
  SOURCE_DIR="$(cd "$(dirname "$SRC")" && pwd)"
  CLEANUP_DIR=""
  echo "🧬 Local install from: $SOURCE_DIR"
else
  command -v git >/dev/null || { echo "git is required for remote install" >&2; exit 1; }
  SOURCE_DIR="$(mktemp -d)"
  CLEANUP_DIR="$SOURCE_DIR"
  echo "🌐 Remote install — cloning $REPO_URL ($BRANCH)"
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$SOURCE_DIR" >/dev/null
fi

echo "🚀 Target: $TARGET"
mkdir -p "$TARGET"

# Core directories — copy only what exists in the source.
for d in .claude bin hooks skills registry; do
  [ -d "$SOURCE_DIR/$d" ] && cp -R "$SOURCE_DIR/$d" "$TARGET/"
done

# Core files.
for f in CLAUDE.md Risk.md claude.json constitution.md; do
  [ -f "$SOURCE_DIR/$f" ] && cp "$SOURCE_DIR/$f" "$TARGET/"
done

# Bootstrap empty work directories.
mkdir -p "$TARGET/tasks" "$TARGET/specs"

# Permissions.
chmod +x "$TARGET"/bin/* 2>/dev/null || true
chmod +x "$TARGET"/hooks/*.sh 2>/dev/null || true

# Optional bulk-install via the marketplace.
if [ -n "$SKILL_TAGS" ] && [ -x "$TARGET/bin/mythos-skill" ]; then
  IFS=',' read -ra TAGS <<<"$SKILL_TAGS"
  for t in "${TAGS[@]}"; do
    echo "📦 installing skills tagged: $t"
    (cd "$TARGET" && CLAUDE_PROJECT_DIR="$TARGET" bin/mythos-skill install-all --tag "$t" || true)
  done
fi
if [ -n "$AGENT_TAGS" ] && [ -x "$TARGET/bin/mythos-agent" ]; then
  IFS=',' read -ra TAGS <<<"$AGENT_TAGS"
  for t in "${TAGS[@]}"; do
    echo "📦 installing agents tagged: $t"
    (cd "$TARGET" && CLAUDE_PROJECT_DIR="$TARGET" bin/mythos-agent install-all --tag "$t" || true)
  done
fi

# Cleanup remote clone.
[ -n "$CLEANUP_DIR" ] && rm -rf "$CLEANUP_DIR"

echo
echo "✅ Mythos installed into $TARGET"
echo "Next steps:"
echo "  cd $TARGET"
echo "  claude"
echo "  > /assimilate          # adapt to the host repo"
echo "  > /marketplace         # browse & install more skills/agents"
