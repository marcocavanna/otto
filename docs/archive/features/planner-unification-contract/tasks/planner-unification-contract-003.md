# Brief tecnico — planner-unification-contract-003

**Origin**: feature-planner
**Context-root**: docs/features/planner-unification-contract/
**Feature**: planner-unification-contract
**Status**: ✅ finalized

---

## Obiettivo

Produrre il documento-contratto che specifica il **bundle leggero del tier `task`**: l'insieme minimo di artefatti che costituisce una planning source di tipo `task`, la sua home (`docs/tasks/<slug>/`), i criteri per decidere quando usare il tier `task` al posto del tier `feature`, e un esempio completo con tutti i file prescritti.

Il deliverable è `skills/planner/task-bundle-spec.md` [new], consumato da:
- Feature `core` (`task-expansion`): sa quali file generare quando crea una planning source di tier `task`.
- Feature `finalize`: sa cosa aspettarsi come context-root di un tier `task` per il bubble-up single-hop.
- Downstream consumer che leggono il contratto v2: sanno che `docs/tasks/<slug>/` è una path valida.

## Definition of done

1. `skills/planner/task-bundle-spec.md` esiste e specifica:
   - File **obbligatori** del bundle (`tasks-active.md` con anchor obbligatorio; `technical-context.md` con anchor obbligatorio; `00-context.md` minimale).
   - File **opzionali** (`02-abstract.md` — ammesso, non richiesto).
   - Criteri "quando è task e non feature": regola binaria e verificabile, non soggettiva.
   - Esempio completo con tutti i file del bundle per uno slug di esempio, incluso il contenuto minimale di ciascuno.
2. Nessuna modifica a file esistenti (questo task è addivo puro).

## File impattati

- `skills/planner/task-bundle-spec.md` [new]

## Vincoli risolti

**Stack**: Markdown puro. Nessun runtime, nessuna compilazione. Il documento è letto da skill Claude Code (bash + CLAUDE.md reader).

**Librerie + versioni**: nessuna.

**VO/pattern/interfacce consumati** (definiti in task -001 e -002, vincolanti — NON modificare):

- **Anchor schema** — `skills/planner/anchor-schema.md`:
  - Formato: `<!-- Anchor --> **Tier**: <tier> · **Parent**: <slug|—> · **Bubble-up target**: <path|—>`
  - Enum `Tier` chiuso: `{project, epic, feature, task}`
  - Valore vuoto: `—` (em-dash)
  - Posizione: riga singola dopo H1 in `00-context.md` e `technical-context.md`
  - Anchor assente = standalone (back-compat)

- **Planning source contract v2** — `skills/planner/planning-source-contract.md`:
  - Tier `task` → context-root `docs/tasks/<slug>/`, tasks-file `docs/tasks/<slug>/tasks-active.md`
  - Brief co-locato: `<context-root>/tasks/<id>.md`
  - ID opachi globalmente unici; scan per directory, esclusione `docs/archive/**`
  - Schema task-entry con campo `Complessità (ipotesi)` ∈ {trivial, standard, critical}

- **Taxonomy 4 tier** — `docs/epics/planner-unification/technical-context.md` § Taxonomy:
  - `project` ⊃ `epic` ⊃ `feature` ⊃ `task`
  - Tier `task` = bundle leggero, 1 task, `02-abstract` opzionale

**Naming convention**:
- File nuovo: `task-bundle-spec.md` (kebab-case, in `skills/planner/`)
- Sezioni: H2, contenuto denso, nessun filler; esempi con blocchi markdown fenced annotati

## Approccio implementativo

Il task è interamente documentale. Il documento deve essere azionabile: il DEV/tool che lo legge sa esattamente quali file creare, con quale contenuto minimale, senza ambiguità.

### Struttura del documento `skills/planner/task-bundle-spec.md`

#### Sezione: Definizione di tier `task`

