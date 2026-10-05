#!/usr/bin/env bash
# Usage: casks.sh <check|fix> <cask file>... Runs brew style on the casks, then, for check,
# brew audit. Both read the casks of a tapped tap by name, so the checkout is tapped under
# a name of its own for the run and untapped after: the installed fundrivendev/tap stays
# untouched, and brew style applies its cask rules wherever the checkout lives.
set -euo pipefail

mode=$1
shift
command -v brew >/dev/null || { echo "the casks need Homebrew (brew), which is not on PATH" >&2; exit 1; }
export HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_ENV_HINTS=1 HOMEBREW_NO_ANALYTICS=1

user="fundrivendev-check-$$"
taps="$(brew --repository)/Library/Taps"
trap 'rm -rf "${taps:?}/$user"' EXIT
mkdir -p "$taps/$user"
ln -s "$PWD" "$taps/$user/homebrew-tap"
names=()
for f in "$@"; do names+=("$user/tap/$(basename "$f" .rb)"); done

case "$mode" in
    fix) brew style --fix --cask "${names[@]}" ;;
    check)
        brew style --cask "${names[@]}"
        # --online fetches each archive: its url must answer and its sha256 must match. The
        # livecheck audits are left out: every cask of the tap releases from this one
        # repository, so GitHub's latest release is some other cask's.
        brew audit --cask --strict --online \
            --except=livecheck_version,hosting_with_livecheck,livecheck_https_availability \
            "${names[@]}"
        ;;
    *) echo "unknown mode $mode: check or fix" >&2; exit 2 ;;
esac
