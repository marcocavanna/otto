#!/usr/bin/env bash
# SubagentStop — gate sul verify del DEV con retry bounded a 2.
# exit 0  = lascia chiudere il subagent.
# exit 2  = blocca lo Stop, stderr torna al subagent come istruzione (correggi e ri-verifica).
set -uo pipefail

TASK=$(jq -r '.current_task // empty' .flow/PROGRESS.json 2>/dev/null) || exit 0
[ -n "$TASK" ] || exit 0

DIR=".flow/briefs/$TASK"; R="$DIR/RESULT.json"; C="$DIR/retries"

[ -f "$R" ] || { echo "RESULT.json mancante: esegui verify e scrivilo" >&2; exit 2; }

V=$(jq -r '.verify // "fail"' "$R")
[ "$V" = "pass" ] && exit 0

N=$(cat "$C" 2>/dev/null || echo 0); N=$((N+1)); echo "$N" > "$C"
if [ "$N" -le 2 ]; then echo "verify=fail (tentativo $N/2): correggi e ri-verifica" >&2; exit 2; fi

# esauriti i retry → marca escalate e lascia chiudere
jq '.escalate=true' "$R" > "$R.tmp" && mv "$R.tmp" "$R"
exit 0
