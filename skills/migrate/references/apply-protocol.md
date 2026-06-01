# Apply — protocollo di migrazione idempotente e reversibile

Reference consumata da `skills/migrate/SKILL.md` §"apply". Codifica l'unica fonte
di verità della logica di apply: gate, backup pre-apply, move loop idempotente,
archiviazione delle source concluse, manifest su disco, report terminale e
procedura di restore.

L'input è il `DetectionPlan` prodotto dalla detection (`references/detection.md`,
shape `{ moves, ambiguous, orphan, already_migrated }`) e il gate di sessione
`migration_plan_ready` impostato dalla preview (`references/preview.md` §3). Questa
reference **consuma** entrambi i contratti, non li ridefinisce: la struttura del
piano e la regola del gate sono contratti downstream già fissati.

L'apply è l'**unica** modalità che scrive su disco. Materializza il piano: non
ricalcola la detection né rivaluta i casi ambigui/orfani — quelli sono già stati
classificati a monte e non vengono toccati.

Tre principi del `SKILL.md` governano l'intero protocollo:
- **Reversibile**: backup pre-apply integrale di `docs/` prima di ogni scrittura.
- **Idempotente**: una seconda apply su un repo già migrato è un no-op completo.
- **Niente commit automatici**: `git mv` quando il repo è git (preserva la
  history), fallback `mv` + nota; mai `git commit`.

---

## 1. Precondizioni

Prima di toccare qualsiasi file, l'apply verifica:

- **Gate di sessione**: `migration_plan_ready == true` (`preview.md` §3). Se
  `false`, abort immediato senza alcuna scrittura, con messaggio di redirect:
  `Nessuna preview valida nella sessione. Esegui prima "preview".`
- **`DetectionPlan` disponibile** in memoria di sessione (è la stessa preview che
  ha sbloccato il gate a produrlo).

Solo i `moves` del piano comportano scritture. `ambiguous`, `orphan` e
`already_migrated` sono informativi: l'apply non li tocca (fail-closed ereditato
dalla detection). Gli `already_migrated` confermano l'idempotenza già a livello di
piano; gli skip emersi al §3 li integrano a runtime (file di destinazione già
presente non previsto dal piano).

---

## 2. Sequenza operativa

Specchio della sequenza in `SKILL.md` §"apply", con il dettaglio operativo di
ogni step.

```text
1. Gate check        — migration_plan_ready == true, altrimenti abort (§1)
2. Backup            — copia integrale di docs/ in docs/.bak-<timestamp>/ (§4)
3. Move loop         — per ogni moves[]: git mv / mv idempotente (§3 idempotenza)
4. Source concluse   — sposta docs/features/<slug>/ → docs/archive/features/<slug>/
5. Manifest          — scrive docs/.bak-<timestamp>/apply-manifest.json (§5)
6. Report terminale  — riepilogo a schermo + istruzioni restore (§6)
7. Post-verify        — DELEGATO al task 005 (references/post-verify.md), NON inline
```

### Step 1 — Gate check

Vedi §1. Se il gate è chiuso, l'apply non parte e nulla viene scritto.

### Step 2 — Backup

Vedi §4. Operazione **bloccante e non skippabile**: se il backup fallisce, abort
prima di toccare qualsiasi file del piano. Senza backup non c'è reversibilità,
quindi non si procede.

### Step 3 — Move loop

Per ogni entry in `DetectionPlan.moves`:

```text
per ogni move { from, to, source_slug, archive } in moves:
  a. mkdir -p della directory padre di `to` (crea le dir intermedie se assenti)
  b. se `to` esiste già su disco:
       → skip + log "già migrato: <id>"
       → registra in moves_skipped { id, reason: "già migrato" }
       → continua (non muovere, non errore, non abort)
  c. se il repo è git:
       → git mv <from> <to>
  d. se il repo NON è git:
       → mv <from> <to>
       → log "repo non-git: mv usato, history non preservata"
  e. registra il move riuscito in moves_done { from, to }
```

L'ordine `mkdir -p` → check destinazione → move è vincolante: la creazione delle
dir intermedie non è condizionata dall'esito del check (il check b. riguarda il
file di destinazione, non la sua directory).

### Step 4 — Source concluse

