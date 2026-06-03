**Origin**: feature-planner
**Context-root**: docs/features/planner-unification-core/

# Brief — planner-unification-core-005: Implementare `tier-epic.md` (modo `plan`)

**Feature**: planner-unification-core
**Status**: ✅ finalized

---

## Obiettivo

Creare `skills/planner/references/tier-epic.md`: il reference tier-specifico che implementa il modo `plan` per il tier `epic`. È il porting della logica `plan` di `skills/epic-planner/` nella nuova skill unificata, con due delta rispetto alla sorgente:

- **ASSUMPTION-008** (`roadmap.md`): il sizing per feature è espresso come **t-shirt size** (S/M/L) indicativo, non come conteggio task/effort autorevole.
- **ASSUMPTION-009** (`tasks-active.md` dei figli): ogni feature figlia riceve un `tasks-active.md` **shell** (stub "da espandere", nessun task autorevole) — i task reali nascono solo a `planner expand <feature>`.

Il task include anche la modifica a `SKILL.md` per aggiornare il TODO parziale del modo `plan`.

---

## Scope

### File impattati

- `skills/planner/references/tier-epic.md` [new] — reference tier-specifico che implementa il modo `plan` per il tier `epic`
- `skills/planner/SKILL.md` [edit] — aggiornare il TODO nel blocco `### plan <scope>`: aggiungere il link attivo a `tier-epic.md` (sul modello dei link già presenti per `tier-feature.md` e `tier-task.md`); rimuovere `epic` dall'elenco del TODO residuo

### Out of scope per questo task

- `references/tier-project.md` — altro tier, task separato (006)
- `references/tier-inference.md` — task 007
- Modi `expand`/`finalize` per il tier epic — rimandati alla feature `planner-unification-finalize`
- Logica di bubble-up — feature `planner-unification-finalize`
- Modifiche a `artifact-contract.md`, `elicitation.md`, `critical-review.md`, `task-expansion.md` — già consolidati in core-002
- Modifiche alle skill `*-planner` esistenti — sola lettura
- Rimozione di `epic-planner` — out of scope di questa feature

---

## Analisi tecnica

### Sorgente del porting

La sorgente è la skill `epic-planner`: `SKILL.md` (modo `plan`) + `references/decomposition.md` + `references/epic-artifacts.md`. Il porting condensa la logica `plan` in `tier-epic.md` senza duplicare i reference condivisi (elicitation, critical-review, task-expansion, artifact-contract) che vivono già sotto `planner/references/`.

Il reference tier-feature.md (prodotto da core-003) è il modello strutturale di riferimento: stesso schema a 6-7 passi, stessa intestazione con elenco reference consumati, stessa delega ai condivisi.

### Delta ASSUMPTION-008: t-shirt size nella `roadmap.md`

Il `roadmap.md` epic esprime il sizing per feature come **t-shirt size** (S/M/L), non come conteggio task/effort autorevole. Motivazione: i task reali nascono solo a `expand`, quindi qualsiasi numero emesso al `plan` sarebbe speculativo e fuorviante. Il t-shirt size è esplicito nella sua natura indicativa.

Nel flusso di generazione della `roadmap.md` (Passo 5), le entry di ciascuna feature devono portare il campo `**Size**: S | M | L` (indicativo) al posto o in aggiunta al campo `**Effort**: [X-Yh] (~N task)` della sorgente. Il `**Effort**: —` è omesso o segnalato come "da determinare a expand".

### Delta ASSUMPTION-009: `tasks-active.md` shell per le feature figlie

Le feature figlie generate al Passo 5 ricevono un `tasks-active.md` **shell** (stub "da espandere") invece di task atomici espansi. La shell contiene:

- L'intestazione standard del tier `feature` (`**Feature**: <slug>`, `**Effort totale stimato**: da determinare`, `**Definition of done feature**: <goal sintetico>`)
- Un'unica nota-stub come placeholder (`> ⏳ Task da espandere. Eseguire \`planner expand <slug>\` per generare i task atomici.`) — nessuna task-entry autorevole
- La sezione `## Out of scope per questa feature` vuota o con l'unica voce "Task atomici — determinati a expand"

Questo garantisce che la feature sia una **planning source valida** (il file esiste e ha una struttura coerente) senza ingannare il DEV o i downstream con task fabricati.

### Struttura di `tier-epic.md`

Il file implementa il flusso `plan <epic>` in **7 passi** (analogo a `tier-feature.md`):

**Passo 1 — Verifica prerequisiti**
1. Verifica CWD come repo di progetto.
2. Deriva lo slug kebab-case dell'epic. Conferma se non ovvio.
3. Guardia anti-overwrite: se `docs/epics/<epic>/` esiste già → rifiuta, indirizza a `revise <epic>` o `add-feature <epic>`.

