# Brief tecnico — planner-unification-finalize-003

**Origin**: feature-planner
**Context-root**: docs/features/planner-unification-finalize/
**Feature**: planner-unification-finalize
**Status**: ✅ finalized

---

## Obiettivo

Implementare il bubble-up single-hop selettivo in `skills/planner/references/finalize.md`: lo Step 9 del flusso `finalize` che, dopo la risoluzione dell'anchor (Step 3 di finalize-002), seleziona il sottoinsieme coerente di informazioni da risalire al padre, esegue UN solo salto con append-only datato e guardia di idempotenza.

Questo task supera e sostituisce il bubble-up grezzo (copia integrale) introdotto in otto 1.1.0 lato flow-run.

---

## Analisi tecnica

### Posizionamento nel flusso `finalize`

Il flusso di `finalize.md` (prodotto da finalize-002) ha 8 step. Questo task aggiunge **Step 9 — Bubble-up single-hop selettivo**, eseguito solo se il `Bubble-up target` risolto in Step 3 è un path valorizzato (non `—`):

```
finalize <scope>
  ... [Step 1-8 già implementati da finalize-002] ...

  9. [BUBBLE-UP] — solo se Bubble-up target = <path>
     a. Verifica guardia di idempotenza
     b. Selezione sottoinsieme coerente
     c. Append-only datato al file target
     d. Aggiorna summary (Step 8 diventa Step 9 come trigger del summary)
```

### Step 9 — Bubble-up single-hop selettivo (shape)

```
9. [BUBBLE-UP SINGLE-HOP]

  Precondizione: Bubble-up target = <path> (valorizzato in Step 3).
  Se Bubble-up target = — o anchor assente → questo step è già no-op (Step 3 lo segnala);
  Step 9 non viene eseguito.

  a. GUARDIA IDEMPOTENZA
     Leggi <Bubble-up target> (technical-context.md del padre).
     Cerca: `## Consolidato da <slug> (` dove <slug> = slug della source corrente.
     - Trovato → idempotenza: la risalita è già avvenuta. Segnala nel summary:
       "bubble-up già eseguito (idempotente, skip)"
       Non modificare il file target. Vai al summary.
     - Non trovato → procedi con b.

  b. SELEZIONE SOTTOINSIEME COERENTE
     Leggi <context-root>/technical-context.md (source corrente).
     Estrai le sezioni "## Decisioni introdotte da ..." presenti.
     Presenta all'utente:
       "Sto per risalire al padre (<Bubble-up target>).
        Queste sono le decisioni candidate alla risalita:
        [lista sezioni con titolo e sintesi]
        Risali tutte o vuoi escludere qualcosa? (tutte / escludi N, M, ...)"
     Attendi risposta prima di procedere.

  c. APPEND-ONLY DATATO
     In <Bubble-up target> appendi in fondo:

     ```markdown
     ## Consolidato da <slug> (<YYYY-MM-DD>)
     > Decisioni durevoli risalite dalla feature `<slug>` a fine feature
     > (bubble-up single-hop). Vincolanti per le feature successive.

     <contenuto selezionato — copia fedele delle sezioni scelte, senza reinventare>
     ```

     - YYYY-MM-DD = data di esecuzione del finalize (data corrente).
     - <slug> = slug della source (es. `planner-unification-finalize`).
     - Il contenuto è copia fedele: non riassumere né riscrivere; copiare le sezioni
       selezionate integralmente.
     - Nessuna cancellazione o modifica del contenuto esistente nel file target.

  d. CONFERMA
     Segnala nel summary:
       "bubble-up eseguito su <Bubble-up target> — N sezioni risalite"
```

### Guardia di idempotenza — dettaglio

Il criterio di presenza si basa sull'heading `## Consolidato da <slug>`:

```bash
# Bash-compatible (grep deterministico)
SLUG="planner-unification-finalize"   # slug della source corrente
TARGET="docs/epics/planner-unification/technical-context.md"

if grep -qF "## Consolidato da ${SLUG}" "$TARGET"; then
  echo "idempotente — skip"
else
  echo "procedi con append"
fi
```

