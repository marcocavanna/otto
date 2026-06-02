# Technical context — Feature: Skill planner core + plan (4 tier) (`planner-unification-core`)

> Seed da `docs/epics/planner-unification/technical-context.md` (convenzioni, pattern e contratti condivisi dell'epic). Qui solo le specializzazioni della feature.

<!-- Anchor --> **Tier**: feature · **Parent**: planner-unification · **Bubble-up target**: docs/epics/planner-unification/technical-context.md
**Epic**: planner-unification
**Dipende da feature**: planner-unification-contract

## Convenzioni di progetto
### Build & test
- build_command: `—` · test_command: `—`
- Verifica = dogfooding manuale: lanciare `planner` in modo `plan` per ciascun tier (project/epic/feature/task) e controllare che gli artefatti escano con anchor coerente; verifica manuale 0-link-orfani sui reference consolidati.

## Pattern architetturali
- **SKILL.md sottile + reference lazy**: il router/scelta-tier sta nel SKILL.md; la logica `plan` per tier e i condivisi stanno in `references/`, letti solo allo step che li usa.
- **Single-source dei reference**: ogni condiviso (`elicitation`, `critical-review`, `task-expansion`, `artifact-contract`) vive in UN solo file sotto `planner/references/` ed è linkato dai tier, mai duplicato. Il consolidamento da `project-planner/` deduplica le varianti tier-specifiche rendendole tier-agnostiche.
- **Porting, non riscrittura**: i tier feature/epic/project portano la logica `plan` delle skill omonime esistenti senza cambiare la shape degli artefatti.

## Value Objects / contratti
Consuma (definiti dalla feature `planner-unification-contract`):
- **Anchor schema**: header `Tier`/`Parent`/`Bubble-up target` su `00-context.md` e `technical-context.md` di ogni artefatto generato.
- **Planning source contract v2**: risoluzione per scan di directory, tier `task` con context-root `docs/tasks/<slug>/`, back-compat anchor assente = standalone.
- **Taxonomy dei 4 tier**: project ⊃ epic ⊃ feature ⊃ task; stesso set di file, profondità di elicitation diversa.

> **Seed aggiornato dall'epic (2026-06-02, ASSUMPTION-007)**: `task-expansion` (consolidato in core-002) deve **emettere per ogni task il campo `Complessità (ipotesi)`** ∈ {trivial, standard, critical}. Ipotesi a priori, antecedente al `meta.json` del PM; il consumo da `flow-run` (single-agent vs PM+DEV) è di una futura epic.

> **Seed aggiornato dall'epic (2026-06-02, ASSUMPTION-008)**: il tier-epic esprime il sizing per feature nella `roadmap.md` come **t-shirt size** (S/M/L) indicativa, **non** come conteggio task/effort autorevole. Numero task ed effort reali li fissa solo `feature-planner expand`.

> **Seed aggiornato dall'epic (2026-06-02, ASSUMPTION-009)**: il tier-epic emette i `tasks-active.md` dei figli come **shell** (stub "da espandere", nessun task autorevole); i task reali nascono solo a `planner expand <feature>`. Nessuna cascata automatica epic→feature→task.

## Decisioni tattiche — core-002 (2026-06-02)

- **Nome file template consolidato**: `artifact-contract.md` (non `artifact-templates.md`): riflette la natura contrattuale del file (artefatti attesi per tier), non solo il template visivo.
- **Euristica `Complessità (ipotesi)` in task-expansion.md**: descritta come guida operativa (trivial/standard/critical con fail-safe verso l'alto); la spec formale dell'enum resta single-source in `planning-source-contract.md` — il reference la applica senza duplicarla.
- **artifact-contract.md tier task**: linka `skills/planner/task-bundle-spec.md`, non duplica il bundle leggero.
- **Sorgenti in sola lettura**: `skills/project-planner/*`, `skills/epic-planner/references/*`, `skills/feature-planner/feature-artifacts.md` non vengono modificate — sono sorgenti di consolidamento.

## Decisioni tattiche — core-007 (2026-06-02)

- **tier-inference.md come reference dedicato**: l'euristica di inferenza e la conferma vivono in `skills/planner/references/tier-inference.md` (nuovo), non inline in SKILL.md. Rispetta il pattern lazy reference e mantiene SKILL.md sottile.
- **Priorità dei segnali di inferenza**: hint esplicito > directory esistente (`docs/<tier>/`) > keyword nello scope > default `feature`. Nessun lookup filesystem obbligatorio: il LLM usa i segnali presenti nel contesto conversazionale.
- **Scaling adiacente**: l'offerta scaling up/down riguarda solo i tier adiacenti (±1); nessun salto multiplo per ridurre ambiguità.
- **Conferma obbligatoria sempre**: anche in presenza di hint esplicito valido, il tier viene proposto e aspetta conferma (ASSUMPTION-planner-unification-core-002).

---
Generato: 2026-06-02 | Versione: 3
