#!/usr/bin/env bash
# scenario-c-archive.sh
#
# Scenario C: auto-archivio coerente.
# Verifica che dopo la sequenza di archivio la source non sia più pending
# e che il materiale sia presente in docs/archive/.
#
# Prerequisiti: bash 5, jq, git, eseguire dalla root del repo otto.
# Attenzione: usa `git mv` — la source deve essere tracciata nel repo.
# Fallback: se git mv fallisce, lo script usa `mv` (annotato nelle asserzioni).
#
# Risultato atteso: exit 0 = PASS.
# Cleanup: nessuno (lo stato finale è quello atteso post-archivio).
#
# Reference: skills/flow-run/SKILL.md § Auto-archivio a fine source

set -euo pipefail

SLUG="source-archive-test"
FEATURE_DIR="docs/features/$SLUG"
ARCHIVE_DIR="docs/archive/features/$SLUG"
LOCK_DIR=".flow/locks/$SLUG"
PROGRESS_DIR=".flow/sources/$SLUG"
INDEX=".flow/index.json"

fail() { echo "FAIL: $1"; exit 1; }

echo "=== Scenario C: auto-archivio e verifica post-archivio ==="

# --- Idempotenza: cleanup residui da run precedenti ---
rm -rf "$FEATURE_DIR" "$ARCHIVE_DIR" "$LOCK_DIR" "$PROGRESS_DIR"
# Rimuovi voce residua da index.json se presente
if [ -f "$INDEX" ] && jq -e ".[\"$SLUG\"]" "$INDEX" >/dev/null 2>&1; then
  jq "del(.[\"$SLUG\"])" "$INDEX" > /tmp/idx_clean.json && mv /tmp/idx_clean.json "$INDEX"
fi

# --- Setup: crea mini-feature con tasks-active.md tracciata ---
mkdir -p "$FEATURE_DIR"
cat > "$FEATURE_DIR/tasks-active.md" <<'EOF'
# Tasks

- [x] source-archive-test-001 | Status: done
EOF

# Tenta di tracciare la feature in git (necessario per git mv); ignora se la dir è in .gitignore
git add "$FEATURE_DIR/tasks-active.md" 2>/dev/null || true

# --- Init PROGRESS per-source con tutti i task done ---
mkdir -p "$PROGRESS_DIR"
cat > "$PROGRESS_DIR/PROGRESS.json" <<EOF
{
  "source": "$SLUG",
  "context_root": "$FEATURE_DIR/",
  "owner": "flow-test-archive",
  "current_task": null,
  "tasks": [{ "id": "source-archive-test-001", "state": "done" }]
}
EOF

# --- Acquisisce lock ---
mkdir -p .flow/locks
mkdir "$LOCK_DIR"
date +%s > "$LOCK_DIR/heartbeat.ts"

# --- Upsert entry in index.json ---
if [ ! -f "$INDEX" ]; then
  echo '{}' > "$INDEX"
fi
# Valida che index.json sia JSON valido prima di modificarlo
jq empty "$INDEX" 2>/dev/null || echo '{}' > "$INDEX"

jq --arg slug "$SLUG" \
   '.[$slug] = { "owner": "flow-test-archive", "alive": true, "active": "source-archive-test-001", "done": 1, "pending": 0, "archived": false }' \
   "$INDEX" > /tmp/idx.json && mv /tmp/idx.json "$INDEX"

echo "  Setup completato: lock, PROGRESS, index.json aggiornato"

# --- Sequenza auto-archivio (da SKILL.md § Auto-archivio) ---
mkdir -p docs/archive/features/

USE_GIT_MV=true
if git mv "$FEATURE_DIR" "docs/archive/features/$SLUG" 2>/dev/null; then
  echo "  git mv: OK"
else
  echo "  git mv fallito (source non tracciata o git non disponibile) — uso mv"
  mv "$FEATURE_DIR" "docs/archive/features/$SLUG"
  USE_GIT_MV=false
fi

rm -rf "$PROGRESS_DIR"
rm -rf "$LOCK_DIR"

jq --arg slug "$SLUG" \
   '.[$slug].archived = true | .[$slug].alive = false | .[$slug].active = null' \
   "$INDEX" > /tmp/idx.json && mv /tmp/idx.json "$INDEX"

echo "  Sequenza archivio completata"

# --- Asserzioni ---
[ ! -d "$FEATURE_DIR" ] \
  || fail "docs/features/$SLUG/ esiste ancora dopo l'archivio"

[ -f "$ARCHIVE_DIR/tasks-active.md" ] \
  || fail "docs/archive/features/$SLUG/tasks-active.md non trovato"

[ ! -d "$LOCK_DIR" ] \
  || fail ".flow/locks/$SLUG/ esiste ancora dopo l'archivio"

[ ! -d "$PROGRESS_DIR" ] \
  || fail ".flow/sources/$SLUG/ esiste ancora dopo l'archivio"

ARCHIVED=$(jq -r --arg slug "$SLUG" '.[$slug].archived' "$INDEX")
[ "$ARCHIVED" = "true" ] \
  || fail "index.json: [$SLUG].archived non è true (valore: $ARCHIVED)"

ALIVE=$(jq -r --arg slug "$SLUG" '.[$slug].alive' "$INDEX")
[ "$ALIVE" = "false" ] \
  || fail "index.json: [$SLUG].alive non è false (valore: $ALIVE)"

# Verifica che la source non compaia tra le feature pending (scan docs/features/)
if ls "$FEATURE_DIR" 2>/dev/null; then
  fail "$SLUG ancora presente in docs/features/ — sarebbe rilevata dallo scan come pending"
fi
echo "  scan docs/features/: $SLUG non presente (corretto)"

echo "PASS: Scenario C — auto-archivio coerente"
echo ""
echo "  Stato finale:"
echo "    $ARCHIVE_DIR/tasks-active.md  (archiviato)"
echo "    index.json: archived=true, alive=false"
if [ "$USE_GIT_MV" = "true" ]; then
  echo "    Nota: git mv ha spostato il file — il move è tracciato nel working tree."
  echo "    Per annullare: git checkout HEAD -- $FEATURE_DIR && rm -rf $ARCHIVE_DIR"
fi
