# fast-path-promotion-003 — Gestione `RESULT.promote` in `flow-run` (re-run `solo → team`)

**Status**: ✅ finalized
**Origin**: feature-planner
**Context-root**: docs/features/fast-path-promotion/
**Feature**: `fast-path-promotion`
**Effort stimato**: 2-3h
**Dipendenze**: fast-path-promotion-001, fast-path-promotion-002
**Generato**: 2026-06-03
**Versione**: 1

> `Origin` + `Context-root` sono il contratto letto da `code-implementer` per caricare il contesto.

## Obiettivo

Rendere operativa la gestione di `RESULT.promote==true` nel ramo `solo` di `skills/flow-run/SKILL.md` (passo S3): l'orchestratore, rilevato `promote==true`, ri-esegue lo stesso task dal passo 3 in modalità `team` (working tree pulito), annota la promozione + il motivo nel summary. La nota inibitrice `"finché assente questo caso non scatta"` va rimossa. Monodirezionale, fail-safe: i fail post-write (`escalate`/`verify!=pass`/`ESCALATION.json`) restano a S3 branch post-write, mai promozione.

## Analisi funzionale

**Input**: al termine dello spawn `solo`, l'orchestratore legge `.flow/briefs/<task>/RESULT.json`. Può contenere:
- `{ "promote": true, "promote_reason": "..." }` → caso pre-write (task non toccato)
- `{ "verify": "pass|fail", "deviations": [...], "escalate": false|true }` → caso post-write (implement completato o escalato)

**Comportamento atteso**:

- Scenario 1 — `promote==true` (pre-write): l'orchestratore **non** esegue il gate del finalize, **non** marca `state="done"`. Annota nel summary: `"PROMOTED: <promote_reason> → re-run in team"`. Ri-esegue il task dal **passo 3** (spawn `pm brief`) con `execution-mode=team` — stessa sequenza del ramo team (3 → 3b → 4 → 5 → 6). Working tree pulito: l'agente `solo` non ha scritto nulla fuori da `.flow/briefs/<task>/`, quindi nessun cleanup necessario. I file materializzati in `.flow/briefs/<task>/` (es. `RESULT.json` con `promote=true`) **non** vengono ripuliti prima del re-run: il PM (spawn al passo 3) sovrascrive `scope.txt`/`frozen.txt`/`brief.md`/`meta.json` idempotentemente; `RESULT.json` viene riscritto dal DEV a fine implement.
- Scenario 2 — `promote` assente o `false`, `escalate==true` OPPURE `verify!="pass"` OPPURE `ESCALATION.json` presente → **vai a 7** (escalation). Invariato.
- Scenario 3 — `promote` assente o `false`, tutti i gate ok → S4 (finalize). Invariato.

