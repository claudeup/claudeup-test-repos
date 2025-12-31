# Go Backend API

Example Go API project demonstrating claudeup team workflows.

## Claude Code Setup

This project uses claudeup for team configuration management.

### First-time setup (after cloning)

```bash
claudeup profile sync
```

This installs the team's Claude Code plugins:
- `tdd-workflows` - Test-driven development practices
- `backend-development` - Backend coding patterns
- `backend-api-security` - API security guidelines

### Team profile

The team profile is stored in `.claudeup/profiles/backend-go.json` and tracked in git.

## Development

```bash
# Run the server
go run ./cmd/server

# Test endpoints
curl http://localhost:8080/health
curl http://localhost:8080/api/users
```
