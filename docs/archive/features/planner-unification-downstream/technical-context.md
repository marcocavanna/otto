# Technical context — Feature: Re-anchoring downstream + scan tier task (`planner-unification-downstream`)

> Seed da `docs/epics/planner-unification/technical-context.md`

<!-- Anchor --> **Tier**: feature · **Parent**: planner-unification · **Bubble-up target**: docs/epics/planner-unification/technical-context.md
**Epic**: planner-unification
**Dipende da feature**: planner-unification-finalize

## Convenzioni di progetto

### Build & test

— Nessuna build. Plugin Claude Code markdown+bash. Verifica = dogfooding (plan → flow-run → finalize) sui tool aggiornati.

## Pattern architetturali

- **single-source dei link**: i reference al "Planning source contract" puntano a un'unica radice `skills/planner/`; nessun mirror del contratto altrove.
- **ID opachi**: i downstream non interpretano il significato dell'ID; lo risolvono per scan di directory.
- **scan per directory**: la risoluzione context-root itera le radici note (`docs/planning/`, `docs/features/*/`, ora `docs/tasks/*/`) — vedi seed dell'epic.

## Value Objects / contratti

- consuma il **contratto v2** (`Planning source contract`) prodotto da `planner-unification-contract` + lo **schema anchor** introdotto dall'epic;
- l'anchor (`<!-- Anchor --> Tier · Parent · Bubble-up target`) è la fonte della gerarchia padre-figlio per rollup (whats-next) e riconciliazione (flow-sync);
- il **tier task** introduce la radice `docs/tasks/<slug>/` nello scan context-root, con brief co-locati sotto `docs/tasks/<slug>/tasks/`.

> **Seed aggiornato dall'epic (2026-06-02, ASSUMPTION-009)**: `whats-next` deve riconoscere le feature **shell / non espanse** (tasks-active stub) e proporre `planner expand <slug>` come prossima azione, oltre ai comandi `flow-run` per le feature espanse. È l'advisor che chiude il loop verso il planner, non solo verso l'esecuzione.

---
Generato 2026-06-02 · v1 · Feature: planner-unification-downstream