Il tier `task` è il livello più granulare della gerarchia. È usato quando l'unità di lavoro:
- È composta da **un solo task atomico** (non c'è pipeline di task da sequenziare).
- Non giustifica la struttura completa di una `feature` (nessun `roadmap.md`/`milestones.md`, nessun `02-abstract.md` obbligatorio, elicitation ridotta).
- Ha una gerarchia parent esplicita (tipicamente una `feature` o un `epic`).

Il documento deve codificare questo come **regola binaria**:

```
Usa il tier `task` se e solo se:
  (a) il lavoro è un singolo task atomico (non 2+ task sequenziati), E
  (b) esiste già una feature o epic parent cui ancorare il task via bubble-up.
Se una delle due condizioni non vale → usa `feature`.
```

#### Sezione: Bundle minimo (file obbligatori e opzionali)

**Obbligatori**:

| File | Anchor | Contenuto minimo |
|---|---|---|
| `00-context.md` | sì (obbligatorio) | Cosa fa il task, da cosa dipende, scope boundary, assunzioni note |
| `technical-context.md` | sì (obbligatorio) | Seed da parent; esteso append-only da `task-implementer` |
| `tasks-active.md` | no | Esattamente 1 task-entry (con tutti i campi schema incl. `Complessità (ipotesi)`) |

**Opzionali**:

| File | Note |
|---|---|
| `02-abstract.md` | Ammesso se il task richiede spec tecnica autonoma; NON richiesto dal bundle minimo |

Non sono ammessi altri file di planning a livello di bundle (`roadmap.md`, `milestones.md`, `03-milestones.md` ecc.) — il tier `task` è intenzionalmente leggero.

#### Sezione: Esempio completo

Slug di esempio: `add-field-to-user-dto`.

Il documento deve includere il contenuto minimale verbatim di ogni file obbligatorio per lo slug d'esempio, con un blocco fenced annotato. Il DEV legge questi esempi e li usa come template.

Struttura dell'esempio:

```
docs/tasks/add-field-to-user-dto/
  00-context.md
  technical-context.md
  tasks-active.md
```

Contenuto minimale di `00-context.md` (shape, NON testo letterale finale — il DEV adatta allo slug reale):

```markdown
# Context — Task: <titolo task> (`<slug>`)

<!-- Anchor --> **Tier**: task · **Parent**: <feature-slug> · **Bubble-up target**: docs/features/<feature-slug>/technical-context.md

## Cosa fa il task

<una-due righe>

## Boundary e scope

- In scope: <elenco>
- Out of scope: <elenco>

## Tracked assumptions

- (nessuna | lista)

## Known risks

- (nessuno | lista)
```

Contenuto minimale di `technical-context.md` (seedato dal parent, esteso da `task-implementer`):

```markdown
# Technical context — Task: <titolo task> (`<slug>`)

<!-- Anchor --> **Tier**: task · **Parent**: <feature-slug> · **Bubble-up target**: docs/features/<feature-slug>/technical-context.md

> Seed da docs/features/<feature-slug>/technical-context.md

## Decisioni tattiche da brief (append-only)

(vuoto al seed; task-implementer aggiunge qui)
```

Contenuto minimale di `tasks-active.md` (1 solo task-entry):

```markdown
# Task attivi — Task: <titolo task> (`<slug>`)

**Tier**: task
**Effort stimato**: <X-Yh>
**Definition of done task**: <concreta, binaria, verificabile>

## Task

### <slug>-001 — <emoji> [<tipo>] <titolo>

- **Effort**: <X-Yh>
- **Definition of done**: <concreta, binaria, verificabile>
- **Dipende da**: —
- **Complessità (ipotesi)**: trivial | standard | critical
- **Status**: ⚪ todo
```

### Decisioni da prendere nel documento

1. **Unicità del task-entry in `tasks-active.md`**: il bundle tier `task` contiene sempre e solo 1 task-entry (per definizione: se ce ne sono 2+, si usa il tier `feature`). Il contratto deve enunciare questo esplicitamente.
2. **Seed di `technical-context.md`**: deve essere seedato dal parent (la feature che ha il task come figlio). Il documento specifica che il seed è responsabilità della skill `core` al momento della creazione; `task-implementer` lo estende in append-only.
3. **Anchor obbligatorio nei file `.md` della coppia `00-context.md`+`technical-context.md`**: confermato da anchor-schema.md; il bundle tier `task` non fa eccezione — l'anchor è always-present (mai `anchor assente`, mai standalone, perché il tier `task` per definizione ha un parent).
4. **`tasks-active.md` non porta l'anchor**: confermato da anchor-schema.md § Posizione — solo la coppia `00-context.md` + `technical-context.md`.

## Out of scope per questo task

- Implementazione della skill `planner` che crea il bundle (→ feature core)
- Logica di finalize / bubble-up single-hop per il tier `task` (→ feature finalize)
- Ripuntamento dei consumer downstream al nuovo tier (→ feature downstream)
- Modifica di file esistenti: questo task è addivo puro

## Subtask

Nessuno necessario, esecuzione lineare.

## Verifica (DoD check)

Il DEV verifica manualmente che `skills/planner/task-bundle-spec.md`:
- [ ] Esiste e ha il path corretto
- [ ] Specifica il criterio binario "quando è task e non feature" (condizioni (a) e (b))
- [ ] Elenca i file obbligatori con anchor obbligatorio per `00-context.md` e `technical-context.md`
- [ ] Specifica `02-abstract.md` come opzionale, non obbligatorio
- [ ] Enumera esplicitamente i file NON ammessi nel bundle (roadmap, milestones ecc.)
- [ ] Specifica che `tasks-active.md` contiene esattamente 1 task-entry
- [ ] Specifica la semantica del seed di `technical-context.md` (da parent, append-only da task-implementer)
- [ ] Contiene un esempio completo per uno slug di esempio con tutti i file obbligatori
- [ ] L'esempio include il campo `Complessità (ipotesi)` nel task-entry
- [ ] L'ancora nell'esempio è coerente con il formato di `anchor-schema.md`

---
Generato: 2026-06-02 | Task: planner-unification-contract-003
