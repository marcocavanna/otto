# Tier-task — modo `plan`

> Reference tier-specifico della skill `planner`. Implementa il modo `plan` per il tier `task`.
> Parte da una context-root **già selezionata** dal router (`SKILL.md`): la scelta del tier e la
> conferma dell'utente sono già avvenute. Questo file descrive l'esecuzione da quel punto in poi.
>
> Reference condivisi consumati (non duplicati qui):
> - Spec bundle tier `task`: `../task-bundle-spec.md`
> - Schema anchor: `../anchor-schema.md`
> - Contratto planning source v2 + schema task-entry: `../planning-source-contract.md`
> - Template artefatti: `artifact-contract.md` § "Tier `task`"
> - Elicitation minima: `elicitation.md` § "Livello di elicitation per tier" (riga `task`)
> - Euristica complessità: `task-expansion.md` § "Assegnazione `Complessità (ipotesi)`"

---

## Flusso `plan <task>`

Il flusso si compone di 6 passi in sequenza. È più corto di `tier-feature.md` (nessuna critica
formale, nessuna derivazione estesa dal codebase): il contesto strategico è ereditato dal parent,
non rielicitato.

### Passo 1 — Verifica prerequisiti e regola binaria

1. Verificare che la CWD sia un repo di progetto. Se ambiguo, chiedere conferma del path.

2. Derivare lo **slug** kebab-case dal nome del task (es. "Aggiungere PhoneNumber a UserDto"
   → `add-phone-number-to-user-dto`). Confermare con l'utente se il mapping non è ovvio o il nome è
   lungo/ambiguo.

3. **Guardia anti-overwrite**: se `docs/tasks/<slug>/` esiste già → **rifiuta immediatamente**,
   indirizza a `expand <slug>` (per ri-generare il task-entry) o `revise <slug>` (per aggiornare
   un'assunzione). Non procedere oltre.

4. **Verifica regola binaria** (da `../task-bundle-spec.md`):
   - (a) **Il lavoro è un singolo task atomico?** Se l'utente descrive 2+ deliverable sequenziati
     → proporre di usare il tier `feature` invece. Il tier `task` per definizione genera
     `tasks-active.md` con esattamente 1 task-entry.
   - (b) **Esiste un parent identificabile?** Se l'utente non sa → proporre come assunzione
     tracciata, ma segnalare che un tier `task` senza parent è un uso scorretto
     (vedi `../task-bundle-spec.md` § "Implicazione strutturale"). In questo caso suggerire
     di usare il tier `feature`.

   Se una delle due condizioni non vale → interrompere e proporre il tier corretto. Non
   procedere oltre senza conferma esplicita.

### Passo 2 — Elicitation minima

Profondità tier `task` da `elicitation.md`: **scope + output atteso + dipendenze**. Non si usano
i blocchi A-F: il contesto strategico è ereditato dal parent.

Tre domande operative in sequenza (una alla volta, attendere risposta prima di proseguire):

1. **Cosa produce esattamente questo task?**
   Output concreto e verificabile — definition of done **binaria**: al termine del task, cosa è
   vero che prima non era vero?
   *Probe se vago:* "Descrivi il risultato come se lo stessi verificando: cosa guardi per
   dire 'fatto'?"

2. **Da cosa dipende?**
   Altri task o precondizioni necessarie per poter iniziare il task.
   *Se "niente":* accettare, annotare `Dipende da: —` nel task-entry.

3. **Ha un parent (feature o epic)?**
   Slug della feature o epic padre, necessario per valorizzare l'anchor (`Parent` e
   `Bubble-up target`) e per seedare `technical-context.md`.
   *Probe se non sa:* "Sai sotto quale feature o epic cade questo task? Serve per collegarlo
   alla gerarchia di planning." Se l'utente non sa, segnalare come ambiguità da risolvere
   (vedi Passo 3 — caso parent non dichiarato).

Non elicitare stack, pattern, convenzioni: si ereditano dal parent e si inseriscono nel seed.

### Passo 3 — Risoluzione anchor e seed

**Risoluzione del parent**:

1. Scan di `docs/features/*/tasks-active.md` e `docs/epics/*/tasks-active.md` per trovare
   la context-root del parent dichiarato al Passo 2.

   ```bash
   find docs/features docs/epics -name "tasks-active.md" | xargs grep -l "<slug-parent>" 2>/dev/null
   ```

2. **1 match** → `Parent: <slug-parent>`, `Bubble-up target: docs/<features|epics>/<slug-parent>/technical-context.md`.

3. **0 match** → segnalare che il parent non esiste ancora come planning source:
   ```
   ⚠ Parent `<slug-parent>` non trovato in docs/features/ né docs/epics/.
   Opzioni:
   a) Il parent non è ancora stato pianificato → crearlo prima con `plan <parent>` al tier feature/epic.
   b) Lo slug è errato → correggere.
   Non posso valorizzare l'anchor senza parent. Vuoi procedere con un bundle standalone (sconsigliato per tier task)?
   ```
   Se l'utente insiste sul bundle standalone: annotare come `ASSUMPTION-<slug>-001` con `Status: active` e usare `Parent: —` e `Bubble-up target: —` (back-compat). Segnalare che il bundle non sarà conforme alla checklist di `../task-bundle-spec.md`.

4. **>1 match** → ambiguità: chiedere disambiguazione esplicita prima di procedere.

**Seed di `technical-context.md`**:

