# Brief tecnico — planner-unification-finalize-005

**Origin**: feature-planner
**Context-root**: docs/features/planner-unification-finalize/
**Feature**: planner-unification-finalize
**Status**: ✅ finalized

---

## Obiettivo

Documentare la catena `finalize` multi-livello: spiegare agli utenti (skill consumer) come eseguire la promozione della conoscenza lungo la catena `task → feature → epic → project`, illustrando il meccanismo single-hop + promozione manuale via `revise` oltre il padre diretto.

Definition of done: sezione dedicata in `skills/planner/references/finalize.md` che documenta la catena multi-livello con esempi concreti della catena `task→feature→epic→project`; inclusa la promozione manuale via `revise` per i livelli superiori.

---

## Analisi tecnica

### Tipo di task

Documentazione operativa: produce contenuto esclusivamente in `finalize.md` (nessun file di produzione nuovo). Non introduce contratti, non modifica logica.

### Cosa va documentato

Il task-004 ha validato i quattro casi limite e ha confermato che il single-hop è deterministico: ogni esecuzione di `planner finalize` risale al **padre diretto** (un solo hop). Per promuovere oltre bisogna eseguire manualmente `planner finalize` sul padre, livello per livello.

La catena completa da documentare:

```
task (docs/tasks/<slug>/)
  → planner finalize <task-slug>
      → technical-context.md della feature padre (un hop)

feature (docs/features/<slug>/)
  → planner finalize <feature-slug>
      → technical-context.md dell'epic padre (un hop)

epic (docs/epics/<slug>/)
  → planner finalize <epic-slug>
      → technical-context.md del progetto padre (un hop)

project (docs/planning/)
  → Bubble-up target: — (standalone; nessuna risalita)
```

### Esempio concreto da includere

Catena reale dell'epic `planner-unification`:

1. `planner finalize planner-unification-finalize-005` → appende in `docs/features/planner-unification-finalize/technical-context.md`
2. `planner finalize planner-unification-finalize` → appende in `docs/epics/planner-unification/technical-context.md`
3. `planner finalize planner-unification` → appende in `docs/planning/technical-context.md` (se esiste) o no-op standalone

Il secondo e terzo hop non avvengono automaticamente: l'utente decide quando e cosa promuovere.

### Promozione via `revise`

Quando le decisioni risalite all'epic o al progetto richiedono una revisione della strategia (non solo un append), l'utente usa `project-planner revise` (o `planner plan` con override esplicito) su `02-abstract.md` del tier appropriato. Documentare questa distinzione:

- bubble-up → accumula conoscenza tecnica tattica in `technical-context.md` (append-only)
- `revise` → revisione strategica di `02-abstract.md` (scrittura guidata, non append-only)

### Dove scrivere

Aggiungere un paragrafo `## Catena finalize multi-livello` in fondo a `skills/planner/references/finalize.md`, dopo lo Step 9 esistente. Non modificare i passi 1-9.

Struttura della sezione:

```markdown
## Catena finalize multi-livello

> Il bubble-up è single-hop deterministico: ogni `planner finalize` risale al padre
> diretto (via `Bubble-up target`). Per promuovere oltre, eseguire `planner finalize`
> sul padre, livello per livello.

### Schema della catena

<tabella o lista ordinata con i 4 livelli>

### Esempio — `planner-unification`

<catena concreta con i 3 comandi in sequenza>

### Promozione via `revise`

<distinzione tra bubble-up (tecnica tattica) e revise (strategia)>
```

---

## File impattati

| File | Stato | Note |
|---|---|---|
| `skills/planner/references/finalize.md` | [edit] | Aggiunta sezione `## Catena finalize multi-livello` in fondo, dopo Step 9 |

Nessun altro file. Il brief co-locato viene scritto dal PM come artefatto di brief, non è un file di produzione della feature.

---

## Vincoli risolti

- **Stack**: Markdown (nessun build/compilazione)
- **Librerie + versioni**: nessuna
- **VO/pattern/interfacce consumati** (da NON modificare):
  - Procedura finalize Steps 1-9 — `skills/planner/references/finalize.md` (intoccabile; solo append)
  - Anchor schema — `skills/planner/anchor-schema.md`; semantica `Bubble-up target: —`, back-compat anchor assente
  - Planning source contract v2 — `skills/planner/planning-source-contract.md`
  - Pattern append-only datato idempotente — heading `## Consolidato da <slug> (YYYY-MM-DD)`
  - Gate attended — `.flow/briefs/<id>/RESULT.json` + assenza `ESCALATION.json`
- **Naming convention**: invariata rispetto ai task precedenti

---

## Decisioni tecniche

- **Append in fondo a `finalize.md`, non modifica dei passi 1-9**: la sezione di documentazione della catena è una appendice referenziale, non altera il flusso operativo già validato da task-003 e task-004.
- **Esempio concreto sull'epic reale** (`planner-unification`): più efficace di un esempio astratto; l'utente può seguire la catena nei file esistenti come verifica.
- **Distinzione bubble-up vs `revise` esplicita**: ASSUMPTION-planner-unification-finalize-002 (promozione oltre il padre = manuale via `revise`) deve essere documentata nella stessa sezione per evitare uso improprio del bubble-up come meccanismo di revisione strategica.

---

## Out of scope per questo task

- Invocazione di `finalize` da flow-run → feature downstream dell'epic
- Retrofit dell'anchor sulle source esistenti → feature release
- Cascading bubble-up multi-livello automatico (by design: non implementato)
- Documentare `expand` (già coperto da `references/expand.md`)
- Modificare `technical-context.md` della feature (operazione del `finalize` stesso al momento della chiusura)

---

## Dipendenze

- **Upstream**: planner-unification-finalize-004 ✅ finalized — casi limite validati; single-hop confermato deterministico
- **Upstream**: planner-unification-finalize-003 ✅ finalized — `finalize.md` Step 1-9 completo; bubble-up single-hop implementato
- **Downstream**: nessuno (task conclusivo della feature)

---

## Verifica

Definition of done verificabile:

1. `skills/planner/references/finalize.md` contiene la sezione `## Catena finalize multi-livello` dopo lo Step 9.
2. La sezione include: schema dei 4 livelli con i comandi corrispondenti, esempio concreto sulla catena `planner-unification`, distinzione bubble-up vs `revise`.
3. I passi 1-9 esistenti sono inalterati (nessuna modifica al flusso operativo).

Subtask: nessuno necessario, esecuzione lineare.

---

Generato: 2026-06-02 | Task: planner-unification-finalize-005