Il pattern è `## Consolidato da <slug>` (non include la data): così un re-run su source già
risalita è sempre skip, indipendentemente dalla data dell'esecuzione precedente.

### Selezione del sottoinsieme coerente — principi

La selezione è guidata dall'utente (non automatica), ma il sistema propone il candidato
completo come punto di partenza. Principi per la selezione:

1. **Risalgono le decisioni durevoli**: pattern, convenzioni, contratti introdotti dal task
   che vincolano i successori nel parent tier.
2. **Non risalgono i dettagli implementativi**: step operativi, verifica, shape di codice
   marcate "non implementazione finale" — restano nel brief co-locato.
3. **Non risalgono i "no-op" e i vincoli già noti al padre**: voci che il padre già contiene
   o che sono back-compat implicita.

Questa euristica è presentata all'utente come guida alla selezione, non come filtro
automatico. La decisione finale è dell'utente.

### Aggiornamento `references/finalize.md`

Il task aggiunge Step 9 al file `skills/planner/references/finalize.md` esistente, in append.
La struttura del file resta invariata: gli Step 1-8 non vengono modificati.

Shape dello Step 9 da aggiungere:

```markdown
## Step 9 — Bubble-up single-hop selettivo

> Eseguito SOLO se `Bubble-up target` valorizzato (non `—`, non anchor assente).

### 9a — Guardia di idempotenza
[grep deterministico su `## Consolidato da <slug>`; se trovato → skip idempotente]

