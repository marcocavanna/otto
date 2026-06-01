# Topology Harness — Uso e manutenzione

Questo documento copre come **lanciare, usare e aggiornare** l'harness di topologia: una suite di test strutturali che esegue il loop di task planning su un set di **golden-task sintetici** e valida gli artefatti prodotti contro invarianti dichiarate.

## Panoramica

L'harness comprende due script:
- **`run.sh`** — esegue il PM (funzione "brief") su ciascun golden-task nel fixture e raccoglie gli artefatti (`brief.md`, `scope.txt`, `frozen.txt`, `meta.json`).
- **`assert.sh`** — valida gli artefatti prodotti contro uno snapshot di invarianti attese, produttore il report pass/fail.

Si lancia dalla **root del repo otto**:

```bash
cd /path/to/otto
./tests/harness/run.sh
./tests/harness/assert.sh <run-id>
```

---

## Lanciare l'harness

### Flusso completo (tutti i golden-task)

```bash
# Esegui il PM su tutti i golden-task
./tests/harness/run.sh

# Attendere il completamento, nota il run-id prodotto (es. 20260601120000)
# Poi valida gli artefatti
./tests/harness/assert.sh 20260601120000
```

L'output sarà:
- `tests/harness/runs/<run-id>/run-summary.json` — elenco dei task eseguiti + status ok/error
- `tests/harness/runs/<run-id>/assert-report.json` — report dettagliato per task e dimensione
- Sommario leggibile a stdout

Exit code di `assert.sh`:
- `0` → tutti i task passano tutte le dimensioni
- `1` → almeno un task fallisce una dimensione (regressione, da indagare)
- `2` → errore setup (run-id inesistente, snapshot mancante, ecc.)

### Varianti utili

**Nominare il run (più leggibile nei path):**
```bash
./tests/harness/run.sh --run-id smoke
./tests/harness/assert.sh smoke
```

**Debuggare un singolo golden-task:**
```bash
./tests/harness/run.sh --task fixture-feat-002 --run-id debug
./tests/harness/assert.sh debug
```

**Combinare:**
```bash
./tests/harness/run.sh --run-id smoke --task fixture-proj-001
./tests/harness/assert.sh smoke
```

### Precondizioni

- `claude` CLI nel PATH (oppure `npx @anthropic-ai/claude-code` se disponibile).
- `jq` installato (parsing JSON negli script).
- Script eseguibili: `chmod +x tests/harness/run.sh tests/harness/assert.sh`.
- Eseguire dalla **root del repo otto** — gli script usano path relativi.

---

## Struttura degli output

Dopo un run, la directory `tests/harness/runs/<run-id>/` conterrà:

```
runs/<run-id>/
  run-summary.json                  # Metadata e status di ogni task (scritto da run.sh)
  <golden-id>/                      # Una dir per ogni task
    brief.md                        # Artefatto prodotto dal PM
    scope.txt
    frozen.txt
    meta.json
    RUNNER_ERROR.txt                # Presente SOLO se claude ha fallito per quel task
  assert-report.json                # Report strutturato (scritto da assert.sh)
```

Esempio `run-summary.json`:
```json
{
  "run_id": "20260601120000",
  "run_output": "tests/harness/runs/20260601120000",
  "tasks": [
    {"task_id": "fixture-proj-001", "status": "ok", "artifacts": "tests/harness/runs/20260601120000/fixture-proj-001"},
    {"task_id": "fixture-proj-002", "status": "error", "artifacts": "tests/harness/runs/20260601120000/fixture-proj-002"},
    ...
  ]
}
```

---

## Leggere un fallimento

### Mappatura exit code → risultati

Quando `assert.sh` termina con exit 1 (fallimento):

1. **Leggere il sommario a stdout** — riporta pass/fail/error per task in forma leggibile
2. **Consultare `assert-report.json`** — schema dettagliato per ogni task e dimensione

### Schema `assert-report.json`

