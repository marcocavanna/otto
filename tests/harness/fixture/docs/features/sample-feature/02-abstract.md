# 02 — Abstract feature (FIXTURE)

> Vincoli strategici della feature `sample-feature`. Statico, versionato.
> Additivo rispetto a `docs/planning/02-abstract.md`: non lo contraddice.

## Scope tecnico

- Estende il dominio Note con il concetto di Share.
- Riusa lo stack di progetto (.NET 8, React 18, EF Core).

## Pattern strategici (feature)

- Stessi del progetto: layering, DTO ai boundary, Result<T>.
- Nuovo VO `SharePermission` introdotto da questa feature.

## Esclusioni tecniche

- NO inviti via email in questa feature (solo share interno al tenant).
- NO MediatR / AutoMapper (ereditato dal progetto).
