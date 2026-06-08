#!/usr/bin/env bash
# Helper condivisi dai flow hook. Solo da `source`, nessun side-effect all'atto del source.
# Single-source del protocollo lock/heartbeat: skills/flow-run/references/concurrency.md.
# Lo stato d'esecuzione vive in .flow/sources/<slug>/PROGRESS.json (per-source); il
# .flow/PROGRESS.json radice è legacy (vedi flow-run/SKILL.md § Principio di stato).

FLOW_RECLAIM_TTL=300   # secondi; DEVE combaciare con references/concurrency.md

# mtime portabile (BSD/macOS `-f%m` vs GNU `-c%Y`). Stampa epoch in secondi, o niente.
_flow_mtime() { stat -f%m "$1" 2>/dev/null || stat -c%Y "$1" 2>/dev/null; }
_flow_now()   { date +%s; }

# Workspace root candidate (dir che contengono `.flow/sources`), cwd-INDEPENDENT.
# La cwd di un hook/subagent non è affidabile: in un monorepo la sessione può girare dal
# parent mentre il workspace otto (`.flow`) vive in una sottocartella (es. GeoStore/ con
# GeoStore.Api/.flow/). Ancorare a `pwd` rompe ogni glob `.flow/**`.
#
# Priorità (la prima che è un workspace VINCE, in isolamento → niente bleed cross-workspace):
#   1. $CLAUDE_PROJECT_DIR — la root di progetto autoritativa secondo CC.
#   2. la cwd — la sessione è ancorata direttamente al workspace.
#   3. fallback monorepo: la sessione gira dal parent → scandisci le sottocartelle immediate
#      (qui sì possono emergere più root: se più sibling hanno un flow attivo l'ambiguità è
#      reale e la gestisce flow_resolve_task con exit 2 → fail-open lato consumer).
# Stdout: path ASSOLUTI canonici, uno per riga.
flow_roots() {
  local d abs seen="|"
  if [ -n "${CLAUDE_PROJECT_DIR:-}" ] && [ -d "$CLAUDE_PROJECT_DIR/.flow/sources" ]; then
    (cd "$CLAUDE_PROJECT_DIR" 2>/dev/null && pwd -P) && return 0
  fi
  if [ -d "./.flow/sources" ]; then
    pwd -P && return 0
  fi
  for d in */; do                                           # solo se cwd NON è un workspace
    [ -d "$d/.flow/sources" ] || continue
    abs=$(cd "$d" 2>/dev/null && pwd -P) || continue        # canonicalizza + risolve symlink
    case "$seen" in *"|$abs|"*) continue ;; esac            # dedup
    seen="$seen$abs|"
    printf '%s\n' "$abs"
  done
}

# Risolve il task attivo dalla source SOTTO LOCK leggendo `current_task` dal PROGRESS
# per-source. Scansiona TUTTE le workspace root (flow_roots) → cwd-independent. Una source è
# candidata sse il suo lock (.flow/locks/<slug>/) esiste e il suo PROGRESS ha un `current_task`
# non vuoto. Tier preferito: lock VIVO (heartbeat fresco, semantica concurrency.md). Fallback:
# lock presente ma heartbeat stantio (task lungo senza transizioni dell'orchestratore, nessun
# reclaim) — la freschezza disambigua un flow vivo da un lock orfano nel caso di collisione.
#
# Stdout: "ROOT<TAB>TASK" (root assoluta del workspace + task) se risolto univoco. La root
# serve ai consumer per costruire path assoluti (es. .flow/briefs/<task>) indipendenti da cwd.
# Exit code: 0 = risolto univoco   1 = nessuna source attiva con task   2 = ambiguo (>1).
flow_resolve_task() {
  local now root prog slug task ts age
  local fresh_count=0 fresh="" any_count=0 any=""
  now=$(_flow_now)
  while IFS= read -r root; do
    [ -n "$root" ] || continue
    for prog in "$root"/.flow/sources/*/PROGRESS.json; do
      [ -f "$prog" ] || continue                            # glob non espanso → skip
      slug=$(basename "$(dirname "$prog")")
      [ -d "$root/.flow/locks/$slug" ] || continue          # source non claimed → non attiva
      task=$(jq -r '.current_task // empty' "$prog" 2>/dev/null) || continue
      [ -n "$task" ] || continue
      any_count=$((any_count + 1)); any="$root	$task"
      ts=$(_flow_mtime "$root/.flow/locks/$slug/heartbeat.ts")
      if [ -n "$ts" ]; then
        age=$((now - ts))
        if [ "$age" -lt "$FLOW_RECLAIM_TTL" ]; then
          fresh_count=$((fresh_count + 1)); fresh="$root	$task"
        fi
      fi
    done
  done < <(flow_roots)
  if [ "$fresh_count" -eq 1 ]; then printf '%s\n' "$fresh"; return 0; fi
  if [ "$fresh_count" -gt 1 ]; then return 2; fi
  # nessuna source fresca → fallback ai lock presenti
  if [ "$any_count" -eq 1 ]; then printf '%s\n' "$any"; return 0; fi
  [ "$any_count" -eq 0 ] && return 1 || return 2
}

# Emette il `context_root` (senza slash finale) della source il cui PROGRESS per-source ha
# current_task == $1, scansionando tutte le workspace root (cwd-independent). Vuoto + exit 1
# se non risolvibile. Best-effort.
flow_context_root_for_task() {
  local task="$1" root prog ct cr
  [ -n "$task" ] || return 1
  while IFS= read -r root; do
    [ -n "$root" ] || continue
    for prog in "$root"/.flow/sources/*/PROGRESS.json; do
      [ -f "$prog" ] || continue
      ct=$(jq -r '.current_task // empty' "$prog" 2>/dev/null) || continue
      [ "$ct" = "$task" ] || continue
      cr=$(jq -r '.context_root // empty' "$prog" 2>/dev/null)
      [ -n "$cr" ] || return 1
      printf '%s\n' "${cr%/}"; return 0
    done
  done < <(flow_roots)
  return 1
}
