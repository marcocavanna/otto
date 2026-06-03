# Context — Feature: Ritiro vecchie skill + migrazione + 2.0.0 (`planner-unification-release`)

**Progetto**: otto
**Tipo**: feature

<!-- Anchor --> **Tier**: feature · **Parent**: planner-unification · **Bubble-up target**: docs/epics/planner-unification/technical-context.md
**Epic**: planner-unification
**Dipende da feature**: planner-unification-downstream

## Cosa fa la feature

Chiude l'epic `planner-unification`. Rimuove in modo netto le 3 vecchie skill di pianificazione (`project-planner`, `feature-planner`, `epic-planner`): i loro trigger sono ormai assorbiti dalla `description` della skill unificata `planner`. Estende la skill `migrate` per il RETROFIT degli anchor negli artefatti dei progetti già esistenti. Porta la versione del plugin a 2.0.0 (plugin.json + marketplace.json) con README/changelog aggiornati e breaking notice esplicita.

## Derivato dal codebase

Moduli coinvolti:
- `skills/project-planner/`, `skills/feature-planner/`, `skills/epic-planner/` — da RIMUOVERE
- `skills/migrate/` — da ESTENDERE (retrofit anchor)
- `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` — bump 2.0.0
- `README.md` — aggiornamento (planner unico, 4 tier, anchor, bubble-up via finalize) + breaking notice
- Build: — (plugin markdown+bash, nessun artefatto compilato)

## Boundary e scope

In scope:
- rimozione delle 3 skill planner
- retrofit anchor via `migrate`
- release 2.0.0 (versioning + README/changelog + breaking notice)

Out of scope:
- nuove funzionalità del planner (anchor, 4 tier, bubble-up single-hop via finalize) — già realizzate nelle feature precedenti dell'epic

## Tracked assumptions

- ASSUMPTION-planner-unification-release-001: rimozione netta delle 3 skill, NESSUN alias o shim di retrocompatibilità; i trigger restano coperti dalla sola `description` di `planner`.
- ASSUMPTION-planner-unification-release-002: il retrofit degli anchor è idempotente e reversibile, coerente con il comportamento attuale di `migrate` (preview → apply con backup → post-verify).

## Known risks

- RISK-planner-unification-release-001 🔴: AUTO-MODIFICA — è l'ultima feature dell'epic; si rimuovono le skill di pianificazione mentre si pianifica. Mitig: eseguire a mano / su branch dedicato, commit incrementali, non affidarsi alle skill in via di rimozione.
- RISK-planner-unification-release-002 🟡: il retrofit opera su artefatti vivi (es. epic tenancy) e può corromperli. Mitig: backup pre-apply, preview obbligatoria, post-verify di coerenza degli anchor.

---
Generato 2026-06-02 v1