**Precedenza**: la condizione `promote==true` è valutata **prima** di `escalate`/`verify` in S3 — ordine già presente nel testo, da rendere esplicito togliendo la nota inibitrice. Se `promote==true` e contemporaneamente sono presenti anche `escalate`/`verify` nel JSON (impossibile in pratica per contratto dell'agente, che termina prima di implement se promuove), la promozione vince comunque: il working tree è pulito, il re-run è sicuro.

**Monodirezionalità**: `solo → team` e mai `team → solo`. Il ramo team non acquisisce logica di promozione. Non aggiungere alcun controllo promozione fuori da S3.

**Annotazione summary**: l'orchestratore include nel suo summary finale la riga:
```
PROMOTED fast-path-promotion-003: <promote_reason> → re-eseguito in team
```

**Edge case**:
- `RESULT.json` assente o non parsabile → il comportamento pre-esistente si applica (fail-closed: vai a 7 come anomalia).
- Il re-run in team è lo stesso task con lo stesso ID: il PROGRESS per-source rimane `state="active"`, `current_task=<task>`. Non segnare `done`, non avanzare al task successivo.

## Analisi tecnica

### Stack di implementazione

- File Markdown — nessuna libreria, nessun runtime. L'orchestratore è il main thread di Claude Code.
- Tooling: `jq` (lettura `RESULT.json` in bash), `bash`.

### Pattern adottati

- **Orchestratore come main thread read-state** — vedi `technical-context.md` § Convenzioni: lo stato vive in PROGRESS.json, l'orchestratore non ricostruisce a mente. Invariato per questo task.
- **Fail-closed** — vedi SKILL.md § Modalità attended: ogni anomalia → escala. Il path `promote` è un deviazione controllata (non un'anomalia), quindi non triggera `AskUserQuestion` — è un'uscita pulita con re-run.
- **Pre-write vs post-write** — ASSUMPTION-fast-path-promotion-002: promozione solo se working tree pulito. Garantito dall'agente solo (che termina prima di (c) se promuove) e dall'ordine delle condizioni in S3.

### Assunzioni operative locali

- **ASSUMPTION-fast-path-promotion-003-001**: Il re-run in team usa gli stessi artefatti di `.flow/briefs/<task>/` già presenti (il PM al passo 3 li sovrascrive). Non è necessario né corretto fare `rm` di `RESULT.json` prima del re-run: il PM produce `brief.md`/`scope.txt`/`frozen.txt`/`meta.json` ex-novo; il DEV produce il nuovo `RESULT.json` al termine dell'implement. La co-esistenza di un vecchio `RESULT.json` con `promote=true` non disturba il ramo team (il DEV non lo legge in ingresso, solo in uscita).
- **ASSUMPTION-fast-path-promotion-003-002**: Il PROGRESS per-source non viene modificato durante la promozione (il task resta `state="active"`, `current_task=<id>`). La promozione è trasparente al PROGRESS: il task completa il suo ciclo nel ramo team come se fosse sempre stato `team`.

Nessuna assunzione locale aggiuntiva — tutto il resto è deciso a livello strategico/tattico.

## File impattati

```
skills/flow-run/SKILL.md [edit]
```

Un solo file: rimozione della nota inibitrice in S3 + esplicitazione della sequenza di re-run.

## Shape di implementazione

> Le seguenti shape sono **direzione**, non implementazione finale. Adattare durante esecuzione.

Il task è un edit chirurgico alla riga 204 di `skills/flow-run/SKILL.md`. La riga attuale:

```markdown
# skills/flow-run/SKILL.md — S3 (riga ~204), testo attuale
# Shape — adattare in implementazione

- **`promote==true`** → **promozione `solo → team`** (pre-write, working tree pulito: l'agente
  non ha toccato il codice): ri-esegui **questo stesso task** dal passo 3 in `team`, annota
  la promozione nel summary.
  *(Il campo `promote` lo introduce la feature `fast-path-promotion`;
  finché assente questo caso non scatta — il ramo è già predisposto.)*
```

Diventa:

```markdown
# skills/flow-run/SKILL.md — S3, testo target
# Shape — adattare in implementazione

- **`promote==true`** → **promozione `solo → team`** (pre-write, working tree pulito: l'agente
  non ha toccato il codice): ri-esegui **questo stesso task** dal passo **3** in `team`
  (esegui la sequenza 3 → 3b → 4 → 5 → 6 del ramo team per lo stesso task, senza toccare
  il PROGRESS né segnare `done`); annota nel summary:
  `"PROMOTED <task>: <promote_reason> → re-eseguito in team"`.
  Valutato **prima** di `escalate`/`verify`: se `promote==true` il working tree è pulito,
  il re-run è sicuro.
```

Il testo immediatamente seguente in S3 (condizioni `escalate==true`, `verify!="pass"`, `ESCALATION.json`) rimane invariato — sono il ramo post-write, già correttamente separato.

## Test minimo

Nessun build command. Verifica = dogfooding:

- **Test 1 (promozione attiva)**: eseguire un task `standard` deliberatamente sottostimato (es. scope reale >6 file): l'agente `solo` emette `RESULT.json` con `promote=true`; l'orchestratore ri-esegue il task in `team`; il summary riporta la riga `PROMOTED`.
- **Test 2 (nessuna regressione ramo solo, no promote)**: task `standard` normale → `promote` assente nel `RESULT.json` → l'orchestratore prosegue a S4 come prima. Nessun `AskUserQuestion` inatteso.
- **Test 3 (nessuna regressione ramo team)**: task `critical` → ramo `team` standard (passi 3–6), nessuna logica promozione introdotta. Invariato.
- **Edge case**: `RESULT.json` con `promote=true` + `escalate=true` (impossibile per contratto, ma se accade): `promote` vince, re-run in `team`. Il ramo team gestirà poi eventuali fail nell'implement.

## Subtask

**Nessun subtask necessario** — esecuzione lineare. Un solo file, edit chirurgico.

## Riferimenti

- Task in plan: `docs/features/fast-path-promotion/tasks-active.md` § fast-path-promotion-003
- Assunzioni rilevanti: ASSUMPTION-fast-path-promotion-002 (confine pre/post-write), ASSUMPTION-fast-path-promotion-003 (monodirezionalità, idempotenza)
- Decisioni tecniche rilevanti: `technical-context.md` § "Pre-write vs post-write", § "RESULT.json" (campi `promote`/`promote_reason`)
- Reference dipendente: `skills/flow-run/references/promotion-triggers.md` (lista trigger, consumata dall'agente solo — non da questo task)
- Implementati in 001/002: `promotion-triggers.md`, step (b2) in `agents/solo.md`, schema `RESULT.json`

## Out of scope per questo task

- Promozione `team → solo` o `inline → *` — mai implementare.
- Modifica della semantica dei fail post-write (`escalate`/`verify!=pass`/`ESCALATION.json` → step 7) — invariata.
- Cleanup di `.flow/briefs/<task>/` prima del re-run in team — non necessario (vedi ASSUMPTION-003-001).
- Modifica del PROGRESS per-source durante la promozione — il task resta `active` fino al completamento nel ramo team.
- Calibrazione o modifica della lista trigger (`promotion-triggers.md`) — già done in 001.
- Modifica di `agents/solo.md` — già done in 002.

---

## Deviazioni durante l'implementazione

---

## Finalize

**Data**: 2026-06-03
**Eseguito da**: flow-run attended (pm finalize)

### Risultato

- `skills/flow-run/SKILL.md` S3: nota inibitrice rimossa, sequenza re-run `3 → 3b → 4 → 5 → 6` esplicitata, annotazione summary `PROMOTED <task>: <promote_reason>` operativa.
- Deviazioni: nessuna. Build skipped previsto (file Markdown, nessun build command).
- `technical-context.md`: invariato — nessuna nuova decisione tattica (assunzioni 003-001/003-002 derivate da pattern pre-esistente "pre-write vs post-write").
