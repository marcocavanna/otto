# Task attivi — Feature: Modalità `solo` (`fast-path-solo`)

**Feature**: fast-path-solo
**Effort totale stimato**: 11-17h (~5 task)
**Definition of done feature**: `flow-run` legge la `Complessità (ipotesi)` a monte e seleziona `solo`/`team` (degrado → `team`); la mappa `complexity → execution-mode` è single-source in `model-tiering.md`; l'agente `solo` produce gli artefatti versionati identici (`<context-root>/tasks/<id>.md` completo + append `technical-context.md`) con gli stessi hook di sicurezza di `dev`; un task `trivial` e uno `standard` girano in **1 spawn** e si chiudono finalized; `team` resta invariato per i `critical`. Contributo alla DoD epic: tronco comune (mappa + lettura a monte + agente + ramo solo).

## Task

### fast-path-solo-001 — 💻 [impl] Mappa `complexity → execution-mode` in `model-tiering.md`

- **Effort**: 2-3h
- **Definition of done**: in `skills/flow-run/references/model-tiering.md` esiste la tabella `complexity → execution-mode` con `trivial → solo`, `standard → solo`, `critical → team`; il degrado conservativo è documentato (complessità assente/illeggibile/fuori-enum → `team`, MAI `solo`); è documentata la regola di **override utente** esplicito (es. *"esegui in team"* / *"forza solo"*) come effimero che vince sulla mappa e va annotato nel summary; la § "Precedenza" include `execution-mode`. La rinomina `model-tiering.md → execution-tiering.md` è **valutata** (conteggio link entranti via grep): eseguita solo se tutti i link reggono e vengono ripuntati nello stesso task; altrimenti si mantiene il nome e si aggiorna solo titolo/scopo interni. Nessun link entrante orfano residuo (`grep` di verifica). Enum `execution-mode = {solo, team}` (`inline` non presente — fuori scope 2.1.0).
- **Dipende da**: —
- **Complessità (ipotesi)**: critical
- **Status**: ✅ done

### fast-path-solo-002 — 💻 [impl] Nuovo agente `agents/solo.md`

- **Effort**: 3-4h
- **Definition of done**: esiste `agents/solo.md` con frontmatter `tools: Read, Write, Edit, Bash, Grep, Glob` e hook **identici a `dev`** (`PreToolUse(Write|Edit) → scope-check.sh`, `PreToolUse(Bash) → scope-check.sh`, `Stop → verify-gate.sh`); risoluzione `SKILL_DIR` come `dev`; istruzioni che impongono lettura **lazy** di `task-implementer` (produzione brief + append `technical-context.md`) e `code-implementer` (implement + verify); sequenza interna documentata: risolve task dal PROGRESS sotto lock → analisi → materializza `scope.txt`/`frozen.txt` in `.flow/briefs/<task>/` (bootstrap consentito) → implementa (gate-ato) → verifica → scrive `<context-root>/tasks/<id>.md` completo (Vincoli risolti · File impattati · Shape reale · Deviazioni · `Status: ✅ finalized`) + append `technical-context.md` se decisioni cumulative → emette `RESULT.json` (`escalate`, `verify`, `deviations`); su anomalia bloccante scrive `ESCALATION.json` e termina. Un solo spawn, nessun dry-run separato (ASSUMPTION-fast-path-solo-002).
- **Dipende da**: fast-path-solo-001
- **Complessità (ipotesi)**: critical
- **Status**: ✅ done

### fast-path-solo-003 — 💻 [impl] Ramo `solo` nel protocollo di `flow-run`

- **Effort**: 3-4h
- **Definition of done**: `skills/flow-run/SKILL.md` legge la `Complessità (ipotesi)` dal tasks-file della source al passo di selezione/attivazione del task (**prima** di ogni spawn) e risolve l'`execution-mode` via `model-tiering.md`; ramo `team` → protocollo per-task **invariato**; ramo `solo` → **un solo** spawn `Agent` (`subagent_type: solo`, modalità `implement`, `model` derivato dalla complessità) poi lettura `RESULT.json` + **gate del finalize** (`verify=="pass"` E nessun `ESCALATION.json` → marca `done` in PROGRESS, heartbeat/index, mirror status invariati; altrimenti step 7 escalation); degrado conservativo (complessità assente/fuori-enum → `team`) con nota nel summary; la modalità resta **effimera** (non entra in `PROGRESS.json`); § "Spawn — cosa passare ai subagent" estesa con la riga `solo`. Nessuna regressione del flusso `team` (verificata su un task `critical`).
- **Dipende da**: fast-path-solo-002
- **Complessità (ipotesi)**: critical
- **Status**: ✅ done

### fast-path-solo-004 — 📚 [docs] Contratto artefatti modalità `solo` in `task-implementer`

- **Effort**: 1-2h
- **Definition of done**: `skills/task-implementer/SKILL.md` documenta che in modalità `solo` gli artefatti versionati (`<context-root>/tasks/<id>.md` + append `technical-context.md`) sono prodotti **durante/dopo** l'implementazione riflettendo la realtà (ordine invertito vs `team`, ASSUMPTION-fast-path-003), con **struttura identica** (sezioni obbligatorie invariate); eventuale nota allineata in `skills/code-implementer/` se il percorso lo richiede. Nessuna modifica alla struttura/sezioni del brief. Coerenza verificata col contratto in `planning-source-contract.md` § "Vincoli risolti".
- **Dipende da**: fast-path-solo-002
- **Complessità (ipotesi)**: standard
- **Status**: ✅ done

### fast-path-solo-005 — 🧪 [test] Dogfooding end-to-end della modalità `solo`

- **Effort**: 2-3h
- **Definition of done**: eseguito (dogfooding) un task `trivial` e uno `standard` in modalità `solo`: ciascuno gira in **1 spawn** (nessun PM brief, nessun dry-run separato) e si chiude con `<context-root>/tasks/<id>.md` completo + `Status: ✅ finalized` + eventuale append `technical-context.md`, artefatti **indistinguibili in struttura** da quelli prodotti in `team`; verificato il degrado conservativo (task senza `Complessità (ipotesi)` → `team`); verificata l'assenza di regressioni su un task `critical` (resta `team`). Esiti e gap minori documentati (es. in un report sotto la feature). Nessun residuo anomalo in `.flow/`.
- **Dipende da**: fast-path-solo-003
- **Complessità (ipotesi)**: standard
- **Status**: ⚪ todo

## Note operative
- **RISK-fast-path-001 (auto-modifica a runtime)**: i task 002/003 toccano l'orchestratore e gli agenti. Valutare l'esecuzione **manuale** (non via `flow-run`) di 002/003, o commit per task. Branch `epic/fast-path-solo-mode` già attivo.
- Tre task `critical` (001/002/003) introducono il contratto `execution-mode`, l'agente di sicurezza e il protocollo del loop: per fail-safe girano in `team`. Solo 004/005 (`standard`) eserciteranno la nuova modalità `solo` — dogfooding del meccanismo su sé stesso.

## Out of scope per questa feature
- Pre-analisi read-only con promozione `solo → team` — feature `fast-path-promotion`.
- Modalità `inline`, modifica struttura artefatti, parallelismo flow.

---
Generato: 2026-06-03 | Versione: 2
