# Technical Context — Feature: Ritiro vecchie skill + migrazione + 2.0.0 (`planner-unification-release`)

> Seed da `docs/epics/planner-unification/technical-context.md`

<!-- Anchor --> **Tier**: feature · **Parent**: planner-unification · **Bubble-up target**: docs/epics/planner-unification/technical-context.md
**Epic**: planner-unification
**Dipende da feature**: planner-unification-downstream

## Convenzioni di progetto

### Build & test

- Build: — (plugin Claude Code in markdown + bash, nessuna pipeline di build)
- Verifica: dogfooding end-to-end completo (smoke via `planner` su task/feature/epic + retrofit `migrate` su progetto reale)

## Pattern architetturali

- `migrate`: ciclo preview → apply → post-verify, idempotente e reversibile (backup) — vedi la skill esistente `skills/migrate/`. Il retrofit anchor riusa lo stesso ciclo.
- SemVer: change breaking (rimozione skill) → bump major a 2.0.0.

## Value Objects / contratti

- Consuma lo schema **Anchor** (Tier / Parent / Bubble-up target) per il retrofit, derivando Parent e bubble-up target dalla roadmap Source e dalla struttura del progetto.

---
Generato 2026-06-02 v1
