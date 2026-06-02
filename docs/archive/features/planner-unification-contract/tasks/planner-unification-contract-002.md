# Brief tecnico — planner-unification-contract-002

**Origin**: feature-planner
**Context-root**: docs/features/planner-unification-contract/
**Feature**: planner-unification-contract
**Status**: ✅ finalized | 2026-06-02

---

## Obiettivo

Redigere il **Planning source contract v2** come documento canonico in `skills/planner/planning-source-contract.md`. Il contratto v2 estende la semantica v1 (oggi in `skills/feature-planner/feature-artifacts.md`) con:

- risoluzione context-root per i **4 tier** incluso `docs/tasks/<slug>/`;
- esclusione esplicita `docs/archive/**`;
- brief co-locato `<context-root>/tasks/<id>.md`;
- ID opachi globalmente unici;
- back-compat su anchor assente (= standalone);
- campo **`Complessità (ipotesi)`** ∈ {trivial, standard, critical} nel task-entry schema.

Il deliverable sostituisce e supera la sezione "Planning source contract (CANONICO)" in `skills/feature-planner/feature-artifacts.md`, che resta in sito come sorgente legacy con un redirect (link) al file canonico v2. Nessun file viene rimosso.

## Definition of done

1. `skills/planner/planning-source-contract.md` esiste e specifica:
   - risoluzione context-root per tutti e 4 i tier (tabella o sezione per tier);
   - regole di esclusione `docs/archive/**`;
   - path canonico del brief co-locato;
   - semantica ID opachi;
   - back-compat (anchor assente = standalone, nessun bubble-up);
   - schema del task-entry con il campo `Complessità (ipotesi)` ∈ {trivial, standard, critical}.
2. `skills/feature-planner/feature-artifacts.md`: la sezione "Planning source contract (CANONICO)" è aggiornata con un redirect al nuovo file canonico v2 (riga di rimando, non eliminazione del contenuto).

## File impattati

- `skills/planner/planning-source-contract.md` [new]
- `skills/feature-planner/feature-artifacts.md` [edit]

## Vincoli risolti

**Stack**: Markdown puro. Nessun runtime, nessuna compilazione. Il documento è letto da skill Claude Code (bash + CLAUDE.md reader).

**Librerie + versioni**: nessuna.

**VO/pattern/interfacce consumati** (definiti in task -001, vincolanti — NON modificare):

- **Anchor schema** — `skills/planner/anchor-schema.md`:
  - Formato: `<!-- Anchor --> **Tier**: <tier> · **Parent**: <slug|—> · **Bubble-up target**: <path|—>`
  - Enum Tier chiuso: `{project, epic, feature, task}`
  - Separatore: punto mediano `·` (U+00B7)
  - Valore vuoto: em-dash `—`
  - Anchor assente ⇒ standalone (back-compat)
- **Taxonomy 4 tier** — `docs/epics/planner-unification/technical-context.md` § Taxonomy:
  - `project` ⊃ `epic` ⊃ `feature` ⊃ `task`
  - Home tier task: `docs/tasks/<slug>/`
- **Campo `Complessità (ipotesi)`** — ASSUMPTION-planner-unification-007:
  - ∈ {trivial, standard, critical}
  - Ipotesi a priori del planner; antecedente al `meta.json` del PM
  - Emesso da `core` in `plan`/`expand`; definito (schema) in questo task

**Contratti invariati dalla v1** (da preservare esplicitamente nel v2):
- Scan per directory (non per path hardcoded)
- Esclusione `docs/archive/**`
- Brief co-locato `<context-root>/tasks/<id>.md`
- ID opachi e globalmente unici

**Naming convention**:
- File nuovo: `planning-source-contract.md` (kebab-case, in `skills/planner/`)
- Sezioni: titolo H2, contenuto denso, niente filler
- Riferimenti al v1: linkare `skills/feature-planner/feature-artifacts.md` — non copiarne il contenuto

## Approccio implementativo

Il task è interamente documentale: nessun codice eseguibile.

### Struttura del documento `skills/planner/planning-source-contract.md`

