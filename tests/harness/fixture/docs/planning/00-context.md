# 00 — Contesto progetto (FIXTURE)

> Progetto fittizio per l'harness di topologia. NON è un progetto reale.
> Serve a esercitare resolver / PM / contratti del loop attended su input controllato.

## Dominio fittizio

**Acme Notes** — micro-servizio di gestione note testuali multi-tenant.
Backend .NET, frontend React. Volutamente minimale.

## Assunzioni di progetto

- **ASSUMPTION-fx-001**: ogni nota appartiene a un singolo tenant; isolamento per `TenantId`.
- **ASSUMPTION-fx-002**: le date sono persistite in UTC.
- **ASSUMPTION-fx-003**: nessun requisito di realtime; CRUD sincrono è sufficiente.

## Vincoli

- Niente dipendenze esterne pesanti oltre lo stack base.
- Boundary multi-tenant non aggirabile da nessun task.

## Rischi

- **RISK-fx-001**: leak cross-tenant se un repository dimentica il filtro `TenantId`.

## Nota fixture

Questo file è statico e versionato. La topologia usata è quella **corrente**
(flat `docs/tasks/`), non la canonical target. Aggiornabile a migrazione completata
(vedi assunzione locale 1 del brief topology-harness-001).
