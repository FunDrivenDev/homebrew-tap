#!/usr/bin/env bash
# Usage: casks.sh <check|fix> <cask or formula file>... Runs brew style on the casks
# (Casks/) and formulae (Formula/), then, for check, brew audit. Both read the casks of a tapped tap by name, so the checkout is tapped under
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
casks=() formulae=()
for f in "$@"; do
    case "$f" in
        Formula/*) formulae+=("$user/tap/$(basename "$f" .rb)") ;;
        *) casks+=("$user/tap/$(basename "$f" .rb)") ;;
    esac
done

# style and audit, once per kind present: --cask for the casks, --formula for the formulae.
each() {
    local cmd=$1
    shift
    if ((${#casks[@]})); then "$cmd" --cask "$@" "${casks[@]}"; fi
    if ((${#formulae[@]})); then "$cmd" --formula "$@" "${formulae[@]}"; fi
}
style() { brew style "$@"; }
audit() { brew audit "$@"; }

case "$mode" in
    fix) each style --fix ;;
    check)
        each style
        # --online fetches each archive: its url must answer and its sha256 must match. The
        # livecheck audits are left out: every cask of the tap releases from this one
        # repository, so GitHub's latest release is some other cask's.
        each audit --strict --online \
            --except=livecheck_version,hosting_with_livecheck,livecheck_https_availability
        ;;
    *) echo "unknown mode $mode: check or fix" >&2; exit 2 ;;
esac
