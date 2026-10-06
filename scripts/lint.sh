#!/usr/bin/env bash
# shellcheck disable=SC2086 # one argument per file: the tap's paths hold no space
# Usage: lint.sh <scope> [family]. Lints the files in scope, by family: shell (shellcheck),
# actions (actionlint, which also shellchecks the run: blocks) and casks (brew style, then
# brew audit, scripts/casks.sh). No family runs all three.
set -euo pipefail

scope=$1
family=${2:-}
case "$family" in
    "" | shell | actions | casks) ;;
    *) echo "unknown family $family: shell, actions or casks" >&2; exit 2 ;;
esac
want() { [[ -z "$family" || "$family" == "$1" ]]; }

if want shell; then
    files=$(scripts/files.sh "$scope" '^scripts/.*\.sh$')
    [[ -z "$files" ]] || shellcheck $files
fi

if want actions; then
    files=$(scripts/files.sh "$scope" '^\.github/workflows/.*\.ya?ml$')
    [[ -z "$files" ]] || actionlint $files
fi

if want casks; then
    files=$(scripts/files.sh "$scope" '^Casks/[^/]+\.rb$')
    [[ -z "$files" ]] || scripts/casks.sh check $files
fi
