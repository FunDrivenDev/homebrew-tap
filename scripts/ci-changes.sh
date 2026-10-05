#!/usr/bin/env bash
set -euo pipefail

# Sorts the files a change touches by kind and says which CI checks it needs (README.md,
# Checks). With a base ref, the change is base...HEAD; without one (a push to main, a
# manual or weekly run), everything runs.
#
#   kind       paths                                              checks
#   docs       *.md, LICENSE, Casks/.gitkeep, .claude/,           none
#              .gitignore, renovate.json
#   casks      Casks/*.rb, cask_renames.json, tap_migrations.json casks
#   ci         .github/                                           everything
#   tooling    mise.toml, mise.lock, Justfile, hk.pkl, .actrc,    everything
#              .gitleaks.toml, scripts/ci-*
#   tooling    other scripts/                                     lint
#   unknown    anything else                                      everything
#
# The audit job runs whatever changed. Answers as key=value lines (lint, casks), appended
# to $GITHUB_OUTPUT when set, and as a table in $GITHUB_STEP_SUMMARY.

base="${1:-}"

lint=false casks=false
everything() { lint=true casks=true; }

rows=""
row() { rows="${rows}| \`$1\` | $2 | $3 |"$'\n'; }

if [ -z "$base" ]; then
    everything
    row "(all files)" "full run" "everything"
else
    files="$(git diff --name-only "$base"...HEAD)"
    while IFS= read -r file; do
        [ -n "$file" ] || continue
        case "$file" in
            *.md | LICENSE | Casks/.gitkeep | .claude/* | .gitignore | renovate.json)
                row "$file" docs "none" ;;
            Casks/*.rb | cask_renames.json | tap_migrations.json)
                casks=true
                row "$file" casks "casks" ;;
            .github/*)
                everything
                row "$file" ci "everything" ;;
            mise.toml | mise.lock | Justfile | hk.pkl | .actrc | .gitleaks.toml | scripts/ci-*)
                everything
                row "$file" tooling "everything" ;;
            scripts/*)
                lint=true
                row "$file" tooling "lint" ;;
            *)
                everything
                row "$file" unknown "everything" ;;
        esac
    done <<<"$files"
fi

answer="lint=$lint
casks=$casks"

echo "$answer"
if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "$answer" >>"$GITHUB_OUTPUT"
fi
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
    {
        echo "### Changed files by kind"
        echo
        echo "| file | kind | checks |"
        echo "| --- | --- | --- |"
        printf '%s' "$rows"
        echo
        echo "Checks that run: lint=$lint, casks=$casks"
    } >>"$GITHUB_STEP_SUMMARY"
fi
