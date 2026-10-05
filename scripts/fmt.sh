#!/usr/bin/env bash
# shellcheck disable=SC2086 # one argument per cask: their paths hold no space
# Usage: fmt.sh <scope>. Fixes the casks in scope with brew style --fix.
set -euo pipefail

casks=$(scripts/files.sh "$1" '^Casks/[^/]+\.rb$')
[[ -z "$casks" ]] || scripts/casks.sh fix $casks
