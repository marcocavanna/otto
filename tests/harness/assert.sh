#!/usr/bin/env bash
# tests/harness/assert.sh — Asseritore strutturale topology-harness
#
# Uso: ./tests/harness/assert.sh <run-id>
#
# Legge gli artefatti in runs/<run-id>/<golden-id>/ e li valida contro
# fixture/golden-tasks/<golden-id>/snapshot.json.
# Scrive runs/<run-id>/assert-report.json, stampa sommario a stdout.
# Exit 0 = tutti pass, Exit 1 = almeno un fail, Exit 2 = errore setup.
#
# Dipendenze: bash 5, jq.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FIXTURE_DIR="$SCRIPT_DIR/fixture"
RUNS_DIR="$SCRIPT_DIR/runs"
RUN_ID="${1:?Usage: assert.sh <run-id>}"
RUN_DIR="$RUNS_DIR/$RUN_ID"

overall_exit=0

# ------------------------------------------------------------
# Strutture dati: risultati accumulati in variabili globali.
# results_json_entries: array di stringhe JSON (una per task).
# total_pass / total_fail / total_error: contatori summary.
# ------------------------------------------------------------
results_json_entries=()
total_pass=0
total_fail=0
total_error=0

# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------

# Emette un record dimensione JSON.
# dim_record <dim> <status> <message>
dim_record() {
  local dim="$1" status="$2" message="$3"
  printf '"%s":{"status":"%s","message":%s}' \
    "$dim" "$status" "$(printf '%s' "$message" | jq -R .)"
}

# ------------------------------------------------------------
# Funzioni di asserzione per dimensione
# Ogni funzione scrive nella variabile locale del chiamante
# tramite nameref: dim_status_<dim> e dim_msg_<dim>.
# Per semplicità accumuliamo in variabili globali prefissate.
# ------------------------------------------------------------

