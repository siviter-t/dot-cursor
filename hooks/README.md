# Hooks

This directory contains Cursor Agent hooks that run automatically at specific points in the development workflow. Hooks are shell scripts (`.sh` files) that process JSON input and output permission responses.

## Hooks

### audit.sh

Logs all hook payloads to `/tmp/agent-audit.log` for debugging and auditing purposes. Timestamps each entry for easier analysis of agent behavior over time.

**Example usage:** The audit hook runs automatically on every hook trigger, creating a comprehensive log of all agent interactions that can be reviewed for debugging or security auditing.

### redact-secrets.sh

Detects and blocks access to files containing probable GitHub API tokens. Scans file content for patterns matching GitHub token formats (`ghp_`, `ghs_`, `gh_api_`) and denies read access if detected.

**Example usage:** This hook prevents accidental exposure of GitHub tokens by automatically detecting them in file reads and denying access, protecting sensitive credentials from being included in agent context.
