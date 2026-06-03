# Abstract tecnico — Feature: Modalità `solo` (`fast-path-solo`)

> Decisioni condivise dell'epic: **vedi `docs/epics/fast-path/02-abstract.md`** e `docs/epics/fast-path/technical-context.md` (seed, vincolante). Qui solo lo specifico della feature.

## Approccio (specifico feature)
Tre innesti, in ordine di dipendenza:

1. **Mappa `complexity → execution-mode`** in `skills/flow-run/references/model-tiering.md`. Quarta colonna accanto a modello/dry-run/finalize. Valori 2.1.0: `trivial → solo`, `standard → solo`, `critical → team`. Degrado (complessità assente/fuori-enum) → `team`. Override utente esplicito (es. *"esegui T-003 in team"* / *"forza solo"*) → effimero, vince sulla mappa, annotato nel summary (stessa meccanica degli override modello/dry-run esistenti). Valutare la rinomina del file in `execution-tiering.md` **solo** se i link entranti reggono (altrimenti aggiornare solo titolo/scopo interni).

2. **Selezione a monte in `flow-run`**. Al passo di selezione/attivazione del task (prima dello spawn), leggere la `Complessità (ipotesi)` dalla riga del task nel tasks-file della source (schema task-entry v2). Risolverne l'`execution-mode` via la mappa. Ramo:
   - `team` → protocollo per-task **invariato** (3 → 3b → [4] → 5 → 6 attuali).
   - `solo` → nuovo ramo: **un solo spawn** dell'agente `solo` (modalità `implement`), poi lettura `RESULT.json` + gate del finalize (vedi sotto). Nessun PM brief, nessun dry-run separato (ASSUMPTION-fast-path-solo-002).
   - La modalità è **effimera** (non entra in `PROGRESS.json`).

3. **Agente `agents/solo.md`** (nuovo, ASSUMPTION-fast-path-004). Frontmatter:
   - `tools: Read, Write, Edit, Bash, Grep, Glob`
   - hook **identici a `dev`**: `PreToolUse(Write|Edit|Bash) → scope-check.sh`, `Stop → verify-gate.sh`.
   - `model:` di default sonnet (sovrascritto per-spawn da `flow-run` con il modello derivato dalla complessità).
   - Istruzioni: risolve `SKILL_DIR` come `dev`; legge **lazy** le istruzioni di `task-implementer` (produzione brief + `technical-context`) e `code-implementer` (implement + verify). Su `trivial`/`standard` non carica upfront `build-verification.md`/`decision-classification.md` (come `dev`).
   - Sequenza interna: (a) risolve context-root + task dal PROGRESS sotto lock; (b) analisi (read-only) del task e dei vincoli; (c) materializza `scope.txt`/`frozen.txt` in `.flow/briefs/<task>/` (consentito dal bootstrap di `scope-check.sh`); (d) implementa (gate-ato dallo `scope.txt`); (e) verifica; (f) scrive `<context-root>/tasks/<id>.md` completo (Vincoli risolti · File impattati · Shape **reale** · Deviazioni · `Status: ✅ finalized`) + append `technical-context.md` se ci sono decisioni cumulative; (g) emette `RESULT.json` (`escalate`, `verify`, `deviations`). Su anomalia bloccante → `ESCALATION.json` e termina (come `dev`).

## Gate del finalize (orchestratore, ramo solo)
Al ritorno dell'agente `solo`, `flow-run` legge `RESULT.json`:
- `escalate==true` OPPURE `verify!="pass"` OPPURE `ESCALATION.json` presente → **escalation** (step 7 invariato). Lo stato del brief resta non-finalized.
- altrimenti → il brief è già `finalized` (scritto dall'agente, ASSUMPTION-fast-path-solo-001): l'orchestratore marca `done` nel `PROGRESS.json` per-source, aggiorna heartbeat/index, fa il **mirror status** sul tasks-file (e roadmap epic) **invariati**, e prosegue. La verità d'esecuzione resta `PROGRESS.json`.

## Punti aperti (per l'expand)
- Forma esatta dei messaggi di spawn dell'agente `solo` (allineare a `agents/dev.md` § Input).
- Se la rinomina `model-tiering.md → execution-tiering.md` è sicura (conteggio link entranti via grep).
- Dove documentare il ramo `solo` in `SKILL.md` (estendere il § "Protocollo (per ogni task)" e § "Spawn — cosa passare ai subagent").

## Esclusioni (feature)
- Pre-analisi read-only con promozione `solo → team` → `fast-path-promotion`.
- `inline`, modifica struttura artefatti, parallelismo flow.

---
Generato: 2026-06-03 | Versione: 1
