#!/usr/bin/env bash
# Usage: audit.sh [scope]. `all` (the default): gitleaks over the whole history (.gitleaks.toml adds a home-path
# rule), then zizmor on the workflows and the action. `staged`: gitleaks on the git index alone, for the pre-commit
# hook. Run through `just audit`.
set -euo pipefail

case "${1:-all}" in
    staged) exec gitleaks git --staged --config .gitleaks.toml --redact --no-banner --log-level warn . ;;
    all) ;;
    *) echo "unknown scope $1: all or staged" >&2; exit 2 ;;
esac
gitleaks git --config .gitleaks.toml --redact --no-banner --log-level warn .
zizmor --quiet .
