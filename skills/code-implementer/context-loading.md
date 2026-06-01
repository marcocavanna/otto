# Context loading

Caricamento del contesto necessario **prima** della generazione di codice. La filosofia: leggere il minimo sufficiente, mai di più.

## Cosa leggere (in quest'ordine)

### 1. Brief del task (obbligatorio)

Leggere il brief del task `<id>`:
- Path canonico: `<context-root>/tasks/<id>.md`
  (vedi `../feature-planner/feature-artifacts.md` § "Planning source contract" per risoluzione context-root e fallback legacy `docs/tasks/<id>.md`)
- In modalità attended: `.flow/briefs/<TASK>/brief.md` (copia del co-locato)

Il brief è **self-sufficient**: la sezione `## Vincoli risolti` embedda già tutto il contesto necessario, distillato dal PM:
- Stack (linguaggio/runtime/framework)
- Librerie + versioni
- VO/pattern/interfacce consumati (da NON modificare)
- Naming convention

Più avanti nel brief: file impattati, shape di implementazione, assunzioni locali del task.

**NON leggere** `00-context`, `02-abstract`, `technical-context` — il PM li ha già distillati nella sezione "Vincoli risolti". Vedi § "Cosa NON leggere".

Eccezione: se il brief NON ha la sezione "Vincoli risolti" (brief legacy pre-topology-canonical), procedere come da fallback preflight (vedi `preflight.md` § Check 1-bis).

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

- `00-context.md`, `02-abstract.md`, `technical-context.md` — già distillati nel brief (sezione "Vincoli risolti"). Leggerli sarebbe ridondante e ignora la garanzia di self-sufficiency del brief.
- Documentazione di progetto fuori dalla context-root
- File README del progetto (a meno che la categoria del task sia "documentation")
- File CI/CD (`.github/workflows/`, `*.yml`)
- File di configurazione build profondi (`vite.config.ts`, `tsconfig.json`) salvo se task li tocca direttamente
- Test esistenti (a meno che task richieda di estendere test)
- Git history

Lo scope di lettura è **bounded**: brief + 1 sample + file da editare. Massimo 7-10 file letti per task. Se il task richiede di leggere di più, è probabilmente troppo grande o il brief è inadeguato.

## Output del context loading

Al termine, la skill ha mentalmente:

1. **Vincoli risolti** (dalla sezione "Vincoli risolti" del brief): stack, librerie+versioni, VO/pattern/interfacce consumati, naming
2. **Specifica del task** (dal resto del brief): cosa fare, file, shape, assunzioni locali
3. **Stile di riferimento** (dal sample): come scrivere concretamente
4. **Stato dei file da modificare** (dai file [edit])

Da qui parte la fase di **decision identification** (vedi `decision-classification.md`).

## Cosa fare se il brief è incoerente al suo interno

Se durante la lettura la skill rileva incoerenze interne al brief (es. la sezione "Vincoli risolti" dichiara "no MediatR" ma la shape di implementazione usa MediatR), bloccare:

```
⛔ Incoerenza nel brief

Rilevata incoerenza:
- "Vincoli risolti": [X]
- Shape di implementazione / obiettivo: [Y, che contraddice X]

Non posso procedere finché il brief è incoerente.
Usa task-implementer (revise del brief) o feature-planner per risolvere.
```

Non tentare di risolvere automaticamente.
