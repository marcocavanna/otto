# Context — Epic: Unificazione dei planner (`planner-unification`)

**Progetto**: otto (plugin Claude Code per planning → brief → code)
**Tipo**: epic (più feature sequenziali) su progetto esistente

<!-- Anchor (modello introdotto da questo stesso epic — dogfooding) -->
**Tier**: epic
**Parent**: —
**Bubble-up target**: —

## Cosa realizza l'epic
Sostituisce i tre planner separati (`project-planner`, `epic-planner`, `feature-planner`) con **una sola skill `planner`** a quattro tier (`project | epic | feature | task`), aggiungendo il tier `task` oggi mancante. Un solo entry point, un solo modello mentale; il tier si sceglie per hint utente o inferenza, **sempre confermato**. Introduce **anchor espliciti** in ogni artefatto e un **bubble-up single-hop selettivo** governato da `finalize`, eliminando l'ambiguità su dove far risalire le decisioni tecniche. Sblocca otto 2.0.0.

## Derivato dal codebase
- **Aree/moduli toccati (d'insieme)**: `skills/{project,feature,epic}-planner/` (collassano in `skills/planner/`), `skills/{task-implementer,code-implementer,flow-run,flow-sync,whats-next,migrate}/` (re-anchoring link + scan tier task), `agents/pm.md`, `.claude-plugin/{plugin,marketplace}.json`, `README.md`.
- **Stack pertinente**: skill Markdown (SKILL.md sottile + `references/` a lettura lazy), hook bash (`hooks/`), nessun runtime compilato.
- **Convenzioni rilevate**: single-source dei contratti (il "Planning source contract" vive in un solo file ed è linkato, non duplicato); reference tier/funzione-specifici; ID task opachi globalmente unici; mirror non-canonici (PROGRESS è la verità).
- **Build/test command**: nessuno (plugin di markdown). "Test" = **dogfooding**: pianificare ed eseguire end-to-end via le skill stesse.

## Decomposizione in feature
- **Criterio di split**: per dipendenza tecnica reale. Prima il **contratto+anchor** (tronco comune che tutto consuma), poi la skill `planner` (plan), poi i modi `expand/finalize` con bubble-up, poi l'adeguamento dei downstream, infine ritiro vecchie skill + migrazione + release.
- **Tronco comune**: il **Planning source contract v2** (relocato sotto `planner/`) + lo **schema anchor** + la **taxonomy dei 4 tier** + la **home `docs/tasks/<slug>/`** del tier task → seed condiviso in `technical-context.md`.

## Boundary e scope d'insieme
- **In scope (epic)**: unificazione skill di planning, tier task, anchor, finalize-owns-bubble-up, re-anchoring downstream, retrofit anchor in `migrate`, release 2.0.0.
- **Fuori scope (epic)**: cambiare la struttura/tipologia degli artefatti (resta identica), riscrivere gli hook, cascading multi-livello automatico del bubble-up (promozione oltre il padre diretto resta **manuale** via `revise`), modifiche a `code-implementer`/`dev` oltre la risoluzione path/anchor. **Anche fuori scope**: il *consumo* della complessità a priori da parte di `flow-run` per scegliere la topologia di spawn (single-agent vs PM+DEV) → materia di una **futura epic** (ASSUMPTION-007). Qui si produce solo il campo nel task-entry.
- **Integrazione con l'esistente**: i downstream restano invariati nella **sostanza** (scan per directory, ID opachi); cambiano solo (a) link ripuntati, (b) scan che impara `docs/tasks/<slug>/`, (c) `flow-run` che invoca `planner finalize` invece dell'append diretto.

## Tracked assumptions (condivise)
### ASSUMPTION-planner-unification-001
- **Descrizione**: una sola skill `planner`, non un file monolitico.
- **Scelta**: `SKILL.md` sottile (router + scelta/conferma tier + modi) + reference tier-specifici (`tier-{project,epic,feature,task}.md`) + condivisi (`elicitation`, `critical-review`, `task-expansion`, `artifact-contract`).
- **Alternative valutate**: mega-SKILL unico (scartato: illeggibile per il modello); tenere 3 skill (scartato: è il problema da risolvere).
- **Impatta**: feature `core`, `finalize`. **Status**: active. **Data**: 2026-06-02

### ASSUMPTION-planner-unification-002
- **Descrizione**: scelta del tier.
- **Scelta**: default `feature`; scaling up (epic/project se trasversale) o down (task se banale); **sempre confermato**, mai silenzioso. Conflitto su `expand`/`finalize` (più candidati per lo slug) → il planner **chiede**.
- **Impatta**: `core` (router), `finalize`. **Status**: active. **Data**: 2026-06-02

### ASSUMPTION-planner-unification-003
- **Descrizione**: tier `task` (la "cazzatina").
- **Scelta**: bundle **leggero** in `docs/tasks/<slug>/` (directory per-task, **non** il vecchio flat rimosso in 1.x). Stessa shape-file (preserva il contratto), elicitation minima, `02-abstract.md` opzionale/vuoto.
- **Impatta**: `contract`, `core` (tier-task), `downstream` (scan). **Status**: active. **Data**: 2026-06-02

### ASSUMPTION-planner-unification-004
- **Descrizione**: anchor espliciti in ogni artefatto.
- **Scelta**: header `Tier` / `Parent` / `Bubble-up target`, presenti anche se vuoti (task slegata → `Parent: —`, `Bubble-up target: —`).
- **Impatta**: `contract`, tutti. **Status**: active. **Data**: 2026-06-02

### ASSUMPTION-planner-unification-005
- **Descrizione**: bubble-up.
- **Scelta**: proprietà di `planner finalize`, **single-hop** e **selettivo** (valuta cosa risale al padre dichiarato nell'anchor, un solo salto). `flow-run` invoca `planner finalize <slug>` a fine source. Supersede il bubble-up grezzo feature→epic della 1.1.0. Nessun cascading automatico multi-livello.
- **Impatta**: `finalize`, `downstream`. **Status**: active. **Data**: 2026-06-02

### ASSUMPTION-planner-unification-006
- **Descrizione**: destino delle vecchie skill e progetti esistenti.
- **Scelta**: **rimozione netta** di `project/feature/epic-planner` (i trigger sono assorbiti dalla description di `planner`); **retrofit anchor** sugli artefatti esistenti via estensione di `migrate`.
- **Impatta**: `release`. **Status**: active. **Data**: 2026-06-02

### ASSUMPTION-planner-unification-007
- **Descrizione**: ipotesi di complessità del task **a priori**, in fase di `plan`/`expand`.
- **Scelta**: quando `planner` definisce un task, gli assegna un'**ipotesi di complessità** (`trivial | standard | critical`, stesso enum di `complexity-criteria.md`) come campo del task-entry in `tasks-active.md`. È un'**ipotesi del planner**, distinta dal `meta.json` che il PM produce al brief: serve perché il dato deve esistere **prima** di qualunque spawn.
- **Razionale (consumo a valle)**: una **futura epic** farà sì che `flow-run` usi questa ipotesi per decidere la **topologia di spawn** — un **solo agent** per i task `trivial`, `PM + DEV` per i task complessi. Quel meccanismo NON è in scope qui (vedi "Fuori scope"): qui si produce solo il dato.
- **Alternative valutate**: lasciare la complessità solo nel `meta.json` del PM (scartato: arriva troppo tardi, dopo lo spawn del PM — chicken-and-egg con la decisione di spawnare o no il PM).
- **Impatta**: `contract` (campo nel task-entry schema), `core` (emissione in `task-expansion` / tier plan). **Status**: active. **Data**: 2026-06-02

### ASSUMPTION-planner-unification-008
- **Descrizione**: sizing a livello epic = **t-shirt size**, non conteggio task autorevole.
- **Scelta**: in `roadmap.md` ogni feature porta solo un **sizing indicativo** (`S ≈ 1-3 task · M ≈ 4-6 · L ≈ 7+`), dichiarato non vincolante. Il **numero reale di task e l'effort** li fissa **solo il `feature-planner` in `expand`**, che è l'unico che analizza la feature. L'epic decide *perché*/*quali feature*/*confini*/*ordine*, non *quanto*.
- **Alternative valutate**: mantenere `~N task` / `X-Yh` a livello epic (scartato: dà un'illusione di precisione su un dato non analizzato).
- **Impatta**: `core` (tier-epic: formato roadmap), `contract` (formato epic-artifacts). **Status**: active. **Data**: 2026-06-02

### ASSUMPTION-planner-unification-009
- **Descrizione**: il tier-epic emette **shell** di feature; i task nascono solo all'`expand`. `whats-next` deve saper proporre le azioni di **planning**, non solo di esecuzione.
- **Scelta**: (a) il `tasks-active.md` di una feature appena decomposta dall'epic è uno **stub** (nessun task autorevole — vuoto o con marker "da espandere"); i task reali li produce `planner expand <feature>`. (b) `whats-next` (advisor read-only) riconosce lo stato "shell / non espansa" e **propone `planner expand <slug>`** (e `planner …` per ciò che non è ancora pianificato), oltre ai consueti comandi verso `flow-run` per le feature già espanse con task pending.
- **Conseguenza**: l'utente non si trova mai una feature "vuota" senza sapere cosa fare: `whats-next` lo indirizza al planner. La catena resta attended (nessuna cascata automatica — vedi ASSUMPTION-001/008).
- **Nota**: *questo* epic resta **first-cut** (i suoi `tasks-active.md` hanno già i task: è stato generato con `epic-planner` 1.x); la regola shell vale per il **nuovo** `planner`.
- **Impatta**: `core` (tier-epic emette shell), `downstream` (`whats-next` propone azioni via planner). **Status**: active. **Data**: 2026-06-02

## Known risks (cross-feature)
### RISK-planner-unification-001 — Auto-modifica a runtime (dogfooding)
- **Severità**: 🔴
- **Descrizione**: le feature che riscrivono `flow-run`/`task-implementer` verranno eseguite **con** quegli stessi tool. Riscrivere l'orchestratore mentre gira è fragile.
- **Mitigazione**: ordine vincolante — i tool d'esecuzione si toccano **per ultimi** (`downstream`/`release` in coda); valutare esecuzione manuale (non via `flow-run`) delle ultime feature; commit/branch prima di ogni feature ad alto rischio.

### RISK-planner-unification-002 — Re-anchoring incompleto dei contratti
- **Severità**: 🟡
- **Descrizione**: ~15-20 link puntano a `feature-planner/feature-artifacts.md` e `project-planner/*`. Un link orfano rompe la risoluzione downstream.
- **Mitigazione**: inventario esaustivo via grep in `downstream`; verifica "0 riferimenti residui alle vecchie path" come DoD.

### RISK-planner-unification-003 — Feature `core` troppo grande
- **Severità**: 🟡
- **Descrizione**: `core` porta 4 tier + reference condivisi: rischio >8 task.
- **Mitigazione**: se in `planner expand` sfora, split in `core` (router + plan feature/task) e una seconda feature (plan epic/project). Già previsto.

### RISK-planner-unification-004 — Retrofit anchor su artefatti vivi
- **Severità**: 🟡
- **Descrizione**: `migrate` che inietta header in artefatti esistenti (es. epic `tenancy`) può corrominterli.
- **Mitigazione**: idempotente, reversibile (backup), preview obbligatoria, post-verify — come l'attuale `migrate`.

---
Generato: 2026-06-02 | Versione: 1
