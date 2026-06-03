**Origin**: feature-planner
**Context-root**: docs/features/planner-unification-core/

# Brief — planner-unification-core-006: Implementare `tier-project.md` (modo `plan`)

**Feature**: planner-unification-core
**Status**: ✅ finalized

---

## Obiettivo

Creare `skills/planner/references/tier-project.md`: il reference tier-specifico che implementa il modo `plan` per il tier `project`. È il porting della logica `init` + `expand` di `skills/project-planner/SKILL.md` nella nuova skill unificata, con adattamento al paradigma tier (router già selezionato a monte, conferma già avvenuta) e allineamento ai reference condivisi già consolidati in core-002 (`elicitation.md`, `critical-review.md`, `task-expansion.md`, `artifact-contract.md`).

Il task include anche la modifica a `SKILL.md` per chiudere il TODO `plan` sul tier `project`, sul modello delle modifiche fatte nei task 003 (tier-feature), 004 (tier-task) e 005 (tier-epic).

---

## Scope

### File impattati

- `skills/planner/references/tier-project.md` [new] — reference tier-specifico che implementa il modo `plan` per il tier `project`
- `skills/planner/SKILL.md` [edit] — aggiungere il link attivo a `tier-project.md` nel blocco `### plan <scope>`; rimuovere `project` dall'elenco dei TODO residui

### Out of scope per questo task

- `references/tier-inference.md` — task 007
- Modi `expand`/`finalize` per il tier project — rimandati alla feature `planner-unification-finalize`
- Modo `revise` di `project-planner` — non è un modo `plan`; fuori scope di questa feature
- `references/artifact-contract.md`, `elicitation.md`, `critical-review.md`, `task-expansion.md` — già consolidati in core-002, non toccare
- Modifiche a `skills/project-planner/` — sola lettura, fonte di consolidamento
- Rimozione di `project-planner` — out of scope di questa feature

---

## Analisi funzionale

`tier-project.md` è il reference più pesante tra i quattro tier: il tier `project` corrisponde al vecchio `project-planner` modo `init` + il ciclo `expand`. Nel contesto del router unificato, la scelta e conferma del tier sono già avvenute prima che questo reference venga letto — il reference parte direttamente dall'esecuzione.

**Responsabilità del reference**:

1. Verifica prerequisiti (repo, guardia anti-overwrite su `docs/planning/`).
2. Derivazione dal codebase (stack, build command, pattern esistenti).
3. Elicitation con profondità **completa**: blocchi A-E obbligatori, F opzionale — delega a `elicitation.md` (già consolidato, tier-agnostico).
4. Critica: tutti e 9 i pattern di `critical-review.md` sono applicabili al tier `project`. Pattern 1 (scope/effort mismatch), 2 (why-now debole), 3 (no concorrenza), 4 (no esclusioni) obbligatori; il resto advisory. Delega a `critical-review.md`.
5. Generazione dei **7 artefatti** in `docs/planning/`: `00-context.md`, `01-pitch.md`, `02-abstract.md`, `03-milestones.md`, `04-phases.md`, `05-tasks-active.md`, `README.md`. Template: `artifact-contract.md` § "Tier `project`".
6. Espansione dei task per la milestone attiva (M1 di default): delega a `task-expansion.md`.
7. Summary post-generazione.

**Delta rispetto a `project-planner/SKILL.md`**:
- Non gestisce il modo `revise` — è compito di un modo futuro del router unificato, non del reference tier.
- Non gestisce il modo `expand` standalone — la logica di espansione task è delegata a `task-expansion.md` (già consolidata in core-002), invocata al Passo 6 durante `plan`.
- La scelta del tier e la conferma esplicita **non stanno qui** — stanno nel router (`SKILL.md`). Questo reference assume che il tier sia già stato confermato.
- Aggiunge l'anchor obbligatorio su `00-context.md` e `technical-context.md` (`Tier: project · Parent: — · Bubble-up target: —`), assente nel `project-planner` originale.

**Scenari**:
- Scenario standard: `docs/planning/` non esiste → esegue i 7 passi, genera i 7 file, milestone M1 espansa con task atomici.
- Guardia anti-overwrite: `docs/planning/` esiste già → rifiuta, indirizza a `revise` (futuro modo del router) o `expand` (futuro modo del router).
- Gap elicitation: sezione non copribile → blocco gap esplicito per quell'artefatto (mai filler).

