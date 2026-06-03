# Task attivi — Feature: Re-anchoring downstream + scan tier task (`planner-unification-downstream`)

**Feature**: planner-unification-downstream
**Effort totale stimato**: 6-12 ore
**Definition of done feature**:
- 0 link residui alle vecchie path (`feature-planner/`, `project-planner/`) nei runtime;
- gli scanner risolvono `docs/tasks/<slug>/` e leggono gli anchor;
- flow-run invoca `planner finalize <slug>` (rimosso l'append 1.1.0);
- `whats-next` propone anche azioni di planning (`planner expand`/`plan`), non solo `flow-run`;
- verifica end-to-end ok.

## Task

### planner-unification-downstream-001 — 🔧 [chore] Ripuntare i link al contratto e ai reference condivisi verso planner/
- **Effort**: 2-3h
- **Definition of done**: grep esaustivo; tutti i ~15-20 link aggiornati; "0 riferimenti residui a `feature-planner/` o `project-planner/`" nei runtime.
- **Dipende da**: planner-unification-finalize-005
- **Status**: ✅ done

### planner-unification-downstream-002 — 💻 [impl] Scan tier task docs/tasks/<slug>/ in task-implementer e code-implementer
- **Effort**: 1-2h
- **Definition of done**: la risoluzione context-root include `docs/tasks/*/`; un ID di un task-tier risolve correttamente; brief co-locato sotto `docs/tasks/<slug>/tasks/`.
- **Dipende da**: planner-unification-downstream-001
- **Status**: ✅ done

### planner-unification-downstream-003 — 💻 [impl] whats-next: tier task nel board + lettura anchor
- **Effort**: 1-2h
- **Definition of done**: il board mostra le source tier-task; il rollup usa gli anchor per la gerarchia padre-figlio.
- **Dipende da**: planner-unification-downstream-002
- **Status**: ⚪ todo

### planner-unification-downstream-004 — 💻 [impl] flow-sync: tier task + coerenza con anchor
- **Effort**: 1-2h
- **Definition of done**: flow-sync riconosce le source tier-task; nessuna regressione sulla riconciliazione roadmap esistente.
- **Dipende da**: planner-unification-downstream-002
- **Status**: ⚪ todo

### planner-unification-downstream-005 — 🔧 [chore] flow-run invoca planner finalize invece dell'append diretto
- **Effort**: 2-3h
- **Definition of done**: l'auto-archivio chiama `planner finalize <slug>`; rimosso l'append grezzo del bubble-up 1.1.0; mirror roadmap e cleanup `.flow/briefs` invariati.
- **Dipende da**: planner-unification-downstream-003, planner-unification-downstream-004
- **Status**: ⚪ todo

### planner-unification-downstream-006 — 🧪 [test] Verifica end-to-end con i tool aggiornati
- **Effort**: 1-2h
- **Definition of done**: dogfooding plan → flow-run → finalize per un tier task e una feature; bubble-up corretto; nessun link orfano.
- **Dipende da**: planner-unification-downstream-005
- **Status**: ⚪ todo

### planner-unification-downstream-007 — 💻 [impl] whats-next propone azioni via planner (expand di shell, ecc.)
- **Effort**: 1-2h
- **Definition of done**: `whats-next` riconosce le feature **shell / non espanse** (`tasks-active.md` stub o senza task) e propone `planner expand <slug>`; per ciò che non è ancora pianificato propone `planner …`; continua a proporre i comandi verso `flow-run` per le feature espanse con task pending. Resta read-only.
- **Dipende da**: planner-unification-downstream-003
- **Status**: ⚪ todo

## Note operative

- **ATTENZIONE auto-modifica**: il task -005 riscrive `flow-run`, l'orchestratore che potrebbe star eseguendo questi task. Toccare `flow-run` per ULTIMO; valutare l'esecuzione manuale (o branch/commit per task) per evitare di mutare il loop in corsa.

## Out of scope per questa feature

- rimozione delle vecchie skill `feature-planner`/`project-planner`;
- retrofit di `migrate` per il nuovo layout;
- bump 2.0.0 → tutto demandato alla release.

---
Generato 2026-06-02 · v1 | Feature: planner-unification-downstream
