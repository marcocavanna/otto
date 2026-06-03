# Abstract tecnico — Feature: Skill planner core + plan (4 tier) (`planner-unification-core`)

<!-- Anchor --> **Tier**: feature · **Parent**: planner-unification · **Bubble-up target**: docs/epics/planner-unification/technical-context.md

## Approccio

Vedi `docs/epics/planner-unification/02-abstract.md` per l'approccio d'insieme. Qui la regola operativa è una: **consolidare, NON copiare** i reference. I quattro condivisi (`elicitation`, `critical-review`, `task-expansion`, `artifact-contract`) hanno oggi più incarnazioni implicite tra le `*-planner`; vengono fusi in una versione tier-agnostica unica sotto `planner/references/` e linkati single-source dai tier. La logica `plan` di feature/epic/project è un **porting** delle skill esistenti in forma di reference, non una riscrittura del formato degli artefatti; il tier `task` è nuovo ma minimale.

## Moduli impattati

- `skills/planner/SKILL.md` [nuovo]: router sottile, scelta/conferma tier, elenco modi (plan attivo; expand/finalize dichiarati ma rimandati).
- `skills/planner/references/tier-{project,epic,feature,task}.md` [nuovi]: logica `plan` per tier.
- `skills/planner/references/{elicitation,critical-review,task-expansion,artifact-contract}.md` [consolidati da `project-planner/`].
- Fonti consolidate (lette, non modificate qui): `skills/{project,feature,epic}-planner/`.

## Contratti da preservare

- Planning source contract v2 e Anchor schema definiti dalla feature `contract`: gli artefatti generati da ogni tier devono portare l'header anchor (Tier/Parent/Bubble-up target) coerente.
- `description` di `SKILL.md`: deve assorbire i trigger delle tre skill `*-planner` (project/epic/feature) così che la muscle-memory utente continui a instradare verso `planner`.
- Tipologia e shape degli artefatti per tier: invariata (`00-context`, `02-abstract`, `technical-context`, `tasks-active`/`roadmap`/`milestones`).

## Trade-off

- SKILL.md sottile + reference lazy vs monolite: scelto il primo (manutenibilità, lettura mirata) accettando più file e indirezione di link.
- Consolidamento dei reference vs copia rapida: il consolidamento costa di più ora ma evita la divergenza a 3 fonti → 1 segnalata nei rischi cross-feature dell'epic.

## Rischi tecnici

- Drift dei reference durante il porting (3 fonti → 1): mitigato dal vincolo "deduplica, non copiare" e dalla verifica manuale 0-link-orfani.
- Ampiezza della feature: in `expand` può sforare 8 task → split lungo `plan-base` vs `plan-epic-project` (vedi RISK-001 in 00-context).

## Esclusioni tecniche

Nessun modo `expand`/`finalize`, nessuna logica di bubble-up, nessun nuovo formato di artefatto, nessun ripuntamento dei downstream, nessuna rimozione delle vecchie skill.

---
Generato: 2026-06-02 | Versione: 1
