# Context — Feature: Contratto v2 + anchor model (`planner-unification-contract`)

**Progetto**: otto
**Tipo**: feature su progetto esistente

<!-- Anchor --> **Tier**: feature · **Parent**: planner-unification · **Bubble-up target**: docs/epics/planner-unification/technical-context.md
**Epic**: planner-unification
**Dipende da feature**: —

## Cosa fa la feature

Definisce — senza implementare alcuna skill — il tronco comune dell'epic: il Planning source contract v2 relocato sotto `skills/planner/`, lo schema dell'header anchor (Tier/Parent/Bubble-up target) e la home `docs/tasks/<slug>/` del tier task. Produce esclusivamente documenti-contratto su cui tutto il resto dell'epic dipende. Per il contesto e gli obiettivi dell'epic vedi `docs/epics/planner-unification/{00-context,02-abstract,technical-context}.md`.

## Derivato dal codebase

- Moduli: `skills/planner/` [nuovo, destinazione del contratto relocato]; il contratto oggi vive in `skills/feature-planner/feature-artifacts.md`.
- Stack: markdown (skill Claude Code; prosa + bash, nessun build/compilazione).
- Build: —

## Boundary e scope

- In scope: schema header anchor; Planning source contract v2 sotto `planner/`; spec del bundle leggero del tier task con home `docs/tasks/<slug>/`.
- Out of scope: implementazione della skill `planner`, logica di finalize/bubble-up, ripuntamento dei downstream (delegati alle feature core/finalize dell'epic).
- Integrazione: i contratti definiti qui sono la single source consumata dalla feature core e dalle skill downstream una volta ripuntate.

## Tracked assumptions

- ASSUMPTION-planner-unification-contract-001: `docs/tasks/<slug>/` è la home del tier task, NON il layout flat `docs/tasks/T-NNN.md` rimosso in 1.x.
- ASSUMPTION-planner-unification-contract-002: header anchor assente ⇒ source trattata come standalone (back-compat) senza bubble-up.

## Known risks

- RISK-planner-unification-contract-001 🟡: il contratto v2 risulta incoerente con i consumer downstream finché questi non vengono ripuntati alla nuova location/semantica → mitigazione: il ripuntamento è responsabilità delle feature downstream dell'epic, non di questa.

---
Generato: 2026-06-02 | Versione: 1
