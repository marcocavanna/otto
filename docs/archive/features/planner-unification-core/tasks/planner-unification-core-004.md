**Origin**: feature-planner
**Context-root**: docs/features/planner-unification-core/

# Brief — planner-unification-core-004: Implementare `tier-task.md` (modo `plan`)

**Feature**: planner-unification-core
**Status**: ✅ finalized

---

## Obiettivo

Creare `skills/planner/references/tier-task.md`: il reference tier-specifico che implementa il modo `plan` per il tier `task`. Il tier `task` è il livello più granulare della gerarchia — produce un **bundle leggero** (`task-bundle-spec.md`) in `docs/tasks/<slug>/` con elicitation minima e un singolo task-entry in `tasks-active.md`.

Il file è uno dei quattro `references/tier-{project,epic,feature,task}.md` dichiarati nel `SKILL.md` del planner unificato. Il tier `task` è nuovo (non esiste un `task-planner` di riferimento): va costruito ex-novo sulla spec `task-bundle-spec.md` + `elicitation.md` (sezione "Tier `task`") + i template di `artifact-contract.md` § "Tier `task`".

Il task include anche la modifica a `SKILL.md` per aggiornare il TODO parziale del modo `plan`.

---

## Scope

### File impattati

- `skills/planner/references/tier-task.md` [new] — reference tier-specifico che implementa il modo `plan` per il tier `task`
- `skills/planner/SKILL.md` [edit] — aggiornare il TODO nel blocco `### plan <scope>`: aggiungere il link attivo a `tier-task.md` (sul modello di come `tier-feature.md` è già linkato)

### Out of scope per questo task

- `references/tier-project.md`, `tier-epic.md` — altri tier, task separati (005/006)
- Modo `expand` per il tier task — rimandato alla feature `finalize`
- Modo `finalize` per il tier task — rimandato alla feature `finalize`
- Logica di bubble-up — feature `finalize`
- Modifiche a `artifact-contract.md`, `elicitation.md`, `critical-review.md`, `task-expansion.md` — già consolidati in core-002
- Modifiche alle skill `*-planner` esistenti — sola lettura
- `references/tier-inference.md` — task 007

---

## Analisi tecnica

### Differenza rispetto a `tier-feature.md`

Il tier `task` non ha una skill esistente da portare: la sorgente di riferimento è la specifica `task-bundle-spec.md`. A differenza di `tier-feature.md` (porting da `feature-planner`), qui si **costruisce** il flusso `plan` a partire dal contratto bundle.

Conseguenze operative:
- Elicitation ridotta: solo scope, dipendenze e output atteso (tabella tier `task` in `elicitation.md`). I blocchi A-F non si usano — il contesto strategico è ereditato dal parent.
- Nessuna critica formale (pattern di `critical-review.md` non applicabili al tier `task` — lo scope è già atomico per definizione).
- Generazione di soli 3 file obbligatori (`00-context.md`, `technical-context.md`, `tasks-active.md`); `02-abstract.md` è opzionale (proposto ma non imposto).
- Il `tasks-active.md` contiene **esattamente 1 task-entry** — vincolo definitorio del tier.

### Struttura del `tier-task.md`

Il file deve contenere i seguenti passi in sequenza.

**Passo 1 — Verifica prerequisiti e regola binaria**

1. Verificare che la CWD sia un repo di progetto.
2. Derivare lo **slug** kebab-case dal nome del task. Confermare se il mapping non è ovvio.
3. **Guardia anti-overwrite**: se `docs/tasks/<slug>/` esiste → rifiuta immediatamente, indirizza a `expand <slug>` o `revise <slug>`.
4. **Verifica regola binaria** (da `task-bundle-spec.md`):
   - (a) il lavoro è un singolo task atomico? Se l'utente descrive 2+ deliverable sequenziati → proporre di usare il tier `feature` invece.
   - (b) esiste un parent identificabile? Se l'utente non sa — proporre come assunzione tracciata, ma segnalare che un tier `task` senza parent è un uso scorretto.

**Passo 2 — Elicitation minima**

Profondità tier `task` da `elicitation.md`: solo scope, output atteso, dipendenze.

Tre domande operative (non A-F):
1. **Cosa produce esattamente questo task?** (output concreto e verificabile — DoD binaria)
2. **Da cosa dipende?** (altri task o precondizioni)
3. **Ha un parent (feature o epic)?** (per popolare anchor `Parent` e `Bubble-up target`)

Non ri-elicitare il contesto strategico (eredita dal parent). Se il parent esiste, leggere il suo `technical-context.md` per il seed del file figlio.

**Passo 3 — Risoluzione anchor e seed**

- Identificare la context-root del parent: scan di `docs/features/*/tasks-active.md` e `docs/epics/*/tasks-active.md` per trovare il parent dichiarato.
- Se parent trovato: `Parent: <slug>`, `Bubble-up target: docs/features/<slug>/technical-context.md` (o `docs/epics/<slug>/technical-context.md`).
- Se parent non trovato o non dichiarato: `Parent: <slug>` con nota che il parent deve essere creato prima, oppure segnalare ambiguità e bloccare.
- Il `technical-context.md` del bundle viene seedato dal `technical-context.md` del parent (sezioni rilevanti copiate con intestazione `> Seed da <path>`).