---

## Analisi tecnica

### Stack di implementazione

- Markdown + prosa (nessun build, nessuna dipendenza esterna) — identico agli altri reference tier.

### Pattern adottati

- **SKILL.md sottile + reference lazy** — vedi `technical-context.md` § "Pattern architetturali": il reference è letto solo allo step che lo invoca; il router non lo inlinea.
- **Single-source dei reference condivisi** — delega esplicita a `elicitation.md`, `critical-review.md`, `task-expansion.md`, `artifact-contract.md` senza duplicare la logica.
- **Porting, non riscrittura** — la logica `plan` del `project-planner` viene portata nella struttura a passi analoga a `tier-epic.md` e `tier-feature.md`, senza cambiare la shape degli artefatti generati.
- **Struttura a 7 passi** — identica alla struttura degli altri tier reference (Verifica → Derivazione → Elicitation → Critica → Conferma → Generazione → Summary); per tier `project` il Passo 5 non è una "conferma della decomposizione" (come in tier-epic) ma una conferma delle milestone proposte prima di generare.

### Assunzioni operative locali

- **ASSUMPTION-planner-unification-core-006-001**: l'anchor su `00-context.md` e `technical-context.md` del tier `project` usa `Parent: —` e `Bubble-up target: —` (il tier `project` è radice della gerarchia, non ha padre). Questo è coerente con `artifact-contract.md` § "Regole trasversali" e `anchor-schema.md`.
- **ASSUMPTION-planner-unification-core-006-002**: il modo `expand` standalone (espandere una milestone già esistente senza rigenerare tutti i 7 file) NON viene portato in questo reference — appartiene a un modo futuro del router unificato. Durante il `plan`, l'espansione della milestone M1 è eseguita inline al Passo 6 come parte integrante del flusso.
- **ASSUMPTION-planner-unification-core-006-003**: il campo `Complessità (ipotesi)` per ogni task in `05-tasks-active.md` è obbligatorio anche per il tier `project`, per coerenza con ASSUMPTION-007 e con il comportamento già implementato negli altri tier. La logica di assegnazione è delegata a `task-expansion.md` § "Assegnazione `Complessità (ipotesi)`" (già consolidato in core-002).

---

## File impattati

```
skills/planner/references/tier-project.md [new]
skills/planner/SKILL.md [edit]
```

---

## Shape di implementazione

> Le seguenti shape sono **direzione**, non implementazione finale. Adattare durante esecuzione.

```markdown
# skills/planner/references/tier-project.md
# Shape — adattare in implementazione

# Tier-project — modo `plan`

> Reference tier-specifico della skill `planner`. Implementa il modo `plan` per il tier `project`.
> Parte da una context-root **già selezionata** dal router (`SKILL.md`): la scelta del tier e la conferma
> dell'utente sono già avvenute. Questo file descrive l'esecuzione da quel punto in poi.
>
> Reference condivisi consumati (non duplicati qui):
> - Elicitation: `elicitation.md`
> - Critica: `critical-review.md`
> - Espansione task: `task-expansion.md`
> - Template artefatti: `artifact-contract.md` § "Tier `project`"
> - Schema anchor: `../anchor-schema.md`
> - Contratto planning source: `../planning-source-contract.md`

---

## Flusso `plan <project>`

Il flusso si compone di 7 passi in sequenza. ...

### Passo 1 — Verifica prerequisiti
1. Verifica che la cwd sia un repo di progetto. ...
2. **Guardia anti-overwrite**: se `docs/planning/` esiste già → rifiuta immediatamente, ...

### Passo 2 — Derivazione dal codebase
...

### Passo 3 — Elicitation
Delega a `elicitation.md` con profondità tier **`project`**: blocchi **A**, **B**, **C**, **D**, **E**
obbligatori; blocco **F** opzionale. ...

### Passo 4 — Critica
Delega a `critical-review.md`. Per il tier `project` sono applicabili tutti i pattern (1-9). ...

### Passo 5 — Conferma milestone proposte
Prima di materializzare, presenta le milestone proposte per conferma esplicita. ...

### Passo 6 — Generazione dei 7 artefatti
Genera in `docs/planning/`: `00-context.md`, `01-pitch.md`, `02-abstract.md`, `03-milestones.md`,
`04-phases.md`, `05-tasks-active.md`, `README.md`.
Template completi: `artifact-contract.md` § "Tier `project`".
`05-tasks-active.md` espande subito la milestone M1: regole in `task-expansion.md`.

#### 6.1 — `00-context.md`
Porta l'**anchor obbligatorio**: `Tier: project · Parent: — · Bubble-up target: —`
...

#### 6.7 — `05-tasks-active.md`
Campi obbligatori per ogni task-entry: schema canonico in `../planning-source-contract.md`.
Il campo `Complessità (ipotesi)` è obbligatorio. Euristica: `task-expansion.md`.

### Passo 7 — Summary
...

## Vincoli di scope
- Scrive **solo** sotto `docs/planning/`.
- Non tocca `docs/epics/`, `docs/features/`, né il codice sorgente.
- Non tocca `skills/project-planner/`: sola lettura come fonte originale.
- I 7 file hanno nome fisso: `00-context.md`, `01-pitch.md`, `02-abstract.md`, `03-milestones.md`,
  `04-phases.md`, `05-tasks-active.md`, `README.md`.
```

