#!/usr/bin/env bash
# statusLine OPT-IN (non installata d'ufficio: vedi README § "Stato live del flow").
# Footer live con la source/task del flow otto attivo. Riceve il JSON di sessione su
# stdin (lo ignora: lo stato viene dal .flow/ del repo). Stampa una riga; vuota se
# nessun flow vivo. Costo trascurabile, refresh gestito da CC (refreshInterval).
set -uo pipefail
cat >/dev/null 2>&1 || true                      # drena lo stdin di CC, non lo usa

[ -d .flow/sources ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

FLOW_TTL=300
_mtime() { stat -f%m "$1" 2>/dev/null || stat -c%Y "$1" 2>/dev/null; }
now=$(date +%s)

for prog in .flow/sources/*/PROGRESS.json; do
  [ -f "$prog" ] || continue
  s=$(basename "$(dirname "$prog")")
  hb=".flow/locks/$s/heartbeat.ts"
  [ -f "$hb" ] || continue
  ts=$(_mtime "$hb"); [ -n "$ts" ] || continue
  [ $((now - ts)) -lt "$FLOW_TTL" ] || continue
  task=$(jq -r '.current_task // "—"' "$prog" 2>/dev/null)
  done_n=$(jq -r '[.tasks[]?|select(.state=="done")]|length' "$prog" 2>/dev/null)
  tot_n=$(jq -r '.tasks|length' "$prog" 2>/dev/null)
  printf '⚙ otto:flow · %s · %s · %s/%s done\n' "$s" "$task" "${done_n:-?}" "${tot_n:-?}"
  exit 0
done
exit 0
