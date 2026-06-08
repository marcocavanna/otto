#!/usr/bin/env bash
# PreToolUse (Write|Edit|Bash) — fail-closed scope guard per i subagent DEV e SOLO.
# Ogni errore (JSON malformato, file mancante, tool assente) → "ask", MAI allow.
#
# DESIGN: non usa flow_resolve_task / current_task — incompatibile con esecuzione parallela
# di più task (PROGRESS ha un solo current_task → con 002+006 in parallelo caricherebbe lo
# scope.txt sbagliato). Gate via scansione di TUTTI i scope.txt attivi in .flow/briefs/*/
# e di TUTTI i PROGRESS per-source (context-root whitelist del solo). Nessuna dipendenza
# da flow-lib.sh.
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

# Risale dagli antenati di un path ASSOLUTO fino alla prima dir che contiene `.flow/`:
# quella è la workspace root che possiede il file. Stdout: root (senza slash finale).
# Exit 1 se nessun antenato ha `.flow` (target fuori da ogni workspace → fail-closed).
find_wsroot() {
  local d
  d=$(dirname "$1")
  while :; do
    [ -d "$d/.flow" ] && { printf '%s\n' "$d"; return 0; }
    [ "$d" = "/" ] && return 1
    d=$(dirname "$d")
  done
}

TOOL=$(echo "$INPUT" | jq -r '.tool_name')

if [ "$TOOL" = "Bash" ]; then
  CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')
  # Rimuovi le redirezioni innocue PRIMA del check: scrivere su /dev/null o duplicare un fd
  # (2>&1) non è una scrittura su file. Evita falsi positivi su comandi read-only tipo
  # `find ... 2>/dev/null | head`.
  SAFE=$(printf '%s' "$CMD" | sed -E 's#&>>?[[:space:]]*/dev/null##g; s#[0-9]*>>?[[:space:]]*/dev/null##g; s#[0-9]*>&[0-9]##g')
  echo "$SAFE" | grep -qE '(>>?[^&]|tee|sed -i|cp |mv |dd |git (restore|checkout)|rm )' && ask "Bash con possibile scrittura → revisione manuale"
  allow
fi

FP=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
[ -n "$FP" ] || ask "tool_input senza file_path"

ABS=$(abspath "$FP") || ask "impossibile normalizzare il path (realpath -m e python3 assenti)"

# Ancora la workspace root al `.flow` ANTENATO del path target, NON a $pwd. La cwd del
# subagent dev/solo non è affidabile (monorepo, git root su sottocartella, sessione aperta
# sul parent → la cwd può essere il parent del workspace, dove `.flow` non esiste). Il gate
# deve essere cwd-independent: si risolve tutto rispetto al `.flow` che possiede davvero il
# file in scrittura. Da qui in poi REL è relativo a $WSROOT.
WSROOT=$(find_wsroot "$ABS") || ask "fuori workspace: nessun '.flow' antenato di $ABS"
REL=${ABS#"$WSROOT"/}

# Blocklist: stato orchestratore — mai scrivibile dal DEV/SOLO indipendentemente da scope.txt
case "$REL" in
  .flow/PROGRESS.json|\
  .flow/index.json|\
  .flow/sources/*|\
  .flow/locks/*)
    ask "path '$REL' è territorio dell'orchestratore (off-limits per dev/solo)"
    ;;
esac

# Service area: tutti i brief dir attivi sotto .flow/briefs/ sono sempre consentiti.
# Ogni agente (dev/solo) materializza scope.txt/frozen.txt/RESULT.json nel proprio brief
# PRIMA di toccare il codice → non c'è scope.txt ancora, non si può gateare. Consentire
# l'intera area .flow/briefs/ è safe: l'orchestratore è bloccato dalla blocklist sopra.
case "$REL" in
  .flow/briefs/*) allow ;;
esac

# Output contract nella context-root — SOLO per l'agente `solo`.
# L'agente scrive <context_root>/tasks/<id>.md (artefatto versionato) e fa append a
# technical-context.md (decisioni cumulative). NON sono codice → non passano da scope.txt.
# Scansiona TUTTI i PROGRESS per-source: compatibile con esecuzione parallela di più source.
case "$AGENT" in
  solo|*:solo)
    for prog in "$WSROOT"/.flow/sources/*/PROGRESS.json; do
      [ -f "$prog" ] || continue
      cr=$(jq -r '.context_root // empty' "$prog" 2>/dev/null) || continue
      [ -n "$cr" ] || continue
      cr="${cr%/}"
      case "$REL" in
        "$cr"/tasks/*.md|\
        "$cr"/technical-context.md) allow ;;
      esac
    done
    ;;
esac

# Gate principale: consenti se il path matcha QUALSIASI scope.txt attivo in .flow/briefs/*/.
# Scansione di tutti i brief → compatibile con esecuzione parallela di più task (es. 002+006
# simultane: il DEV della 006 ha i propri file in scope.txt della 006, indipendentemente da
# quale task PROGRESS.json segni come current_task).
# Se nessun scope.txt esiste → ask (nessun brief attivo).
FOUND_SCOPE=0
for scope_file in "$WSROOT"/.flow/briefs/*/scope.txt; do
  [ -f "$scope_file" ] || continue
  FOUND_SCOPE=1
  while IFS= read -r g; do
    [ -z "$g" ] && continue
    case "$REL" in $g) allow ;; esac
  done < "$scope_file"
done

[ "$FOUND_SCOPE" -eq 0 ] && ask "nessun scope.txt attivo trovato in .flow/briefs/"
ask "path '$REL' fuori da tutti gli scope.txt attivi"
