# Task bundle spec — Tier `task`

> Versione: 1.0.0
> Consumato da: feature `core` (task-expansion), feature `finalize` (bubble-up single-hop), downstream consumer che leggono il contratto v2.

Specifica del **bundle leggero** che costituisce una planning source di tier `task`. Definisce i file obbligatori, quelli opzionali, il criterio binario per decidere quando usare il tier `task` e un esempio completo con contenuto minimale.

Contratti correlati (single-source, non duplicare):
- Anchor schema: `skills/planner/anchor-schema.md`
- Planning source contract v2: `skills/planner/planning-source-contract.md`
- Taxonomy dei 4 tier: `docs/epics/planner-unification/technical-context.md` § Taxonomy

---

## Definizione di tier `task`

Il tier `task` è il livello più granulare della gerarchia (`project` ⊃ `epic` ⊃ `feature` ⊃ `task`). È il bundle **intenzionalmente leggero**: struttura di planning minima, senza roadmap, senza milestones, con elicitation ridotta.

**Regola binaria** — usa il tier `task` se e solo se:

```
(a) il lavoro è un singolo task atomico (non 2+ task sequenziati), E
(b) esiste già una feature o epic parent cui ancorare il task via bubble-up.

Se una delle due condizioni non vale → usa `feature`.
```

La regola è verificabile: `(a)` = `tasks-active.md` contiene esattamente 1 task-entry; `(b)` = il campo `Parent` dell'anchor è valorizzato (non `—`).

**Implicazione strutturale**: il tier `task` per definizione ha sempre un parent — l'anchor nei file `00-context.md` e `technical-context.md` è **sempre presente e valorizzato** (mai `Parent: —`, mai anchor assente). Un tier `task` standalone non è un uso corretto del tier: in quel caso usare `feature`.

---

## Bundle minimo

La context-root di un tier `task` è `docs/tasks/<slug>/`. La planning source è composta dai file seguenti.

### File obbligatori

| File | Anchor | Contenuto minimo |
|---|---|---|
| `00-context.md` | sì — obbligatorio, `Parent` e `Bubble-up target` valorizzati | Cosa fa il task, da cosa dipende, scope boundary, assunzioni note |
| `technical-context.md` | sì — obbligatorio, `Parent` e `Bubble-up target` valorizzati | Seedato dal parent; esteso in append-only da `task-implementer` |
| `tasks-active.md` | no — l'anchor appartiene solo alla coppia `00-context`+`technical-context` | Esattamente **1** task-entry con tutti i campi dello schema (incl. `Complessità (ipotesi)`) |

### File opzionali

| File | Note |
|---|---|
| `02-abstract.md` | Ammesso se il task richiede una spec tecnica autonoma; NON richiesto dal bundle minimo |

### File NON ammessi nel bundle

I seguenti file di planning **non** sono compatibili con il tier `task` (appartengono al tier `feature` o superiori):

- `roadmap.md`
- `milestones.md`
- `03-milestones.md`
- `04-phases.md`
- `05-tasks-active.md`

Qualsiasi file di questo insieme presente in `docs/tasks/<slug>/` è un segnale di tier errato.

### Unicità del task-entry

Il bundle tier `task` contiene **sempre e solo 1 task-entry** in `tasks-active.md`. Questa è una proprietà definitoria: se servono 2+ task sequenziati, il tier corretto è `feature`. Non ci sono eccezioni.

### Seed di `technical-context.md`

`technical-context.md` viene **seedato dal parent** al momento della creazione della planning source. Il seed è responsabilità della skill `core` nell'azione `plan`/`expand`: copia le sezioni rilevanti del `technical-context.md` del parent, aggiungendo l'anchor con `Tier: task`. Da quel momento `task-implementer` lo estende in **append-only** (sezione "Decisioni tattiche da brief"): nessuna modifica alle sezioni seedate.

---

## Esempio completo — slug `add-field-to-user-dto`

Struttura della directory:

```
docs/tasks/add-field-to-user-dto/
  00-context.md
  technical-context.md
  tasks-active.md
```

I blocchi seguenti mostrano il **contenuto minimale verbatim** di ciascun file. Il DEV li usa come template adattando i valori allo slug reale.

### `docs/tasks/add-field-to-user-dto/00-context.md`

```markdown
# Context — Task: Add field to UserDto (`add-field-to-user-dto`)

<!-- Anchor --> **Tier**: task · **Parent**: user-management · **Bubble-up target**: docs/features/user-management/technical-context.md

## Cosa fa il task

Aggiunge il campo `PhoneNumber` al DTO `UserDto` e allinea mapping e validazione.

## Boundary e scope

- In scope: modifica `UserDto`, aggiornamento `AutoMapper` profile, aggiunta validazione `FluentValidation`
- Out of scope: migrazione database, modifica contratto API pubblico

## Tracked assumptions

- Il campo `PhoneNumber` è opzionale (nullable string)
- Nessun impatto su query esistenti

## Known risks

- (nessuno)
```

### `docs/tasks/add-field-to-user-dto/technical-context.md`

```markdown
# Technical context — Task: Add field to UserDto (`add-field-to-user-dto`)

<!-- Anchor --> **Tier**: task · **Parent**: user-management · **Bubble-up target**: docs/features/user-management/technical-context.md

> Seed da docs/features/user-management/technical-context.md

## Stack

- .NET 8 / ASP.NET Core
- AutoMapper 12.x
- FluentValidation 11.x

## Pattern e interfacce rilevanti (da parent)

- `UserDto` in `Application/Users/Dtos/UserDto.cs`
- Mapping profile: `UserMappingProfile`
- Validatore: `UserDtoValidator`

## Decisioni tattiche da brief (append-only)

(vuoto al seed; task-implementer aggiunge qui)
```

### `docs/tasks/add-field-to-user-dto/tasks-active.md`

```markdown
# Task attivi — Task: Add field to UserDto (`add-field-to-user-dto`)

**Tier**: task
**Effort stimato**: 1-2h
**Definition of done task**: `PhoneNumber` presente in `UserDto`, mappato e validato; build verde.

## Task

### add-field-to-user-dto-001 — 🔧 [feature] Add PhoneNumber to UserDto

- **Effort**: 1-2h
- **Definition of done**: Campo `PhoneNumber` aggiunto a `UserDto`, mapping e validazione aggiornati, build verde
- **Dipende da**: —
- **Complessità (ipotesi)**: trivial
- **Status**: ⚪ todo
```

---

## Checklist di conformità (uso interno)

Un bundle tier `task` è conforme se:

- [ ] `docs/tasks/<slug>/00-context.md` esiste con anchor valorizzato (`Parent` ≠ `—`)
- [ ] `docs/tasks/<slug>/technical-context.md` esiste con anchor valorizzato e sezione seed tracciata
- [ ] `docs/tasks/<slug>/tasks-active.md` esiste con esattamente 1 task-entry
- [ ] Il task-entry include il campo `Complessità (ipotesi)` ∈ `{trivial, standard, critical}`
- [ ] Nessun file `roadmap.md`, `milestones.md`, `03-milestones.md`, `04-phases.md`, `05-tasks-active.md` presente
- [ ] L'ancora è nel formato canonico di `anchor-schema.md` (separatore `·`, em-dash `—` per vuoto)

---
Generato: 2026-06-02 | Task: planner-unification-contract-003
