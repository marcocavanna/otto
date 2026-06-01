#!/usr/bin/env bash
# tests/harness/run.sh — Runner harness topology
#
# Per ogni golden-task: copia il fixture in una dir temporanea ISOLATA (fuori dal
# repo otto, con `git init` proprio), invoca il PM lì, raccoglie gli artefatti e
# scrive run-summary.json.
#
# Perché la copia temporanea: il fixture non è un repo git proprio; eseguendo il PM
# direttamente dentro il fixture, la risoluzione di `.flow/` via git-root finiva (in
# modo NON deterministico) nel `.flow` del repo otto reale → artefatti non raccolti +
# leak. Eseguendo in una temp dir con git init proprio, `.flow` risolve sempre lì:
# deterministico e senza toccare il repo otto.
#
# Uso:
#   ./tests/harness/run.sh [--run-id <name>] [--task <golden-id>]
#
# Dipendenze: bash 5, jq, git, claude CLI nel PATH.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FIXTURE_DIR="$SCRIPT_DIR/fixture"
RUNS_DIR="$SCRIPT_DIR/runs"
# Root del repo plugin (tests/harness → repo root): caricato via --plugin-dir per
# testare la otto del WORKING TREE, scavalcando quella installata globalmente, SENZA
# toccare l'installazione globale né l'auth (no --bare). Meccanismo verificato:
# `--plugin-dir <repo>` con plugin omonimo → la copia locale prevale per la sessione.
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# --- Parsing argomenti ---

RUN_ID="$(date +%Y%m%d%H%M%S)"
SINGLE_TASK=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --run-id)
      RUN_ID="$2"; shift 2 ;;
    --task)
      SINGLE_TASK="$2"; shift 2 ;;
    *)
      echo "Argomento non riconosciuto: $1" >&2; exit 1 ;;
  esac
done

# --- Funzioni ---

# make_workdir: crea una copia isolata del fixture in una temp dir con git init proprio.
# Stampa il path della workdir su stdout.
make_workdir() {
  local wd
  wd="$(mktemp -d)"
  cp -R "$FIXTURE_DIR"/. "$wd"/
  # parti pulito: niente .flow ereditato, niente golden-tasks (non serve al PM)
  rm -rf "$wd/.flow" "$wd/golden-tasks"
  # git init proprio → git-root = workdir → `.flow` risolve QUI (deterministico, no leak)
  git -C "$wd" init -q
  echo "$wd"
}

# run_pm_brief: unico punto di contatto con la CLI claude.
# Invoca il PM (attended) con cwd = workdir isolata, plugin dal working tree.
# D1: se l'interfaccia CLI cambia, modificare solo questa funzione.
run_pm_brief() {
  local task_id="$1"
  local workdir="$2"
  # --plugin-dir "$REPO_ROOT": usa la otto del working tree (override della globale), auth intatta.
  # Modalità ATTENDED esplicita: emula il subagent pm di flow-run, che materializza gli artefatti
  # machine-readable in .flow/briefs/<id>/ (scope/frozen/meta/brief.md).
  (cd "$workdir" && claude --print \
     --plugin-dir "$REPO_ROOT" \
     --allowedTools "Read,Write,Edit,Bash,Glob,Grep" \
     -p "Agisci come il subagent 'pm' di otto/flow-run seguendo agents/pm.md in modalità ATTENDED. Funzione: brief. TASK: $task_id. Oltre al brief co-locato, materializza in .flow/briefs/$task_id/ gli artefatti machine-readable scope.txt, frozen.txt, meta.json e brief.md come da attended-flow.md.")
}

# collect_artifacts: copia gli artefatti prodotti dal PM (in workdir/.flow/briefs/<id>/) nel run-output.
collect_artifacts() {
  local task_id="$1"
  local workdir="$2"
  local dest="$3"
  mkdir -p "$dest"
  cp -r "$workdir/.flow/briefs/$task_id/." "$dest/" 2>/dev/null || true
}

# --- Main ---

main() {
  local run_out="$RUNS_DIR/$RUN_ID"
  mkdir -p "$run_out"

  local summary_entries=()
  local exit_code

  for snapshot_dir in "$FIXTURE_DIR/golden-tasks"/*/; do
    [ -d "$snapshot_dir" ] || continue
    local task_id
    task_id="$(basename "$snapshot_dir")"

    # D4: supporto subset via --task
    [[ -n "$SINGLE_TASK" && "$task_id" != "$SINGLE_TASK" ]] && continue

    # Isolamento per-task: copia temporanea del fixture (vedi header).
    local workdir
    workdir="$(make_workdir)"

    local status="ok"
    exit_code=0
    run_pm_brief "$task_id" "$workdir" || exit_code=$?

    collect_artifacts "$task_id" "$workdir" "$run_out/$task_id"

    if [[ $exit_code -ne 0 ]]; then
      status="error"
      printf "claude exited with code %d for task %s\n" "$exit_code" "$task_id" \
        > "$run_out/$task_id/RUNNER_ERROR.txt"
    fi

    rm -rf "$workdir"

    summary_entries+=("{\"task_id\":\"$task_id\",\"status\":\"$status\",\"artifacts\":\"$run_out/$task_id\"}")
  done

  # Scrive run-summary.json via jq per JSON valido garantito
  local tasks_json
  tasks_json="$(printf '%s\n' "${summary_entries[@]}" | jq -s '.')"
  jq -n \
    --arg run_id "$RUN_ID" \
    --arg run_out "$run_out" \
    --argjson tasks "$tasks_json" \
    '{run_id: $run_id, run_output: $run_out, tasks: $tasks}' \
    > "$run_out/run-summary.json"

  echo "Run completato: $run_out/run-summary.json"
}

main "$@"
