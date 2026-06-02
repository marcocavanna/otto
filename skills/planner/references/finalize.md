# Finalize — Planner

> Letto da `SKILL.md` § "finalize <scope>" allo step di chiusura task.
> Dipendenze: `../planning-source-contract.md` (risoluzione slug, path brief co-locato),
> `../anchor-schema.md` (parsing `<!-- Anchor -->`, semantica `Bubble-up target`, back-compat).

---

## Step 1 — Risoluzione slug / source

**Input**: `<scope>` — slug parziale o completo, oppure path parziale.

**Algoritmo** (identico a `expand.md` § Step 1 — da `../planning-source-contract.md` § "Algoritmo di risoluzione"):

1. Scan per directory di tutti i tasks-file per i 4 tier:
   - `project` → `docs/planning/05-tasks-active.md`
   - `epic` → `docs/epics/*/tasks-active.md`
   - `feature` → `docs/features/*/tasks-active.md`
   - `task` → `docs/tasks/*/tasks-active.md`
2. Esclude `docs/archive/**` dallo scan.
3. Per ogni tasks-file trovato: controlla se la directory (o il path del file) contiene `<scope>` come sottostringa o se corrisponde esattamente allo slug.
4. Esito:
   - **0 match** → errore: `"source sconosciuta: <scope>"`. Interrompi.
   - **1 match** → context-root confermata; procedi al Step 2.
   - **>1 match** → elenca i candidati e chiedi selezione esplicita (vedi sotto). Non procedere autonomamente.

**Gestione conflitto (>1 candidato)**:

```
finalize planner-unification
→ Trovate 2 source con "<scope>" nel path:
  [1] docs/features/planner-unification-finalize/tasks-active.md
  [2] docs/epics/planner-unification/tasks-active.md
Quale source vuoi finalizzare? (1/2)
```

Non procedere fino alla selezione esplicita dell'utente.

**Disambiguazione task ID**: la source identifica lo slug; il task da finalizzare (`<id>`) è
l'ID specifico che si sta chiudendo (es. `planner-unification-finalize-002`), non lo scope
della source. In modalità attended il PM lo passa direttamente; in modalità standalone
l'utente lo specifica o viene dedotto dal `current_task` del PROGRESS.json della source.

---

## Step 2 — Gate attended

**Verifica precondizioni** per il task `<id>` prima di qualsiasi modifica. Legge:

```
.flow/briefs/<id>/
  RESULT.json     → obbligatorio; deve contenere "verify": "pass"
  ESCALATION.json → se esiste → gate bloccato (assenza = OK)
```

**Logica di valutazione**:

| Condizione | Esito |
|---|---|
| `RESULT.json` mancante | BLOCKED — `verify=mancante` |
| `RESULT.json` con `"verify": "fail"` | BLOCKED — `verify=fail` |
| `ESCALATION.json` presente | BLOCKED — `escalation aperta` |
| `RESULT.json` con `"verify": "pass"` **e** nessun `ESCALATION.json` | gate OK → procedi |

**Output se BLOCKED**:

```
BLOCKED: finalize negato — verify=<valore|mancante> / escalation aperta
```

Il gate è **fail-early**: se non passa, nulla viene modificato (né brief, né technical-context.md,
né SKILL.md). Non chiedere conferma: blocco immediato.

---

## Step 3 — Risoluzione anchor del padre

**Input**: `<context-root>/technical-context.md` dalla source risolta al Step 1.

**Parsing bash deterministico**:

```bash
ANCHOR_LINE=$(grep '<!-- Anchor -->' "<context-root>/technical-context.md" | head -1)
BUBBLE_TARGET=$(echo "$ANCHOR_LINE" | sed 's/.*\*\*Bubble-up target\*\*: //' | sed 's/ *$//')
# Valori attesi: "—" | "<path>"
```

Il separatore `·` (U+00B7) è gestito implicitamente: si legge il campo dopo
`**Bubble-up target**: ` fino a fine riga, che segue l'ultimo separatore.

