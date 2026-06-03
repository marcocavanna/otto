# Planning source contract v2

> Versione: 2.0.0 — sostituisce la sezione "Planning source contract (CANONICO)"
> della v1 (ex skill `feature-planner`, rimossa in 2.0.0 assorbita da `planner`).
> Consumato da: `task-implementer`, `code-implementer`, `flow-run`, `planner`.

Documento **canonico** del meccanismo con cui i downstream risolvono il contesto (context-root) di un task a partire dal suo ID. Estende la semantica v1 (per-tier `project`/`feature`) alla taxonomy completa dei **4 tier** (`project`/`epic`/`feature`/`task`) definita in `docs/epics/planner-unification/technical-context.md` § Taxonomy.

## Definizione di planning source

Una **planning source** = una directory **context-root** che contiene:

- `00-context.md`
- `technical-context.md` (può essere seedato a monte; `task-implementer` lo estende append-only)
- un file lista-task (**tasks-file**)
- (opzionale) `02-abstract.md`

La coppia `00-context.md` + `technical-context.md` porta in testa la riga **anchor** (vedi `skills/planner/anchor-schema.md`), che dichiara tier, parent e bubble-up target della source.

## Risoluzione della context-root per tier

Lo scan di risoluzione enumera i tasks-file di **tutti e quattro** i tier:

| Tier    | Tasks-file                          | Context-root            |
|---------|-------------------------------------|-------------------------|
| project | `docs/planning/05-tasks-active.md`  | `docs/planning/`        |
| epic    | `docs/epics/<slug>/tasks-active.md` | `docs/epics/<slug>/`    |
| feature | `docs/features/<slug>/tasks-active.md` | `docs/features/<slug>/` |
| task    | `docs/tasks/<slug>/tasks-active.md` | `docs/tasks/<slug>/`    |

Relazione di contenimento: `project` ⊃ `epic` ⊃ `feature` ⊃ `task`. Il tier `task` è la home dei task standalone, con context-root `docs/tasks/<slug>/`.

## Algoritmo di risoluzione (per un ID task `X`)

1. **Scan per directory** di tutti i tasks-file elencati sopra (mai path hardcoded: si enumera per directory).
   — Lo scan **esclude `docs/archive/**`**: i brief e i task-file archiviati non partecipano alla risoluzione.
2. Il file la cui lista contiene `X` definisce la source; context-root = la sua directory; tasks-file = quel file.
3. **0 match** → errore "task sconosciuto". **>1 match** → errore "ID ambiguo" (gli ID devono essere globalmente unici).
4. **Override esplicito**: l'orchestratore può passare la source diretta (es. `feature <slug>`), saltando lo scan.

## Path del brief (co-locato)

- **Canonico (unico)**: `<context-root>/tasks/<id>.md` — co-locato con la planning source. Scritto dal PM (`task-implementer`), consumato dal DEV via la copia effimera in `.flow/briefs/<id>/brief.md`.
- Il path flat legacy `docs/tasks/<id>.md` **non è più supportato** (né scritto né letto in risoluzione): i progetti pre-canonical vanno portati al layout co-locato con la skill `migrate` prima di operare.

## ID dei task

- Stringa **globalmente unica**, trattata in modo **opaco** dai downstream.
- Formato per tier (convenzione, non interpretata in risoluzione):
  - project: `T-NNN`
  - epic: `<epic-slug>-NNN`
  - feature: `<feature-slug>-NNN`
  - task: `<task-slug>-NNN`
- I downstream **non interpretano** il formato: risolvono la source per scan di directory (vedi algoritmo sopra).

## Back-compat (anchor assente)

Se `00-context.md` / `technical-context.md` non portano la riga anchor, la source è trattata come **standalone** (creata pre-2.0.0 o esplicitamente senza gerarchia): nessun bubble-up, nessun errore. Il retrofit dell'anchor è opt-in (via `migrate`), non automatico.

Vedi `skills/planner/anchor-schema.md` § "Semantica anchor assente".

## Schema task-entry (tasks-file)

Ogni entry in un tasks-file deve contenere:

```markdown
### <id> — <emoji> [<tipo>] <titolo>

- **Effort**: <X-Yh>
- **Definition of done**: <concreta, binaria, verificabile>
- **Dipende da**: <id> | —
- **Complessità (ipotesi)**: trivial | standard | critical
- **Status**: ⚪ todo | 🔵 in progress | ✅ done | ⏸ blocked
```

### Campo `Complessità (ipotesi)`

- Enum **chiuso**: `{ trivial, standard, critical }` — stesso enum di `skills/task-implementer/references/complexity-criteria.md`.
- **Stima a priori** del planner: ipotesi emessa al momento della pianificazione, **antecedente** al `meta.json` prodotto dal PM (`task-implementer`), che può raffinarla.
- **Emessa da** `planner` nelle azioni `plan`/`expand` (logica in `core`); qui se ne definisce esclusivamente lo **schema**.

## Header del brief

Scritto da `task-implementer`, letto da `code-implementer`:

```
**Origin**: planner
**Context-root**: <path>/
```

`code-implementer` risolve la `Context-root` dall'header. Se l'header manca → default `docs/planning/` (retro-compatibilità con i brief storici).

## Sezione obbligatoria del brief — "Vincoli risolti"

[Invariata dalla v1.] Ogni brief generato da `task-implementer` deve contenere la sezione **"Vincoli risolti"**, che embedda nel brief tutto ciò che serve al DEV. Campi obbligatori:

- **Stack** — linguaggio/runtime/framework rilevanti per il task
- **Librerie + versioni** — quelle effettivamente usate nel task
- **VO/pattern/interfacce consumati** — costrutti esistenti che il task consuma e NON deve modificare
- **Naming convention** — convenzione applicata nel task

→ Template dettagliato: `skills/task-implementer/references/brief-template.md`.
→ Conseguenza (pattern **brief self-sufficient**): il DEV non ri-legge il contesto di **task** (`00-context.md` / `02-abstract.md` / `technical-context.md`) — è distillato in "Vincoli risolti". Legge però le **regole-ambiente** del repo (`CLAUDE.md` + `.claude/rules`), invarianti di progetto non distillabili nel brief. Reading-set del DEV: regole-ambiente + `brief.md` + `scope.txt` + `frozen.txt` + 1 sample + i file `[edit]`.

---
Generato: 2026-06-02 | Task: planner-unification-contract-002
