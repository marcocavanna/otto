---
Task: fast-path-solo-004
Feature: fast-path-solo
Origin: feature-planner
Context-root: docs/features/fast-path-solo/
Status: ✅ finalized
---

# fast-path-solo-004 — Contratto artefatti modalità `solo` in `task-implementer`

## Obiettivo

Documentare in `skills/task-implementer/SKILL.md` che in modalità `solo` gli artefatti versionati del task (`<context-root>/tasks/<id>.md` completo + eventuale append `technical-context.md`) sono prodotti **durante/dopo** l'implementazione — riflettendo la realtà, ordine invertito rispetto a `team` — ma con **struttura identica** (sezioni obbligatorie invariate). Verificare se serve una nota allineata in `skills/code-implementer/` e, se sì, aggiungerla. Coerenza col contratto in `planning-source-contract.md` § "Vincoli risolti".

## Vincoli risolti

- **Stack/formato**: Markdown (skill instructions). Nessuna build, nessun test command automatico. Verifica = ispezione manuale del file modificato + grep di coerenza.
- **Dipende da**: `fast-path-solo-002` (finalized — `agents/solo.md` definisce la sequenza interna dell'agente `solo` e produce gli artefatti). `fast-path-solo-003` non è una dipendenza diretta di questo task.
- **Artefatti versionati (VO, da `technical-context.md`)**: `<context-root>/tasks/<id>.md` + append `technical-context.md`. Struttura invariata: sezioni obbligatorie `Vincoli risolti · File impattati · Shape · Deviazioni · Status`. In `solo` l'ordine di produzione è invertito (prima l'implementazione, poi il brief completo con shape reale), ma il risultato su disco è indistinguibile da `team`.
- **ASSUMPTION-fast-path-003** (vincolante, epic): gli artefatti versionati prodotti in `solo` hanno struttura identica a quelli di `team`; l'ordine di produzione è diverso ma non entra nel contratto su disco.
- **ASSUMPTION-fast-path-solo-001** (vincolante, feature): l'agente `solo` scrive il brief co-locato con `Status: ✅ finalized`; l'orchestratore fa solo il gate.
- **`planning-source-contract.md` § "Vincoli risolti"**: il brief co-locato deve essere self-sufficient. L'agente `solo` produce un brief che rispetta questo contratto (sezione "Vincoli risolti" inclusa), con l'aggiunta che lo shape riflette l'implementazione reale (non un'analisi pre-codice).
- **Scope di scrittura**: solo `skills/task-implementer/SKILL.md`. Eventuale nota in `skills/code-implementer/SKILL.md` solo se emerge che il DEV ha bisogno di leggere la distinzione ordine-di-produzione per operare correttamente — valutare in corso d'opera; default: non toccare.
- **Non modificare**: `agents/solo.md` (frozen, 002), `skills/flow-run/SKILL.md` (frozen, 003), `skills/flow-run/references/model-tiering.md` (frozen, 001), struttura/sezioni dei brief esistenti, `planning-source-contract.md`.
- **Subtask**: nessuno, esecuzione lineare.

## File impattati

- `skills/task-implementer/SKILL.md` [edit] — innesto nella sezione `Mode 1: brief T-NNN` (nota modale `solo`) e/o nel blocco `Mode 3: finalize T-NNN` (chiarimento ordine produzione in `solo`).
- `skills/code-implementer/SKILL.md` [edit] — **condizionale**: solo se la distinzione ordine-di-produzione è rilevante per il DEV. Valutare leggendo la SKILL prima di editare; se non serve, omettere.

## Shape

> Shape degli innesti — struttura, non implementazione finale.

### Innesto principale — `skills/task-implementer/SKILL.md`

Nella **nota modale** del Mode 1 (il blocco `> **Modalità attended**...`), estendere o aggiungere il riferimento alla modalità `solo`:

```markdown
> **Modalità `solo`** (quando il task gira in `solo` via `flow-run`): il brief co-locato
> `<context-root>/tasks/<id>.md` è prodotto dall'agente `solo` **dopo** l'implementazione,
> riflettendo la realtà (shape reale, non pre-analisi). Struttura identica a `team`:
> sezioni obbligatorie invariate (`Vincoli risolti · File impattati · Shape · Deviazioni ·
> Status: ✅ finalized`). Il PM non produce un brief separato; l'orchestratore fa solo il
> gate del finalize al ritorno (ASSUMPTION-fast-path-solo-001).
> Vedi `attended-flow.md` e `agents/solo.md` per la sequenza interna.
```

Valutare il punto esatto di inserimento: preferire una nota standalone dopo il blocco `> **Modalità attended**` esistente piuttosto che modificare il flusso numerato (meno invasivo, non-regressione garantita).

### Innesto condizionale — `skills/code-implementer/SKILL.md`

Se (e solo se) il DEV in modalità `solo` riceve istruzioni da `code-implementer` e la distinzione "brief prodotto post-implementazione" è rilevante per il suo flusso:

```markdown
> **Modalità `solo`**: il brief co-locato viene prodotto **dopo** l'implementazione (non prima).
> Il DEV-solo ha già il contesto completo: non attendere né leggere un brief pre-esistente.
> Gli artefatti prodotti devono rispettare le sezioni obbligatorie del brief (self-sufficient).
```

Se `code-implementer/SKILL.md` non ha sezioni che il DEV-solo leggerebbe in questo contesto, omettere l'innesto.

## Deviazioni durante l'implementazione

_(sezione da compilare al momento dell'implementazione se emergono deviazioni rispetto a questo brief)_

## Out of scope per questo task

- Modifica alla struttura/sezioni del brief (invariate by design).
- Modifica a `agents/solo.md` — frozen (002).
- Modifica a `skills/flow-run/SKILL.md` — frozen (003).
- Modifica a `planning-source-contract.md`.
- Qualunque logica attiva: questo è solo aggiornamento documentale del contratto.
- Dogfooding end-to-end — task `fast-path-solo-005`.
