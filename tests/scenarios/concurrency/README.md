# Scenari di concorrenza — topology-concurrency-core

Tre script bash che validano il protocollo di lock source-level implementato nei task 001-004
della feature `topology-concurrency-core`.

**Prerequisiti**: bash 5, jq, git — dalla root del repo otto.

---

## Scenari

### Scenario A — due flow su source diverse, nessuna collisione

**File**: `scenario-a-parallel-sources.sh`

Verifica che due flow che operano su source distinte acquisiscano lock indipendenti senza
interferire. Flow 1 prende `source-alpha`; Flow 2 vede il lock vivo e passa a `source-beta`.

**Asserzioni**:
- `.flow/locks/source-alpha/` e `.flow/locks/source-beta/` entrambi presenti
- PROGRESS per-source presenti per entrambe le source
- `owner` dei due PROGRESS è diverso

### Scenario B — lock stantio reclamato

**File**: `scenario-b-reclaim.sh`

Verifica che un lock orfano (heartbeat oltre soglia 300s) venga reclamato correttamente:
`rm -rf` del lock stantio seguito da `mkdir` e scrittura di un nuovo heartbeat.

**Nota portabilità `touch -t`**:
- **macOS/BSD**: `touch -t $(date -v-10M +%Y%m%d%H%M.%S)`
- **Linux/GNU**: `touch -d "$(date -d '10 minutes ago' '+%Y-%m-%d %H:%M:%S')"`

Lo script rileva l'ambiente a runtime e usa il branch corretto.

**Asserzioni**:
- Lock dir presente dopo reclaim
- `mtime(heartbeat.ts)` recente (entro 5s da now)
- Source "viva" secondo la semantica di `concurrency.md`

### Scenario C — auto-archivio coerente

**File**: `scenario-c-archive.sh`

Verifica la sequenza completa di auto-archivio: `git mv` della feature in `docs/archive/`,
rimozione PROGRESS e lock, aggiornamento `index.json`.

**Nota `git mv` vs `mv`**: se la source non è tracciata da git, lo script usa `mv` come
fallback (annotato nell'output). In entrambi i casi le asserzioni sul filesystem sono le stesse.

**Attenzione**: questo scenario **non esegue cleanup finale** — lo stato archiviato è il risultato
atteso. Per ripristinare dopo un run di test:
```sh
git checkout HEAD -- docs/features/source-archive-test/
rm -rf docs/archive/features/source-archive-test/
jq 'del(.["source-archive-test"])' .flow/index.json > /tmp/idx.json && mv /tmp/idx.json .flow/index.json
```

**Asserzioni**:
- `docs/features/source-archive-test/` assente
- `docs/archive/features/source-archive-test/tasks-active.md` presente
- `.flow/locks/source-archive-test/` assente
- `.flow/sources/source-archive-test/` assente
- `index.json`: `archived=true`, `alive=false`
- La source non compare in uno scan di `docs/features/`

---

## Ordine di esecuzione consigliato

```sh
bash tests/scenarios/concurrency/scenario-a-parallel-sources.sh
bash tests/scenarios/concurrency/scenario-b-reclaim.sh
bash tests/scenarios/concurrency/scenario-c-archive.sh
```

Exit code 0 = PASS per ogni scenario. Exit code 1 = FAIL con messaggio diagnostico.

Gli scenari A e B sono idempotenti (cleanup via `trap EXIT`). Lo scenario C lascia lo stato
archiviato come risultato finale.

---

## Interpretare i risultati

| Output finale | Significato |
|---|---|
| `PASS: Scenario X — ...` | Scenario superato, exit 0 |
| `FAIL: <messaggio>` | Asserzione fallita, exit 1 |

---

## Reference

- Primitivi del protocollo: `skills/flow-run/references/concurrency.md`
- Algoritmo claim/reclaim: `concurrency.md` § Algoritmo claim, § Reclaim
- Logica auto-archivio: `skills/flow-run/SKILL.md` § Auto-archivio a fine source
