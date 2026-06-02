# Technical context — Feature: Contratto v2 + anchor model (`planner-unification-contract`)

> Seed da docs/epics/planner-unification/technical-context.md

<!-- Anchor --> **Tier**: feature · **Parent**: planner-unification · **Bubble-up target**: docs/epics/planner-unification/technical-context.md
**Epic**: planner-unification
**Dipende da feature**: —

## Convenzioni di progetto

### Build & test

- build_command: `—`
- Verifica: dogfooding manuale (le skill sono markdown+bash, nessun build/compilazione; "test" = lettura/uso manuale dei contratti prodotti).

## Pattern architetturali

- Single-source dei contratti: il Planning source contract vive in un unico file canonico (relocato sotto `skills/planner/`), non duplicato tra skill.
- Lettura lazy: i consumer caricano il contratto e la context-root solo quando servono — vedi seed `docs/epics/planner-unification/technical-context.md`.

## Value Objects / contratti

Definiti QUI (deliverable di questa feature):

- **Anchor schema**: header in testa a `00-context.md` e `technical-context.md`. Tre campi — `Tier`, `Parent`, `Bubble-up target`. `Tier` ∈ enum {project, epic, feature, task}. Valore vuoto `—` = campo non applicabile (es. feature senza dipendenze). Anchor assente ⇒ source standalone (back-compat).
- **Planning source contract v2**: risoluzione context-root per i 4 tier (incl. `docs/tasks/<slug>/`), esclusione `docs/archive/**`, brief co-locato `<context-root>/tasks/<id>.md`, ID opachi unici, back-compat su anchor assente.
- **Taxonomy 4 tier**: project · epic · feature · task — gerarchia con bubble-up single-hop selettivo via finalize (semantica nel seed; qui se ne fissa la tassonomia e il mapping su Tier).
- **Bundle leggero del tier `task`**: spec dei file minimi di una planning source di tipo `task` (home `docs/tasks/<slug>/`), criteri di scelta tier, esempio completo. Definito da task -003.

> **Seed aggiornato dall'epic (2026-06-02, ASSUMPTION-007)**: il Planning source contract v2 include il campo **`Complessità (ipotesi)`** ∈ {trivial, standard, critical} nel task-entry. Ipotesi a priori del planner, antecedente al `meta.json` del PM. Definito qui (schema), emesso da `core` (`task-expansion`). Consumo da `flow-run` (topologia di spawn) = futura epic, fuori scope.

## Decisioni tattiche da brief (append-only)

### planner-unification-contract-001 — 2026-06-02

- **Formato canonico anchor**: `<!-- Anchor --> **Tier**: <tier> · **Parent**: <slug|—> · **Bubble-up target**: <path|—>` — riga singola dopo il titolo H1.
- **Separatore**: punto mediano `·` (U+00B7) tra i campi — già usato negli artefatti esistenti.
- **Commento HTML `<!-- Anchor -->`**: necessario per parsing bash unambiguo (`grep '<!-- Anchor -->'`).
- **Posizione**: in `00-context.md` (human-readable) E in `technical-context.md` (machine-parsato da `finalize`). Entrambi obbligatori.
- **Deliverable**: `skills/planner/anchor-schema.md` [new].

### planner-unification-contract-001 — finalize — 2026-06-02

- **Artefatti che portano l'anchor**: solo `00-context.md` e `technical-context.md`. Gli altri artefatti di planning (`02-abstract.md`, `roadmap.md`, `milestones.md`, `tasks-active.md`, brief dei task) non portano l'anchor — la coppia è sufficiente per risoluzione e bubble-up.
- **Distinzione "anchor assente" vs "anchor con —"**: anchor assente = back-compat implicita (pre-2.0.0 o standalone non dichiarato); anchor presente con `—` = standalone moderno esplicito e tracciato. Semantica identica, intenzionalità diversa.
- **build skipped**: stack Markdown puro, nessuna compilazione necessaria. Confermato in fase di implementazione.

### planner-unification-contract-002 — 2026-06-02

- **Deliverable**: `skills/planner/planning-source-contract.md` [new] — file canonico del contratto v2.
- **Redirect v1**: `skills/feature-planner/feature-artifacts.md` § "Planning source contract (CANONICO)" riceve un avviso LEGACY in testa; il contenuto v1 rimane (no delete).
- **Schema task-entry esteso**: aggiunge il campo `Complessità (ipotesi)` ∈ {trivial, standard, critical} al formato canonico del task-entry in `tasks-active.md`. Ipotesi a priori del planner; schema definito qui, emissione in feature `core`.
- **Tier `task`**: home `docs/tasks/<slug>/`, tasks-file `docs/tasks/<slug>/tasks-active.md` — esplicitato nel contratto v2 (non era nella v1).
- **Invariati dalla v1**: scan per directory, esclusione `docs/archive/**`, brief co-locato `<context-root>/tasks/<id>.md`, ID opachi unici.

### planner-unification-contract-003 — 2026-06-02

- **Deliverable**: `skills/planner/task-bundle-spec.md` [new] — spec del bundle leggero del tier `task`.
- **Criterio di scelta tier task**: condizioni binarie (a) singolo task atomico E (b) parent esistente; se una non vale → tier `feature`.
- **File obbligatori bundle**: `00-context.md` (anchor obbligatorio), `technical-context.md` (anchor obbligatorio, seedato dal parent), `tasks-active.md` (esattamente 1 task-entry con schema completo incl. `Complessità (ipotesi)`).
- **File opzionali bundle**: `02-abstract.md` — ammesso ma non obbligatorio.
- **File esclusi dal bundle**: `roadmap.md`, `milestones.md`, `03-milestones.md` — non ammessi al tier `task`.
- **Anchor obbligatorio per tier `task`**: mai `anchor assente` per questo tier; il tier `task` per definizione ha un parent, quindi l'anchor è sempre presente e valorizzato.
- **Seed `technical-context.md`**: responsabilità di `core` al momento della creazione; `task-implementer` lo estende append-only.

---
Generato: 2026-06-02 | Versione: 1