```json
{
  "run_id": "<run-id>",
  "results": [
    {
      "task_id": "<golden-id>",
      "status": "pass|fail|error",
      "dimensions": {
        "resolver": {"status": "pass|fail|error", "message": ""},
        "brief":    {"status": "pass|fail|error", "message": ""},
        "scope":    {"status": "pass|fail|error", "message": ""},
        "frozen":   {"status": "pass|fail|error", "message": ""},
        "meta":     {"status": "pass|fail|error", "message": ""}
      }
    },
    ...
  ],
  "summary": {"total": N, "pass": N, "fail": N, "error": N}
}
```

**Significato dei campi:**

- `status: "error"` — il runner (PM) ha fallito, nessun artefatto prodotto (vedi `RUNNER_ERROR.txt` nel task-dir)
- `status: "fail"` → una o più dimensioni falliscono le asserzioni
- `status: "pass"` → tutte le dimensioni passano

**Dimensioni asserite:**

| Dimensione | Cosa controlla |
|-----------|---|
| `resolver` | `brief.md` e `scope.txt` prodotti (artefatti base risolvono il task) |
| `brief` | Sezioni richieste presenti (es. "Obiettivo", "Vincoli risolti"); sezioni obbligatorie non vuote |
| `scope` | `scope.txt` contiene tutti i path attesi + il glob `.flow/briefs/<task-id>/**` |
| `frozen` | `frozen.txt` contiene i contratti/VO che il task non deve toccare |
| `meta` | `meta.json.complexity` nell'enum {trivial, standard, critical} e pari a quello atteso |

### Leggere un messaggio di fallimento

Esempi di messaggi di fail:

```
resolver.resolves_to_one: missing artifacts: scope.txt
→ il task ha prodotto brief.md ma non scope.txt: il PM ha fallito parzialmente

brief.required_sections: missing=Obiettivo; File impattati
→ il brief non contiene una o entrambe le sezioni canoniche

brief.must_not_be_empty: empty=Vincoli risolti
→ la sezione "Vincoli risolti" è presente ma vuota

scope.must_contain: missing=docs/features/sample-feature/VO.ts
→ scope.txt non include il path atteso (il task potrebbe aver ignorato un file)

scope.must_contain_service_glob: missing=.flow/briefs/fixture-feat-002/**
→ scope.txt non contiene il glob del task stesso

frozen.must_contain: missing=TenantId
→ frozen.txt non contiene un contratto che il task non deve modificare

meta.expected_complexity: expected=standard, got=trivial
→ la complessità calcolata non corrisponde a quella attesa
```

### Procedura di triage

1. **Nota il `task_id` e la dimensione che fallisce** (es. `fixture-feat-002` → `scope`)
2. **Leggi il `message`** per capire cosa è atteso vs. cosa è stato trovato
3. **Apri `runs/<run-id>/<task_id>/` e ispeziona manualmente** — es. leggi `scope.txt` per vedere se il path è vraiment mancante oppure solo formattato diversamente
4. **Confronta con `tests/harness/fixture/golden-tasks/<task-id>/snapshot.json`** — verifica se l'invariante attesa è corretta
5. **Decidi: regressione o variazione intenzionale?**
   - **Regressione** → il codice ha regredito, fix obbligatorio
   - **Variazione intenzionale** → nuovo contratto, percorso di aggiornamento snapshot (vedi sezione sotto)

---

## Aggiornare gli snapshot

**Quando aggiornare?** Quando un contratto **intenzionalmente cambia** — es. nuovo campo obbligatorio nel brief, nuovo path in scope, cambio di tier di complessità di un golden-task.

**Non aggiornare snapshot "per far passare il test" senza verificare.**

### Procedura

1. **Riesegui il loop sul task interessato:**
   ```bash
   ./tests/harness/run.sh --task <golden-id> --run-id update
   ```

