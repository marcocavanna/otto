#!/usr/bin/env bash
# SubagentStop — gate sul verify del DEV con retry bounded a 2.
# exit 0  = lascia chiudere il subagent.
# exit 2  = blocca lo Stop, stderr torna al subagent come istruzione (correggi e ri-verifica).
set -uo pipefail

# Hook registrato a livello plugin (il frontmatter `hooks` è ignorato per i plugin):
# SubagentStop scatta per QUALSIASI subagent. Gate POSITIVO: procede (e può bloccare con
# exit 2) SOLO se `agent_type` è dev/solo. Per pm / altri subagent / agent_type assente →
# exit 0 (fail-open): non blocca MAI un subagent che non scrive RESULT.json. Se agent_type
# non è fornito dalla piattaforma il gate degrada a no-op (come lo stato storico), mai un
# blocco errato. `agent_type` può arrivare bare (`dev`) o scoped (`otto:dev`).
INPUT=$(cat 2>/dev/null || echo "")
AGENT=$(printf '%s' "$INPUT" | jq -r '.agent_type // ""' 2>/dev/null || echo "")
case "$AGENT" in
  dev|solo|*:dev|*:solo) ;;
  *) exit 0 ;;
esac

# Task attivo dalla source SOTTO LOCK (PROGRESS per-source; il .flow/PROGRESS.json radice è
# legacy e non più scritto dall'orchestratore). Vedi flow-lib.sh § flow_resolve_task.
# Fail-open: se il task non è risolvibile univocamente, lascia chiudere lo Stop (exit 0).
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd) || exit 0
. "$SCRIPT_DIR/flow-lib.sh" 2>/dev/null || exit 0
TASK=$(flow_resolve_task) || exit 0
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
