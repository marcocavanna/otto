**Origin**: feature-planner
**Context-root**: docs/features/planner-unification-core/
**Feature**: planner-unification-core
**Status**: ✅ finalized

---

# Brief tecnico — planner-unification-core-002

## Obiettivo

Materializzare i quattro reference condivisi sotto `skills/planner/references/`: `elicitation.md`, `critical-review.md`, `task-expansion.md`, `artifact-contract.md`. I file devono essere consolidati (deduplicati, tier-agnostici) a partire da `skills/project-planner/` come sorgente primaria, non semplici copie. `task-expansion.md` deve emettere il campo `Complessità (ipotesi)` ∈ {trivial, standard, critical} per ogni task-entry (ASSUMPTION-007). Al termine, `skills/planner/SKILL.md` link ai reference TODO esistenti (task 002) sarà risolto.

---

## Vincoli risolti

**Stack**
- Markdown puro (file di skill Claude Code). Nessun build, nessuna dipendenza runtime.
- Struttura: leggibile in lazy (H2/H3, link espliciti), senza prosa ridondante.

**Librerie + versioni**
- Nessuna. Stack: markdown + prosa.

**VO/pattern/interfacce consumati — da NON modificare**
- `skills/planner/anchor-schema.md` — schema anchor (Tier/Parent/Bubble-up target); i reference non lo ridefiniscono, lo linkano dove necessario.
- `skills/planner/planning-source-contract.md` — schema task-entry con campo `Complessità (ipotesi)` (canonico); `task-expansion.md` consolida NON duplica: deve richiamare il contratto per lo schema, non re-definirlo inline.
- `skills/planner/task-bundle-spec.md` — spec tier `task`; consumata da `artifact-contract.md` (linkare, non duplicare).
- `skills/planner/SKILL.md` — router; i TODO `references/elicitation.md` e `references/critical-review.md` vengono risolti da questo task. Non modificare SKILL.md.
- Taxonomy dei 4 tier: `project ⊃ epic ⊃ feature ⊃ task` (definita in `docs/epics/planner-unification/technical-context.md` § Taxonomy).

**Naming convention**
- Path canonici: `skills/planner/references/elicitation.md`, `skills/planner/references/critical-review.md`, `skills/planner/references/task-expansion.md`, `skills/planner/references/artifact-contract.md`.
- I file sorgente (`skills/project-planner/{elicitation,critical-review,task-expansion,artifact-templates}.md`) restano intatti — non toccarli.
- Enum `Complessità (ipotesi)`: `trivial | standard | critical` (lowercase, stesso enum di `task-implementer/references/complexity-criteria.md`).

---

## Analisi funzionale

### elicitation.md (consolidato)

Sorgente primaria: `skills/project-planner/elicitation.md`. Il file è attualmente orientato al tier `project` (blocchi A-F, elicitation completa pitch/market/stack). Il consolidamento lo rende tier-agnostico:

- I blocchi A-F restano come livello massimo (usati dal tier `project`).
- Aggiungere una sezione di scope **"Livello di elicitation per tier"**: il tier `feature` usa A-D ridotto (no pitch/market/success-metric elaborate); il tier `epic` usa A-D con focus su decomposizione; il tier `task` ha elicitation minima (scope, dipendenze, output atteso — vedi `task-bundle-spec.md`).
- La regola "una domanda alla volta", le regole di probe, le tracked assumptions e la sezione "End of elicitation" rimangono invariate (tier-agnostiche già).

### critical-review.md (consolidato)

Sorgente primaria: `skills/project-planner/critical-review.md`. I 9 pattern di rischio sono quasi tutti tier-agnostici, con qualche scope legato al tier `project` (es. "Scope/effort mismatch" presuppone C1/C2 da elicitation). Il consolidamento:

- Mantiene i 9 pattern invariati.
- Aggiunge una sezione "Applicabilità per tier" che indica quali pattern sono rilevanti per ciascun tier (es. al tier `task` i pattern rilevanti sono solo 1 e 4; al tier `feature` tutti tranne 8; al tier `project`/`epic` tutti).
- Il formato di output critico (rosso/giallo) è invariato.

### task-expansion.md (consolidato + ASSUMPTION-007)

Sorgente primaria: `skills/project-planner/task-expansion.md`. Modifiche rispetto alla sorgente:

1. **Aggiungere il campo `Complessità (ipotesi)`** allo schema task-entry — obbligatorio, emesso a ogni task generato in `plan`/`expand`. Valore ∈ {trivial, standard, critical}. Lo schema canonico è in `planning-source-contract.md`; il reference lo linka e descrive la **euristica di assegnazione** (logica delegata qui, non nel contratto).
2. La sezione "Formato file 05-tasks-active.md" diventa "Formato del tasks-file" (tier-agnostico): il field `Milestone attiva` è sostituito da `Feature` / `Epic` / ecc. secondo il tier; il formato per-task include il campo `Complessità (ipotesi)`.
3. Anti-pattern, categorie, composizione milestone, regole spike: invariati e già tier-agnostici.
4. La sezione "Re-expand della stessa milestone" ha titolo generico "Re-expand dello stesso scope" (milestone per project, feature per feature, ecc.).

**Euristica di assegnazione `Complessità (ipotesi)` (da implementare in task-expansion.md):**
- `trivial`: 1 file, nessun contratto nuovo, nessuna dipendenza, tipo setup/config/dto.
- `standard`: 2-3 file, consuma contratti esistenti, dipendenze lineari, tipo impl/query-handler/repository.
- `critical`: introduce contratti nuovi consumati da altri task, >3 file, o tipo domain-entity/value-object/cross-cutting.
- In dubbio tra due tier adiacenti: scegliere il più alto (fail-safe, coerente con `complexity-criteria.md`).
- Nota esplicita: questa è una stima **a priori**; il PM (`task-implementer`) la può raffinare nel `meta.json`.

### artifact-contract.md (consolidato)

Sorgente primaria: `skills/project-planner/artifact-templates.md`. Il file attuale è orientato al tier `project` (7 artefatti: 00-context, 01-pitch, 02-abstract, 03-milestones, 04-phases, 05-tasks-active, README). Il consolidamento:

- Mantiene le regole trasversali (H1 titolo+progetto, metadata footer, gestione gap).
- Organizza i template per tier in sezioni H2: `## Tier project`, `## Tier epic`, `## Tier feature`, `## Tier task`.
- Tier `project`: i 7 template esistenti, invariati.
- Tier `epic`: template di `00-context`, `02-abstract`, `technical-context`, `roadmap` (derivati da `epic-planner/references/epic-artifacts.md`).
- Tier `feature`: i 4 template di `feature-planner/feature-artifacts.md` — `00-context`, `02-abstract`, `technical-context`, `tasks-active`.
- Tier `task`: il bundle leggero da `skills/planner/task-bundle-spec.md` — linkata, non duplicata.
- Ogni template include l'anchor header dove obbligatorio (`00-context.md` e `technical-context.md`).

---

## Analisi tecnica

### Stack di implementazione

- Markdown puro. Nessuna libreria o tool.
- Sorgenti da leggere e consolidare: `skills/project-planner/{elicitation,critical-review,task-expansion,artifact-templates}.md`, `skills/epic-planner/references/epic-artifacts.md`, `skills/feature-planner/feature-artifacts.md`, `skills/planner/task-bundle-spec.md`.

### Pattern adottati

- **Single-source dei reference** — vedi `technical-context.md` § Pattern architetturali: ogni concetto vive in UN solo file, linkato dai tier. I file consolidati NON duplicano schema già definiti in `planning-source-contract.md` o `task-bundle-spec.md`: linkano.
- **Porting, non riscrittura** — la logica dei file sorgente viene portata fedelmente; solo le sezioni tier-specifiche vengono generalizzate (titoli, campi contestuali).
- **Append-only sul technical-context** — se questo task introduce decisioni tattiche nuove, si aggiornano in append al `technical-context.md` della feature al termine.

### Assunzioni operative locali

- **ASSUMPTION-planner-unification-core-002-001**: l'euristica `Complessità (ipotesi)` è descritta in `task-expansion.md` come guida operativa per il planner (non come spec formale); la spec formale dell'enum e dello schema è in `planning-source-contract.md`. Il reference non duplica lo schema, lo applica con linee guida.
- **ASSUMPTION-planner-unification-core-002-002**: `artifact-contract.md` per il tier `epic` trae i template da `skills/epic-planner/references/epic-artifacts.md` in lettura (il file non viene modificato). Se i template ivi presenti sono sufficientemente completi, vengono portati; se parziali, vengono completati sulla base di `00-context.md`/`02-abstract.md` dell'epic esistente come campione.
- **ASSUMPTION-planner-unification-core-002-003**: il nome del file consolidato per i template è `artifact-contract.md` (non `artifact-templates.md`): riflette che il contenuto è un contratto degli artefatti attesi per tier, non solo un template visivo.