**Passo 2 — Derivazione dal codebase**
Prima di chiedere, ispezione del repo (CLAUDE.md, `.claude/assistant/`, sample di codice delle aree toccate, build/test command). Delega alla stessa tecnica di `tier-feature.md` Passo 2. Pre-compila bozze di technical-context condiviso e `02-abstract.md`.

**Passo 3 — Elicitation**
Delega a `elicitation.md` con profondità tier **`epic`**: blocchi A1-A3, B (scope d'insieme), C e D come advisory. Aggiunge il punto epic-specifico: behavior atteso d'insieme, boundary inter-feature, edge case di sequencing non desumibili dal codebase. Delega a `references/decomposition.md` della sorgente `epic-planner` per le regole di decomposizione — non duplica qui.

**Passo 4 — Critica**
Delega a `critical-review.md`. Pattern applicabili al tier `epic`: pattern 1 (scope/effort mismatch: 1 sola feature emerge → non è un epic), 3 (logica di sequencing debole), 4 (nessuna esclusione scope d'insieme), 6 (scope che sconfina nel tier `project`: se serve milestone/pitch → redirecta a `project-planner`). Sollevare prima di generare; l'utente decide se mitigare o procedere.

**Passo 5 — Decomposizione e conferma**
Prima di materializzare: presentare all'utente la lista ordinata delle feature figlie (goal, dipendenza inter-feature, size S/M/L, tipo emoji). Attendere conferma esplicita. Solo dopo l'ok: generare gli artefatti.

**Passo 6 — Generazione degli artefatti**

Produce in sequenza:

1. **`docs/epics/<epic>/00-context.md`** — anchor (`Tier: epic`, `Parent: <project-slug|—>`, `Bubble-up target: docs/planning/technical-context.md|—>`), contesto epic, decomposizione in feature (razionale), boundary, assumptions condivise, rischi cross-feature. Template: `artifact-contract.md` § "Tier `epic`" `00-context.md (epic)`.

2. **`docs/epics/<epic>/02-abstract.md`** — approccio d'insieme, decisioni condivise, contratti da preservare, trade-off, rischi tecnici cross-feature, esclusioni. Nessun anchor (vedi `anchor-schema.md` § "Posizione"). Template: `artifact-contract.md` § "Tier `epic`" `02-abstract.md (epic)`.

3. **`docs/epics/<epic>/technical-context.md`** — seed condiviso, anchor (`Tier: epic`, `Parent`, `Bubble-up target`), build_command, pattern architetturali condivisi, VO/contratti condivisi. Template: `artifact-contract.md` § "Tier `epic`" `technical-context.md (epic)`.

4. **`docs/epics/<epic>/roadmap.md`** — outcome epic, DoD epic, elenco feature (ordine sequenziale) con `**Size**: S|M|L` indicativo, dipendenze inter-feature, fronti paralleli, note di sequencing. **Non include `**Effort**: [X-Yh] (~N task)`** — sizing è t-shirt size come da ASSUMPTION-008.

5. **Feature figlie** (una per voce confermata): in `docs/features/<epic>-<feat>/`, ciascuna con:
   - `00-context.md` — anchor (`Tier: feature`, `Parent: <epic>`, `Bubble-up target: docs/epics/<epic>/technical-context.md`), `**Epic**: <epic>`, `**Dipende da feature**: [...]`, cosa fa la feature, boundary, assumptions, rischi.
   - `02-abstract.md` — approccio specifico; **referenzia** le decisioni condivise (`vedi docs/epics/<epic>/02-abstract.md`) senza ripeterle.
   - `technical-context.md` — anchor, **seed dal condiviso** (copia sezioni rilevanti con intestazione `> Seed da docs/epics/<epic>/technical-context.md`).
   - `tasks-active.md` — **shell** come da ASSUMPTION-009: intestazione standard + stub di espansione, **zero task-entry autorevoli**.

**Passo 7 — Summary**
1. File generati (epics layer + feature figlie).
2. Decomposizione adottata: ordine feature, dipendenze, fronti paralleli.
3. Assunzioni più fragili.
4. Prossimo passo: `planner expand <epic>-<prima-feature>` oppure `flow-run <prima-feature>` dopo aver espanso i task.

### Modifica a `SKILL.md`

Nel blocco `### plan <scope>`, dopo la riga:

```
Per tier `task`: vedi `references/tier-task.md`.
```

Aggiungere:

```
Per tier `epic`: vedi `references/tier-epic.md`.
```

Il TODO `[TODO: references/tier-{project,epic}.md — task 005/006]` va aggiornato rimuovendo `epic` e lasciando solo `project` (task 006):

```
[TODO: references/tier-project.md — task 006]
```

### Vincoli di implementazione

- **Porting, non riscrittura**: il flusso sorgente in `epic-planner/SKILL.md` § "Mode 1: plan" + `references/epic-artifacts.md` è la specifica di riferimento. Non reinventare logica già funzionante.
- **Single-source**: delegare sempre ai reference condivisi (`elicitation.md`, `critical-review.md`, `task-expansion.md`, `artifact-contract.md`) via link — mai duplicare.
- **Delta ASSUMPTION-008/009** rispetto alla sorgente: sono modifiche additive localizzate al Passo 6 (roadmap + tasks-active figli). Il resto del flusso è fedele alla sorgente.
- **Propagazione seed**: la logica di propagazione del seed dal technical-context condiviso al figlio è documentata in `epic-planner/references/epic-artifacts.md` § "Propagazione del seed" — qui si linka, non si riscrive.
- **Contratto downstream invariato**: le feature figlie sono bundle standard di tier `feature` già validi per `task-implementer` / `flow-run`; il `tasks-active.md` shell è syntactically valido (ha l'intestazione e almeno una nota), ma non contiene task-entry effettivi.
- **Anchor obbligatorio**: tutti i file `00-context.md` e `technical-context.md` (sia epics layer sia feature figlie) portano l'anchor. Template in `artifact-contract.md` e `anchor-schema.md`.

---

## Vincoli risolti

- **Stack**: Markdown (skill Claude Code); bash per scan anti-overwrite
- **Librerie + versioni**: nessuna
- **VO/pattern/interfacce consumati** (da NON modificare):
  - `skills/epic-planner/SKILL.md` — sorgente del porting (solo lettura)
  - `skills/epic-planner/references/decomposition.md` — regole di decomposizione (solo lettura; linkato da `tier-epic.md`)
  - `skills/epic-planner/references/epic-artifacts.md` — template e contratto di coordinamento (solo lettura; linkato da `tier-epic.md`)
  - `skills/planner/anchor-schema.md` — formato anchor canonico
  - `skills/planner/planning-source-contract.md` — schema task-entry, path brief co-locato
  - `skills/planner/references/artifact-contract.md` § "Tier `epic`" — template 4 file del layer epic
  - `skills/planner/references/elicitation.md` — livello elicitation per tier `epic`
  - `skills/planner/references/critical-review.md` — critica per tier `epic`
  - `skills/planner/references/task-expansion.md` — non usato direttamente (i task non sono espansi), ma referenziato per la shell
  - `skills/planner/references/tier-feature.md` — reference strutturalmente analogo (modello formato file)
  - ASSUMPTION-008 (in `docs/features/planner-unification-core/technical-context.md`): t-shirt size nella `roadmap.md`
  - ASSUMPTION-009 (ibidem): `tasks-active.md` shell per le feature figlie
- **Naming convention**: `tier-epic.md` (kebab, prefisso `tier-`, nome tier); link via path relativo `../anchor-schema.md`, `../planning-source-contract.md`; path verso la sorgente `../../epic-planner/references/decomposition.md`

---

## Verifica (DoD)

- `skills/planner/references/tier-epic.md` esiste e implementa il flusso `plan` per il tier epic (7 passi: prerequisiti → derivazione codebase → elicitation → critica → decomposizione+conferma → generazione artefatti → summary)
- Il file delega ai reference condivisi via link, senza duplicarne la logica
- Il flusso genera:
  - layer epic (`docs/epics/<epic>/`) con i 4 file (`00-context`, `02-abstract`, `technical-context`, `roadmap`) con anchor coerente e `roadmap.md` con t-shirt size (non effort numerico)
  - feature figlie (`docs/features/<epic>-<feat>/`) con i 4 file standard, `technical-context.md` seedato dal condiviso, `tasks-active.md` **shell** (stub senza task-entry autorevoli)
- `skills/planner/SKILL.md` linka `tier-epic.md` come reference attivo nel modo `plan` (TODO aggiornato: solo `project` rimasto)
- Verifica manuale (dogfooding): lanciare `planner plan <un epic di test>`, seguire il flusso guidato da `tier-epic.md` e verificare che il layer epic e le feature figlie escano con anchor coerente, `roadmap.md` con t-shirt size, e `tasks-active.md` shell nelle feature figlie
- Nessun link orfano tra `tier-epic.md` e i reference condivisi / sorgenti

---

## Subtask

Nessun subtask necessario — esecuzione lineare.

---

Generato: 2026-06-02 | Task: planner-unification-core-005 | Feature: planner-unification-core
