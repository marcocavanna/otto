---
Task: fast-path-solo-003
Feature: fast-path-solo
Origin: feature-planner
Context-root: docs/features/fast-path-solo/
Status: ✅ finalized
---

# fast-path-solo-003 — Ramo `solo` nel protocollo di `flow-run`

> **Esecuzione manuale** (no flow-run, RISK-fast-path-001): il task riscrive il protocollo dell'orchestratore. Eseguito dal main thread editando direttamente `skills/flow-run/SKILL.md` (la copia delle istruzioni già caricata nella sessione non è alterata; la modifica vale dal prossimo run). Brief prodotto **dopo** l'implementazione, riflettendo la realtà — coerente col contratto artefatti della modalità `solo` (ASSUMPTION-fast-path-003).

## Obiettivo

Insegnare a `flow-run` a leggere la `Complessità (ipotesi)` **a monte** (prima di qualunque spawn) e a biforcare il protocollo per-task in **ramo `team`** (invariato) e **ramo `solo`** (un solo spawn dell'agente `solo` + gate del finalize). Degrado conservativo → `team`. Modalità effimera.

## Vincoli risolti

- **Stack/formato**: Markdown (skill instructions). Nessuna build.
- **Dipendenze completate**: `fast-path-solo-001` (mappa `complexity → execution-mode` in `model-tiering.md`, finalized) e `fast-path-solo-002` (`agents/solo.md`, finalized). Questo task **consuma** entrambi: legge la mappa e spawna l'agente.
- **Single-source mappa** (`references/model-tiering.md`): il ramo `solo`/`team` deriva dalla mappa lì definita; `flow-run` la consuma, non ridefinisce le tabelle (rispettato: gli edit linkano `§ "Mappa"`).
- **Lettura complessità a monte**: dal **tasks-file** della source (campo `Complessità (ipotesi)`, schema task-entry `planning-source-contract.md`), al passo di selezione/attivazione del task — **prima** di ogni spawn. Distinta dal `meta.json` del PM (che arriva solo al brief).
- **Degrado conservativo** (vincolo, da `technical-context.md` § VO `execution-mode` + ASSUMPTION-fast-path-005): complessità assente/illeggibile/fuori-enum o riga task non risolvibile → `team` (MAI `solo`) + nota nel summary.
- **Effimerità**: l'`execution-mode` non entra in `PROGRESS.json` né in alcun contratto su disco (come modello/dry-run).
- **Hook/sicurezza**: l'agente `solo` è un subagent → eredita `scope-check`/`verify-gate` dal proprio frontmatter (già garantito da 002). `flow-run` non tocca gli hook.
- **Pre/post-write** (predisposizione per `fast-path-promotion`): `RESULT.promote` (pre-write) → re-run in `team`; fail post-write (`escalate`/`verify!=pass`/`ESCALATION.json`) → step 7, mai promozione. Il campo `promote` non è ancora emesso (feature successiva): il ramo è predisposto ma inerte.
- **Non-regressione `team`**: i passi 3–6 restano invariati, solo incapsulati sotto l'header "Ramo `team`".
- **Subtask**: nessuno, esecuzione lineare.

## File impattati

- `skills/flow-run/SKILL.md` [edit] — +19/-1 righe, 4 innesti (vedi sotto)

## Shape

> Shape reale degli innesti applicati a `skills/flow-run/SKILL.md`. Struttura, non implementazione finale.

### Innesto 1 — § "Protocollo (per ogni task)", nuovo passo `1b` (dopo step 1, prima di step 2)

```markdown
1b. **Risolvi l'`execution-mode`** … dalla single-source `model-tiering.md` § "Mappa".
    Leggi la `Complessità (ipotesi)` dal tasks-file: trivial/standard → solo; critical → team.
    Degrado: assente/illeggibile/fuori-enum/non risolvibile → team (MAI solo) + nota summary.
    Override utente (--mode <solo|team>) → vince, effimero. Non entra in PROGRESS.json.
```

Step 2: intestazione adeguata da "PRIMA dello spawn DEV" → "PRIMA dello spawn (DEV o `solo`)".

### Innesto 2 — biforcazione (prima di step 3)

```markdown
> Biforcazione per execution-mode (1b): team → passi 3–6; solo → § "Ramo solo".

**Ramo `team`** (execution-mode == team) — flusso invariato:
3. … (PM brief → 3b → [dry-run] → DEV implement → finalize)
```

### Innesto 3 — nuova § "Ramo `solo`" (dopo step 6)

```markdown
### Ramo `solo` (execution-mode == solo)
- S1. Deriva modello (trivial→haiku, standard→sonnet; mai critical).
- S2. Spawn `solo` → implement (subagent_type: solo): analisi+scope/frozen+implement+verify+artefatti
      versionati identici (Status: ✅ finalized) + append technical-context se cumulative.
- S3. RESULT.json: promote==true → re-run in team (pre-write, tree pulito); else escalate/verify!=pass/
      ESCALATION → step 7 (post-write, mai promozione).
- S4. Gate finalize (orchestratore): pass → brief già finalized, PROGRESS done + mirror; else step 7.
```

### Innesto 4 — § "Spawn — cosa passare ai subagent", riga `solo`

```markdown
- `solo` (implement): "Modalità: implement. TASK: <task>." — subagent_type: solo,
  model derivato dalla complessità. Un solo spawn. Solo per trivial/standard.
```

## Deviazioni durante l'implementazione

- **`promote` predisposto ma inerte**: il ramo S3 documenta la promozione `solo → team` via `RESULT.promote`, ma il campo è introdotto da `fast-path-promotion` (feature successiva). Scelta: definire ora il **punto d'innesto** nel protocollo (riduce la churn futura, rende esplicita la distinzione pre/post-write) marcandolo chiaramente come "finché assente non scatta". Non è implementazione fuori scope: è un placeholder di contratto, zero logica attiva.
- **Diff minimo (+19/-1)**: gli innesti incapsulano i passi 3–6 esistenti sotto l'header "Ramo `team`" senza riscriverli (non-regressione per costruzione). Nessuna modifica alla numerazione 3–6 né alla logica model-tiering/dry-run/finalize.
- **Frontmatter description di `flow-run` non aggiornato**: la description trigger menziona ancora solo lo spawn DEV/PM. Lasciata invariata (fuori dalla DoD del task; polish opzionale). Annotato per eventuale ritocco in `fast-path-solo-005`/release.
- **build skipped**: artefatto markdown/skill, nessun build command. Verifica = fence bilanciate (pari) + ancore presenti + grep coerenza.

## Out of scope per questo task

- Contratto artefatti modalità `solo` in `task-implementer/SKILL.md` — task `fast-path-solo-004`.
- Dogfooding end-to-end — task `fast-path-solo-005`.
- Campo `promote` e pre-analisi read-only — feature `fast-path-promotion`.
- Modifica a `model-tiering.md` (frozen, 001), `agents/solo.md` (frozen, 002), hook bash.