---

## File impattati

```
skills/planner/references/elicitation.md     [new]
skills/planner/references/critical-review.md [new]
skills/planner/references/task-expansion.md  [new]
skills/planner/references/artifact-contract.md [new]
```

Le sorgenti (`skills/project-planner/*`, `skills/epic-planner/references/*`, `skills/feature-planner/feature-artifacts.md`, `skills/planner/task-bundle-spec.md`) sono in sola lettura — nessuna modifica.

---

## Shape di implementazione

> Le seguenti shape sono direzione, non implementazione finale. Adattare in esecuzione.

```markdown
// skills/planner/references/elicitation.md
// Shape — adattare in implementazione

# Elicitation

> Reference condiviso della skill `planner`. Tier-agnostico: la profondità di elicitation
> varia per tier (vedi § "Livello per tier"). Consumato da `references/tier-*.md`.

## Regole
[invariate da project-planner/elicitation.md — copia fedele]

## Question sequence

### Block A — Problema e motivazione (obbligatorio tutti i tier tranne task)
[...]

### Block B — Forma e scope (obbligatorio project/epic/feature)
[...]

### Block C — Vincoli di execution (obbligatorio project/epic)
[...]

### Block D — Stack e competenze (obbligatorio project; advisory per epic/feature)
[...]

### Block E — Definizione di successo (obbligatorio project; opzionale epic)
[...]

### Block F — Distribuzione (opzionale, solo project)
[...]

## Livello di elicitation per tier

| Tier    | Blocchi obbligatori | Blocchi opzionali |
|---------|---------------------|-------------------|
| project | A, B, C, D, E       | F                 |
| epic    | A, B (scope only)   | C, D, E           |
| feature | A, B (scope+scope)  | D (stack check)   |
| task    | scope + output      | —                 |

## End of elicitation
[invariato]

## Tracked assumptions
[invariato]
```

```markdown
// skills/planner/references/task-expansion.md
// Shape — adattare in implementazione

# Task expansion

> Reference condiviso della skill `planner`. Tier-agnostico: "milestone" diventa "scope"
> (feature, epic, ecc. secondo il tier). Lo schema task-entry è canonico in
> `skills/planner/planning-source-contract.md` — questo file descrive le regole operative
> e l'euristica di assegnazione `Complessità (ipotesi)`.

## Granularità
[invariata]

## Anti-pattern da evitare
[invariati]

## Categorie di task
[invariate]

## Assegnazione `Complessità (ipotesi)`

Per ogni task generato emettere il campo `Complessità (ipotesi)` ∈ {`trivial`, `standard`, `critical`}.

Euristica operativa:
- `trivial`: 1 file, nessun contratto nuovo, nessuna dipendenza upstream critica; tipo setup/config/dto.
- `standard`: 2-3 file, consuma contratti esistenti senza introdurne di nuovi, tipo impl/repository/query-handler.
- `critical`: introduce contratti consumati da altri task, >3 file impattati, o tipo domain-entity/value-object/cross-cutting.
- Fail-safe verso l'alto: in dubbio tra due tier adiacenti, scegliere il più alto.

> Questa è una stima a priori del planner; il PM (`task-implementer`) la raffina nel `meta.json`.
> Schema canonico dell'enum: `skills/planner/planning-source-contract.md` § "Campo Complessità".

## Composizione attesa per scope
[invariata, "milestone" → "scope"]

## Spike
[invariato]

## Formato del tasks-file (post-expand)

Schema task-entry minimo (canonico in `planning-source-contract.md`):

### <id> — <emoji> [<tipo>] <titolo>
- **Effort**: X-Yh
- **Definition of done**: [concreta, binaria]
- **Dipende da**: <id> | —
- **Complessità (ipotesi)**: trivial | standard | critical
- **Status**: ⚪ todo | 🔵 in progress | ✅ done | ⏸ blocked

## Numero di task per scope
[invariato, "milestone" → "scope"]
```