**Passo 4 — Generazione dei 3 file obbligatori**

Directory di output: `docs/tasks/<slug>/`.

Template: `artifact-contract.md` § "Tier `task`" e `task-bundle-spec.md` § "Bundle minimo".

1. `00-context.md` — anchor obbligatorio (`Tier: task`, `Parent` valorizzato), cosa fa il task, boundary e scope (in/out of scope), assunzioni note, rischi.
2. `technical-context.md` — anchor obbligatorio, sezione seed tracciata (`> Seed da <path>`), build_command dal parent, pattern e interfacce rilevanti per il task.
3. `tasks-active.md` — intestazione `**Tier**: task`, esattamente **1 task-entry** con tutti i campi dello schema canonico (incluso `Complessità (ipotesi)` per cui usare euristica di `task-expansion.md`).

**Passo 5 — `02-abstract.md` opzionale**

Proporre la generazione di `02-abstract.md` solo se il task richiede una spec tecnica autonoma non già coperta dal brief `task-implementer`. In uso normale: non necessario. Se l'utente conferma, generare con template standard senza anchor (l'anchor è solo su `00-context` + `technical-context`).

**Passo 6 — Summary**

1. File generati con path.
2. Anchor valorizzato (parent risolto o gap segnalato).
3. Prossimo passo: `flow-run <slug>` oppure `task-implementer brief <id>` per il task creato.

### Modifica a `SKILL.md`

Nel blocco `### plan <scope>`, dopo la riga:

```
Per tier `feature`: vedi `references/tier-feature.md`.
```

Aggiungere:

```
Per tier `task`: vedi `references/tier-task.md`.
```

Il commento `[TODO: references/tier-{project,epic,task}.md — task 002/004/005/006]` va aggiornato rimuovendo `task` dall'elenco (004 risolto) e lasciando solo `project`/`epic` (005/006).

### Vincoli di implementazione

- **Nuovo, non porting**: non esiste una `task-planner` sorgente — il tier si costruisce dalla spec `task-bundle-spec.md`. Il flusso è più corto di `tier-feature.md`: 6 passi vs 7.
- **Bundle leggero**: nessun file `roadmap.md`, `milestones.md`, `03-milestones.md`, `04-phases.md`, `05-tasks-active.md` — file non ammessi per questo tier (checklist di conformità in `task-bundle-spec.md`).
- **Anchor sempre valorizzato**: il tier `task` per definizione ha sempre un parent — `Parent: —` è un errore di utilizzo, non un caso legittimo.
- **Single-source**: link ai reference condivisi, nessuna duplicazione della logica di elicitation, task-expansion, artifact-contract.
- **Campo `Complessità (ipotesi)`** nel task-entry: obbligatorio; euristica in `task-expansion.md`.

---

## Vincoli risolti

- **Stack**: Markdown (skill Claude Code); bash per scan dove indicato
- **Librerie + versioni**: nessuna
- **VO/pattern/interfacce consumati** (da NON modificare):
  - `skills/planner/task-bundle-spec.md` — spec canonica del bundle tier `task` (file obbligatori, regola binaria, unicità task-entry, seed, checklist conformità, esempio verbatim)
  - `skills/planner/anchor-schema.md` — formato anchor canonico
  - `skills/planner/planning-source-contract.md` — schema task-entry (incl. `Complessità (ipotesi)`), path brief co-locato
  - `skills/planner/references/artifact-contract.md` § "Tier `task`" — template dei 3 file obbligatori
  - `skills/planner/references/elicitation.md` — livello elicitation per tier `task` (scope + output atteso + dipendenze)
  - `skills/planner/references/task-expansion.md` — euristica `Complessità (ipotesi)`, schema task-entry
  - `skills/planner/references/tier-feature.md` — reference strutturalmente analogo (modello di riferimento per il formato del file)
- **Naming convention**: `tier-task.md` (kebab, prefisso `tier-`, nome tier); link via path relativo `../anchor-schema.md`, `../planning-source-contract.md`, `../task-bundle-spec.md` (pattern già in `tier-feature.md`)

---

## Verifica (DoD)

- `skills/planner/references/tier-task.md` esiste e implementa il flusso `plan` per il tier task (6 passi: prerequisiti/regola-binaria → elicitation minima → risoluzione anchor/seed → generazione 3 file → `02-abstract` opzionale → summary)
- Il file delega ai reference condivisi via link, senza duplicare logica
- Il flusso genera bundle conformi a `task-bundle-spec.md` § "Checklist di conformità": anchor valorizzato, `tasks-active.md` con esattamente 1 task-entry, `Complessità (ipotesi)` presente, nessun file non ammesso
- `skills/planner/SKILL.md` linka `tier-task.md` come reference attivo nel modo `plan` (TODO aggiornato: solo `project`/`epic` rimasti)
- Verifica manuale (dogfooding): lanciare `planner plan <un task di test>`, selezionare tier `task`, seguire il flusso guidato da `tier-task.md` e verificare che i 3 file vengano generati con anchor coerente in `docs/tasks/<slug>/`
- Nessun link orfano tra `tier-task.md` e i reference condivisi

---

Generato: 2026-06-02 | Task: planner-unification-core-004 | Feature: planner-unification-core
