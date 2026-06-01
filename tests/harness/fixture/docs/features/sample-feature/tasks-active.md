# tasks-active (FIXTURE — feature source)

> Golden-task da **feature source**. Context-root atteso: `docs/features/sample-feature`.
> Topologia corrente: brief con sezioni canoniche. Statico, versionato.

---

## fixture-feat-001 — DTO `ShareNoteRequest`

**Source**: feature
**Category**: dto
**Complexity**: trivial

### Obiettivo

Definire il DTO di richiesta `ShareNoteRequest` (note id + target user + permission).
Tipo passivo al boundary, nessun contratto cross-task nuovo, nessuna logica.

### Vincoli risolti

- Mapping manuale (NO AutoMapper).
- Validazione gestita altrove (FluentValidation).

### File impattati

```
src/Application/Dto/ShareNoteRequest.cs   [new]
```

### Out of scope

- Validator del DTO.
- Endpoint che lo riceve.

---

## fixture-feat-002 — `NoteShareRepository`

**Source**: feature
**Category**: repository
**Complexity**: standard

### Obiettivo

Implementare `INoteShareRepository` e la sua impl `NoteShareRepository` su EF Core.
Consuma VO esistenti (`TenantId`, `NoteId`), nessun contratto nuovo cross-task.

### Vincoli risolti

- Repository pattern (interfaccia application, impl infrastructure).
- Filtro `TenantId` obbligatorio in ogni query (ASSUMPTION-fx-001).
- Result<T> per esiti.

### File impattati

```
src/Application/Repositories/INoteShareRepository.cs   [new]
src/Infrastructure/Repositories/NoteShareRepository.cs [new]
```

### Out of scope

- Modifica del DbContext esistente oltre il DbSet necessario.
- Modifica VO `TenantId` / `NoteId` (frozen).

---

## fixture-feat-003 — Componente React `ShareDialog`

**Source**: feature
**Category**: ui-component
**Complexity**: standard

### Obiettivo

Componente `ShareDialog` per selezionare utente e livello permesso e confermare la
condivisione. UI controllata, props esplicite, TypeScript strict.

### Vincoli risolti

- React 18 + TS strict.
- Composizione su componente grande; props tipizzate.
- Nessuna animazione non richiesta.

### File impattati

```
web/src/components/ShareDialog.tsx   [new]
```

### Out of scope

- Chiamata API reale (mockata via prop callback).
- Stato globale / store.

---

## fixture-feat-004 — Value Object `SharePermission`

**Source**: feature
**Category**: value-object
**Complexity**: critical

### Obiettivo

Introdurre il VO `SharePermission` (`Read` | `ReadWrite`). Contratto nuovo
consumato da repository, DTO e UI → cross-cutting, fail-safe verso `critical`.

### Vincoli risolti

- Record immutabile, factory di validazione.
- Boundary di sicurezza: solo i due valori ammessi (RISK-feat-001).

### File impattati

```
src/Domain/ValueObjects/SharePermission.cs   [new]
```

### Out of scope

- Persistenza del VO (conversione EF).
- Modifica VO esistenti di progetto.

---

## fixture-feat-005 — Config opzioni di share `ShareOptions`

**Source**: feature
**Category**: config
**Complexity**: standard

### Obiettivo

Introdurre `ShareOptions` (max share per nota, default permission) bindato da
configurazione. Pur essendo `config` di default `trivial`, introduce un **contratto
di opzioni** consumato da handler/repository → segnale 1 alza a `standard`.

### Vincoli risolti

- Options pattern .NET (`IOptions<ShareOptions>`).
- Default sicuri: `MaxSharesPerNote = 10`, `DefaultPermission = Read`.

### File impattati

```
src/Application/Configuration/ShareOptions.cs   [new]
src/appsettings.json                            [edit]
```

### Out of scope

- Registrazione DI dettagliata (solo binding minimo).
- UI di configurazione.
