# Decision recording

Come e dove registrare le decisioni emerse durante implementazione. Due destinazioni: `T-NNN.md` (sempre) e `technical-context.md` (solo cross-task).

## Destinazione 1: T-NNN.md — sezione Deviazioni

Tutte le decisioni cross-task confermate e le decisioni locali meritevoli vanno qui.

### Formato della sezione

La sezione esiste già nel template del brief (creata da task-implementer). Se per qualche motivo non c'è, la skill la crea **prima** del separator finale, dopo "Out of scope".

```markdown
## Deviazioni durante l'implementazione

### DEV-001 — YYYY-MM-DD — [tipo]
- **Tipo**: cross-task | locale
- **Cosa è cambiato**: [descrizione concisa, 1-2 righe]
- **Perché**: [motivazione]
- **Riferimenti**: [eventuali — task-implementer's brief sezioni impattate, sample seguito]
- **Impatto su technical-context.md**: [solo se cross-task: lista voci aggiunte/modificate]

### DEV-002 — YYYY-MM-DD — [tipo]
...
```

### Convenzioni di numerazione

- DEV-001, DEV-002, ... incrementale all'interno del singolo T-NNN.md
- Mai riusare numeri (anche se una deviazione è "annullata", resta nel file)
- Date in formato ISO YYYY-MM-DD

### Tipo "cross-task"

Quando una decisione cross-task viene registrata:

```markdown
### DEV-003 — 2026-01-15 — cross-task
- **Tipo**: cross-task
- **Cosa è cambiato**: Introdotta libreria FluentValidation 11.9.0 per validazione DTO
- **Perché**: Brief richiedeva validazione robusta su CreateOrderDto, nessuna lib di validazione era ancora in technical-context.md. Scelta tra a) FluentValidation, b) DataAnnotations, c) custom: scelta (a) per espressività e testabilità.
- **Riferimenti**: discussione cross-task durante implement
- **Impatto su technical-context.md**: 
  - Aggiunta riga in § Librerie e versioni
  - Aggiunto pattern "Validation layer" in § Pattern architetturali
```

### Tipo "locale"

Per decisioni locali meritevoli:

```markdown
### DEV-001 — 2026-01-15 — locale
- **Tipo**: locale
- **Cosa è cambiato**: Brief shape prevedeva `User.Create(string email, string password)`. Implementazione usa `User.Create(Email email, PasswordHash password)` con VO esistenti.
- **Perché**: Email e PasswordHash sono VO già in technical-context.md (da T-002). Usarli direttamente è coerente con sample UsersController.cs e evita ri-validazione interna.
- **Riferimenti**: sample src/Controllers/UsersController.cs
- **Impatto su technical-context.md**: nessuno
```

### Confirmation prima di annotare locali

Per decisioni locali, la skill mostra all'utente la deviazione PRIMA di annotarla:

```
Decisioni locali emerse durante implementazione:

1. Adattata shape User.Create per usare VO esistenti (Email, PasswordHash)
   invece di primitivi come da brief.

2. Errore "non trovato" gestito con Result.NotFound() invece di eccezione,
   coerente con sample.

Quali annotare in Deviazioni di T-NNN.md?
(rispondi con numeri separati da virgole, "tutte", "nessuna")
```

Utente decide. Mai annotare automaticamente le locali — c'è una soglia di rilevanza che è soggettiva.

Per decisioni cross-task confermate prima della scrittura, **annotazione automatica**: sono state già negoziate e non serve seconda conferma.

## Destinazione 2: technical-context.md

Solo decisioni **cross-task confermate** modificano `technical-context.md`. Mai dalle locali.

### Modifiche consentite

Aggiungere voci alle sezioni esistenti:

```markdown
## Librerie e versioni

| Libreria | Versione | Scopo | Deciso in |
|----------|----------|-------|-----------|
| ...esistenti... |
| FluentValidation | 11.9.0 | validation DTO | T-008 |
```

Aggiungere nuove voci alle sezioni di pattern, VO, naming:

```markdown
### Validation layer
- **Adottato in**: T-008
- **Definizione**: Validazione di DTO/Request via FluentValidation. Ogni DTO ha un classe `[Dto]Validator : AbstractValidator<[Dto]>` nello stesso namespace.
- **Reference**: T-008.md sezione "Pattern adottati"
```

### Modifiche NON consentite

- Modificare voci esistenti (eccetto superseded — vedi sotto)
- Riscrivere sezioni
- Toccare la sezione "Storia decisioni superseded"
- Cambiare struttura del file

### Superseded: quando una decisione precedente cambia

Se l'implementazione del task **cambia** una decisione cross-task precedente (raro ma possibile):

1. La voce vecchia va spostata in § "Storia decisioni superseded" con motivo
2. Voce nuova aggiunta nella sezione attiva
3. Riferimento al task che ha causato il cambio

Esempio:

```markdown
## Storia decisioni superseded

### Superseded — BCrypt.Net-Next → ASP.NET Core Identity PasswordHasher
- **Originale**: BCrypt.Net-Next 4.0.3 (deciso in T-005)
- **Sostituito da**: Microsoft.AspNetCore.Identity.PasswordHasher (T-012)
- **Motivo**: integrazione naturale con ASP.NET Core Identity introdotto in T-012
- **Data**: 2026-01-20
```

E nella sezione attiva, la riga BCrypt.Net-Next viene rimossa e sostituita con la nuova.

Per superseded, la skill chiede **conferma esplicita** all'utente prima di procedere:

```
⚠ Decisione cross-task introduce superseded

Per implementare T-NNN propongo di sostituire:
- Voce attuale: [voce in technical-context.md]
- Con: [nuova decisione]
- Motivo: [...]

Questo è un cambiamento di decisione tattica già presa. Conferma?
```

## Ordine delle operazioni

Sequenza obbligatoria durante reporting (step 6 del flusso `implement`):

```
1. Mostra all'utente:
   - Decisioni cross-task confermate (già negoziate prima della scrittura)
   - Decisioni locali candidate ad annotazione (per scelta utente)

2. Utente conferma quali locali annotare

3. Scrivi in T-NNN.md sezione Deviazioni:
   - Tutte le cross-task confermate (auto)
   - Le locali confermate dall'utente

4. Scrivi in technical-context.md:
   - Solo cross-task confermate
   - Una sezione alla volta, in ordine: Librerie → Pattern → VO → Naming → Convenzioni

5. Verifica integrità:
   - I file modificati sono ancora valid markdown?
   - I riferimenti tra file sono coerenti?

6. Riporta all'utente il summary finale
```

## Quando NON annotare (anche se sembra appropriato)

- Decisioni dettate da errori di build dell'auto-fix → mai annotare
- Decisioni "preventive" non emerse da implementazione reale → no, sarebbero speculative
- Modifiche di formatting o stile pure → no
- Refactoring non richiesti dal task → no (e in più non dovevano avvenire)

## Edge case: nessuna decisione da annotare

Se l'implementazione è andata liscia, nessuna cross-task chiesta, nessuna locale meritevole:

```
✅ Implementazione completata
Nessuna deviazione da annotare — il codice segue il brief senza scelte
non previste.
```

La sezione Deviazioni del T-NNN.md resta vuota. È un buon segno.

## Versionamento

Ogni modifica di `T-NNN.md` o `technical-context.md` incrementa il footer:

```
---
Generato: YYYY-MM-DD | Versione: 2
```

Versione = N+1 rispetto alla versione precedente. Footer aggiornato automaticamente.
