# technical-context (FIXTURE — feature source)

> Vincoli tattici della feature `sample-feature`. Statico, versionato.
> Additivo rispetto a `docs/planning/technical-context.md`.

## Convenzioni di progetto

### Build & test
- build_command: `dotnet build`
- test_command: `dotnet test`

## Librerie e versioni

- Eredita progetto. Nessuna libreria nuova introdotta dalla feature.

## Pattern architetturali

- Repository pattern (come progetto).
- DTO request/response per i boundary di share.

## Value Objects

- `SharePermission` (enum-like record: `Read` | `ReadWrite`) — introdotto da questa feature.
- Riusa `TenantId`, `NoteId` dal progetto.

## Struttura cartelle

```
src/
  Domain/        # VO SharePermission
  Application/   # INoteShareRepository, DTO
  Infrastructure/# NoteShareRepository
web/
  src/components/ # ShareDialog
```