La shape indica la struttura attesa e i punti di delega; il DEV riempie il contenuto basandosi su `project-planner/SKILL.md` come fonte e allineando lo stile agli altri tier reference già completati (`tier-feature.md`, `tier-epic.md`).

---

## Test minimo

- `tier-project.md` è linkato da `SKILL.md` (blocco `plan`) e referenzia correttamente `elicitation.md`, `critical-review.md`, `task-expansion.md`, `artifact-contract.md` § "Tier `project`", `../anchor-schema.md`, `../planning-source-contract.md` — zero link orfani.
- Il flusso copre i 7 passi e genera i 7 artefatti in `docs/planning/` con anchor corretto su `00-context.md` e `technical-context.md`.
- `SKILL.md` aggiornato: link attivo a `tier-project.md` nel blocco `plan`; `project` rimosso dall'elenco TODO residuo.
- Il campo `Complessità (ipotesi)` è dichiarato obbligatorio per ogni task-entry in `05-tasks-active.md`, con rinvio a `task-expansion.md`.
- Guardia anti-overwrite documentata: `docs/planning/` esiste → rifiuta e indirizza.

---

## Subtask

**Nessun subtask necessario** — esecuzione lineare.

---

## Riferimenti

- Task in plan: `docs/features/planner-unification-core/tasks-active.md` § planner-unification-core-006
- Fonte di porting: `skills/project-planner/SKILL.md` (solo lettura)
- Template artefatti: `skills/planner/references/artifact-contract.md` § "Tier `project`"
- Pattern tier reference già completati: `skills/planner/references/tier-feature.md`, `tier-epic.md`
- Reference condivisi già consolidati: `skills/planner/references/elicitation.md`, `critical-review.md`, `task-expansion.md`
- Anchor schema: `skills/planner/anchor-schema.md`
- Planning source contract: `skills/planner/planning-source-contract.md`
- Assunzioni di feature: ASSUMPTION-planner-unification-core-001, ASSUMPTION-planner-unification-core-002 in `docs/features/planner-unification-core/00-context.md`
- ASSUMPTION-007 (campo `Complessità (ipotesi)`): `docs/features/planner-unification-core/technical-context.md`

---

## Out of scope per questo task

- Modo `revise` del tier `project` — non è un modo `plan`; fuori scope di questa feature
- Modo `expand` standalone del tier `project` — fuori scope di questa feature (feature `planner-unification-finalize`)
- `references/tier-inference.md` — task 007
- Modifiche a qualsiasi reference condiviso già in `planner/references/` — già consolidati in core-002
- Rimozione di `skills/project-planner/` — out of scope di questa feature

---

## Deviazioni durante l'implementazione

---

## Finalize

---
Generato: 2026-06-02 | Task: planner-unification-core-006 | Feature: planner-unification-core
