# 00 — Contesto feature (FIXTURE)

> Feature fittizia `sample-feature` del progetto Acme Notes. Statico, versionato.
> Context-root della feature: `docs/features/sample-feature`.

## Feature

**Note sharing** — condivisione di una nota con altri utenti dello stesso tenant.

## Assunzioni di feature

- **ASSUMPTION-feat-001**: la condivisione resta dentro il boundary tenant (no cross-tenant).
- **ASSUMPTION-feat-002**: i permessi di condivisione sono `read` o `read-write`.

## Vincoli

- Eredita tutti i vincoli di progetto (vedi `docs/planning/`).
- Boundary multi-tenant non aggirabile.

## Rischi

- **RISK-feat-001**: escalation di permessi se il livello di share non è validato.
