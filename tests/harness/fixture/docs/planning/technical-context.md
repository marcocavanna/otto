# technical-context (FIXTURE — project source)

> Vincoli tattici del progetto fittizio. Statico, versionato.

## Convenzioni di progetto

### Build & test
- build_command: `dotnet build`
- test_command: `dotnet test`

### Naming
- File C#: PascalCase, un tipo per file.
- Repository: `<Entity>Repository`.
- Command handler: `<Verb><Entity>CommandHandler`.

## Librerie e versioni

- `Microsoft.EntityFrameworkCore` 8.0.x
- `FluentValidation` 11.x

## Pattern architetturali

- Repository pattern (interfaccia in application, impl in infrastructure).
- Command handler espliciti (no mediator).
- Result<T> per esiti operazione (no eccezioni come flow control).

## Value Objects

- `TenantId` (record, wrapper su Guid).
- `NoteId` (record, wrapper su Guid).

## Struttura cartelle

```
src/
  Domain/        # entità, VO
  Application/   # interfacce repo, command handler, DTO
  Infrastructure/# impl repo, DbContext
web/
  src/components/ # componenti React
```