# assert_resolver: brief.md e scope.txt presenti nell'artifact_dir
assert_resolver() {
  local artifact_dir="$1"
  local snapshot="$2"
  local resolves_to_one
  resolves_to_one="$(jq -r '.invariants.resolver.resolves_to_one' "$snapshot")"

  if [[ "$resolves_to_one" == "true" ]]; then
    local missing=()
    [[ -f "$artifact_dir/brief.md" ]] || missing+=("brief.md")
    [[ -f "$artifact_dir/scope.txt" ]] || missing+=("scope.txt")

    if [[ ${#missing[@]} -eq 0 ]]; then
      _dim_status="pass"
      _dim_msg=""
    else
      _dim_status="fail"
      _dim_msg="resolver.resolves_to_one: missing artifacts: ${missing[*]}"
    fi
  else
    # resolves_to_one=false non è nei casi attuali; pass senza controllo
    _dim_status="pass"
    _dim_msg=""
  fi
}

# assert_brief: sezioni required + must_not_be_empty
assert_brief() {
  local artifact_dir="$1"
  local snapshot="$2"
  local brief_file="$artifact_dir/brief.md"

  if [[ ! -f "$brief_file" ]]; then
    _dim_status="fail"
    _dim_msg="brief: brief.md non trovato"
    return
  fi

  local required_sections
  required_sections="$(jq -r '.invariants.brief.required_sections[]?' "$snapshot")"

  local missing_sections=()
  local empty_sections=()

  while IFS= read -r section; do
    [[ -z "$section" ]] && continue
    # Match heading ## <sezione> case-insensitive (livello 2 esatto)
    if ! grep -qi "^## ${section}" "$brief_file"; then
      missing_sections+=("$section")
    fi
  done <<< "$required_sections"

  local must_not_be_empty
  must_not_be_empty="$(jq -r '.invariants.brief.must_not_be_empty[]?' "$snapshot")"

  while IFS= read -r section; do
    [[ -z "$section" ]] && continue
    # Già assente → già in missing_sections, non raddoppiare
    if grep -qi "^## ${section}" "$brief_file"; then
      # Verifica che ci sia contenuto non-vuoto dopo l'heading
      # Strategia: estrai le righe dopo l'heading fino al prossimo ## (o EOF)
      local has_content
      has_content="$(awk -v sec="$section" '
        BEGIN { found=0; content=0 }
        /^## / {
          if (found) { exit }
          if (tolower($0) ~ "^## " tolower(sec) "$") { found=1; next }
        }
        found && /[^[:space:]]/ { content=1; exit }
        END { print content }
      ' "$brief_file")"
      if [[ "$has_content" != "1" ]]; then
        empty_sections+=("$section")
      fi
    fi
  done <<< "$must_not_be_empty"

  if [[ ${#missing_sections[@]} -eq 0 && ${#empty_sections[@]} -eq 0 ]]; then
    _dim_status="pass"
    _dim_msg=""
  else
    _dim_status="fail"
    local msgs=()
    [[ ${#missing_sections[@]} -gt 0 ]] && \
      msgs+=("brief.required_sections: missing=${missing_sections[*]}")
    [[ ${#empty_sections[@]} -gt 0 ]] && \
      msgs+=("brief.must_not_be_empty: empty=${empty_sections[*]}")
    _dim_msg="$(IFS='; '; echo "${msgs[*]}")"
  fi
}

# assert_scope: must_contain (exact line match) + must_contain_service_glob
assert_scope() {
  local artifact_dir="$1"
  local snapshot="$2"
  local task_id="$3"
  local scope_file="$artifact_dir/scope.txt"

  if [[ ! -f "$scope_file" ]]; then
    _dim_status="fail"
    _dim_msg="scope: scope.txt non trovato"
    return
  fi

  local missing_paths=()

  # must_contain: confronto stringa esatta riga per riga
  while IFS= read -r expected_path; do
    [[ -z "$expected_path" ]] && continue
    if ! grep -qxF "$expected_path" "$scope_file"; then
      missing_paths+=("$expected_path")
    fi
  done <<< "$(jq -r '.invariants.scope.must_contain[]?' "$snapshot")"

  # must_contain_service_glob: la riga specifica del task
  local service_glob
  service_glob="$(jq -r '.invariants.scope.must_contain_service_glob // empty' "$snapshot")"

  local missing_glob=""
  if [[ -n "$service_glob" ]]; then
    if ! grep -qxF "$service_glob" "$scope_file"; then
      missing_glob="$service_glob"
    fi
  fi

  if [[ ${#missing_paths[@]} -eq 0 && -z "$missing_glob" ]]; then
    _dim_status="pass"
    _dim_msg=""
  else
    _dim_status="fail"
    local msgs=()
    [[ ${#missing_paths[@]} -gt 0 ]] && \
      msgs+=("scope.must_contain: missing=${missing_paths[*]}")
    [[ -n "$missing_glob" ]] && \
      msgs+=("scope.must_contain_service_glob: missing=${missing_glob}")
    _dim_msg="$(IFS='; '; echo "${msgs[*]}")"
  fi
}

# assert_frozen: must_contain (exact line match)
assert_frozen() {
  local artifact_dir="$1"
  local snapshot="$2"
  local frozen_file="$artifact_dir/frozen.txt"

  local required_entries
  required_entries="$(jq -r '.invariants.frozen.must_contain[]?' "$snapshot")"

  # Se non ci sono voci richieste, pass immediato (anche se frozen.txt manca)
  if [[ -z "$required_entries" ]]; then
    _dim_status="pass"
    _dim_msg=""
    return
  fi

  if [[ ! -f "$frozen_file" ]]; then
    _dim_status="fail"
    _dim_msg="frozen: frozen.txt non trovato ma must_contain non vuoto"
    return
  fi

  local missing_entries=()
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    if ! grep -qxF "$entry" "$frozen_file"; then
      missing_entries+=("$entry")
    fi
  done <<< "$required_entries"

  if [[ ${#missing_entries[@]} -eq 0 ]]; then
    _dim_status="pass"
    _dim_msg=""
  else
    _dim_status="fail"
    _dim_msg="frozen.must_contain: missing=${missing_entries[*]}"
  fi
}

# assert_meta: complexity_in_enum + expected_complexity
assert_meta() {
  local artifact_dir="$1"
  local snapshot="$2"
  local meta_file="$artifact_dir/meta.json"

  if [[ ! -f "$meta_file" ]]; then
    _dim_status="fail"
    _dim_msg="meta: meta.json non trovato"
    return
  fi

  local complexity
  complexity="$(jq -r '.complexity // empty' "$meta_file")"

  local msgs=()

  # complexity_in_enum
  local check_enum
  check_enum="$(jq -r '.invariants.meta.complexity_in_enum // false' "$snapshot")"
  if [[ "$check_enum" == "true" ]]; then
    case "$complexity" in
      trivial|standard|critical) ;;
      *)
        msgs+=("meta.complexity_in_enum: got=${complexity:-<empty>}, expected one of {trivial,standard,critical}")
        ;;
    esac
  fi

  # expected_complexity
  local expected_complexity
  expected_complexity="$(jq -r '.invariants.meta.expected_complexity // empty' "$snapshot")"
  if [[ -n "$expected_complexity" && "$complexity" != "$expected_complexity" ]]; then
    msgs+=("meta.expected_complexity: expected=${expected_complexity}, got=${complexity:-<empty>}")
  fi

  if [[ ${#msgs[@]} -eq 0 ]]; then
    _dim_status="pass"
    _dim_msg=""
  else
    _dim_status="fail"
    _dim_msg="$(IFS='; '; echo "${msgs[*]}")"
  fi
}

# ------------------------------------------------------------
# assert_task: orchestra tutte le dimensioni per un task
# Appende a results_json_entries; aggiorna contatori globali.
# ------------------------------------------------------------
assert_task() {
  local task_id="$1"
  local artifact_dir="$RUN_DIR/$task_id"
  local snapshot="$FIXTURE_DIR/golden-tasks/$task_id/snapshot.json"

  # Caso: runner aveva segnalato errore
  if [[ -f "$artifact_dir/RUNNER_ERROR.txt" ]]; then
    local error_msg
    error_msg="$(cat "$artifact_dir/RUNNER_ERROR.txt")"
    local task_json
    task_json="$(jq -n \
      --arg tid "$task_id" \
      --arg emsg "$error_msg" \
      '{task_id:$tid,status:"error",dimensions:{
        resolver:{status:"error",message:$emsg},
        brief:{status:"error",message:$emsg},
        scope:{status:"error",message:$emsg},
        frozen:{status:"error",message:$emsg},
        meta:{status:"error",message:$emsg}
      }}')"
    results_json_entries+=("$task_json")
    (( total_error++ )) || true
    overall_exit=1
    return
  fi

  # Snapshot deve esistere
  if [[ ! -f "$snapshot" ]]; then
    local task_json
    task_json="$(jq -n --arg tid "$task_id" \
      '{task_id:$tid,status:"error",dimensions:{
        resolver:{status:"error",message:"snapshot.json non trovato nel fixture"},
        brief:{status:"error",message:"snapshot.json non trovato nel fixture"},
        scope:{status:"error",message:"snapshot.json non trovato nel fixture"},
        frozen:{status:"error",message:"snapshot.json non trovato nel fixture"},
        meta:{status:"error",message:"snapshot.json non trovato nel fixture"}
      }}')"
    results_json_entries+=("$task_json")
    (( total_error++ )) || true
    overall_exit=1
    return
  fi

  # Variabili globali temporanee per ritorno dalle funzioni di assert
  _dim_status=""
  _dim_msg=""

  # resolver
  assert_resolver "$artifact_dir" "$snapshot"
  local res_resolver="$_dim_status" msg_resolver="$_dim_msg"

  # brief
  assert_brief "$artifact_dir" "$snapshot"
  local res_brief="$_dim_status" msg_brief="$_dim_msg"

  # scope
  assert_scope "$artifact_dir" "$snapshot" "$task_id"
  local res_scope="$_dim_status" msg_scope="$_dim_msg"

  # frozen
  assert_frozen "$artifact_dir" "$snapshot"
  local res_frozen="$_dim_status" msg_frozen="$_dim_msg"

  # meta
  assert_meta "$artifact_dir" "$snapshot"
  local res_meta="$_dim_status" msg_meta="$_dim_msg"

  # Status task: pass se tutte pass, fail altrimenti
  local task_status="pass"
  for s in "$res_resolver" "$res_brief" "$res_scope" "$res_frozen" "$res_meta"; do
    [[ "$s" != "pass" ]] && { task_status="fail"; break; }
  done

  local task_json
  task_json="$(jq -n \
    --arg tid "$task_id" \
    --arg ts "$task_status" \
    --arg res_r "$res_resolver" --arg msg_r "$msg_resolver" \
    --arg res_b "$res_brief"   --arg msg_b "$msg_brief" \
    --arg res_s "$res_scope"   --arg msg_s "$msg_scope" \
    --arg res_f "$res_frozen"  --arg msg_f "$msg_frozen" \
    --arg res_m "$res_meta"    --arg msg_m "$msg_meta" \
    '{
      task_id: $tid,
      status: $ts,
      dimensions: {
        resolver: {status: $res_r, message: $msg_r},
        brief:    {status: $res_b, message: $msg_b},
        scope:    {status: $res_s, message: $msg_s},
        frozen:   {status: $res_f, message: $msg_f},
        meta:     {status: $res_m, message: $msg_m}
      }
    }')"

  results_json_entries+=("$task_json")

  if [[ "$task_status" == "pass" ]]; then
    (( total_pass++ )) || true
  else
    (( total_fail++ )) || true
    overall_exit=1
  fi
}

# ------------------------------------------------------------
# print_summary: stampa a stdout il sommario leggibile
# ------------------------------------------------------------
print_summary() {
  local total=$(( total_pass + total_fail + total_error ))
  echo ""
  echo "assert.sh — Run: $RUN_ID"
  echo "────────────────────────────────────────"
  printf "  Tasks: %-4d  Pass: %-4d  Fail: %-4d  Error: %d\n" \
    "$total" "$total_pass" "$total_fail" "$total_error"
  echo "────────────────────────────────────────"

  # Dettaglio solo per fail/error
  for entry in "${results_json_entries[@]}"; do
    local tid status
    tid="$(jq -r '.task_id' <<< "$entry")"
    status="$(jq -r '.status' <<< "$entry")"

    if [[ "$status" == "pass" ]]; then
      printf "  [pass]  %s\n" "$tid"
    else
      printf "  [%s] %s\n" "$status" "$tid"
      # Dettaglio dimensioni con messaggio non-vuoto
      while IFS= read -r line; do
        [[ -n "$line" ]] && printf "          %s\n" "$line"
      done <<< "$(jq -r '
        .dimensions | to_entries[] |
        select(.value.status != "pass" and .value.message != "") |
        "  \(.key): \(.value.message)"
      ' <<< "$entry")"
    fi
  done

  echo ""
  if [[ $overall_exit -eq 0 ]]; then
    echo "  RESULT: PASS"
  else
    echo "  RESULT: FAIL"
  fi
  echo ""
}

# ------------------------------------------------------------
# main
# ------------------------------------------------------------
main() {
  local summary_json="$RUN_DIR/run-summary.json"
  if [[ ! -f "$summary_json" ]]; then
    echo "run-summary.json non trovato in $RUN_DIR" >&2
    exit 2
  fi

  local task_ids
  task_ids="$(jq -r '.tasks[].task_id' "$summary_json")"

  while IFS= read -r task_id; do
    [[ -z "$task_id" ]] && continue
    assert_task "$task_id"
  done <<< "$task_ids"

  # Serializza results in JSON array
  local results_array="[]"
  for entry in "${results_json_entries[@]}"; do
    results_array="$(jq -n --argjson arr "$results_array" --argjson e "$entry" '$arr + [$e]')"
  done

  local total=$(( total_pass + total_fail + total_error ))

  jq -n \
    --arg run_id "$RUN_ID" \
    --argjson results "$results_array" \
    --argjson total "$total" \
    --argjson pass "$total_pass" \
    --argjson fail "$total_fail" \
    --argjson error "$total_error" \
    '{
      run_id: $run_id,
      results: $results,
      summary: {
        total: $total,
        pass: $pass,
        fail: $fail,
        error: $error
      }
    }' > "$RUN_DIR/assert-report.json"

  print_summary

  exit $overall_exit
}

main "$@"
