#!/usr/bin/env bash
# tests/harness/run.sh — Runner harness topology
#
# Esegue il loop PM (Funzione: brief) su ciascun golden-task del fixture,
# raccoglie gli artefatti prodotti e scrive un run-summary.json.
#
# Uso:
#   ./tests/harness/run.sh [--run-id <name>] [--task <golden-id>]
#
# Dipendenze: bash 5, jq, claude CLI nel PATH.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FIXTURE_DIR="$SCRIPT_DIR/fixture"
RUNS_DIR="$SCRIPT_DIR/runs"

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

# run_pm_brief: unico punto di contatto con la CLI claude.
# Invoca il PM in modalità non-interattiva con cwd = fixture.
# D1: se l'interfaccia CLI cambia, modificare solo questa funzione.
run_pm_brief() {
  local task_id="$1"
  (cd "$FIXTURE_DIR" && claude --print -p "Funzione: brief. TASK: $task_id.")
}

# collect_artifacts: copia gli artefatti prodotti dal PM nel run-output.
collect_artifacts() {
  local task_id="$1"
  local dest="$2"
  mkdir -p "$dest"
  # Copia da fixture/.flow/briefs/<id>/ → dest/; ignora assenza (il PM potrebbe non aver prodotto nulla)
  cp -r "$FIXTURE_DIR/.flow/briefs/$task_id/." "$dest/" 2>/dev/null || true
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

    # D2: pulizia .flow/ tra task per garantire isolamento
    rm -rf "$FIXTURE_DIR/.flow"

    local status="ok"
    exit_code=0
    run_pm_brief "$task_id" || exit_code=$?

    collect_artifacts "$task_id" "$run_out/$task_id"

    if [[ $exit_code -ne 0 ]]; then
      status="error"
      # Registra il codice di errore senza interrompere il run
      printf "claude exited with code %d for task %s\n" "$exit_code" "$task_id" \
        > "$run_out/$task_id/RUNNER_ERROR.txt"
    fi

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