**Valutazione**:

| Condizione | Comportamento |
|---|---|
| Riga `<!-- Anchor -->` assente | no-op di risalita — back-compat implicita |
| `Bubble-up target: —` | no-op di risalita — standalone esplicito |
| `Bubble-up target: <path>` | memorizza `<path>` come target del bubble-up (eseguito in 003) |

Il no-op è **sempre comunicato esplicitamente** nel summary (non silenzioso).

---

## Step 4 — Lettura decisioni del brief

Leggi `<context-root>/tasks/<id>.md` (brief co-locato — da `../planning-source-contract.md`
§ "Path del brief"):

1. Sezione **"Decisioni tecniche"** — decisioni prese durante l'analisi/pianificazione.
2. Sezione **"Vincoli risolti"** — stack, librerie, VO/pattern/interfacce, naming convention.
3. Sezione **"Deviazioni durante l'implementazione"** (se presente) — delta rispetto al piano.

**Output**: presenta all'utente il delta consolidato:

```
Decisioni del brief <id>:
- [lista decisioni tecniche]

Deviazioni registrate:
- [lista deviazioni | "nessuna"]
```

---

## Step 5 — Aggiornamento technical-context.md (locale)

**Domanda obbligatoria** (non saltabile):

```
Qualcosa in technical-context.md è cambiato per effetto di questo task?
(es. libreria diversa, pattern modificato, naming convention introdotta) (sì/no)
```

- **No** → nessuna modifica a `<context-root>/technical-context.md`. Prosegui.
- **Sì** → chiedi all'utente il contenuto della modifica, poi scrivi in **append-only**:

```markdown
## Decisioni introdotte da <id> (<titolo>)

<contenuto fornito dall'utente>
```

L'append-only garantisce la non-distruttività: non si riscrivono sezioni esistenti.

---

## Step 6 — Finalizzazione brief

Aggiorna l'header del brief `<context-root>/tasks/<id>.md`:

```
Status: ✅ finalized
```

**Non toccare** `tasks-active.md`: la gestione dello stato nei tasks-file è responsabilità
dell'utente o di `project-planner`. Questa skill aggiorna solo il brief.

---

## Step 7 — Aggiornamento SKILL.md

Sostituisce lo stub nella sezione `### finalize <scope>` di `skills/planner/SKILL.md`:

**Prima (stub)**:
```markdown
### finalize <scope>

> Rimandato — feature `planner-unification-finalize`.
```

**Dopo (flusso reale)**:
```markdown
### finalize <scope>

Chiude un task: verifica il gate attended (RESULT.json + assenza ESCALATION.json),
risolve l'anchor del padre, aggiorna technical-context.md locale (append-only),
e prepara il bubble-up single-hop selettivo.
Logica completa: `references/finalize.md`.
```

Questo step viene eseguito **una sola volta**: se SKILL.md non contiene più lo stub
"Rimandato", lo step è già applicato (idempotente via guard check).

---

## Step 8 — Summary

Output finale obbligatorio:

```
Finalize completato per <id>:
- task finalizzato: <id> → ✅ finalized
- technical-context.md aggiornato: sì / no
- bubble-up target: <path> | "nessuno (source standalone)"
- bubble-up: eseguito su <path> — N sezioni risalite
  oppure
- bubble-up: skip — già eseguito (idempotente)
  oppure
- bubble-up: nessuno (source standalone)
```

Se il no-op di risalita è attivo, la riga `bubble-up target` deve **esplicitare il motivo**:

```
- bubble-up target: nessuno (anchor assente — back-compat)
  oppure
- bubble-up target: nessuno (Bubble-up target: — — source standalone)
```

---

## Step 9 — Bubble-up single-hop selettivo

> Eseguito SOLO se `Bubble-up target` valorizzato (non `—`, non anchor assente).
> Se Step 3 ha risolto un no-op, questo step è già saltato — nessuna azione.

