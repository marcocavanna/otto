#!/usr/bin/env bash
# PreToolUse (Write|Edit|Bash) — fail-closed scope guard per il subagent DEV.
# Ogni errore (JSON malformato, file mancante, tool assente) → "ask", MAI allow.
set -uo pipefail

INPUT=$(cat)

ask()   { jq -n --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"ask",permissionDecisionReason:$r}}'; exit 0; }
allow() { jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"allow"}}'; exit 0; }

command -v jq >/dev/null || { echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"jq mancante"}}'; exit 0; }

# realpath -m portabile: BSD/macOS non supporta -m. Fallback su python3. Fail-closed.
abspath() {
  if command -v realpath >/dev/null 2>&1 && realpath -m / >/dev/null 2>&1; then
    realpath -m "$1"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' "$1"
  else
    return 1
  fi
}

TOOL=$(echo "$INPUT" | jq -r '.tool_name')

if [ "$TOOL" = "Bash" ]; then
  CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')
  echo "$CMD" | grep -qE '(>>?|tee|sed -i|cp |mv |dd |git (restore|checkout)|rm )' && ask "Bash con possibile scrittura → revisione manuale"
  allow
fi

TASK=$(jq -r '.current_task // empty' .flow/PROGRESS.json 2>/dev/null) || ask "PROGRESS.json illeggibile"
[ -n "$TASK" ] || ask "nessun task attivo"
SCOPE=".flow/briefs/$TASK/scope.txt"
[ -f "$SCOPE" ] || ask "scope.txt mancante per $TASK"

FP=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
[ -n "$FP" ] || ask "tool_input senza file_path"

ROOT=$(pwd -P) || ask "pwd fallita"
ABS=$(abspath "$FP") || ask "impossibile normalizzare il path (realpath -m e python3 assenti)"
case "$ABS" in "$ROOT"/*) REL=${ABS#"$ROOT"/} ;; *) ask "fuori repo: $ABS" ;; esac

while IFS= read -r g; do
  [ -z "$g" ] && continue
  case "$REL" in $g) allow;; esac
done < "$SCOPE"

ask "path '$REL' fuori da scope.txt"
