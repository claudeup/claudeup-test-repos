#!/usr/bin/env bash
# ABOUTME: Simulates Bob (team member) syncing team profiles after cloning
# ABOUTME: Verifies plugins are actually installed in a clean environment

set -euo pipefail

# =============================================================================
# Colors
# =============================================================================

if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN='' BOLD='' NC=''
fi

# =============================================================================
# Helpers
# =============================================================================

section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}┃${NC} ${BOLD}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

step() { echo -e "${MAGENTA}→${NC} $1"; }
info() { echo -e "${CYAN}ℹ${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
success() { echo -e "${GREEN}✔${NC} $1"; }
error() { echo -e "${RED}✖${NC} $1" >&2; }

run_cmd() {
    echo -e "${YELLOW}\$ $*${NC}"
    "$@"
}

pause() {
    if [[ "${NON_INTERACTIVE:-false}" != "true" ]]; then
        echo ""
        read -r -p "Press ENTER to continue..."
        echo ""
    fi
}

# =============================================================================
# Configuration
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
GO_PROJECT="$REPO_ROOT/go-backend-api"
REACT_PROJECT="$REPO_ROOT/react-frontend-app"
CLAUDEUP_BIN="${CLAUDEUP_BIN:-claudeup}"

# Track test results
TESTS_PASSED=0
TESTS_FAILED=0

# Create isolated temp environment
TEMP_DIR=""

setup_temp_env() {
    TEMP_DIR=$(mktemp -d "/tmp/bob-sync-test-XXXXXXXXXX")

    # Set up isolated Claude environment for Bob
    export CLAUDE_CONFIG_DIR="$TEMP_DIR/.claude"
    export CLAUDEUP_HOME="$TEMP_DIR/.claudeup"

    mkdir -p "$CLAUDE_CONFIG_DIR/plugins"
    mkdir -p "$CLAUDEUP_HOME/profiles"

    info "Created isolated environment: $TEMP_DIR"
}

cleanup_temp_env() {
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        case "$TEMP_DIR" in
            /tmp/bob-sync-test-*)
                rm -rf "$TEMP_DIR"
                success "Cleaned up temp environment"
                ;;
        esac
    fi
}

# Cleanup on exit (success or failure)
trap cleanup_temp_env EXIT

# Verify a plugin is installed
verify_plugin_installed() {
    local plugin_name="$1"
    local installed_plugins_file="$CLAUDE_CONFIG_DIR/plugins/installed_plugins.json"

    if [[ ! -f "$installed_plugins_file" ]]; then
        error "installed_plugins.json not found"
        return 1
    fi

    if grep -q "\"$plugin_name\"" "$installed_plugins_file"; then
        success "Plugin installed: $plugin_name"
        return 0
    else
        error "Plugin NOT installed: $plugin_name"
        return 1
    fi
}

# Verify plugin count
verify_plugin_count() {
    local expected="$1"
    local installed_plugins_file="$CLAUDE_CONFIG_DIR/plugins/installed_plugins.json"

    if [[ ! -f "$installed_plugins_file" ]]; then
        error "installed_plugins.json not found"
        return 1
    fi

    # Count plugin entries (look for scope field which appears once per installation)
    local actual
    actual=$(grep -c '"scope":' "$installed_plugins_file" 2>/dev/null || echo "0")

    if [[ "$actual" -ge "$expected" ]]; then
        success "Plugin count: $actual (expected at least $expected)"
        return 0
    else
        error "Plugin count: $actual (expected at least $expected)"
        return 1
    fi
}

# =============================================================================
# Main Script
# =============================================================================

cat <<'EOF'
╔════════════════════════════════════════════════════════════════╗
║         Bob Syncs Team Profiles (Team Member Workflow)         ║
╚════════════════════════════════════════════════════════════════╝

This test verifies that a new team member can sync Claude Code
configurations from a project using claudeup profile sync.

EOF
pause

# Check claudeup is available
if ! command -v "$CLAUDEUP_BIN" &>/dev/null; then
    error "claudeup not found. Please install it first."
    exit 1
fi
success "Found claudeup: $(command -v "$CLAUDEUP_BIN")"

section "0. Setup Clean Environment"

step "Creating isolated Claude environment (simulating fresh machine)"
setup_temp_env
echo ""
info "HOME=$HOME"
info "CLAUDE_CONFIG_DIR=$CLAUDE_CONFIG_DIR"
info "CLAUDEUP_HOME=$CLAUDEUP_HOME"
pause

step "Verify no plugins installed initially"
run_cmd "$CLAUDEUP_BIN" plugin list
echo ""
pause

section "1. Test Go Backend Project Sync"

step "Navigate to Go project"
cd "$GO_PROJECT"
info "Current directory: $(pwd)"
echo ""

step "Show project config"
cat .claudeup.json
echo ""
pause

step "Run 'claudeup profile sync'"
if run_cmd "$CLAUDEUP_BIN" profile sync; then
    success "Sync completed successfully"
else
    error "Sync failed!"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
echo ""
pause

step "Verify plugins were installed"
echo ""

# Expected Go plugins
GO_PLUGINS=(
    "tdd-workflows@claude-code-workflows"
    "backend-development@claude-code-workflows"
    "backend-api-security@claude-code-workflows"
)

for plugin in "${GO_PLUGINS[@]}"; do
    if verify_plugin_installed "$plugin"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
done
echo ""

step "Show installed plugins"
run_cmd "$CLAUDEUP_BIN" plugin list
echo ""
pause

section "2. Test React Frontend Project Sync"

step "Navigate to React project"
cd "$REACT_PROJECT"
info "Current directory: $(pwd)"
echo ""

step "Show project config"
cat .claudeup.json
echo ""
pause

step "Run 'claudeup profile sync'"
if run_cmd "$CLAUDEUP_BIN" profile sync; then
    success "Sync completed successfully"
else
    error "Sync failed!"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
echo ""
pause

step "Verify plugins were installed"
echo ""

# Expected React plugins
REACT_PLUGINS=(
    "frontend-design@claude-plugins-official"
    "ralph-wiggum@claude-plugins-official"
    "superpowers@superpowers-marketplace"
)

for plugin in "${REACT_PLUGINS[@]}"; do
    if verify_plugin_installed "$plugin"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
done
echo ""

step "Show all installed plugins"
run_cmd "$CLAUDEUP_BIN" plugin list
echo ""
pause

section "3. Test Results"

echo ""
if [[ $TESTS_FAILED -eq 0 ]]; then
    success "All tests passed! ($TESTS_PASSED passed, $TESTS_FAILED failed)"
    echo ""
    info "The team workflow is working correctly:"
    info "  • Profiles are detected from project .claudeup/profiles/"
    info "  • Sync installs marketplaces and plugins"
    info "  • New team members can onboard with one command"
else
    error "Some tests failed! ($TESTS_PASSED passed, $TESTS_FAILED failed)"
    echo ""
    error "Check the output above for details."
    exit 1
fi
echo ""

section "Cleanup"

# Cleanup happens automatically via trap
success "Test complete!"
