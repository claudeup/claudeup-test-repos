# React Frontend App

Example React application demonstrating claudeup team workflows.

## Claude Code Setup

This project uses claudeup for team configuration management.

### First-time setup (after cloning)

```bash
claudeup profile sync
```

This installs the team's Claude Code plugins:
- `frontend-design` - UI/UX design patterns and best practices
- `superpowers` - Enhanced Claude Code capabilities

### Team profile

The team profile is stored in `.claudeup/profiles/frontend-react.json` and tracked in git.

## Development

```bash
# Install dependencies
npm install

# Start dev server
npm run dev

# Build for production
npm run build
```