> **Supersede**: il bubble-up grezzo (copia integrale di `technical-context.md`) introdotto
> in otto 1.1.0 lato flow-run. Il bubble-up è ora di proprietà di `planner finalize`,
> eseguito single-hop selettivamente, con guardia di idempotenza.
> L'invocazione da flow-run è gestita dalla feature downstream dell'epic.

### 9a — Guardia di idempotenza

Leggi `<Bubble-up target>` (il `technical-context.md` del padre, path risolto in Step 3).

Cerca l'heading:

```bash
SLUG="<slug-source-corrente>"   # slug della source (da planning-source-contract.md)
TARGET="<Bubble-up target>"

if grep -qF "## Consolidato da ${SLUG}" "$TARGET"; then
  echo "idempotente — skip"
else
  echo "procedi con 9b"
fi
```

Il pattern di ricerca è `## Consolidato da <slug>` **senza la data**: così un re-run
identifica correttamente la risalita già eseguita indipendentemente dalla data di esecuzione.

| Esito grep | Comportamento |
|---|---|
| Heading trovato | skip idempotente — vai direttamente al summary (Step 8); segnala "bubble-up: skip — già eseguito (idempotente)" |
| Heading non trovato | procedi con 9b |

### 9b — Selezione sottoinsieme coerente

Leggi `<context-root>/technical-context.md` (source corrente).
Estrai tutte le sezioni `## Decisioni introdotte da ...` presenti.

Presenta all'utente:

```
Sto per risalire al padre (<Bubble-up target>).
Queste sono le decisioni candidate alla risalita:
  [1] ## Decisioni introdotte da <id-A> (<titolo>) — <sintesi 1 riga>
  [2] ## Decisioni introdotte da <id-B> (<titolo>) — <sintesi 1 riga>
  ...
Risali tutte o vuoi escludere qualcosa? (tutte / escludi N, M, ...)
```

Attendi risposta prima di procedere. Non filtrare automaticamente.

Principi guida da presentare all'utente come orientamento (non come filtro automatico):
- **Risalgono** le decisioni durevoli: pattern, convenzioni, contratti che vincolano i successori nel parent tier.
- **Non risalgono** i dettagli implementativi: step operativi, shape di codice marcate "non implementazione finale".
- **Non risalgono** i no-op e i vincoli già noti al padre o già presenti nel target.

### 9c — Append-only datato

Con le sezioni selezionate, appendi in fondo a `<Bubble-up target>`:

```markdown
## Consolidato da <slug> (<YYYY-MM-DD>)
> Decisioni durevoli risalite dalla feature `<slug>` a fine feature
> (bubble-up single-hop). Vincolanti per le feature successive.

<contenuto selezionato — copia fedele delle sezioni scelte, senza reinventare>
```

Regole:
- `YYYY-MM-DD` = data di esecuzione del finalize (data corrente).
- `<slug>` = slug della source corrente (da `planning-source-contract.md`).
- Il contenuto è **copia fedele**: non riassumere né riscrivere; copiare le sezioni selezionate integralmente.
- Nessuna cancellazione o modifica del contenuto esistente nel file target.
- Un solo hop: si risale al padre diretto. Il nonno è responsabilità di un successivo `planner finalize` eseguito sul padre.

### 9d — Summary aggiornato

Segnala nel summary finale (Step 8):

```
- bubble-up: eseguito su <Bubble-up target> — N sezioni risalite
```

oppure, se la guardia 9a ha rilevato idempotenza:

```
- bubble-up: skip — già eseguito (idempotente)
```

---

## Catena finalize multi-livello

> Il bubble-up è **single-hop deterministico**: ogni `planner finalize` risale al padre
> diretto (via `Bubble-up target`). Per promuovere oltre, eseguire `planner finalize`
> sul padre, livello per livello. Nessuna cascata automatica.

### Schema della catena

La catena completa di promozione della conoscenza copre **4 livelli**:

