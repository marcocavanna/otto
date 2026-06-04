#!/usr/bin/env bash
# Helper condivisi dai flow hook. Solo da `source`, nessun side-effect all'atto del source.
# Single-source del protocollo lock/heartbeat: skills/flow-run/references/concurrency.md.
# Lo stato d'esecuzione vive in .flow/sources/<slug>/PROGRESS.json (per-source); il
# .flow/PROGRESS.json radice è legacy (vedi flow-run/SKILL.md § Principio di stato).

FLOW_RECLAIM_TTL=300   # secondi; DEVE combaciare con references/concurrency.md

# mtime portabile (BSD/macOS `-f%m` vs GNU `-c%Y`). Stampa epoch in secondi, o niente.
_flow_mtime() { stat -f%m "$1" 2>/dev/null || stat -c%Y "$1" 2>/dev/null; }
_flow_now()   { date +%s; }

# Risolve il task attivo dalla source SOTTO LOCK leggendo `current_task` dal PROGRESS
# per-source. Una source è candidata sse il suo lock (.flow/locks/<slug>/) esiste e il suo
# PROGRESS ha un `current_task` non vuoto. Tier preferito: lock VIVO (heartbeat fresco,
# semantica concurrency.md). Fallback: lock presente ma heartbeat stantio (task lungo senza
# transizioni dell'orchestratore, nessun reclaim) — la freschezza disambigua un flow vivo da
# un lock orfano nel caso di collisione comune.
#
# Stdout: TASK (se risolto univoco). Exit code:
#   0 = risolto univoco   1 = nessuna source attiva con task   2 = ambiguo (più di una)
flow_resolve_task() {
  local now prog slug task ts age
  local fresh_count=0 fresh_task="" any_count=0 any_task=""
  now=$(_flow_now)
  for prog in .flow/sources/*/PROGRESS.json; do
    [ -f "$prog" ] || continue                              # glob non espanso → skip
    slug=$(basename "$(dirname "$prog")")
    [ -d ".flow/locks/$slug" ] || continue                  # source non claimed → non attiva
    task=$(jq -r '.current_task // empty' "$prog" 2>/dev/null) || continue
    [ -n "$task" ] || continue
    any_count=$((any_count + 1)); any_task="$task"
    ts=$(_flow_mtime ".flow/locks/$slug/heartbeat.ts")
    if [ -n "$ts" ]; then
      age=$((now - ts))
      if [ "$age" -lt "$FLOW_RECLAIM_TTL" ]; then
        fresh_count=$((fresh_count + 1)); fresh_task="$task"
      fi
    fi
  done
  if [ "$fresh_count" -eq 1 ]; then printf '%s\n' "$fresh_task"; return 0; fi
  if [ "$fresh_count" -gt 1 ]; then return 2; fi
  # nessuna source fresca → fallback ai lock presenti
  if [ "$any_count" -eq 1 ]; then printf '%s\n' "$any_task"; return 0; fi
  [ "$any_count" -eq 0 ] && return 1 || return 2
}

# Emette il `context_root` (senza slash finale) della source il cui PROGRESS per-source ha
# current_task == $1. Vuoto + exit 1 se non risolvibile. Best-effort, usato da scope-check
# per consentire all'agente di scrivere il proprio artefatto versionato del task.
flow_context_root_for_task() {
  local task="$1" prog ct cr
  [ -n "$task" ] || return 1
  for prog in .flow/sources/*/PROGRESS.json; do
    [ -f "$prog" ] || continue
    ct=$(jq -r '.current_task // empty' "$prog" 2>/dev/null) || continue
    [ "$ct" = "$task" ] || continue
    cr=$(jq -r '.context_root // empty' "$prog" 2>/dev/null)
    [ -n "$cr" ] || return 1
    printf '%s\n' "${cr%/}"; return 0
  done
  return 1
}
