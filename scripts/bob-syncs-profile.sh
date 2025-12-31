#!/usr/bin/env bash
# ABOUTME: Simulates Bob (team member) syncing team profiles after cloning
# ABOUTME: Demonstrates the team member workflow for claudeup profile sharing

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

# Create isolated temp environment
TEMP_DIR=""
TEMP_CLAUDE_HOME=""

setup_temp_env() {
    TEMP_DIR=$(mktemp -d "/tmp/bob-sync-test-XXXXXXXXXX")
    TEMP_CLAUDE_HOME="$TEMP_DIR/.claude"

    # Set up isolated Claude environment for Bob
    export HOME="$TEMP_DIR"
    export CLAUDE_CONFIG_DIR="$TEMP_CLAUDE_HOME"
    export CLAUDEUP_HOME="$TEMP_DIR/.claudeup"

    mkdir -p "$TEMP_CLAUDE_HOME/plugins"
    mkdir -p "$TEMP_DIR/.claudeup/profiles"

    info "Created isolated environment for Bob: $TEMP_DIR"
}

cleanup_temp_env() {
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        case "$TEMP_DIR" in
            /tmp/bob-sync-test-*)
                rm -rf "$TEMP_DIR"
                success "Cleaned up Bob's temp environment"
                ;;
        esac
    fi
}

# =============================================================================
# Main Script
# =============================================================================

cat <<'EOF'
╔════════════════════════════════════════════════════════════════╗
║         Bob Syncs Team Profiles (Team Member Workflow)         ║
╚════════════════════════════════════════════════════════════════╝

This simulation shows how Bob (a new team member) syncs Claude Code
configurations after cloning a project.

EOF
pause

# Check claudeup is available
if ! command -v "$CLAUDEUP_BIN" &>/dev/null; then
    error "claudeup not found. Please install it first."
    exit 1
fi
success "Found claudeup: $(command -v "$CLAUDEUP_BIN")"

section "0. Setup Isolated Environment"

step "Creating isolated Claude environment for Bob"
info "This simulates Bob having a fresh machine without plugins installed"
setup_temp_env
echo ""
info "CLAUDE_CONFIG_DIR=$CLAUDE_CONFIG_DIR"
info "CLAUDEUP_HOME=$CLAUDEUP_HOME"
pause

section "1. Bob Clones and Syncs Go Project"

step "Bob 'clones' the Go backend project"
info "(Simulated - project already exists at $GO_PROJECT)"
cd "$GO_PROJECT"
info "Current directory: $(pwd)"
echo ""

step "Bob sees the .claudeup.json and knows to run sync"
cat .claudeup.json
echo ""
pause

step "Bob checks what plugins he currently has installed"
info "Bob's current Claude plugins (should be empty):"
run_cmd "$CLAUDEUP_BIN" plugin list 2>&1 || info "(No plugins installed yet)"
echo ""
pause

step "Bob runs 'claudeup profile sync' to get team config"
info "This reads .claudeup.json and installs the team's plugins"
echo ""
run_cmd "$CLAUDEUP_BIN" profile sync 2>&1 || {
    warn "Sync may have encountered issues (expected in test env)"
    info "In a real scenario, this would install:"
    info "  - tdd-workflows@claude-code-workflows"
    info "  - backend-development@claude-code-workflows"
    info "  - backend-api-security@claude-code-workflows"
}
echo ""
pause

step "Bob verifies the profile is now active"
run_cmd "$CLAUDEUP_BIN" profile list 2>&1 || true
echo ""
pause

section "2. Bob Clones and Syncs React Project"

step "Bob 'clones' the React frontend project"
cd "$REACT_PROJECT"
info "Current directory: $(pwd)"
echo ""

step "Bob sees the .claudeup.json"
cat .claudeup.json
echo ""
pause

step "Bob runs sync for the React project"
run_cmd "$CLAUDEUP_BIN" profile sync 2>&1 || {
    warn "Sync may have encountered issues (expected in test env)"
    info "In a real scenario, this would install:"
    info "  - frontend-design@claude-code-workflows"
    info "  - superpowers@superpowers-marketplace"
}
echo ""
pause

step "Bob verifies the React profile is active"
run_cmd "$CLAUDEUP_BIN" profile list 2>&1 || true
echo ""
pause

section "3. Bob's Workflow Summary"

success "Bob has synced both team profiles!"
echo ""
info "Go Backend API workflow:"
echo -e "  ${YELLOW}\$ git clone <repo>${NC}"
echo -e "  ${YELLOW}\$ cd go-backend-api${NC}"
echo -e "  ${YELLOW}\$ claudeup profile sync${NC}"
echo -e "  ${GREEN}✔ Team plugins installed automatically${NC}"
echo ""
info "React Frontend App workflow:"
echo -e "  ${YELLOW}\$ git clone <repo>${NC}"
echo -e "  ${YELLOW}\$ cd react-frontend-app${NC}"
echo -e "  ${YELLOW}\$ claudeup profile sync${NC}"
echo -e "  ${GREEN}✔ Team plugins installed automatically${NC}"
echo ""
pause

section "4. Key Benefits"

info "For Bob (team member):"
info "  • One command to get the team's Claude setup"
info "  • No manual plugin installation"
info "  • Always in sync with team standards"
echo ""
info "For Alice (team lead):"
info "  • Define Claude config once, share via git"
info "  • New team members onboard instantly"
info "  • Updates propagate with 'git pull && claudeup profile sync'"
echo ""

section "Cleanup"

step "Cleaning up Bob's isolated environment"
cleanup_temp_env
echo ""
success "Simulation complete!"
