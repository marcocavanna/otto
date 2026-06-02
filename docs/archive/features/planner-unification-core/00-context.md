# Context — Feature: Skill planner core + plan (4 tier) (`planner-unification-core`)

**Progetto**: otto
**Tipo**: feature su progetto esistente

<!-- Anchor --> **Tier**: feature · **Parent**: planner-unification · **Bubble-up target**: docs/epics/planner-unification/technical-context.md
**Epic**: planner-unification
**Dipende da feature**: planner-unification-contract

## Cosa fa la feature

Materializza la skill unificata `skills/planner/`: un `SKILL.md` sottile (router + scelta/conferma del tier) e i quattro reference tier-{project,epic,feature,task} che implementano il modo `plan`. Consolida sotto `planner/references/` i reference condivisi (`elicitation`, `critical-review`, `task-expansion`, `artifact-contract`) oggi sparsi in `skills/project-planner/`, deduplicandoli e rendendoli tier-agnostici. Copre SOLO il modo `plan`: `expand` e `finalize` sono rimandati alla feature successiva. Per contesto, approccio e contratto dell'epic vedi `docs/epics/planner-unification/{00-context,02-abstract,technical-context}.md`.

## Derivato dal codebase

- Moduli: `skills/planner/` [nuovo, target della skill unificata]; `skills/{project,feature,epic}-planner/` [fonti da consolidare — logica plan, reference condivisi e templating].
- Stack: markdown (skill Claude Code; prosa + bash, nessun build).
- Build: —

## Boundary e scope

- In scope: `SKILL.md` (router, modi, scelta/conferma tier); i tier reference `plan` per project/epic/feature/task; consolidamento dei reference condivisi sotto `planner/references/`.
- Out of scope: modi `expand`/`finalize` e logica di bubble-up (feature finalize); ripuntamento dei downstream; rimozione delle vecchie skill `*-planner`; release/versioning.
- Integrazione: consuma i contratti definiti dalla feature `contract` (Anchor schema, Planning source contract v2, taxonomy tier). I downstream restano invariati in questa feature.

## Tracked assumptions

- ASSUMPTION-planner-unification-core-001: `SKILL.md` resta sottile (router + scelta tier) con la logica nei reference a lettura lazy, NON un monolite che inlinea i quattro tier.
- ASSUMPTION-planner-unification-core-002: il tier di default è `feature`; lo scaling up (epic/project) o down (task) è proposto dal router ma SEMPRE confermato dall'utente prima di generare artefatti.

## Known risks

- RISK-planner-unification-core-001 🟡: la feature è ampia (4 tier + consolidamento) e in `expand` può sforare 8 task → mitigazione: split lungo il confine naturale `core` + `plan-base` (SKILL.md, reference condivisi, tier feature/task) vs `plan-epic-project` (tier epic e project, più pesanti).

---
Generato: 2026-06-02 | Versione: 1
