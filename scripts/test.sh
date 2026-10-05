#!/usr/bin/env bash
# Usage: test.sh <scope>. Runs the CI change classifier's tests when it is in scope.
set -euo pipefail

[[ -n "$(scripts/files.sh "$1" '^scripts/ci-changes')" ]] || exit 0
scripts/ci-changes.test.sh
