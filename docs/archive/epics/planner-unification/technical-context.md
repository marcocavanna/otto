# Technical context (shared) — Epic: Unificazione dei planner (`planner-unification`)

> Seed condiviso che tutte le feature figlie ereditano. Da qui ogni `docs/features/planner-unification-<feat>/technical-context.md` viene seedato. `planner` (ex task-implementer) estende il file del figlio in append-only; le decisioni di una figlia conclusa risalgono qui via `planner finalize`.

<!-- Anchor --> **Tier**: epic · **Parent**: — · **Bubble-up target**: —

## Convenzioni di progetto
### Build & test
- build_command: `—` (plugin di markdown + hook bash, niente compilazione)
- test_command: `—` · **Verifica** = dogfooding manuale: `plan`/`expand`/`finalize` + `flow-run` end-to-end su un task, una feature, un'epic di prova.
- Lint markdown/link: verifica manuale "0 link orfani" (grep) come DoD delle feature che ripuntano i riferimenti.

## Pattern architetturali condivisi
- **Skill = `SKILL.md` sottile + `references/` a lettura lazy**: il router/flusso sta nel SKILL.md, i dettagli nei reference, letti solo allo step che li usa. Modello di riferimento: gli attuali `skills/*/SKILL.md`.
- **Single-source dei contratti**: un contratto/tabella vive in **un solo file** ed è **linkato**, mai duplicato. (Oggi: "Planning source contract" in `feature-planner/feature-artifacts.md`; "model-tiering" in `flow-run/references/model-tiering.md`.)
- **Mirror non-canonici**: lo stato d'esecuzione è in `.flow/.../PROGRESS.json`; tasks-file e roadmap sono riflessi advisory, aggiornati best-effort e riparati da `flow-sync`.
- **ID opachi globalmente unici**: i downstream non interpretano l'ID, risolvono la context-root per scan di directory.
- **Append-only datato con guardia di idempotenza**: pattern già usato in 1.1.0 per il bubble-up (`## Consolidato da <slug> (YYYY-MM-DD)`); riusato e generalizzato da `finalize`.

## Value Objects / contratti condivisi
### Anchor (header di artefatto) — introdotto da questo epic
- **Campi**: `Tier` ∈ {project, epic, feature, task}; `Parent` = slug del padre o `—`; `Bubble-up target` = path del `technical-context.md` del padre o `—`.
- **Dove**: header di `00-context.md` e `technical-context.md` di ogni artefatto, ogni tier. Presenti anche se vuoti.
- **Consumato da**: `planner finalize` (decide il target di risalita), `flow-run` (invoca finalize), retrofit di `migrate`.
- **Definito in**: feature `contract`.

### Planning source contract v2 — relocato in `skills/planner/`
- **Aggiunge** rispetto alla v1: tier `task` con context-root `docs/tasks/<slug>/`; campi anchor; back-compat (anchor assente = standalone).
- **Invariato**: scan per directory, esclusione `docs/archive/**`, brief co-locato `<context-root>/tasks/<id>.md`, ID opachi.
- **Definito in**: feature `contract`. **Consumato da**: tutti i downstream (link ripuntati in `downstream`).

### Taxonomy dei 4 tier
- `project` (più pesante: pitch/milestone/phases) ⊃ `epic` (roadmap/sequencing) ⊃ `feature` (unità atomica, 1-8 task) ⊃ `task` (bundle leggero, 1 task, `02-abstract` opzionale).
- Ogni tier produce gli stessi tipi di file; cambia il **set** e la **profondità** dell'elicitation.

### Complessità a priori del task (campo del task-entry) — ASSUMPTION-007
- **Campo**: `Complessità (ipotesi)` ∈ {`trivial`, `standard`, `critical`} (stesso enum di `flow-run/references/model-tiering.md` e `task-implementer/references/complexity-criteria.md`).
- **Dove**: ogni task-entry di `tasks-active.md`, emesso da `planner` in `plan`/`expand` (logica in `task-expansion`).
- **Semantica**: ipotesi a priori del planner, **antecedente** al `meta.json` del PM (che può raffinarla al brief). Esiste prima di qualunque spawn.
- **Consumo (futuro, fuori scope di questo epic)**: `flow-run` la userà per la topologia di spawn (single-agent per `trivial` vs PM+DEV).
- **Definito in**: feature `contract` (schema) + `core` (emissione).

## Librerie e versioni
- Nessuna (Markdown + bash). Le skill non hanno dipendenze runtime.

## Consolidato da planner-unification-contract (2026-06-02)
> Decisioni durevoli risalite dalla feature `contract` a fine feature (bubble-up single-hop). Vincolanti per le feature successive dell'epic.

- **File-contratto canonici** (single-source, le feature successive li linkano — non li duplicano):
  - `skills/planner/anchor-schema.md` — schema dell'header anchor.
  - `skills/planner/planning-source-contract.md` — Planning source contract **v2** (4 tier, scan, esclusione `docs/archive/**`, brief co-locato, ID opachi, back-compat, campo `Complessità (ipotesi)`).
  - `skills/planner/task-bundle-spec.md` — bundle leggero del tier `task`.
  - `skills/feature-planner/feature-artifacts.md` porta ora un redirect **LEGACY v1** in testa (contenuto v1 intatto) → la feature `downstream` ripunta i consumer alla v2.
