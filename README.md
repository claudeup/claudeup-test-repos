# claudeup Test Repos

Example repositories demonstrating claudeup team workflows for sharing Claude Code configurations.

## Overview

This repository contains two example projects that demonstrate how teams can share Claude Code configurations using claudeup:

| Project | Description | Team Profile |
|---------|-------------|--------------|
| `go-backend-api/` | Go HTTP API server | `backend-go` (TDD, backend dev, API security) |
| `react-frontend-app/` | React TypeScript app | `frontend-react` (frontend design, superpowers) |

## Quick Start

### Prerequisites

- claudeup installed (`go install github.com/claudeup/claudeup/cmd/claudeup@latest`)
- Claude Code CLI installed

### Run the Simulations

```bash
# See how a team lead (Alice) sets up profiles
./scripts/alice-creates-profile.sh

# See how a team member (Bob) syncs after cloning
./scripts/bob-syncs-profile.sh
```

## Team Workflow

### Alice (Team Lead) Creates Profiles

1. Configure Claude with the plugins your team needs
2. Save the configuration as a project profile:
   ```bash
   claudeup profile save backend-go --scope project
   ```
3. Commit to git:
   ```bash
   git add .claudeup .claude .claudeup.json
   git commit -m "Add Claude Code team profile"
   git push
   ```

### Bob (Team Member) Syncs

1. Clone the repository:
   ```bash
   git clone <repo-url>
   cd <project>
   ```
2. Sync Claude configuration:
   ```bash
   claudeup profile sync
   ```

## Project Structure

Each example project follows this structure:

```text
project/
├── .claudeup/
│   └── profiles/
│       └── <profile>.json    # Team profile definition
├── .claudeup.json            # Project config (which profile to use)
├── .claude/
│   └── settings.json         # Claude settings at project scope
├── .gitignore                # Excludes .claude/settings.local.json
└── src/                      # Project source code
```

## Files to Commit

| File | Purpose | Commit? |
|------|---------|---------|
| `.claudeup/profiles/` | Team profile definitions | Yes |
| `.claudeup.json` | Project configuration | Yes |
| `.claude/settings.json` | Project Claude settings | Yes |
| `.claude/settings.local.json` | Personal overrides | No (gitignore) |

## Scripts

| Script | Description |
|--------|-------------|
| `scripts/alice-creates-profile.sh` | Team lead workflow simulation |
| `scripts/bob-syncs-profile.sh` | Team member workflow simulation |

Set `NON_INTERACTIVE=true` to skip pauses:

```bash
NON_INTERACTIVE=true ./scripts/bob-syncs-profile.sh
```

## Profiles

### Go Backend (`backend-go`)

Plugins:
- `tdd-workflows@claude-code-workflows` - Test-driven development practices
- `backend-development@claude-code-workflows` - Backend coding patterns
- `backend-api-security@claude-code-workflows` - API security guidelines

### React Frontend (`frontend-react`)

Plugins:
- `frontend-design@claude-code-workflows` - UI/UX design patterns
- `superpowers@superpowers-marketplace` - Enhanced Claude capabilities