- Se parent trovato e il suo `technical-context.md` esiste: copiare le sezioni rilevanti
  (build_command, pattern, librerie, VO/contratti consumati dal task) con intestazione:
  ```
  > Seed da docs/<features|epics>/<slug-parent>/technical-context.md
  ```
- Se `technical-context.md` del parent non esiste: segnalare il gap; compilare il seed
  con le informazioni disponibili dal task elicitato, marcando come gap ciò che manca.

### Passo 4 — Generazione dei 3 file obbligatori

Directory di output: `docs/tasks/<slug>/`.

Template canonici: `artifact-contract.md` § "Tier `task`" e `../task-bundle-spec.md` § "Bundle minimo"
(include esempi verbatim — usarli come base).

#### 1. `00-context.md`

Ancora obbligatoria subito dopo il titolo H1 (vedi `../anchor-schema.md` § "Formato canonico"):

```
<!-- Anchor --> **Tier**: task · **Parent**: <slug-parent> · **Bubble-up target**: docs/<features|epics>/<slug-parent>/technical-context.md
```

Contenuto minimo:

- **Cosa fa il task** — 2-4 frasi: comportamento osservabile, output concreto (da Passo 2 domanda 1).
- **Boundary e scope** — in scope / out of scope (esplicito; almeno 1 esclusione dichiarata).
- **Tracked assumptions** — gap emersi all'elicitation; se nessuno, sezione omessa.
- **Known risks** — se nessuno, `(nessuno)`.

#### 2. `technical-context.md`

Ancora obbligatoria (stesso valore di `00-context.md`), subito dopo il titolo H1.

Intestazione seed obbligatoria:
```
> Seed da docs/<features|epics>/<slug-parent>/technical-context.md
```

Sezioni minime (solo quelle popolabili dal seed o dall'elicitation):

- **Stack** — dal seed del parent.
- **Pattern e interfacce rilevanti (da parent)** — pattern/VO che questo task consuma.
- **Decisioni tattiche da brief (append-only)** — vuoto al momento del `plan`; `task-implementer`
  aggiunge qui dopo il brief. **Non modificare le sezioni seedate**: append-only da questo punto.

#### 3. `tasks-active.md`

Schema canonico: `../planning-source-contract.md` § "Schema task-entry".

Intestazione obbligatoria (non porta l'anchor — vedi `../anchor-schema.md` § "Posizione"):

```markdown
**Tier**: task
**Effort stimato**: <X-Yh>
**Definition of done task**: <criterio binario da Passo 2 domanda 1>
```

Contiene **esattamente 1 task-entry**. ID: `<slug>-001`.

Formato entry (euristica `Complessità (ipotesi)`: vedi `task-expansion.md` § "Assegnazione"):

```markdown
### <slug>-001 — <emoji> [<tipo>] <titolo>

- **Effort**: <X-Yh>
- **Definition of done**: <da Passo 2 domanda 1 — binaria e verificabile>
- **Dipende da**: <id> | —
- **Complessità (ipotesi)**: trivial | standard | critical
- **Status**: ⚪ todo
```

**Vincoli di conformità** (da `../task-bundle-spec.md` § "Checklist di conformità"):

- `tasks-active.md` contiene **esattamente 1** task-entry — proprietà definitoria.
- Il campo `Complessità (ipotesi)` è **obbligatorio**.
- I file `roadmap.md`, `milestones.md`, `03-milestones.md`, `04-phases.md`, `05-tasks-active.md`
  **non** devono essere creati — non ammessi per il tier `task`.

### Passo 5 — `02-abstract.md` opzionale

Proporre la generazione di `02-abstract.md` solo se il task richiede una spec tecnica autonoma
non già coperta dal brief di `task-implementer`. In uso normale non è necessario.

Proposta standard:

> "Il bundle minimo è completo. Vuoi che generi anche un `02-abstract.md` con la spec tecnica
> dettagliata? Utile se il task ha una logica non ovvia che vale la pena documentare prima
> dell'implementazione. In genere per i task atomici non serve — skip se non sai."

Se l'utente conferma: generare con template standard di `artifact-contract.md` § "Tier `feature`"
`02-abstract.md` (adattato al task), **senza anchor** (l'anchor appartiene solo a `00-context.md` e
`technical-context.md` — vedi `../anchor-schema.md` § "Posizione").

Se l'utente skippa o non risponde: non generare.

### Passo 6 — Summary

Dopo la generazione dei file:

1. **File generati** con path assoluto/relativo dalla root del repo.
2. **Anchor valorizzato**: parent risolto (`docs/<features|epics>/<slug-parent>/`) oppure
   gap segnalato (parent non trovato, bundle standalone).
3. **Prossimo passo**:
   - `flow-run <task-slug>` — se il progetto usa il flow orchestrator.
   - `task-implementer brief <slug>-001` — per generare il brief del task prima dell'implementazione.

---

## Vincoli di scope

- Scrive **solo** sotto `docs/tasks/<slug>/`.
- Non tocca `docs/planning/`, `docs/features/`, `docs/epics/` né il codice sorgente.
- Non tocca le skill `*-planner` esistenti.
- I 3 file obbligatori hanno nome fisso: `00-context.md`, `technical-context.md`,
  `tasks-active.md`.
- Il file `02-abstract.md` è opzionale e solo su richiesta esplicita dell'utente.

---
Generato: 2026-06-02 | Task: planner-unification-core-004 | Feature: planner-unification-core
