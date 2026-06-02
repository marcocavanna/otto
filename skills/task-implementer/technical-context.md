# Technical context

Gestione di `docs/planning/technical-context.md` — il registro tattico cumulativo delle decisioni tecniche del progetto.

## Cosa contiene

`technical-context.md` raccoglie decisioni **tattiche** emerse durante l'analisi dei task. Decisioni che:
- Sono **vincolanti** per i task successivi (un task futuro non può contraddirle)
- Sono **specifiche** rispetto al livello di astrazione di `02-abstract.md` (versioni di librerie, nomi di VO, naming conventions)
- Hanno **portata cross-task** (non sono assunzioni locali di un singolo task)

## Cosa NON contiene

- Decisioni **strategiche** (quelle stanno in `02-abstract.md`)
- Assunzioni **locali** di singoli task (quelle stanno nel brief stesso, prefisso ASSUMPTION-T-NNN-XXX)
- Documentazione delle classi/funzioni (questo è scope del codice e dei suoi doc comments)
- Storia delle deviazioni (quelle stanno nei brief)

## Regola di non-contraddizione

**Non negoziabile**: `technical-context.md` non può contenere voci che contraddicono `02-abstract.md`.

Se durante un brief emerge che una scelta tattica necessaria contraddice l'abstract:
1. Fermare il flusso del brief
2. Sollevare il conflitto all'utente
3. Indirizzare a `revise` di project-planner per aggiornare `02-abstract.md` *prima* di proseguire
4. Solo dopo, riprendere il brief

## Template del file

```markdown
# Technical context — [Nome progetto]

> Registro cumulativo delle decisioni tecniche tattiche del progetto.
> Vincolante per tutti i task futuri.
> 
> Vincoli strategici (non duplicare): vedi `02-abstract.md`.
> Per assunzioni locali a un singolo task: vedi il brief co-locato `<context-root>/tasks/<id>.md`.

## Librerie e versioni

[Una riga per ogni libreria scelta in modo definitivo. Versione esatta + motivo breve.]

| Libreria | Versione | Scopo | Deciso in |
|----------|----------|-------|-----------|
| BCrypt.Net-Next | 4.0.3 | password hashing | T-005 |
| FluentValidation | 11.9.0 | validation layer | T-008 |
| [...] | [...] | [...] | [...] |

## Value Objects

[Lista dei VO definiti, con la loro shape essenziale e dove sono usati.]

### Email
- **Definito in**: T-002
- **Shape**:
  ```csharp
  public sealed record Email
  {
      public string Value { get; }
      private Email(string value) { Value = value; }
      public static Result<Email> Create(string raw) { /* ... */ }
  }
  ```
- **Vincoli**: normalizzato a lowercase, validazione RFC 5322 semplificata
- **Usato in**: User, Invitation, AuditLog

### [Altro VO]
[...]

## Pattern architetturali

[Pattern adottati con scope cross-task.]

### Error handling — Result<T>
- **Adottato in**: T-005
- **Definizione**: ogni operazione di dominio che può fallire ritorna `Result<T>` o `Result`. Niente eccezioni per business logic.
- **Eccezioni ammesse solo per**: invariant violations, infrastructure errors
- **Reference**: T-005.md sezione "Pattern adottati"

### Repository pattern
- **Adottato in**: T-007
- **Definizione**: ogni aggregate root ha un repository con interfaccia in Domain e implementazione in Infrastructure
- **Convenzione naming**: `I[Entity]Repository` / `[Entity]Repository`
- **Reference**: T-007.md

### [Altro pattern]
[...]

## Naming conventions

[Convenzioni introdotte e da seguire.]

- **Entità di dominio**: PascalCase, singolare. Es: `User`, `Order`, non `Users` o `users`
- **DTO**: suffisso `Dto`. Es: `UserDto`, `CreateUserDto`
- **Interfacce**: prefisso `I`. Es: `IUserRepository`
- **Test**: `[Subject]Tests`. Es: `UserTests`, `OrderServiceTests`
- **File migration EF**: `[timestamp]_[VerboPascalCase]`. Es: `20250527_AddUserTable`
- [...]

## Convenzioni di progetto

[Cose che non rientrano nelle categorie precedenti ma sono vincolanti.]

### Struttura cartelle
```
src/
  Domain/
  Application/
  Infrastructure/
  Web/        (o Api/, Worker/, ecc.)
tests/
  Domain.UnitTests/
  Application.UnitTests/
  Integration/
```
Deciso in T-001.

### Configurazione
- Tutti i settings via `appsettings.json` + `IOptions<T>`
- Secrets via user-secrets in dev, env vars in prod
- Niente hardcoded paths/URLs/credentials

### Logging
- `Microsoft.Extensions.Logging` con sink Serilog
- Log structured (no string interpolation nei messaggi)
- Deciso in T-003

## Storia decisioni superseded

[Voci precedenti rimpiazzate. Mantenute per audit trail.]

### Superseded — BCrypt → ASP.NET Core Identity PasswordHasher
- **Originale**: BCrypt.Net-Next 4.0.3 (deciso in T-005)
- **Sostituito da**: Microsoft.AspNetCore.Identity.PasswordHasher (T-005 finalize)
- **Motivo**: già parte del runtime, niente dipendenza extra
- **Data**: YYYY-MM-DD
```

## Operazioni sul file

### Aggiungere voci

Durante `brief T-NNN`, se il task introduce decisioni nuove cross-task:
1. Aggiungere voci nelle sezioni appropriate
2. Sempre con riferimento "Deciso in: T-NNN"
3. Mai modificare voci esistenti (eccetto come superseded — vedi sotto)

### Modificare voci esistenti

Durante `finalize T-NNN`, se la realtà del codice diverge dalla decisione iniziale:
1. **Non** cancellare la voce vecchia
2. Spostarla in "Storia decisioni superseded" con motivo
3. Aggiungere nuova voce con riferimento "Sostituisce X (vedi storia)"

### Verifiche di coerenza interna

Quando si modifica `technical-context.md`:
- Le librerie referenziate nei brief esistenti sono ancora coerenti?
- I pattern citati esistono ancora?
- I VO definiti hanno tutti almeno un task che li introduce?

Se rilevate incoerenze, segnalare ma **non** modificare automaticamente i brief — modifica manuale dell'utente.

## Quando il file non esiste ancora

Al primo `brief` di un progetto, `technical-context.md` non esiste. La skill lo crea con la struttura del template ma sezioni vuote. Voci popolate man mano che i task le introducono.

Esempio sezione vuota:
```markdown
## Value Objects

[Nessun VO definito ancora.]
```

Mantenere lo scheletro anche se vuoto — serve come reminder visivo di dove andranno le voci future.
