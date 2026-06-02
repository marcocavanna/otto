# Task attivi — Feature: Contratto v2 + anchor model (`planner-unification-contract`)

**Feature**: planner-unification-contract
**Effort totale stimato**: 4-7 ore
**Definition of done feature**: contratto v2 + schema anchor + spec tier task + campo `Complessità (ipotesi)` nel task-entry documentati e coerenti, pronti per la feature core.

## Task

### planner-unification-contract-001 — 🏗️ [design] Definire lo schema header anchor (Tier/Parent/Bubble-up target)

- **Effort**: 1-2h
- **Definition of done**: documento che specifica i 3 campi, enum Tier {project, epic, feature, task}, semantica del valore vuoto `—`, posizione dell'header (00-context + technical-context), esempi per ogni tier.
- **Dipende da**: —
- **Status**: ✅ done

### planner-unification-contract-002 — 🏗️ [design] Redigere il Planning source contract v2 relocato sotto skills/planner/

- **Effort**: 2-3h
- **Definition of done**: definisce risoluzione context-root per i 4 tier incl. `docs/tasks/<slug>/`, esclusione `docs/archive/**`, brief co-locato `<context-root>/tasks/<id>.md`, ID opachi unici, back-compat (anchor assente = standalone), **e il campo `Complessità (ipotesi)` ∈ {trivial,standard,critical} nel task-entry schema** (ipotesi a priori del planner, antecedente al `meta.json` del PM — ASSUMPTION-planner-unification-007).
- **Dipende da**: planner-unification-contract-001
- **Status**: ✅ done

### planner-unification-contract-003 — 📚 [docs] Specificare il bundle leggero del tier task

- **Effort**: 1-2h
- **Definition of done**: file minimi del tier task (tasks-active + technical-context con anchor obbligatori; 00-context minimale; 02-abstract opzionale), criteri "quando è task e non feature", esempio completo in `docs/tasks/<slug>/`.
- **Dipende da**: planner-unification-contract-002
- **Status**: ✅ done

## Note operative

- Deliverable interamente in markdown; nessun build/test, verifica via dogfooding.
- Il contratto v2 va relocato sotto `skills/planner/`; l'origine attuale è `skills/feature-planner/feature-artifacts.md`.
- Preservare la semantica di risoluzione esistente (scan per directory, esclusione archive, brief co-locato, ID opachi) — vedi 02-abstract.

## Out of scope per questa feature

- Implementazione della skill `planner` → feature core.
- Logica di finalize / bubble-up e ripuntamento dei consumer downstream → feature core/finalize.

---
Generato: 2026-06-02 | Versione: 1 | Feature: planner-unification-contract
