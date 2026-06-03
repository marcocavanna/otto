# Context — Feature: Re-anchoring downstream + scan tier task (`planner-unification-downstream`)

**Progetto**: otto (plugin Claude Code — markdown + bash, nessuna build)
**Tipo**: feature

<!-- Anchor --> **Tier**: feature · **Parent**: planner-unification · **Bubble-up target**: docs/epics/planner-unification/technical-context.md
**Epic**: planner-unification
**Dipende da feature**: planner-unification-finalize

## Cosa fa la feature

Adegua i consumatori downstream alla nuova `skills/planner/` a 4 tier SENZA cambiarne la sostanza:
- **ripunta i link** (~15-20) al "Planning source contract" e ai reference condivisi da `skills/feature-planner/` e `skills/project-planner/` verso `skills/planner/`;
- **insegna agli scanner** (task-implementer, code-implementer, flow-sync, whats-next) la radice del nuovo tier task `docs/tasks/<slug>/` e la lettura degli anchor per ricostruire la gerarchia padre-figlio;
- **sposta flow-run sul contratto**: a fine source invoca `planner finalize <slug>` invece di fare l'append diretto del bubble-up (comportamento grezzo introdotto in 1.1.0).

## Derivato dal codebase

Moduli toccati:
- `skills/task-implementer/` — scan context-root + risoluzione ID.
- `skills/code-implementer/` — scan context-root + risoluzione ID.
- `skills/flow-run/` — invocazione finalize a fine source (era append diretto).
- `skills/flow-sync/` — riconoscimento source tier-task, coerenza anchor.
- `skills/whats-next/` — board multi-piano + rollup gerarchico via anchor.
- `agents/pm.md` — reference al contratto/planner.

Build & test: — (plugin markdown+bash; verifica = dogfooding).

## Boundary e scope

**In scope**:
- ripuntare i link verso `skills/planner/`;
- scan del tier task `docs/tasks/<slug>/`;
- flow-run → `planner finalize <slug>`;
- whats-next e flow-sync anchor-aware.

**Out of scope**:
- rimozione delle vecchie skill `feature-planner`/`project-planner` e retrofit di `migrate` → demandati alla release.

## Tracked assumptions

- **ASSUMPTION-downstream-001**: i downstream restano scanner per-directory di ID opachi; cambiano SOLO path, scan e invocazione, non la semantica di risoluzione né il modello dati interno.

## Known risks

- **RISK-downstream-001 🔴 — AUTO-MODIFICA**: questa feature riscrive `flow-run`, che potrebbe essere lo stesso orchestratore che la sta eseguendo. → Mitig: eseguire a mano o con branch/commit per task; toccare `flow-run` per ULTIMO (task -005).
- **RISK-downstream-002 🟡 — link orfano**: un link non ripuntato rompe la risoluzione del contratto. → Mitig: grep esaustivo, DoD "0 riferimenti residui".

---
Generato 2026-06-02 · v1 · Feature: planner-unification-downstream
