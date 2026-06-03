# Detection — riconoscimento layout e risoluzione brief→source

Reference consumata da `skills/migrate/SKILL.md` §"Detection". Codifica tre capacità:
riconoscimento del layout (vecchio vs nuovo), scan delle source con risoluzione
`ID → source target`, produzione di un piano strutturato (`DetectionPlan`).

Il contratto canonico di risoluzione è `planner/planning-source-contract.md`
§"Planning source contract" (resolver `topology-canonical`): la detection lo
**usa**, non lo ridefinisce. Da quel contratto deriva anche la regola
`docs/archive/**` escluso dallo scan.

Due principi del `SKILL.md` sono implementati qui:
- **Fail-closed**: nel dubbio non si muove (ORFANO / AMBIGUO).
- **Idempotente**: ciò che è già al path canonico non rientra nei move
  (`already_migrated`).

La detection **non scrive nulla su disco**. Produce solo il `DetectionPlan` in
memoria, consumato dalla preview (task 003) e dall'apply (task 004). La logica di
scrittura/spostamento è in `apply-protocol.md`.

---

## 1. Riconoscimento del layout (vecchio vs nuovo)

Il riconoscimento è **per-brief**, non per-repo: in un caso misto alcuni brief
sono già migrati e altri no. Il giudizio "vecchio layout" sotto serve solo a
decidere se c'è lavoro di migrazione da fare; la classificazione vincolante
avviene comunque brief per brief nello scan (§2).

### Segnali di "vecchio layout"

Basta **uno o più** dei seguenti:

- Esistono file `docs/tasks/*.md` — brief flat, non sotto una sub-directory
  `tasks/` di una feature.
- Non esiste `docs/archive/`, oppure esiste ma è vuota.
- Esiste `.flow/PROGRESS.json` con lista task cross-feature nello shape storico
  `{ "tasks": [...] }` (lista piatta, senza partizione per-source).

### Segnale di "nuovo layout" (canonico)

Nessuno dei segnali precedenti è presente, **oppure** ogni ID elencato nei
`docs/features/*/tasks-active.md` ha già il proprio brief al path canonico
`<context-root>/tasks/<id>.md`.

### Caso misto

Repo in transizione: alcuni brief migrati, altri ancora flat. La detection non
emette un verdetto globale "vecchio/nuovo" — classifica ogni brief
individualmente (§2). I brief già al path canonico finiscono in
`already_migrated`; i brief flat residui vengono risolti normalmente.

---

## 2. Scan delle source e risoluzione `ID → source target`

Lo scan legge **solo** i file piano `tasks-active.md`, cercando l'ID come
stringa. Non apre i brief. `docs/archive/**` è **escluso** dallo scan: un brief
già archiviato non partecipa alla risoluzione (regola del resolver canonico).

Match = substring `<id>` presente nel `tasks-active.md` (tipicamente nella riga
`### <id> —`).

### Algoritmo

```
per ogni file <id>.md in docs/tasks/:
  estrai <id> dal nome file

  # idempotenza: già al path canonico?
  slug = slug_da_id(<id>)
  se esiste <context-root(slug)>/tasks/<id>.md:
    → already_migrated { id, canonical_path }
    → continua (non entra nei moves)

  # scan delle source (escludi docs/archive/**)
  matches = source S in docs/features/*/ tali che
            tasks-active.md di S contiene la stringa <id>

  se |matches| == 0  → orphan    { id, reason: "0 match" }
  se |matches| >  1  → ambiguous { id, reason: "N match: <slug1>, <slug2>, ..." }
  se |matches| == 1:
    source = docs/features/<slug>/
    se source_conclusa(source):
      to      = docs/archive/features/<slug>/tasks/<id>.md
      archive = true
    altrimenti:
      to      = docs/features/<slug>/tasks/<id>.md
      archive = false
    → moves { from: docs/tasks/<id>.md, to, source_slug: <slug>, archive }
```

### `slug_da_id(<id>)`

Lo slug è il prefisso dell'ID prima del suffisso numerico `-NNN`:
- `flow-sync-001` → slug `flow-sync`
- `model-tiering-003` → slug `model-tiering`
- `topology-migration-002` → slug `topology-migration`

