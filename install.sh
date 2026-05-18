#!/usr/bin/env bash
# Mythos Universal GitHub Installer
# Usage:
#   Local:  ./install.sh /path/to/target
#   Remote: bash <(curl -s https://raw.githubusercontent.com/YOUR_GITHUB/mythos/main/install.sh) /path/to/target

set -e

if [ -z "$1" ]; then
  echo "Usage: install.sh /path/to/target/repository"
  exit 1
fi

TARGET="$1"
# If running remotely via curl, BASH_SOURCE[0] might not be a local path
if [ -f "${BASH_SOURCE[0]}" ]; then
  SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  echo "🧬 Injecting Mythos locally from: $SOURCE_DIR"
else
  # Running from curl. Clone the repository into a temporary directory
  echo "🌐 Injecting Mythos remotely from GitHub..."
  REPO_URL="https://github.com/nobodyohm-web/mythos-framework.git"
  SOURCE_DIR=$(mktemp -d)
  git clone --depth 1 "$REPO_URL" "$SOURCE_DIR"
fi

echo "🚀 Target host: $TARGET"
mkdir -p "$TARGET"

# Copy core directories
cp -R "$SOURCE_DIR/.claude" "$TARGET/"
cp -R "$SOURCE_DIR/bin" "$TARGET/"
cp -R "$SOURCE_DIR/hooks" "$TARGET/"
cp -R "$SOURCE_DIR/skills" "$TARGET/"

# Copy core files
cp "$SOURCE_DIR/CLAUDE.md" "$TARGET/"
cp "$SOURCE_DIR/claude.json" "$TARGET/"

# Ensure empty task and spec directories exist
mkdir -p "$TARGET/tasks"
mkdir -p "$TARGET/specs"

# Make binaries executable
chmod +x "$TARGET"/bin/* 2>/dev/null || true
chmod +x "$TARGET"/hooks/*.sh 2>/dev/null || true

# Cleanup if we cloned remotely
if [ ! -f "${BASH_SOURCE[0]}" ]; then
  rm -rf "$SOURCE_DIR"
fi

echo "✅ Mythos framework injected successfully into $TARGET!"
echo "➡️  Next step: cd $TARGET and run 'claude' then type '/assimilate' to let the agent adapt to the new codebase."