Le source con `archive: true` in **almeno un** move vengono spostate dalla loro
posizione attiva all'archivio:

```text
docs/features/<slug>/   →   docs/archive/features/<slug>/
```

Vincolo d'ordine: l'archiviazione della directory della source avviene **solo dopo**
che tutti i brief di quella source sono stati processati al §3. Per le source
concluse, i `moves` portano già i brief direttamente in
`docs/archive/features/<slug>/tasks/` (`to` con prefisso archive, da
`detection.md` §2): lo spostamento §4 riguarda il **residuo** della directory
della source (planning, eventuali altri artefatti) non già ricollocato dai move.

Idempotenza: se `docs/features/<slug>/` non esiste più (2ª esecuzione, source già
archiviata), skip senza errore — vedi §3 idempotenza, caso "source conclusa già in
archivio".

### Step 5 — Manifest

Vedi §5. Scrive `docs/.bak-<timestamp>/apply-manifest.json` con `moves_done`,
`moves_skipped`, `sources_archived` e il `timestamp` del backup.

### Step 6 — Report terminale

Vedi §6. Stampa il riepilogo a schermo e le istruzioni di restore.

### Step 7 — Post-verify

**Delegato** a `references/post-verify.md` (task 005, `topology-migration-005`).
L'apply NON esegue il post-verify inline: si conclude dopo manifest + report e
rimanda l'utente al post-verify. Il `SKILL.md` §"apply" cita il post-verify come
step della sequenza, ma la sua logica è single-source nel task 005; questa
reference chiarisce la delega per evitare duplicazione.

---

## 3. Idempotenza — regole per ogni edge case

Una seconda apply su un repo già migrato deve essere un **no-op completo**:
nessun errore, nessun file duplicato, nessun danno.

| Caso | Condizione | Comportamento |
|---|---|---|
| File destinazione già esiste | `to` presente su disco | skip + log "già migrato"; entry in `moves_skipped`. Non errore, non abort |
| Backup già esistente | `docs/.bak-<timestamp>/` presente | nessun conflitto: ogni apply usa un timestamp distinto (§4) |
| Directory destinazione già esiste | dir padre di `to` presente | nessun problema: `mkdir -p` è idempotente |
| Source conclusa già archiviata | `docs/features/<slug>/` assente | skip dell'archiviazione §4, niente errore |

Il backup con timestamp distinto (§4) è ciò che rende l'idempotenza compatibile con
la reversibilità: una 2ª apply non può sovrascrivere né cancellare il backup di una
apply precedente.

---

## 4. Backup — strategia con timestamp

Prima di qualsiasi scrittura del piano, l'apply crea uno snapshot integrale
dell'albero `docs/`:

```text
docs/   →   docs/.bak-<ISO8601>/
```

- `<ISO8601>` è il timestamp dell'apply in formato file-safe, es.
  `docs/.bak-2026-06-01T12-00-00Z/` (`:` non ammessi nei path su alcuni FS →
  sostituiti con `-`).
- Lo snapshot è una **copia integrale** di `docs/` al momento dell'apply: serve da
  punto di restore universale (vale anche per file non ancora tracciati da git).
- Ogni apply crea un backup con **timestamp distinto**: nessuna sovrascrittura del
  backup precedente. Questo è il razionale della scelta `docs/.bak-<timestamp>/` al
  posto del `docs/.bak/` generico indicato dal task 001.
- Il backup **esclude** i backup precedenti (`docs/.bak-*/`) per evitare crescita
  ricorsiva dello snapshot.
- Operazione **bloccante**: se fallisce, abort prima di toccare qualsiasi file del
  piano (§2, step 2).

Struttura del backup:

```text
docs/.bak-<timestamp>/
  <copia integrale dell'albero docs/ al momento dell'apply>
  apply-manifest.json          ← scritto al §5, dentro lo stesso backup
```

---

## 5. Manifest — shape di `apply-manifest.json`

Path: `docs/.bak-<timestamp>/apply-manifest.json` (dentro il backup della stessa
apply). È un artefatto **machine-readable**, non un log human-readable: il log
operativo è stampato a schermo (§6), il manifest è la traccia persistente
consumata dal post-verify (task 005) e dall'eventuale debug.