Path canonico della source: `docs/features/<slug>/`; path canonico del brief:
`docs/features/<slug>/tasks/<id>.md`. La risoluzione del path resta delegata al
contratto del resolver canonico; lo slug serve come chiave di lookup, non come
fonte di verità del path.

### `source_conclusa(source)`

Una source è **conclusa** quando, nel suo `tasks-active.md`, **tutti** i task
risultano `Status: ✅ done` (campo done presente per ogni task). In quel caso i
brief migrati vanno in `docs/archive/features/<slug>/tasks/` (`archive: true`).

Se anche un solo task è in stato `todo` / `in-progress` (o privo del campo done),
la source è attiva: i brief restano in `docs/features/<slug>/tasks/`
(`archive: false`).

---

## 3. Output strutturato — `DetectionPlan`

La detection produce un piano in memoria con quattro categorie disgiunte. È un
**contratto downstream**: consumato dalla preview (task 003) e dall'apply
(task 004). Non modificare la struttura senza aggiornare i task downstream.

```
DetectionPlan {
  moves:            [{ from: string, to: string, source_slug: string, archive: bool }]
  ambiguous:        [{ id: string, reason: string }]
  orphan:           [{ id: string, reason: string }]
  already_migrated: [{ id: string, canonical_path: string }]
}
```

Semantica delle categorie:

- **`moves`** — brief risolti con destinazione univoca. `from` = path flat
  attuale; `to` = path canonico (in `docs/features/<slug>/tasks/` o, per source
  conclusa, in `docs/archive/features/<slug>/tasks/`); `archive` riflette la
  scelta di destinazione. Solo questi vengono spostati dall'apply.
- **`ambiguous`** — ID che risolve a più di una source (`>1 match`).
  Fail-closed: non mosso. `reason` elenca gli slug in conflitto.
- **`orphan`** — ID non trovato in nessun `tasks-active.md` (`0 match`).
  Fail-closed: non mosso.
- **`already_migrated`** — brief già presente al path canonico. Idempotenza: non
  entra nei `moves`. `canonical_path` è il path canonico già occupato.

Solo `moves` comporta scritture. `ambiguous`, `orphan` e `already_migrated` sono
informativi: la preview li riporta, l'apply non li tocca.

---

## 4. Limite e fail-safe dello scan

- Lo scan legge **solo** i `tasks-active.md` (file piano). Non legge i brief.
- Match = substring `<id>` nel file. Nessun parsing semantico del piano è
  richiesto per la risoluzione.
- **Parsing fail su un `tasks-active.md`**: se la lettura/parsing di un file
  piano fallisce, registrare (log) il file problematico e trattare gli ID che
  matcherebbero quel file come **non risolvibili** (→ `orphan`) anziché
  interrompere l'intera detection. Fail-closed: meglio non muovere che muovere
  su dati corrotti.

---

## 5. Edge case — source senza `tasks-active.md`

Se una feature ha la directory `docs/features/<slug>/` ma **non** il file
`tasks-active.md` (file assente, non solo vuoto), la source non è scansionabile.
In questo caso i brief con ID che, per slug, matcherebbero quella feature vanno
classificati come **AMBIGUO**, non ORFANO.

Razionale: trattarli da ORFANO suggerirebbe "nessuna source", quando invece una
source plausibile esiste ma non è verificabile. Classificarli AMBIGUO è la scelta
conservativa (fail-closed): non si muove e si segnala per intervento manuale.

---

## Riepilogo contratti

| Aspetto | Regola |
|---|---|
| Fonte del path canonico | resolver `topology-canonical` (`feature-artifacts.md`) |
| Scope scan | `docs/features/*/tasks-active.md` |
| Esclusione | `docs/archive/**` |
| Match | substring `<id>` nel file piano |
| 0 match | `orphan` (fail-closed) |
| >1 match | `ambiguous` (fail-closed) |
| già canonico | `already_migrated` (idempotenza) |
| source conclusa | tutti `Status: ✅ done` → `archive: true` |
| `tasks-active.md` assente | `ambiguous` (fail-closed), non `orphan` |
| parsing fail | log + `orphan` (fail-closed) |
| scritture | nessuna (delegate ad `apply-protocol.md`) |