- **Formato canonico anchor** (riga singola dopo l'H1): `<!-- Anchor --> **Tier**: <tier> · **Parent**: <slug|—> · **Bubble-up target**: <path|—>`. Separatore `·` (U+00B7), vuoto `—` (U+2014), marker `<!-- Anchor -->` per parsing bash.
- **Anchor solo su** `00-context.md` e `technical-context.md` (gli altri artefatti non lo portano). Anchor assente = back-compat implicita; anchor con `—` = standalone esplicito.
- **Tier `task`**: home `docs/tasks/<slug>/`; obbligatori `00-context.md` + `technical-context.md` (anchor) + `tasks-active.md` (1 task-entry); `02-abstract.md` opzionale; `roadmap`/`milestones` esclusi; anchor sempre valorizzato (ha sempre un parent).
- **Schema task-entry**: include `Complessità (ipotesi)` ∈ {trivial, standard, critical} (ASSUMPTION-007), emesso da `core`.

## Consolidato da planner-unification-core (2026-06-02)
> Decisioni durevoli risalite dalla feature `core` (bubble-up single-hop). La skill `planner` è ora materializzata.

- **Skill `planner` esistente**: `skills/planner/SKILL.md` — router sottile (description che assorbe i trigger dei 3 planner, scelta/conferma tier, modo `plan` attivo). I modi `expand` e `finalize` sono **stub "Rimandato"** → li implementa la feature `finalize`.
- **Reference materializzati** sotto `skills/planner/references/`: condivisi `elicitation.md`, `critical-review.md`, `task-expansion.md`, `artifact-contract.md` (nome scelto vs `artifact-templates`); per-tier `tier-feature.md`, `tier-task.md`, `tier-epic.md`, `tier-project.md`; routing `tier-inference.md`. **Single-source, linkati, non duplicati.**
- **Routing tier** (`tier-inference.md`): priorità hint esplicito > directory `docs/<tier>/` > keyword > default `feature`; scaling solo adiacente (±1); **conferma sempre obbligatoria** anche con hint valido.
- **`task-expansion.md`** emette il campo `Complessità (ipotesi)` per ogni task (euristica trivial/standard/critical, fail-safe verso l'alto); enum single-source in `planning-source-contract.md`.
- **Sorgenti `*-planner` non ancora rimosse**: restano in sola lettura (consolidate, non modificate) → la rimozione è della feature `release`; il ripuntamento dei consumer è di `downstream`.

## Consolidato da planner-unification-finalize (2026-06-02)
> Decisioni durevoli risalite dalla feature `finalize` (bubble-up single-hop). I modi `expand`/`finalize` sono ora reali.

- **Modi `expand` e `finalize` materializzati**: `skills/planner/references/expand.md` e `finalize.md`; `SKILL.md` li linka (stub rimossi). Pattern SKILL.md sottile + reference lazy.
- **`finalize` POSSIEDE il bubble-up** (Step 9 di `finalize.md`): gate attended (verify==pass, no escalation) → legge `Bubble-up target` dall'anchor → **selezione guidata dall'utente** del sottoinsieme → append-only datato (`## Consolidato da <slug> (YYYY-MM-DD)`) → **un solo hop**. Guardia idempotenza: `grep "## Consolidato da <slug>"` (senza data). Copia fedele, non riassunto. **Supersede** il bubble-up grezzo (copia integrale) di flow-run 1.1.0.
- **Per `downstream`**: `flow-run`, a fine source, deve **invocare `planner finalize <slug>`** invece dell'append diretto del bubble-up 1.1.0 (è il task `downstream-005`). Standalone (`Parent —`/anchor assente) → finalize locale no-op di risalita.
- **`expand`**: conflitto slug → chiede (non procede); backup `<tasks-file>.bak`; ID stabili (match per ID, mai riassegnare ID rimossi, nuovi da `max+1`).
- **`finalize` non tocca `tasks-active.md`** (responsabilità utente/orchestratore — coerente con l'attuale task-implementer).

## Consolidato da planner-unification-downstream (2026-06-02)
> Decisioni durevoli risalite dalla feature `downstream` (bubble-up single-hop, attended). Eseguita **a mano** (RISK-001), un commit per task.

- **Consumer ripuntati a `skills/planner/`**: task-implementer, code-implementer, flow-run, flow-sync, whats-next, migrate (+ reference) puntano al contratto v2 e ai reference condivisi sotto `planner/`. **0 link path residui a `feature-planner/`/`project-planner/` nei consumer** → i 3 vecchi planner sono **safe da rimuovere** in `release`.
- **Scan tier task**: la risoluzione context-root include `docs/tasks/*/tasks-active.md` (guardia: solo dir con tasks-file) in task-implementer/code-implementer/flow-sync/whats-next.
- **flow-run auto-archivio → `planner finalize` (attended)**: rimosso l'append grezzo 1.1.0; bubble-up via planner finalize.md in modalità attended (auto-select coerente); padre via anchor `Bubble-up target`.
- **whats-next**: propone `planner expand <slug>` per le source shell/non espanse; gerarchia via anchor `Parent`.

---
Generato: 2026-06-02 | Versione: 1
