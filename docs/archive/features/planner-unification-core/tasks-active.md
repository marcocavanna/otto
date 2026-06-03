# Task attivi — Feature: Skill planner core + plan (`planner-unification-core`)

**Feature**: planner-unification-core
**Effort totale stimato**: 8-14 ore
**Definition of done feature**: skill `planner` esistente con modo `plan` funzionante per i 4 tier (genera gli artefatti con anchor) e reference condivisi consolidati sotto `planner/references/`.

## Task

### planner-unification-core-001 — 🏗️ [setup] Scaffolding skills/planner/ + SKILL.md sottile (router, modi, scelta/conferma tier)
- Effort: 2-3h
- Definition of done: `SKILL.md` con `description` che assorbe i trigger dei 3 planner; sezione routing tier (default `feature`, scaling up/down, conferma OBBLIGATORIA prima di generare); elenco modi `plan`/`expand`/`finalize` (gli ultimi due rimandati alle feature successive); link ai reference.
- Dipende da: planner-unification-contract-002
- Status: ✅ done

### planner-unification-core-002 — 💻 [impl] Consolidare i reference condivisi sotto planner/references/
- Effort: 2-3h
- Definition of done: `elicitation.md`, `critical-review.md`, `task-expansion.md`, `artifact-contract.md` sotto `planner/references/`, consolidati (deduplicati, non semplici copie) da `project-planner/`, tier-agnostici. `task-expansion` **emette per ogni task il campo `Complessità (ipotesi)`** ∈ {trivial,standard,critical} (ASSUMPTION-planner-unification-007).
- Dipende da: planner-unification-core-001
- Status: ✅ done

### planner-unification-core-003 — 💻 [impl] tier-feature.md (plan)
- Effort: 1-2h
- Definition of done: porting della logica `plan` di `feature-planner`; produce i 4 file con anchor (`Parent`=epic se figlia, altrimenti `—`).
- Dipende da: planner-unification-core-002
- Status: ✅ done

### planner-unification-core-004 — 💻 [impl] tier-task.md (plan)
- Effort: 1-2h
- Definition of done: nuovo; bundle leggero in `docs/tasks/<slug>/` con anchor; elicitation minima; `02-abstract` opzionale.
- Dipende da: planner-unification-core-003
- Status: ✅ done

### planner-unification-core-005 — 💻 [impl] tier-epic.md (plan)
- Effort: 2-3h
- Definition of done: porting di `epic-planner` (decomposition + epic-artifacts) come tier; materializza layer epic + feature figlie con anchor coerenti. La `roadmap.md` esprime il sizing per feature come **t-shirt size** indicativa (S/M/L), **non** conteggio task/effort autorevole (ASSUMPTION-008). I `tasks-active.md` dei figli sono **shell** (stub "da espandere", nessun task autorevole): i task reali nascono solo a `planner expand <feature>` (ASSUMPTION-009).
- Dipende da: planner-unification-core-002
- Status: ✅ done

### planner-unification-core-006 — 💻 [impl] tier-project.md (plan)
- Effort: 2-3h
- Definition of done: porting di `project-planner` (pitch/milestone/phases) come tier più pesante.
- Dipende da: planner-unification-core-002
- Status: ✅ done

### planner-unification-core-007 — 💻 [impl] Inferenza + conferma del tier nel router
- Effort: 1-2h
- Definition of done: euristica di inferenza dal testo/funzionalità; default `feature`; proposta di scaling up/down; conferma esplicita prima di generare; gestione hint utente esplicito.
- Dipende da: planner-unification-core-001
- Status: ✅ done

## Note operative
- Rischio dimensione (RISK-planner-unification-core-001): se in `expand` la feature sfora 8 task, split lungo il confine `plan-base` (001/002/003/004/007) vs `plan-epic-project` (005/006).

## Out of scope per questa feature
- Modi `expand`/`finalize` e logica di bubble-up → feature finalize.
- Ripuntamento dei downstream → feature downstream.
- Rimozione delle vecchie skill `*-planner` e release/versioning.

---
Generato: 2026-06-02 | Versione: 1 | Feature: planner-unification-core
