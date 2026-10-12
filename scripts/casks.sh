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
casks=() formulae=() linux_formulae=()
for f in "$@"; do
    case "$f" in
        Formula/*)
            # A Linux-only formula has no url on macOS, so it is audited as on Linux.
            if grep -q '^  depends_on :linux' "$f"; then
                linux_formulae+=("$user/tap/$(basename "$f" .rb)")
            else
                formulae+=("$user/tap/$(basename "$f" .rb)")
            fi
            ;;
        *) casks+=("$user/tap/$(basename "$f" .rb)") ;;
    esac
done

# style and audit, once per kind present: --cask for the casks, --formula for the formulae.
each() {
    local cmd=$1
    shift
    if ((${#casks[@]})); then "$cmd" --cask "$@" "${casks[@]}"; fi
    if ((${#formulae[@]})); then "$cmd" --formula "$@" "${formulae[@]}"; fi
    if ((${#linux_formulae[@]})); then
        if [[ $cmd == audit && $(uname -s) == Darwin ]]; then
            linux_online "${linux_formulae[@]}"
        else
            "$cmd" --formula "$@" "${linux_formulae[@]}"
        fi
    fi
}
style() { brew style "$@"; }
# brew audit cannot load a Linux-only formula on macOS (it has no url there), so on
# macOS each of its url/sha256 pairs is checked as --online would: the archive must
# download and match.
linux_online() {
    local name file url sum got
    for name in "$@"; do
        file="Formula/${name##*/}.rb"
        echo "$file: Linux-only, brew audit runs on Linux; checking its archives" >&2
        while read -r url sum; do
            url=${url//'#{version}'/$(sed -n 's/^  version "\(.*\)"/\1/p' "$file")}
            got=$(curl -fsSL "$url" | shasum -a 256 | cut -d' ' -f1)
            [[ $got == "$sum" ]] || { echo "$file: $url: sha256 $got, expected $sum" >&2; return 1; }
            echo "  ok $url" >&2
        done < <(awk '/^ *url "/{gsub(/"/,"",$2); u=$2} /^ *sha256 "/{gsub(/"/,"",$2); print u, $2}' "$file")
    done
}
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
