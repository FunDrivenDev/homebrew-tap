#!/usr/bin/env bash
set -euo pipefail

# The one result CI reports, from the results of the jobs it gathers
# (success, skipped, failure, cancelled). A skipped job is fine — the change
# did not need it; a failed or cancelled one fails the whole run.

failed=0
for result in "$@"; do
    case "$result" in
        success | skipped) ;;
        *)
            echo "a needed check ended in: $result"
            failed=1
            ;;
    esac
done

if [ "$failed" -eq 0 ]; then
    echo "every needed check passed ($*)"
fi
exit $failed
