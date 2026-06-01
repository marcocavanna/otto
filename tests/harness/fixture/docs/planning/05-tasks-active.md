# 05 — Task attivi (FIXTURE — project source)

> Golden-task da **project source**. Context-root atteso: `docs/planning`.
> Topologia corrente: brief flat, sezioni canoniche. Statico, versionato.

---

## fixture-proj-001 — Aggiungere flag di feature `notes.export`

**Source**: project
**Category**: config
**Complexity**: trivial

### Obiettivo

Introdurre un feature flag booleano `notes.export` in configurazione per abilitare
l'esportazione note. Modifica locale, nessun contratto nuovo, nessun consumo cross-task.

### Vincoli risolti

- Stack: appsettings JSON (vedi 02-abstract.md).
- Nessuna nuova libreria.
- Default flag: `false`.

### File impattati

```
src/appsettings.json   [edit]
```

### Out of scope

- Implementazione dell'export vero e proprio.
- UI di toggle del flag.

---

## fixture-proj-002 — Comando `ArchiveNote` con handler

**Source**: project
**Category**: command-handler
**Complexity**: critical

### Obiettivo

Introdurre il command `ArchiveNoteCommand` e il relativo `ArchiveNoteCommandHandler`,
che marca una nota come archiviata. Introduce un **contratto nuovo** (il command)
consumato da altri task → cross-cutting.

### Vincoli risolti

- Handler esplicito (NO MediatR, vedi 02-abstract.md).
- Result<T> per l'esito.
- Filtro `TenantId` obbligatorio (ASSUMPTION-fx-001).

### File impattati

```
src/Application/Commands/ArchiveNoteCommand.cs          [new]
src/Application/Commands/ArchiveNoteCommandHandler.cs   [new]
```

### Out of scope

- Endpoint REST che invoca il command.
- Modifica del VO `NoteId` (frozen).