```markdown
// skills/planner/references/artifact-contract.md
// Shape — adattare in implementazione

# Artifact contract

> Reference condiviso della skill `planner`. Definisce gli artefatti attesi per ciascun tier
> e i loro template. Tier `task`: vedi `skills/planner/task-bundle-spec.md` (link, non duplicare).

## Regole trasversali
[invariate da artifact-templates.md: H1, metadata footer, gestione gap]

## Tier project

### 00-context.md
[template invariato da project-planner/artifact-templates.md]
### 01-pitch.md
[...]
### 02-abstract.md
[...]
### 03-milestones.md
[...]
### 04-phases.md
[...]
### 05-tasks-active.md
[...]
### README.md
[...]

## Tier epic

### 00-context.md (epic)
[con anchor header obbligatorio — vedi anchor-schema.md]
### 02-abstract.md (epic)
[...]
### technical-context.md (epic)
[con anchor header obbligatorio]
### roadmap.md (epic)
[...]

## Tier feature

### 00-context.md (feature)
[con anchor header obbligatorio]
### 02-abstract.md (feature)
[...]
### technical-context.md (feature)
[con anchor header obbligatorio]
### tasks-active.md (feature)
[schema task-entry con Complessità (ipotesi) — vedi planning-source-contract.md]

## Tier task

> Bundle leggero: vedi `skills/planner/task-bundle-spec.md`. Non duplicare qui.
```

---

## Test minimo

- I 4 file esistono sotto `skills/planner/references/`.
- `task-expansion.md` contiene il campo `Complessità (ipotesi)` con l'euristica e il link al contratto canonico.
- `artifact-contract.md` ha sezioni per tutti e 4 i tier; il tier `task` linka `task-bundle-spec.md` senza duplicarne il contenuto.
- `elicitation.md` ha la tabella "Livello per tier" e non cita esplicitamente solo il tier project.
- `critical-review.md` ha la sezione "Applicabilità per tier".
- Verifica "0 link orfani": ogni link interno ai reference punta a un file esistente. Grep su `skills/planner/references/*.md` per `](` e verifica manuale.
- `skills/planner/SKILL.md` linka `references/elicitation.md` e `references/critical-review.md` già — i TODO di 002 sono ora risolti (i file esistono).

## Subtask

**Nessun subtask necessario** — esecuzione lineare. I 4 file sono indipendenti tra loro nell'ordine di scrittura (anche se `artifact-contract.md` è il più lungo); nessun gate intermedio richiesto.

---

## Riferimenti

- Task in plan: `docs/features/planner-unification-core/tasks-active.md` § planner-unification-core-002
- Sorgenti da consolidare: `skills/project-planner/{elicitation,critical-review,task-expansion,artifact-templates}.md`
- Sorgenti aggiuntive: `skills/epic-planner/references/epic-artifacts.md`, `skills/feature-planner/feature-artifacts.md`
- Contratti consumati: `skills/planner/planning-source-contract.md`, `skills/planner/task-bundle-spec.md`, `skills/planner/anchor-schema.md`
- ASSUMPTION-007 (campo Complessità): `docs/epics/planner-unification/technical-context.md` § "Complessità a priori del task"
- Technical context feature: `docs/features/planner-unification-core/technical-context.md`

## Out of scope per questo task

- Creazione dei tier reference `tier-{project,epic,feature,task}.md` → task 003/004/005/006.
- Logica di inferenza tier (`tier-inference.md`) → task 007.
- Modifica delle skill sorgente (`project-planner/`, `epic-planner/`, `feature-planner/`) → mai in questa feature.
- Modi `expand` e `finalize` → feature finalize.
- Bubble-up / ripuntamento downstream → feature downstream.

---

## Deviazioni durante l'implementazione

- **build skipped**: markdown puro, nessun `build_command` dichiarato — atteso.
- **ASSUMPTION-planner-unification-core-002-003 confermata**: file consolidato nominato `artifact-contract.md` (non `artifact-templates.md`) — coerente col brief.
- **Verifica 0-link-orfani**: unico match `docs/planning/technical-context.md` è un valore segnaposto dentro l'anchor di un template (`<...|—>`), non un link reale — nessun link orfano effettivo.

---

## Finalize

**Data chiusura**: 2026-06-02
**verify**: pass

**Decisioni del brief confermate senza variazioni**:
- 4 reference prodotti in `skills/planner/references/` come da spec.
- `artifact-contract.md` adotta il nome contrattuale (ASSUMPTION-003 confermata).
- `task-expansion.md` emette `Complessità (ipotesi)` con euristica operativa e link a `planning-source-contract.md` (ASSUMPTION-001 confermata).
- Sorgenti (`project-planner/*`, `epic-planner/references/*`, `feature-planner/feature-artifacts.md`) rimaste in sola lettura.

**Aggiornamento `technical-context.md`**: non necessario. La sezione `## Decisioni tattiche — core-002 (2026-06-02)` era già stata scritta durante la generazione del brief; le deviazioni registrate dal DEV non introducono nuove decisioni tattiche.
