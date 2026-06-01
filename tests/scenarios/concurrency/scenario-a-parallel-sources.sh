#!/usr/bin/env bash
# scenario-a-parallel-sources.sh
#
# Scenario A: due flow su source diverse non collidono.
#
# Prerequisiti: bash 5, eseguire dalla root del repo otto.
# Risultato atteso: exit 0 = PASS.
#
# Reference: skills/flow-run/references/concurrency.md

set -euo pipefail

FLOW1_OWNER="flow-test-1"
FLOW2_OWNER="flow-test-2"
RECLAIM_TTL=300

# Wrapper portabile mtime (BSD/GNU) — da concurrency.md
mtime() { stat -f%m "$1" 2>/dev/null || stat -c%Y "$1" 2>/dev/null; }
now()   { date +%s; }

cleanup() {
  rm -rf \
    .flow/locks/source-alpha/ \
    .flow/locks/source-beta/ \
    .flow/sources/source-alpha/ \
    .flow/sources/source-beta/ \
    docs/features/source-alpha/ \
    docs/features/source-beta/
}
trap cleanup EXIT

echo "=== Scenario A: two flows, distinct sources, no collision ==="

# --- Setup: due source fittizie con almeno un task pending ---
mkdir -p docs/features/source-alpha docs/features/source-beta
printf "# Tasks\n- [ ] source-alpha-001 | Status: todo\n" > docs/features/source-alpha/tasks-active.md
printf "# Tasks\n- [ ] source-beta-001  | Status: todo\n" > docs/features/source-beta/tasks-active.md
mkdir -p .flow/locks .flow/sources

# --- Flow 1: acquisisce source-alpha ---
mkdir .flow/locks/source-alpha/
date +%s > .flow/locks/source-alpha/heartbeat.ts
echo "$FLOW1_OWNER" > .flow/locks/source-alpha/owner

mkdir -p .flow/sources/source-alpha/
cat > .flow/sources/source-alpha/PROGRESS.json <<EOF
{
  "source": "source-alpha",
  "context_root": "docs/features/source-alpha/",
  "owner": "$FLOW1_OWNER",
  "current_task": "source-alpha-001",
  "tasks": [{ "id": "source-alpha-001", "state": "active" }]
}
EOF

# --- Flow 2: tenta source-alpha (lock vivo) → passa a source-beta ---
ALPHA_HB=".flow/locks/source-alpha/heartbeat.ts"
ALPHA_MTIME=$(mtime "$ALPHA_HB")
ALPHA_AGE=$(( $(now) - ALPHA_MTIME ))

if [ "$ALPHA_AGE" -lt "$RECLAIM_TTL" ]; then
  echo "source-alpha: lock vivo (age=${ALPHA_AGE}s < TTL=${RECLAIM_TTL}s) — Flow 2 passa a source-beta"
  mkdir .flow/locks/source-beta/
  date +%s > .flow/locks/source-beta/heartbeat.ts
  echo "$FLOW2_OWNER" > .flow/locks/source-beta/owner

  mkdir -p .flow/sources/source-beta/
  cat > .flow/sources/source-beta/PROGRESS.json <<EOF
{
  "source": "source-beta",
  "context_root": "docs/features/source-beta/",
  "owner": "$FLOW2_OWNER",
  "current_task": "source-beta-001",
  "tasks": [{ "id": "source-beta-001", "state": "active" }]
}
EOF
else
  echo "FAIL: source-alpha già stantia durante setup (age=${ALPHA_AGE}s); timing troppo stretto"
  exit 1
fi

# --- Asserzioni ---
fail() { echo "FAIL: $1"; exit 1; }

[ -d .flow/locks/source-alpha/ ] \
  || fail "lock source-alpha assente — Flow 1 avrebbe dovuto tenerlo"
[ -d .flow/locks/source-beta/ ] \
  || fail "lock source-beta assente — Flow 2 non ha acquisito source-beta"

[ -f .flow/sources/source-alpha/PROGRESS.json ] \
  || fail "PROGRESS source-alpha mancante"
[ -f .flow/sources/source-beta/PROGRESS.json ] \
  || fail "PROGRESS source-beta mancante"

OWNER_ALPHA=$(jq -r '.owner' .flow/sources/source-alpha/PROGRESS.json)
OWNER_BETA=$(jq -r  '.owner' .flow/sources/source-beta/PROGRESS.json)

[ "$OWNER_ALPHA" != "$OWNER_BETA" ] \
  || fail "owner identici ($OWNER_ALPHA) — i due flow non devono condividere lo stesso owner"

echo "  owner source-alpha: $OWNER_ALPHA"
echo "  owner source-beta:  $OWNER_BETA"
echo "PASS: Scenario A — due flow su source diverse, nessuna collisione"