```markdown
# Planning source contract v2

> Versione: 2.0.0 — sostituisce la sezione "Planning source contract (CANONICO)"
> di `skills/feature-planner/feature-artifacts.md` (v1, mantenuta come legacy).
> Consumato da: `task-implementer`, `code-implementer`, `flow-run`, `planner`.

## Definizione di planning source

Una planning source = una directory context-root che contiene:
- `00-context.md`
- `technical-context.md`
- un file lista-task (tasks-file)
- (opzionale) `02-abstract.md`

## Risoluzione della context-root per tier

| Tier    | Tasks-file                              | Context-root                  |
|---------|-----------------------------------------|-------------------------------|
| project | docs/planning/05-tasks-active.md        | docs/planning/               |
| epic    | docs/epics/<slug>/tasks-active.md       | docs/epics/<slug>/           |
| feature | docs/features/<slug>/tasks-active.md   | docs/features/<slug>/        |
| task    | docs/tasks/<slug>/tasks-active.md      | docs/tasks/<slug>/           |

## Algoritmo di risoluzione (per un ID task X)

1. Scan di tutti i tasks-file sopra elencati.
   — Esclude `docs/archive/**`: i brief e i task-file archiviati
     non partecipano alla risoluzione.
2. Il file la cui lista contiene X definisce la source;
   context-root = sua directory; tasks-file = quel file.
3. 0 match → errore "task sconosciuto".
   >1 match → errore "ID ambiguo" (gli ID devono essere unici).
4. Override esplicito: l'orchestratore può passare source diretta
   (es. `feature <slug>`), saltando lo scan.

## Path del brief (co-locato)

Canonico (unico): `<context-root>/tasks/<id>.md`
— scritto dal PM, consumato dal DEV via copia effimera `.flow/briefs/<id>/brief.md`.

Il path flat legacy `docs/tasks/<id>.md` non è più supportato.

## ID dei task

- Stringa globalmente unica, trattata in modo opaco.
- Formato per tier:
  - project: `T-NNN`
  - epic: `<epic-slug>-NNN`
  - feature: `<feature-slug>-NNN`
  - task: `<task-slug>-NNN`
- I downstream non interpretano il formato: risolvono per scan.

## Back-compat (anchor assente)

Se `00-context.md` / `technical-context.md` non portano la riga anchor,
la source è trattata come **standalone** (pre-2.0.0 o esplicitamente senza
gerarchia): nessun bubble-up, nessun errore.
Vedi anchor-schema.md § "Semantica anchor assente".

## Schema task-entry (tasks-file)

Ogni entry in tasks-file deve contenere:

### <id> — <emoji> [<tipo>] <titolo>

- **Effort**: <X-Yh>
- **Definition of done**: <concreta, binaria, verificabile>
- **Dipende da**: <id> | —
- **Complessità (ipotesi)**: trivial | standard | critical
- **Status**: ⚪ todo | 🔵 in progress | ✅ done | ⏸ blocked

`Complessità (ipotesi)` = stima a priori del planner,
∈ {trivial, standard, critical}, stesso enum di
`task-implementer/references/complexity-criteria.md`.
Antecedente al `meta.json` del PM (che può raffinare).
Emessa da `planner` in `plan`/`expand` (logica in `core`);
qui se ne definisce lo schema.

## Header del brief

Scritto da `task-implementer`, letto da `code-implementer`:

  **Origin**: project-planner | feature-planner | epic-planner | task-planner
  **Context-root**: <path>/

`code-implementer` risolve la context-root dall'header.
Header assente → default `docs/planning/` (retro-compatibilità brief storici).

## Sezione obbligatoria del brief — "Vincoli risolti"

[invariata dalla v1: Stack · Librerie+versioni · VO/pattern/interfacce consumati · Naming convention]
Vedi template dettagliato: `skills/task-implementer/references/brief-template.md`.
```

### Modifica a `skills/feature-planner/feature-artifacts.md`

Nella sezione "Planning source contract (CANONICO)", aggiungere **in testa alla sezione** (sopra il blocco esistente):

```markdown
> **⚠ LEGACY v1** — Il contratto canonico è stato relocato in
> `skills/planner/planning-source-contract.md` (v2). Questa sezione
> è mantenuta per retrocompatibilità dei brief storici. Per nuovi task
> usare il file v2.
```

Il contenuto esistente della sezione rimane invariato sotto il redirect.

## Out of scope per questo task

- Spec del bundle leggero del tier task (→ task -003)
- Implementazione della skill `planner` che emette `Complessità (ipotesi)` (→ feature core)
- Logica di finalize / bubble-up (→ feature finalize)
- Ripuntamento dei consumer downstream alla nuova location (→ feature downstream)
- Modifica di `skills/task-implementer/SKILL.md` o altri consumer (→ feature downstream)

## Subtask

Nessuno necessario, esecuzione lineare.

## Verifica (DoD check)

Il DEV verifica manualmente che:

- [ ] `skills/planner/planning-source-contract.md` esiste
- [ ] Specifica risoluzione context-root per tutti e 4 i tier (tabella + algoritmo di scan)
- [ ] Esclusione `docs/archive/**` documentata esplicitamente
- [ ] Path canonico brief co-locato: `<context-root>/tasks/<id>.md`
- [ ] Back-compat (anchor assente = standalone) documentata con rimando ad `anchor-schema.md`
- [ ] Schema task-entry include `Complessità (ipotesi)` ∈ {trivial, standard, critical}
- [ ] Semantica `Complessità (ipotesi)` (ipotesi a priori, antecedente a `meta.json`) documentata
- [ ] `skills/feature-planner/feature-artifacts.md` contiene il redirect al v2 in testa alla sezione
- [ ] Nessun contenuto v1 eliminato (solo redirect aggiunto)

---
Generato: 2026-06-02 | Task: planner-unification-contract-002