2. **Ispeziona manualmente gli artefatti nel run prodotto:**
   ```bash
   cat tests/harness/runs/update/<golden-id>/brief.md
   cat tests/harness/runs/update/<golden-id>/scope.txt
   cat tests/harness/runs/update/<golden-id>/meta.json
   ```

3. **Confronta con lo snapshot attuale:**
   ```bash
   cat tests/harness/fixture/golden-tasks/<golden-id>/snapshot.json | jq .
   ```

4. **Valida che la variazione sia intenzionale:**
   - Leggi il commit message o il brief del task che ha introdotto il cambio
   - Verifica che non sia una regressione spuria
   - Se in dubbio, chiedi revisione nel PR

5. **Aggiorna lo snapshot.json:**
   ```bash
   # Edita manualmente
   vim tests/harness/fixture/golden-tasks/<golden-id>/snapshot.json
   ```

   Campi tipici da aggiornare:
   - `invariants.brief.required_sections` — nuove sezioni canoniche nel brief
   - `invariants.brief.must_not_be_empty` — sezioni obbligatorie
   - `invariants.scope.must_contain` — path attesi nel scope.txt
   - `invariants.frozen.must_contain` — contratti/VO in frozen.txt
   - `invariants.meta.expected_complexity` — cambio di tier

6. **Riesegui l'assert per validare:**
   ```bash
   ./tests/harness/assert.sh update
   # Deve uscire con exit 0 (tutte le dimensioni pass)
   ```

7. **Commit con messaggio esplicito:**
   ```bash
   git add tests/harness/fixture/golden-tasks/<golden-id>/snapshot.json
   git commit -m "Update snapshot <golden-id>: <motivo conciso della variazione>

   - Invariant changed: <descrizione>
   - Reason: <causa (es. topology-canonical, nuovo schema brief)>
   - Verified: run-id=update, all assertions pass"
   ```

---

## Dipendenze e prerequisiti

**Software:**
- `bash` 5+
- `jq` (parsing JSON)
- `claude` CLI disponibile come `claude` oppure invocabile via `npx @anthropic-ai/claude-code`

**Permessi:**
- Script eseguibili: `chmod +x tests/harness/run.sh tests/harness/assert.sh`

**Posizione di esecuzione:**
- Sempre dalla **root del repo otto**, non da `tests/harness/`
- Gli script usano path relativi calcolati rispetto a `dirname "$0"`, quindi funzionano da ovunque se invocati con path relativo

**Fixture:**
- `tests/harness/fixture/` contiene i golden-task sintetici e i relativi snapshot
- Vedi `tests/harness/fixture/README.md` per layout e dettagli su golden-task, schema snapshot, invarianze

---

## Nota sulla fixture

La fixture è un piccolo repo controllato (`Acme Notes`) con:
- **7 golden-task**: 2 da project source, 5 da feature source
- **Distribuzione complessità**: 2 trivial, 3 standard, 2 critical
- **Contratti sintetici**: es. `NoteId`, `TenantId` in `frozen.txt`

Per dettagli sulla struttura, schema snapshot, definizione di invariante e procedura di aggiornamento estesa, vedi:
👉 **`tests/harness/fixture/README.md`**

---

## Golden-task di riferimento

Per consultazione rapida (vedi `fixture/README.md` per dettagli):

| Golden-id          | Categoria       | Complexity | Context-root              |
|--------------------|-----------------|-----------|-|
| fixture-proj-001   | config          | trivial   | docs/planning              |
| fixture-proj-002   | command-handler | critical  | docs/planning              |
| fixture-feat-001   | dto             | trivial   | docs/features/sample-feature |
| fixture-feat-002   | repository      | standard  | docs/features/sample-feature |
| fixture-feat-003   | ui-component    | standard  | docs/features/sample-feature |
| fixture-feat-004   | value-object    | critical  | docs/features/sample-feature |
| fixture-feat-005   | config          | standard  | docs/features/sample-feature |

---

Generato da task `topology-harness-004`. Versione: 1 (2026-06-01)
