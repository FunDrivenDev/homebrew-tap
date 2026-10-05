#!/usr/bin/env bash
set -euo pipefail

# Tests scripts/ci-changes.sh: one case per kind of path, docs only, an unknown path and a
# run without a base. Each case commits its files in a scratch repository and checks the
# answer against the base commit.

classifier="$(cd "$(dirname "$0")" && pwd)/ci-changes.sh"
# A git hook (pre-push) exports GIT_DIR and the like, which would point the scratch
# repositories' git commands back at this one.
# shellcheck disable=SC2046 # one variable name per word
unset $(git rev-parse --local-env-vars)
failures=0

# expect <name> <expected answer, flags joined by spaces> <path>...
expect() {
    local name=$1 want=$2 repo got
    shift 2
    repo=$(mktemp -d)
    git -C "$repo" init --quiet
    git -C "$repo" -c user.name=t -c user.email=t@example.com -c commit.gpgsign=false commit --quiet --allow-empty -m base
    for path in "$@"; do
        mkdir -p "$repo/$(dirname "$path")"
        echo x >"$repo/$path"
    done
    git -C "$repo" add --all
    git -C "$repo" -c user.name=t -c user.email=t@example.com -c commit.gpgsign=false commit --quiet -m change
    got=$(cd "$repo" && GITHUB_OUTPUT='' GITHUB_STEP_SUMMARY='' "$classifier" HEAD^1 | tr '\n' ' ')
    rm -rf "$repo"
    if [ "$got" = "$want " ]; then
        echo "ok    $name"
    else
        echo "FAIL  $name: want '$want', got '$got'"
        failures=$((failures + 1))
    fi
}

expect "docs only" "lint=false casks=false" README.md LICENSE Casks/.gitkeep renovate.json
expect "a cask" "lint=false casks=true" Casks/memo.rb
expect "cask renames" "lint=false casks=true" cask_renames.json
expect "a cask and docs" "lint=false casks=true" Casks/memo.rb README.md
expect "a workflow" "lint=true casks=true" .github/workflows/ci.yml
expect "the composite action" "lint=true casks=true" .github/actions/publish-cask/action.yml
expect "the toolchain" "lint=true casks=true" mise.toml
expect "a CI script" "lint=true casks=true" scripts/ci-verdict.sh
expect "another script" "lint=true casks=false" scripts/lint.sh
expect "an unknown path" "lint=true casks=true" Formula/thing.rb

got=$(GITHUB_OUTPUT='' GITHUB_STEP_SUMMARY='' "$classifier" | tr '\n' ' ')
if [ "$got" = "lint=true casks=true " ]; then
    echo "ok    no base"
else
    echo "FAIL  no base: got '$got'"
    failures=$((failures + 1))
fi

[ "$failures" -eq 0 ]
