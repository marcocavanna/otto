#!/usr/bin/env bash
# SessionStart / UserPromptSubmit — rinomina la sessione CC quando un flow otto è vivo.
# Naming canonico: "otto:flow · <slug>[ · <task>]". No-op (exit 0, nessun output) se
# non c'è un flow vivo o mancano le dipendenze: non tocca mai il titolo in quel caso.
# Best-effort: il titolo riflette lo stato al momento del prompt/resume (vedi flow-naming
# in flow-run); per lo stato live continuo usa la statusLine (hooks/flow-statusline.sh).
set -uo pipefail

EVENT="${1:-UserPromptSubmit}"     # passato come arg dal registro hooks.json

# Fast-exit nei progetti non-otto (la stragrande maggioranza delle sessioni).
[ -d .flow/sources ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

FLOW_TTL=300   # secondi; combacia con references/concurrency.md
_mtime() { stat -f%m "$1" 2>/dev/null || stat -c%Y "$1" 2>/dev/null; }
now=$(date +%s)

slug=""; task=""
for prog in .flow/sources/*/PROGRESS.json; do
  [ -f "$prog" ] || continue
  s=$(basename "$(dirname "$prog")")
  hb=".flow/locks/$s/heartbeat.ts"
  [ -f "$hb" ] || continue                      # source non claimed → non viva
  ts=$(_mtime "$hb"); [ -n "$ts" ] || continue
  [ $((now - ts)) -lt "$FLOW_TTL" ] || continue # heartbeat stantio → non viva
  slug="$s"
  task=$(jq -r '.current_task // empty' "$prog" 2>/dev/null)
  break
done

[ -n "$slug" ] || exit 0                         # nessun flow vivo → titolo invariato

title="otto:flow · $slug"
[ -n "$task" ] && title="$title · $task"
seq=$(printf '\033]2;%s\007' "$title")           # OSC 2 — titolo tab terminale

jq -n --arg ev "$EVENT" --arg t "$title" --arg seq "$seq" \
  '{continue:true, terminalSequence:$seq, hookSpecificOutput:{hookEventName:$ev, sessionTitle:$t}}'
exit 0
