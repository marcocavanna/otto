# Context loading

Caricamento del contesto necessario **prima** della generazione di codice. La filosofia: leggere il minimo sufficiente, mai di più.

## Cosa leggere (in quest'ordine)

### 1. Planning files (obbligatorio)

> **Performance**: questi file **non** hanno dipendenze di lettura tra loro. Emetti i Read in un **unico batch parallelo** (un solo messaggio con N Read), non in sequenza. L'ordine sotto è solo quello in cui *ragionarli*, non un vincolo di lettura.

Leggere in quest'ordine, accumulando contesto:

1. `docs/planning/00-context.md` — assunzioni di progetto, vincoli, rischi
2. `docs/planning/02-abstract.md` — stack, pattern strategici, esclusioni tecniche
3. `docs/planning/technical-context.md` — librerie esatte, VO, pattern adottati, naming
4. `docs/tasks/T-NNN.md` — brief specifico del task

Dopo questi 4 file, la skill ha:
- Lo stack tecnologico esatto
- Le librerie con versione
- I pattern già adottati
- I VO già definiti
- Le naming conventions
- I file impattati dal task
- Lo shape code proposto
- Le assunzioni locali del task

**Non leggere altro dai file di planning.** Niente `03-milestones.md`, `04-phases.md`, `05-tasks-active.md` durante implementazione — sono fuori scope.

### 2. Identificazione categoria del costrutto

Dal brief, la skill identifica la **categoria primaria** del task. Esempi:

| Indicatori nel brief | Categoria |
|----------------------|-----------|
| Endpoint, route, controller | `controller` |
| Repository, DbContext, query | `repository` |
| Command, handler, mediator | `command-handler` |
| Query handler | `query-handler` |
| Service, business logic | `application-service` |
| Entity, aggregate, domain | `domain-entity` |
| Value Object | `value-object` |
| Migration, schema | `migration` |
| DTO, request, response | `dto` |
| Validator | `validator` |
| Component (React, Vue) | `ui-component` |
| Hook (React) | `react-hook` |
| Configuration | `config` |
| Middleware | `middleware` |

Se il task tocca più categorie (es. controller + DTO + validator), categoria primaria = quella con più file impattati o quella centrale del task. Le altre saranno gestite con sample dedicati se disponibili (vedi sotto).

### 3. Sample reading (al massimo 1)

Cercare nel codebase un file che rappresenta un esempio già esistente della categoria primaria.

**Strategia di ricerca:**

1. Se `technical-context.md` ha una sezione "Struttura cartelle", usarla come mappa
2. Cercare per pattern di naming:
   - `controller` → `*Controller.cs`, `*Controller.ts`
   - `repository` → `*Repository.cs`, repositories/*.ts
   - `command-handler` → `*Handler.cs` con tipi `*Command`
   - `domain-entity` → file in `Domain/Entities/`
   - ecc.
3. Se più candidati: scegliere il più recente per data modifica (tendenzialmente lo stile più aggiornato)
4. Se nessun candidato: nessun sample, procedere senza

**Leggere il sample completo.** Non frammenti.

**Cosa estrarre dal sample:**
- Struttura file (using, namespace, class declaration)
- Pattern di costruttore (DI, parametri, base class)
- Convenzioni di gestione errori
- Convenzioni async/await
- Pattern di logging
- Convenzioni di test (se presente test associato)
- Stile dei commenti

**Cosa NON estrarre dal sample:**
- Logica di business specifica (irrilevante per il nuovo task)
- Bug eventuali del sample (non replicarli)

### 4. File "edit" dichiarati nel brief

Per ogni file con flag `[edit]` in "File impattati", leggere il file esistente prima di modificarlo. Serve per:
- Capire dove inserire le modifiche
- Non rompere codice esistente
- Mantenere stile coerente con il file stesso

## Cosa NON leggere

Esplicitamente fuori scope:

- Documentazione di progetto fuori da `docs/planning/`
- File README del progetto (a meno che la categoria del task sia "documentation")
- File CI/CD (`.github/workflows/`, `*.yml`)
- File di configurazione build profondi (`vite.config.ts`, `tsconfig.json`) salvo se task li tocca direttamente
- Test esistenti (a meno che task richieda di estendere test)
- Git history

Lo scope di lettura è **bounded**: planning + brief + 1 sample + file da editare. Massimo 7-10 file letti per task. Se il task richiede di leggere di più, è probabilmente troppo grande o il brief è inadeguato.

## Output del context loading

Al termine, la skill ha mentalmente:

1. **Vincoli strategici** (da 02-abstract.md): stack, esclusioni
2. **Vincoli tattici** (da technical-context.md): librerie, pattern, VO, naming
3. **Specifica del task** (da T-NNN.md): cosa fare, file, shape, assunzioni locali
4. **Stile di riferimento** (dal sample): come scrivere concretamente
5. **Stato dei file da modificare** (dai file [edit])

Da qui parte la fase di **decision identification** (vedi `decision-classification.md`).

## Cosa fare se i 4 file di planning sono inconsistenti

Se durante la lettura la skill rileva inconsistenze tra i file di planning (es. `02-abstract.md` dice "no MediatR" ma `technical-context.md` ha entry per MediatR), bloccare:

```
⛔ Inconsistenza nel planning

Rilevata inconsistenza:
- 02-abstract.md sezione "Esclusioni tecniche": [X]
- technical-context.md: [Y, che contraddice X]

Non posso procedere con implementazione finché il planning è inconsistente.
Usa project-planner (revise) o task-implementer per risolvere.
```

Non tentare di risolvere automaticamente.