### 9b — Selezione sottoinsieme coerente
[presentazione candidati all'utente; attesa risposta; nessun filtro automatico]

### 9c — Append-only datato
[heading canonico `## Consolidato da <slug> (YYYY-MM-DD)`; copia fedele; non riscrive]

### 9d — Summary aggiornato
[formato: "bubble-up eseguito su <path> — N sezioni" oppure "idempotente, skip"]
```

### Aggiornamento Summary (Step 8)

Lo Step 8 di `finalize.md` riporta:

```
- nota: bubble-up effettivo → planner-unification-finalize-003
```

Con questo task, quella nota viene **rimossa** e sostituita dal report effettivo di Step 9:

```
- bubble-up: eseguito su <path> — N sezioni risalite
  oppure
- bubble-up: skip — già eseguito (idempotente)
  oppure
- bubble-up: nessuno (source standalone)
```

Questo è l'unico punto in cui Step 8 viene modificato.

### Supersede del bubble-up grezzo di otto 1.1.0

La implementazione consente di documentare esplicitamente nel `finalize.md` che il bubble-up
single-hop selettivo **supersede** il comportamento precedente. Il note è parte del file
reference (non del SKILL.md), come nota architetturale:

```markdown
> **Supersede**: il bubble-up grezzo (copia integrale di `technical-context.md`) introdotto
> in otto 1.1.0 lato flow-run. Il bubble-up è ora di proprietà di `planner finalize`,
> eseguito single-hop selettivamente, con guardia di idempotenza.
> L'invocazione da flow-run è gestita dalla feature downstream dell'epic.
```

---

## File impattati

| File | Stato | Note |
|---|---|---|
| `skills/planner/references/finalize.md` | [edit] | Aggiunge Step 9 (bubble-up single-hop selettivo) + modifica nota in Step 8 summary |

---

## Vincoli risolti

- **Stack**: Markdown + bash (skill Claude Code; nessun build/compilazione)
- **Librerie + versioni**: nessuna
- **VO/pattern/interfacce consumati** (da NON modificare):
  - Pattern append-only datato idempotente: heading `## Consolidato da <slug> (YYYY-MM-DD)` — definito in `docs/epics/planner-unification/technical-context.md` § "Pattern architetturali condivisi"; già usato in otto 1.1.0
  - Anchor schema (`skills/planner/anchor-schema.md`) — `Bubble-up target`, semantica `—`, back-compat anchor assente
  - Planning source contract v2 (`skills/planner/planning-source-contract.md`) — slug della source, path `technical-context.md`
  - Contratto gate attended (finalize-002): Step 1-8 di `finalize.md` invariati; Step 9 è additivo
  - Procedura finalize/bubble-up (definita in `technical-context.md` feature) — implementazione di questa feature conclude la definizione
- **Naming convention**:
  - Heading bubble-up: `## Consolidato da <slug> (YYYY-MM-DD)` (invariato rispetto a 1.1.0)
  - Guardia idempotenza: `## Consolidato da <slug>` (no data nel grep — compatibile con qualunque data)

---

## Decisioni tecniche

- **Step 9 è additivo, non modifica gli Step 1-8**: boundary netto tra infrastruttura (finalize-002) e contenuto (questo task). Riduce il rischio di regressione.
- **Selezione guidata dall'utente, non automatica**: la valutazione di "cosa risale" è un judgment soggettivo (RISK-planner-unification-finalize-002). Il sistema propone il candidato completo; la decisione finale è dell'utente. Evita propagazioni opache.
- **Copia fedele, non riassunto**: il bubble-up copia le sezioni selezionate integralmente. Riassumere introdurrebbe perdita di informazione e soggettività; il padre deve ricevere le decisioni esatte, non una sintesi.
- **Guardia idempotenza senza data**: il grep usa `## Consolidato da <slug>` senza la data — così un re-run identifica correttamente la risalita già eseguita anche se le date differiscono (es. re-run il giorno dopo). La data è solo documentativa nell'heading, non parte della guardia.
- **Un solo hop**: il bubble-up risale al padre diretto (la source usa il suo `Bubble-up target`). Non esegue un secondo hop sul nonno — quello è responsabilità di un successivo `planner finalize` eseguito sul padre. Cascading multi-livello resta manuale via `revise`.
- **Nota "supersede 1.1.0" nel reference**: documentata nel `finalize.md` come nota architetturale — non nel SKILL.md (troppo dettagliata per il router). Il SKILL.md resta sottile.

---

## Out of scope per questo task

- Invocazione di `finalize` da flow-run (il ripuntamento è della feature downstream dell'epic)
- Cascading bubble-up multi-livello (promozione oltre il padre resta manuale via `revise`)
- Retrofit dell'anchor sulle source esistenti (→ feature release)
- Gestione casi limite (re-run idempotente end-to-end, conflitto slug, catena multi-livello) → planner-unification-finalize-004
- Documentazione della catena finalize multi-livello → planner-unification-finalize-005
- Modifica degli Step 1-7 di `finalize.md`

---

## Dipendenze

- **Upstream**: planner-unification-finalize-002 ✅ finalized — `finalize.md` con Step 1-8 esiste; `Bubble-up target` già risolto in Step 3 è il contratto di input per Step 9
- **Downstream**: planner-unification-finalize-004 — consuma il bubble-up per dogfooding dei casi limite; planner-unification-finalize-005 — documenta la catena

---

## Verifica

Dogfooding manuale:

1. Gate e risoluzione anchor già verificati da finalize-002: lo step 9 si inserisce dopo step 8; prerequisiti mantenuti.
2. Invocare `finalize planner-unification-finalize-003` su source con `Bubble-up target` valorizzato → sistema presenta le sezioni candidate, attende selezione utente, appende al target con heading canonico.
3. Re-invocare `finalize planner-unification-finalize-003` sulla stessa source → guardia idempotenza attiva, skip; summary segnala "già eseguito".
4. Invocare su source con `Bubble-up target: —` → Step 9 non eseguito; summary segnala "nessuno (source standalone)".
5. Verificare che `finalize.md` contenga Step 9 con le 4 sottosezioni (9a-9d).
6. Verificare che lo Step 8 summary non contenga più la nota "bubble-up effettivo → planner-unification-finalize-003".
7. Verificare heading idempotenza: `grep "## Consolidato da planner-unification-finalize" docs/epics/planner-unification/technical-context.md` — trovato dopo la prima esecuzione.

Subtask: nessuno necessario, esecuzione lineare.

---

Generato: 2026-06-02 | Task: planner-unification-finalize-003
