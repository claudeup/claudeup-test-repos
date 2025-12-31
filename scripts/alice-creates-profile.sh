#!/usr/bin/env bash
# ABOUTME: Simulates Alice (team lead) creating team profiles for Go and React projects
# ABOUTME: Demonstrates the team lead workflow for claudeup profile sharing

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

# =============================================================================
# Main Script
# =============================================================================

cat <<'EOF'
╔════════════════════════════════════════════════════════════════╗
║        Alice Creates Team Profiles (Team Lead Workflow)        ║
╚════════════════════════════════════════════════════════════════╝

This simulation shows how Alice (team lead) sets up Claude Code
configurations that can be shared with the team via git.

EOF
pause

# Check claudeup is available
if ! command -v "$CLAUDEUP_BIN" &>/dev/null; then
    error "claudeup not found. Please install it first."
    exit 1
fi
success "Found claudeup: $(command -v "$CLAUDEUP_BIN")"

section "1. Go Backend API Project"

step "Alice navigates to the Go project"
cd "$GO_PROJECT"
info "Current directory: $(pwd)"
echo ""

step "Project structure:"
find . -type f \( -name "*.go" -o -name "go.mod" -o -name ".gitignore" \) | head -20
echo ""
pause

step "Alice reviews the existing team profile"
info "The profile was pre-created at .claudeup/profiles/backend-go.json"
echo ""
cat .claudeup/profiles/backend-go.json
echo ""
pause

step "Alice checks what plugins the profile specifies"
info "Plugins for Go backend development:"
info "  - tdd-workflows@claude-code-workflows"
info "  - backend-development@claude-code-workflows"
info "  - backend-api-security@claude-code-workflows"
echo ""

step "Alice verifies the profile with claudeup"
run_cmd "$CLAUDEUP_BIN" profile list || true
echo ""
pause

step "Alice checks the .claudeup.json project config"
cat .claudeup.json
echo ""
info "This file tells claudeup which profile to use for this project"
pause

section "2. React Frontend App Project"

step "Alice navigates to the React project"
cd "$REACT_PROJECT"
info "Current directory: $(pwd)"
echo ""

step "Project structure:"
find . -type f \( -name "*.tsx" -o -name "*.json" -o -name ".gitignore" \) 2>/dev/null | grep -v node_modules | head -20
echo ""
pause

step "Alice reviews the existing team profile"
info "The profile was pre-created at .claudeup/profiles/frontend-react.json"
echo ""
cat .claudeup/profiles/frontend-react.json
echo ""
pause

step "Alice checks what plugins the profile specifies"
info "Plugins for React frontend development:"
info "  - frontend-design@claude-code-workflows"
info "  - superpowers@superpowers-marketplace"
echo ""

step "Alice verifies the profile with claudeup"
run_cmd "$CLAUDEUP_BIN" profile list || true
echo ""
pause

section "3. Committing to Git"

step "Alice would commit these files to share with the team"
info "Files to commit:"
info "  .claudeup/profiles/<profile>.json  - Profile definition"
info "  .claudeup.json                     - Project config"
info "  .claude/settings.json              - Claude settings"
echo ""

info "Commands Alice would run:"
echo -e "${YELLOW}\$ git add .claudeup .claude .claudeup.json${NC}"
echo -e "${YELLOW}\$ git commit -m \"Add Claude Code team profile\"${NC}"
echo -e "${YELLOW}\$ git push${NC}"
echo ""
pause

section "Summary"

success "Alice has prepared team profiles for both projects!"
echo ""
info "Go Backend API:"
info "  Profile: backend-go"
info "  Plugins: tdd-workflows, backend-development, backend-api-security"
echo ""
info "React Frontend App:"
info "  Profile: frontend-react"
info "  Plugins: frontend-design, superpowers"
echo ""
info "Next step: Run bob-syncs-profile.sh to see how team members sync"
echo ""
