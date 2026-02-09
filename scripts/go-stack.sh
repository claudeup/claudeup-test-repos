#!/usr/bin/env bash
#
# Demonstrates claudeup profile stacking: composing a Go development
# environment from reusable building-block profiles (language, workflow,
# tools) into a single stack profile, then applying it.

set -euo pipefail

# --- Configuration -----------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_DIR="$REPO_ROOT/go-backend-api"

CLAUDEUP_BIN="${CLAUDEUP_BIN:-claudeup}"

# --- Isolated environment ----------------------------------------------------

TEMP_DIR="$(mktemp -d "/tmp/claudeup-stack-test-XXXXXXXXXX")"
export CLAUDE_CONFIG_DIR="$TEMP_DIR/.claude"
export CLAUDEUP_HOME="$TEMP_DIR/.claudeup"

cleanup() {
  echo "Cleaning up $TEMP_DIR ..."
  rm -rf "$TEMP_DIR"
  rm -rf "$PROJECT_DIR/.claude"
}
trap cleanup EXIT

mkdir -p "$CLAUDE_CONFIG_DIR/plugins" "$CLAUDEUP_HOME/profiles"
echo "Isolated env at: $TEMP_DIR"
echo "  CLAUDE_CONFIG_DIR=$CLAUDE_CONFIG_DIR"
echo "  CLAUDEUP_HOME=$CLAUDEUP_HOME"

# --- Create building-block profiles ------------------------------------------

mkdir -p "$CLAUDEUP_HOME/profiles/languages"
cat > "$CLAUDEUP_HOME/profiles/languages/go.json" <<'EOF'
{
  "name": "go",
  "description": "Go language development with gopls LSP",
  "marketplaces": [
    { "source": "github", "repo": "anthropics/claude-plugins-official" }
  ],
  "perScope": {
    "project": {
      "plugins": ["gopls-lsp@claude-plugins-official"]
    }
  },
  "detect": {
    "files": ["go.mod", "go.sum"]
  }
}
EOF

mkdir -p "$CLAUDEUP_HOME/profiles/workflow"
cat > "$CLAUDEUP_HOME/profiles/workflow/testing.json" <<'EOF'
{
  "name": "testing",
  "description": "Testing, TDD, and performance testing",
  "marketplaces": [
    { "source": "github", "repo": "anthropics/claude-plugins-official" }
  ],
  "perScope": {
    "project": {
      "plugins": ["tdd-workflows@claude-plugins-official"]
    }
  }
}
EOF

mkdir -p "$CLAUDEUP_HOME/profiles/tools"
cat > "$CLAUDEUP_HOME/profiles/tools/memory.json" <<'EOF'
{
  "name": "memory",
  "description": "Memory and context persistence",
  "marketplaces": [
    { "source": "github", "repo": "anthropics/claude-plugins-official" }
  ],
  "perScope": {
    "user": {
      "plugins": ["episodic-memory@claude-plugins-official"]
    }
  }
}
EOF

# --- Create composite stack profile ------------------------------------------

mkdir -p "$CLAUDEUP_HOME/profiles/stacks"
cat > "$CLAUDEUP_HOME/profiles/stacks/go-dev.json" <<'EOF'
{
  "name": "go-dev",
  "description": "Go development: memory + Go language + testing",
  "includes": ["memory", "go", "testing"]
}
EOF

echo ""
echo "=== Profiles created ==="
find "$CLAUDEUP_HOME/profiles" -name "*.json" | sort

# --- Exercise the stack -------------------------------------------------------

echo ""
echo "=== Profile list ==="
"$CLAUDEUP_BIN" profile list 2>&1

echo ""
echo "=== Show go-dev stack ==="
"$CLAUDEUP_BIN" profile show go-dev 2>&1

echo ""
echo "=== Apply go-dev stack to project ==="
cd "$PROJECT_DIR"
"$CLAUDEUP_BIN" profile apply go-dev -y 2>&1

# --- Verify results -----------------------------------------------------------

echo ""
echo "=== User-scope settings.json ==="
if [[ ! -f "$CLAUDE_CONFIG_DIR/settings.json" ]]; then
  echo "FAIL: $CLAUDE_CONFIG_DIR/settings.json was not created"
  exit 1
fi
cat "$CLAUDE_CONFIG_DIR/settings.json"

echo ""
echo "=== Project-scope settings.json ==="
if [[ ! -f "$PROJECT_DIR/.claude/settings.json" ]]; then
  echo "FAIL: $PROJECT_DIR/.claude/settings.json was not created"
  exit 1
fi
cat "$PROJECT_DIR/.claude/settings.json"

echo ""
echo "=== Real ~/.claude untouched ==="
echo "CLAUDE_CONFIG_DIR pointed to: $CLAUDE_CONFIG_DIR"
