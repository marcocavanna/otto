#!/usr/bin/env bash
# PreToolUse (Write|Edit|Bash) — fail-closed scope guard per il subagent DEV.
# Ogni errore (JSON malformato, file mancante, tool assente) → "ask", MAI allow.
set -uo pipefail

INPUT=$(cat)

ask()   { jq -n --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"ask",permissionDecisionReason:$r}}'; exit 0; }
allow() { jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"allow"}}'; exit 0; }

command -v jq >/dev/null || { echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"jq mancante"}}'; exit 0; }

# Hook registrato a livello plugin (il frontmatter `hooks` è ignorato per i plugin): gira
# sull'INTERA sessione. Il gate di scope vale SOLO per i subagent dev/solo. Per main thread /
# orchestratore / pm / altri subagent → allow (no-op). Default permissivo: non bloccare mai
# fuori dal contesto gated. `agent_type` può arrivare bare (`dev`) o scoped (`otto:dev`).
AGENT=$(echo "$INPUT" | jq -r '.agent_type // ""')
case "$AGENT" in
  dev|solo|*:dev|*:solo) ;;
  *) allow ;;
esac

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
  # Rimuovi le redirezioni innocue PRIMA del check: scrivere su /dev/null o duplicare un fd
  # (2>&1) non è una scrittura su file. Evita falsi positivi su comandi read-only tipo
  # `find ... 2>/dev/null | head` (scope-check ora gira davvero per dev/solo).
  SAFE=$(printf '%s' "$CMD" | sed -E 's#&>>?[[:space:]]*/dev/null##g; s#[0-9]*>>?[[:space:]]*/dev/null##g; s#[0-9]*>&[0-9]##g')
  echo "$SAFE" | grep -qE '(>>?[^&]|tee|sed -i|cp |mv |dd |git (restore|checkout)|rm )' && ask "Bash con possibile scrittura → revisione manuale"
  allow
fi

# Task attivo dalla source SOTTO LOCK (PROGRESS per-source; il .flow/PROGRESS.json radice è
# legacy e non più scritto dall'orchestratore). Vedi flow-lib.sh § flow_resolve_task.
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd) || ask "dirname fallita"
. "$SCRIPT_DIR/flow-lib.sh" 2>/dev/null || ask "flow-lib.sh non sourceabile"
TASK=$(flow_resolve_task); RC=$?
case "$RC" in
  0) ;;
  2) ask "più source attive sotto lock: task ambiguo, revisione manuale" ;;
  *) ask "nessun task attivo nella source sotto lock" ;;
esac
[ -n "$TASK" ] || ask "nessun task attivo"

FP=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
[ -n "$FP" ] || ask "tool_input senza file_path"

ROOT=$(pwd -P) || ask "pwd fallita"
ABS=$(abspath "$FP") || ask "impossibile normalizzare il path (realpath -m e python3 assenti)"
case "$ABS" in "$ROOT"/*) REL=${ABS#"$ROOT"/} ;; *) ask "fuori repo: $ABS" ;; esac

# Blocklist: stato orchestratore — mai scrivibile dal DEV indipendentemente da scope.txt
case "$REL" in
  .flow/PROGRESS.json|\
  .flow/index.json|\
  .flow/sources/*|\
  .flow/locks/*)
    ask "path '$REL' è territorio dell'orchestratore (off-limits per il DEV)"
    ;;
esac

# Service area del task: l'agente materializza i propri contratti (scope.txt/frozen.txt/
# brief) PRIMA di toccare il codice. Sempre consentita, anche se scope.txt non esiste
# ancora → evita il deadlock di bootstrap (un agente self-sufficient deve potersi scrivere
# il proprio scope). Il codice resta gated dallo scope.txt appena materializzato (sotto).
case "$REL" in
  ".flow/briefs/$TASK/"*) allow ;;
esac

# Output contract nella context-root — SOLO per l'agente `solo`: scrive il proprio artefatto
# versionato del task (<context_root>/tasks/<TASK>.md) e l'append a technical-context.md (step
# finalize). NON è codice, quindi non passa da scope.txt (come .flow/briefs/$TASK/). Il `dev`
# in team mode tocca solo codice (dev.md gli vieta technical-context.md) → resta gated, il
# guard non si indebolisce.
case "$AGENT" in
  solo|*:solo)
    CR=$(flow_context_root_for_task "$TASK" 2>/dev/null || true)
    if [ -n "$CR" ]; then
      case "$REL" in
        "$CR"/tasks/"$TASK".md|"$CR"/technical-context.md) allow ;;
      esac
    fi
    ;;
esac

SCOPE=".flow/briefs/$TASK/scope.txt"
[ -f "$SCOPE" ] || ask "scope.txt mancante per $TASK"

while IFS= read -r g; do
  [ -z "$g" ] && continue
  case "$REL" in $g) allow;; esac
done < "$SCOPE"

ask "path '$REL' fuori da scope.txt"
