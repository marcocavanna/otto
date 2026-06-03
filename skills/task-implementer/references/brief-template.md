# Brief template

Template del brief tecnico generato da `task-implementer` in modalità `brief T-NNN`. Il brief è la **fonte unica** del DEV (`code-implementer`): deve essere self-sufficient.

## Path di scrittura

- **Canonico**: `<context-root>/tasks/<id>.md` (co-locato con la planning source).
  - `<context-root>` = `docs/planning/` (project source) | `docs/features/<slug>/` (feature source).
  - `<id>` = `T-NNN` (project) | `<slug>-NNN` (feature).

> Il vecchio path flat `docs/tasks/<id>.md` non è più né scritto né letto: i progetti pre-canonical vanno portati al layout co-locato con la skill `migrate`.

→ Meccanismo canonico (resolver, scan, esclusione `docs/archive/**`): `skills/planner/planning-source-contract.md` § "Planning source contract". Non ridefinirlo qui.

---

## Struttura del brief

### Header

```
# <id> — [titolo conciso del task]

**Status**: 🔵 active
**Origin**: planner
**Context-root**: docs/planning/ | docs/features/<slug>/
**Feature**: `<slug>`            # solo per feature source
**Milestone**: M[N]              # solo per project source — NON inventarla per le feature
**Effort stimato**: [es. 2-3h]
**Dipendenze**: [id task dipendenti | nessuna]
**Generato**: [data]
**Versione**: [n]
```

> `Origin` + `Context-root` sono il contratto letto da `code-implementer` per caricare il contesto. Vedi `../planner/planning-source-contract.md` § "Planning source contract".

### Vincoli risolti

> Sezione **obbligatoria**. Inserirla **prima** di `## Obiettivo`.
> Il DEV legge **solo** il brief (self-sufficient): non ri-legge `00-context.md` / `02-abstract.md` / `technical-context.md`.
> Distillata dal PM dal planning al momento della generazione del brief.

```markdown
## Vincoli risolti

> Sezione self-sufficient: il DEV non ri-legge `00-context`/`02-abstract`/`technical-context`.

- **Stack**: [linguaggio/runtime/framework rilevanti per QUESTO task]
- **Librerie + versioni**: [quelle effettivamente usate nel task — con versione se nota]
- **VO/pattern/interfacce consumati** (da NON modificare): [costrutti esistenti che il task consuma]
- **Naming convention**: [convenzione applicata in questo task]
```

→ I 4 campi sono definiti canonicamente in `../planner/planning-source-contract.md` § "Sezione obbligatoria del brief — Vincoli risolti". **Non ridefinirli qui**: questo è solo il layout della sezione nel brief.

### Corpo

```markdown
## Obiettivo

[Cosa deve essere vero a fine task. Comportamento osservabile.]

## Analisi funzionale

[Scenari, comportamento osservabile, casi limite a livello funzionale.]

## Analisi tecnica

### Stack di implementazione
[Eco compatto dei vincoli risolti rilevanti.]

### Pattern adottati
[Pattern consumati — con rimando ai contratti esistenti, senza duplicarli.]

### Assunzioni operative locali
- **ASSUMPTION-<id>-001**: [assunzione locale del task]

## File impattati

\`\`\`
path/al/file.ext [new|edit]
...
\`\`\`

## Shape (contratti & innesti)

> Shape = **direzione**, non implementazione. Solo firme, tipi, contratti, punti d'innesto.
> **Mai corpi di metodo né logica completa**: il corpo è competenza esclusiva del DEV.
> Limite duro: ~10-15 righe per costrutto, max 3-4 costrutti. Se sfora o contiene un corpo
> non banale, è già implementazione → rimuoverlo.
>
> - **Sì**: firme di classi/metodi/interfacce; struttura di tipi (record/DTO/VO); schema
>   tabelle/JSON/contratti; ordine costruttore e dipendenze DI; dove si innesta una modifica `[edit]`.
> - **No**: corpi di metodo, boilerplate (using/namespace), try/catch/logging/config,
>   algoritmi completi (al più pseudocodice di 2-3 righe se la logica è non ovvia).
>
> Task di pura configurazione o triviali: nessuno stralcio. Scrivere "Non applicabile — vedi File impattati". Mai forzare uno stralcio per completezza visiva.

## Test minimo

[Condizioni verificabili che definiscono "done" per questo task.]

## Subtask

[Nessun subtask necessario — esecuzione lineare. | Lista subtask se i criteri lo giustificano.]

## Riferimenti

- Task in plan: `<context-root>/tasks-active.md` (feature) | `docs/planning/05-tasks-active.md` (project) § <id>
- Contratti/contesto rilevanti (link, non duplicati)

## Out of scope per questo task

[Cosa NON fa questo task e a quale task/feature è rimandato.]

---

## Deviazioni durante l'implementazione

[Sezione opzionale, popolata via `deviation <id>`. Vuota inizialmente.]

---

## Finalize

[Popolato solo via `finalize <id>`. Vuoto inizialmente.]
```

## Regole di compilazione

- La sezione `## Vincoli risolti` è **non negoziabile**: ogni brief deve averla con i 4 campi.
- Nessuna sezione del brief deve descrivere un path di scrittura del brief che contraddica `<context-root>/tasks/<id>.md`.
- Shape ≠ codice di produzione: nessun blocco di codice completo, solo struttura.
- Subtask sono l'eccezione, non la regola (vedi `subtask-criteria.md`).
