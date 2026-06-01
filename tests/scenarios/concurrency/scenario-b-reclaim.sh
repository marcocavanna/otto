#!/usr/bin/env bash
# scenario-b-reclaim.sh
#
# Scenario B: lock stantio viene reclamato da un secondo flow.
#
# Prerequisiti: bash 5, eseguire dalla root del repo otto.
# Risultato atteso: exit 0 = PASS.
#
# Note portabilità:
#   touch -t su macOS/BSD usa formato YYYYMMDDHHmm.SS
#   touch -d su Linux/GNU usa stringa leggibile ("10 minutes ago")
#
# Reference: skills/flow-run/references/concurrency.md § Reclaim

set -euo pipefail

RECLAIM_TTL=300
SLUG="source-stale"
LOCK_DIR=".flow/locks/$SLUG"
HB="$LOCK_DIR/heartbeat.ts"

# Wrapper portabile mtime (BSD/GNU) — da concurrency.md
mtime() { stat -f%m "$1" 2>/dev/null || stat -c%Y "$1" 2>/dev/null; }
now()   { date +%s; }

cleanup() {
  rm -rf "$LOCK_DIR"
}
trap cleanup EXIT

echo "=== Scenario B: stale lock reclaim ==="

mkdir -p "$LOCK_DIR"

# --- Simula lock stantio: mtime 10 min nel passato (oltre soglia 300s) ---
# Wrapper BSD/GNU per touch -t (forzare mtime nel passato)
stale_touch() {
  local target="$1"
  # BSD (macOS): touch -t YYYYMMDDHHmm.SS
  if date -v-10M +%Y%m%d%H%M.%S >/dev/null 2>&1; then
    touch -t "$(date -v-10M +%Y%m%d%H%M.%S)" "$target"
  else
    # GNU (Linux): date -d '10 minutes ago'
    touch -d "$(date -d '10 minutes ago' '+%Y-%m-%d %H:%M:%S')" "$target"
  fi
}

echo "1717000000" > "$HB"   # contenuto fittizio
stale_touch "$HB"

STALE_MTIME=$(mtime "$HB")
STALE_AGE=$(( $(now) - STALE_MTIME ))
echo "  mtime artificiale: ${STALE_MTIME}  age=${STALE_AGE}s (TTL=${RECLAIM_TTL}s)"

[ "$STALE_AGE" -ge "$RECLAIM_TTL" ] \
  || { echo "FAIL: touch non ha portato il mtime oltre soglia (age=${STALE_AGE}s < ${RECLAIM_TTL}s)"; exit 1; }

# --- Reclaim: algoritmo da concurrency.md § Reclaim ---
# rm -rf (rimuove dir + heartbeat.ts) poi mkdir
rm -rf "$LOCK_DIR"
mkdir "$LOCK_DIR"
date +%s > "$HB"

# --- Asserzioni ---
fail() { echo "FAIL: $1"; exit 1; }

[ -d "$LOCK_DIR" ] \
  || fail "lock dir assente dopo reclaim"
[ -f "$HB" ] \
  || fail "heartbeat.ts assente dopo reclaim"

NEW_MTIME=$(mtime "$HB")
NEW_AGE=$(( $(now) - NEW_MTIME ))
echo "  nuovo mtime: ${NEW_MTIME}  age=${NEW_AGE}s"

# Il nuovo heartbeat deve essere recente (entro 5s da now)
[ "$NEW_AGE" -le 5 ] \
  || fail "heartbeat dopo reclaim non è recente (age=${NEW_AGE}s > 5s)"

# Verifica semantica "source viva" dopo reclaim
[ "$NEW_AGE" -lt "$RECLAIM_TTL" ] \
  || fail "source non risulta viva dopo reclaim (age=${NEW_AGE}s >= TTL=${RECLAIM_TTL}s)"

echo "PASS: Scenario B — lock stantio reclamato correttamente"
