#!/usr/bin/env bash
# Runs every harness test script and reports which ones failed.
# Usage: tools/harness/run-tests.sh [HARNESS_BINARY] [TEST...]
set -u
here="$(cd "$(dirname "$0")" && pwd)"
harness="${1:-$here/../../build-linux/tools/harness/RallyHarness}"
shift || true
tests=("$@")
[ ${#tests[@]} -eq 0 ] && tests=("$here"/tests/*.txt)

failed=()
for t in "${tests[@]}"; do
    if "$harness" "$t" > "/tmp/rallyharness-$(basename "$t" .txt).log" 2>&1; then
        echo "PASS  $(basename "$t")"
    else
        echo "FAIL  $(basename "$t")  (log: /tmp/rallyharness-$(basename "$t" .txt).log)"
        failed+=("$t")
    fi
done
echo "${#failed[@]} of ${#tests[@]} failed"
[ ${#failed[@]} -eq 0 ]