```json
{
  "timestamp": "2026-06-01T12:00:00Z",
  "moves_done": [
    { "from": "docs/tasks/flow-sync-001.md", "to": "docs/features/flow-sync/tasks/flow-sync-001.md" }
  ],
  "moves_skipped": [
    { "id": "model-tiering-001", "reason": "già migrato" }
  ],
  "sources_archived": [
    { "slug": "flow-sync", "from": "docs/features/flow-sync/", "to": "docs/archive/features/flow-sync/" }
  ]
}
```

- `timestamp` — lo stesso usato per il nome del backup (ISO8601 canonico, con `:`).
- `moves_done` — i move effettivamente eseguiti al §3 step e. (`from`/`to`).
- `moves_skipped` — gli skip per idempotenza al §3 step b. (`id` + `reason`).
- `sources_archived` — le source concluse spostate al §4 (`slug`/`from`/`to`).

**Contratto downstream**: shape consumata dal post-verify (task 005). Non
modificare senza aggiornare `topology-migration-005`.

---

## 6. Report terminale

Al termine, l'apply stampa a schermo un riepilogo con i contatori e le istruzioni
di restore. Forma canonica:

```text
=== Apply migrazione — completata ===

Move effettuati (N):
  docs/tasks/<id>.md  →  docs/features/<slug>/tasks/<id>.md
  ...

Skip — già migrati (M):
  <id>

Source archiviate (S):
  docs/features/<slug>/  →  docs/archive/features/<slug>/

Riepilogo: N move effettuati, M skip (già migrati), S source archiviate.
Backup: docs/.bak-<timestamp>/ (manifest: docs/.bak-<timestamp>/apply-manifest.json)

Per ripristinare allo stato pre-apply:
  cp -r docs/.bak-<timestamp>/ docs/
  (oppure, in un repo git: git checkout HEAD -- docs/)

Prossimo passo: esegui il post-verify per confermare che ogni ID risolve al path
canonico.
```

Le sezioni a cardinalità 0 sono **omesse** dal corpo (coerente con il rendering
della preview), ma i contatori restano nel riepilogo.

---

## 7. Reversibilità — procedura di restore

Il ripristino dal backup è documentato sia inline nel report (§6) sia qui:

```text
Per ripristinare allo stato pre-apply:
  cp -r docs/.bak-<timestamp>/ docs/
  (oppure, in un repo git: git checkout HEAD -- docs/)
```

- `cp -r` dal `docs/.bak-<timestamp>/` è il metodo **universale**: ripristina ogni
  file dello snapshot, inclusi quelli non ancora tracciati da git al momento
  dell'apply.
- `git checkout HEAD -- docs/` ripristina **solo** i file tracciati: utile in repo
  git con working tree pulito, ma non copre file non ancora in index.

Più apply consecutive lasciano più backup `docs/.bak-<timestamp>/` distinti: il
restore usa quello con il timestamp dello stato a cui si vuole tornare.

---

## Riepilogo contratti

| Aspetto | Regola |
|---|---|
| Input | `DetectionPlan` (`detection.md`) + gate `migration_plan_ready` (`preview.md` §3) |
| Gate chiuso | abort senza scritture, redirect a `preview` |
| Scritture | solo durante apply; solo `moves` comporta spostamenti |
| Backup | `docs/.bak-<timestamp>/`, copia integrale, bloccante, esclude `.bak-*` |
| Move git | `git mv` se repo git (preserva history) |
| Move non-git | `mv` + nota "history non preservata" |
| Destinazione già esiste | skip + "già migrato", entry in `moves_skipped` |
| Dir intermedie | `mkdir -p` idempotente prima del move |
| Source conclusa | `docs/features/<slug>/` → `docs/archive/features/<slug>/`, dopo i move |
| Source già archiviata | skip, no errore (idempotenza) |
| Manifest | `docs/.bak-<timestamp>/apply-manifest.json`, contratto del task 005 |
| Report | riepilogo a schermo + istruzioni restore; sezioni a 0 omesse |
| Restore | `cp -r docs/.bak-<timestamp>/ docs/` (universale) o `git checkout HEAD -- docs/` |
| Post-verify | DELEGATO a `references/post-verify.md` (task 005), non inline |
| Commit git | mai (nessun `git commit` automatico) |