| Livello | Path | Comando | Destinazione bubble-up |
|---------|------|---------|------------------------|
| **Task** | `docs/tasks/<slug>/` | `planner finalize <task-slug>` | `docs/features/<feature-slug>/technical-context.md` |
| **Feature** | `docs/features/<slug>/` | `planner finalize <feature-slug>` | `docs/epics/<epic-slug>/technical-context.md` |
| **Epic** | `docs/epics/<slug>/` | `planner finalize <epic-slug>` | `docs/planning/technical-context.md` (se esiste) |
| **Project** | `docs/planning/` | N/A | — (standalone; nessuna risalita) |

Ogni livello riporta le **decisioni durevoli** (pattern, convenzioni, contratti) al livello padre **una sola volta** (idempotente). Dettagli implementativi e step operativi non risalgono.

### Esempio — `planner-unification`

Catena reale della feature `planner-unification-finalize` verso l'epic `planner-unification`:

**Passo 1: Finalizza il task**
```bash
planner finalize planner-unification-finalize-005
→ Bubble-up target: docs/features/planner-unification-finalize/technical-context.md
→ Risalgono le decisioni durevoli da task a feature
```

Risultato: `docs/features/planner-unification-finalize/technical-context.md` contiene:
```markdown
## Consolidato da planner-unification-finalize-005 (YYYY-MM-DD)
> Decisioni durevoli risalite dalla task ...
```

**Passo 2: Finalizza la feature**
```bash
planner finalize planner-unification-finalize
→ Bubble-up target: docs/epics/planner-unification/technical-context.md
→ Risalgono le decisioni durevoli (incluse quelle consolidate dal task precedente)
```

Risultato: `docs/epics/planner-unification/technical-context.md` contiene:
```markdown
## Consolidato da planner-unification-finalize (YYYY-MM-DD)
> Decisioni durevoli risalite dalla feature ...
```

**Passo 3: Finalizza l'epic**
```bash
planner finalize planner-unification
→ Bubble-up target: docs/planning/technical-context.md (se esiste)
→ Risalgono le decisioni durevoli a livello di planning
```

Risultato: `docs/planning/technical-context.md` contiene:
```markdown
## Consolidato da planner-unification (YYYY-MM-DD)
> Decisioni durevoli risalite dall'epic ...
```

**Nota**: nessuno di questi hop avviene automaticamente. L'utente decide **quando** e **cosa**
promuovere via `revise` o quando eseguire il finalize successivo.

### Promozione strategica via `revise`

Quando le decisioni risalite richiedono una **revisione della strategia** (non solo accumulo
tecnico), l'utente usa `project-planner revise` su `02-abstract.md` del tier appropriato.

**Distinzione**:

- **Bubble-up** (`planner finalize`): accumula conoscenza tecnica **tattica** in `technical-context.md` (append-only, idempotente).
  - Serve a non dimenticare vincoli implementativi importanti.
  - Vincolante per i task futuri nello stesso tier.
  - Non richiede decisioni strategiche.

- **Revise** (`project-planner revise`): revisione **strategica** di `02-abstract.md` (scrittura guidata, non append-only).
  - Serve a reorientare il plan se i vincoli emersi durante l'implementazione contraddicono le assunzioni di planning.
  - Es. se un task scopre che un'interfaccia deve cambiare, il revise aggiorna l'abstract della feature prima di lanciare task dipendenti.
  - Non obbligatorio se il bubble-up tecnico basta a informare i successori.

**Esempio di revise**: se il task `planner-unification-finalize-005` scopre che il protocolo
`finalize` non può supportare cascata automatica (by design), il bubble-up documenta il vincolo
in `technical-context.md`. Se però questo significa che il progetto planning non ha abbastanza risorse per implementare il multi-hop, il revise aggiorna il `02-abstract.md` dell'epic
per dichiarare esplicitamente "single-hop only" come strategic decision.

---

Generato: 2026-06-02 | Task: planner-unification-finalize-003
