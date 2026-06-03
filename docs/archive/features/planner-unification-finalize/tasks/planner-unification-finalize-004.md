# Brief tecnico — planner-unification-finalize-004

**Origin**: feature-planner
**Context-root**: docs/features/planner-unification-finalize/
**Feature**: planner-unification-finalize
**Status**: ✅ finalized
> Chiuso dall'orchestratore su decisione utente: accettata la **verifica statica di copertura** (4 casi limite coperti dal design di `finalize.md`). Il `RESULT.json` automatico era `verify=fail`/`escalate` perché il dogfooding **interattivo live** non è automatizzabile dal DEV → resta un **follow-up manuale** quando si esercita `planner finalize` su uno scenario reale.

---

## Obiettivo

Validare per dogfooding manuale il comportamento end-to-end del modo `finalize` nei quattro casi limite che 003 ha lasciato out-of-scope:

1. **Source standalone** — `Bubble-up target: —` o anchor assente; il finalize completa localmente senza errori; no-op segnalato nel summary.
2. **Conflitto di risoluzione slug** — `<scope>` parziale che batte su >1 source; il sistema elenca i candidati e attende selezione esplicita senza procedere autonomamente.
3. **Re-run idempotente** — `finalize` eseguito due volte sulla stessa source con `Bubble-up target` valorizzato; la seconda esecuzione riconosce l'heading `## Consolidato da <slug>` e fa skip (idempotenza).
4. **Catena task→feature→epic** — `planner finalize` eseguito a livello feature (scope `planner-unification-finalize`) con `Bubble-up target` valorizzato; verifica che il single-hop risalga correttamente al padre e che la catena multi-livello resti manuale.

Definition of done: tutti e quattro i casi verificati manualmente; eventuali bug o comportamenti inattesi documentati come deviazioni nel brief prima che il DEV proceda con le correzioni.

---

## Analisi tecnica

### Tipo di task

Dogfooding manuale: non produce file di produzione. L'esecutore esegue comandi `planner` in sessione e verifica gli output/effetti collaterali sui file. Se emergono regressioni, il DEV annota le deviazioni qui (sezione da aggiungere) e corregge nei file impattati del task precedente.

### Caso 1 — Source standalone

**Setup**: source con `Bubble-up target: —` (es. `docs/planning/05-tasks-active.md` di un progetto standalone, oppure modificare temporaneamente una source di test).
**Procedura**:
1. Creare un `RESULT.json` valido (verify=pass) nella dir `.flow/briefs/<id>/` del task che si finalizza.
2. Invocare `planner finalize <scope-standalone>`.
3. **Atteso**: Step 3 identifica `Bubble-up target: —`; Step 9 non eseguito; summary riporta `bubble-up target: nessuno (Bubble-up target: — — source standalone)`.

**Caso degenerato** — anchor assente (nessuna riga `<!-- Anchor -->`):
- Atteso: comportamento identico al `Bubble-up target: —`; summary riporta `bubble-up target: nessuno (anchor assente — back-compat)`.

### Caso 2 — Conflitto di risoluzione slug

**Setup**: invocare `planner finalize planner-unification` (slug parziale che batte su almeno 2 source).
**Procedura**:
1. Invocare `planner finalize planner-unification`.
2. **Atteso**: Step 1 trova >1 match; sistema elenca le source candidate (`[1] docs/features/planner-unification-finalize/tasks-active.md`, `[2] docs/epics/planner-unification/tasks-active.md`, ecc.) e si ferma chiedendo selezione. Non procede autonomamente.
3. Selezionare una source; il flusso riprende con quella context-root.

Verifica che il comportamento di conflitto di `finalize` sia coerente con quello di `expand` (stesso algoritmo Step 1).

### Caso 3 — Re-run idempotente (guardia di idempotenza)

**Setup**: source con `Bubble-up target: <path>` valorizzato e task con gate ok.
**Procedura** (in due fasi):
1. **Prima esecuzione**: `planner finalize <scope>` → Step 9 eseguito → append `## Consolidato da <slug> (YYYY-MM-DD)` nel target. Summary: `bubble-up: eseguito su <path> — N sezioni risalite`.
2. **Seconda esecuzione** (re-run): `planner finalize <scope>` → Step 9 → `grep -qF "## Consolidato da <slug>"` trova l'heading → skip idempotente. Summary: `bubble-up: skip — già eseguito (idempotente)`.

Verifica che il grep usi il pattern senza data (`## Consolidato da <slug>`) e non con data (che renderebbe la guardia dipendente dalla data e fallerebbe su re-run lo stesso giorno).

### Caso 4 — Catena task→feature→epic (single-hop)

**Setup**: la feature `planner-unification-finalize` ha `Bubble-up target: docs/epics/planner-unification/technical-context.md`.
**Procedura**:
1. Invocare `planner finalize planner-unification-finalize` (scope = slug feature).
2. Gate: verificare che `.flow/briefs/<id>/RESULT.json` e assenza ESCALATION.json siano controllati per il task corrente (non per lo scope della source).
3. Step 9: il sistema propone le sezioni candidate dal `technical-context.md` della feature. Selezionare le sezioni pertinenti.
4. **Atteso**: append in `docs/epics/planner-unification/technical-context.md` con heading `## Consolidato da planner-unification-finalize (2026-06-02)`.
5. Verificare che il sistema **non** abbia eseguito un secondo hop verso `docs/` o verso un livello ancora superiore — il cascading è manuale.

**Catena manuale** (documentare nel summary): per promuovere le decisioni all'epic-root, l'utente eseguirà successivamente `planner finalize planner-unification` (su scope epic).

### Punti critici da verificare

| Check | Criterio |
|---|---|
| Guardia idempotenza senza data | `grep "## Consolidato da <slug>"` senza `(YYYY-MM-DD)` nel pattern |
| No-op standalone esplicito | Summary riporta il motivo (non silenzioso) |
| Conflitto → attende selezione | Il sistema non procede autonomamente su >1 candidato |
| Single-hop deterministico | Nessun secondo hop automatico; nessun file oltre il padre diretto modificato |
| Gate attended corretto | `.flow/briefs/<id>/RESULT.json` letto per l'ID task, non per lo slug source |

---

## File impattati

| File | Stato | Note |
|---|---|---|
| `docs/features/planner-unification-finalize/tasks/planner-unification-finalize-004.md` | [edit] | Aggiunta sezione deviazioni se emergono bug durante il dogfooding |
| `skills/planner/references/finalize.md` | [edit] | Solo se emergono bug nei casi limite: correzione Step 9 (guardia idempotenza, no-op, conflitto) |
| `skills/planner/references/expand.md` | [edit] | Solo se emerge incoerenza nel comportamento Step 1 tra expand e finalize |

**Nota**: se il dogfooding non produce regressioni, nessun file di produzione viene modificato. Il task si chiude con la sola aggiunta della sezione `## Verifica completata` in questo brief.

---

## Vincoli risolti

- **Stack**: Markdown + bash (skill Claude Code; nessun build/compilazione)
- **Librerie + versioni**: nessuna
- **VO/pattern/interfacce consumati** (da NON modificare salvo regressioni confermate):
  - Procedura finalize/bubble-up — `skills/planner/references/finalize.md` Step 1-9 (prodotto da finalize-002 e finalize-003)
  - Anchor schema — `skills/planner/anchor-schema.md`; semantica `Bubble-up target: —`, back-compat anchor assente
  - Planning source contract v2 — `skills/planner/planning-source-contract.md`; algoritmo scan Step 1, esclusione `docs/archive/**`
  - Pattern append-only datato idempotente — heading `## Consolidato da <slug> (YYYY-MM-DD)`, guardia senza data
  - Gate attended — `.flow/briefs/<id>/RESULT.json` + assenza `ESCALATION.json`
- **Naming convention**: invariata rispetto ai task precedenti

---

## Decisioni tecniche

- **Dogfooding manuale come strategia di test**: la skill è markdown+bash, non ha una suite di test automatizzati. Il dogfooding su casi reali è la modalità di verifica prescritta dal `technical-context.md` della feature (`Verifica: dogfooding manuale`).
- **Deviazioni nel brief, non in file separati**: se emergono bug, il DEV annota la deviazione nella sezione "Deviazioni durante l'implementazione" di questo brief, poi corregge direttamente i reference impattati. Il flusso `deviation` della skill task-implementer non è invocato separatamente.
- **Scope delle correzioni limitato a finalize.md / expand.md Step 1**: qualunque fix deve restare nei file già modificati dai task 002-003. Se il fix richiede di toccare SKILL.md o altri contratti, è una regressione di scope che richiede escalation.
- **Single-hop verificato come proprietà del sistema, non dell'utente**: il DEV verifica che il sistema non esegua un secondo hop automatico, indipendentemente da cosa l'utente risponda al Step 9b. La catena multi-livello è responsabilità dell'utente via `revise`.

---

## Out of scope per questo task

- Documentazione della catena finalize multi-livello → planner-unification-finalize-005
- Invocazione di `finalize` da flow-run → feature downstream dell'epic
- Retrofit dell'anchor sulle source esistenti → feature release
- Cascading bubble-up multi-livello automatico (by design: non implementato)
- Modifica di `technical-context.md` locale (quella è operazione del `finalize` stesso, non del test)

---

## Dipendenze

- **Upstream**: planner-unification-finalize-003 ✅ finalized — `finalize.md` completo con Step 1-9; guardia idempotenza; bubble-up single-hop selettivo implementato
- **Downstream**: planner-unification-finalize-005 — documenta la catena; dipende da questo task per avere i casi limite validati

---

## Verifica

Criteri di completamento del dogfooding (tutti e quattro devono passare):

1. **Standalone**: `planner finalize <scope-standalone>` → Step 9 non eseguito; summary esplicita il motivo del no-op. ✓/✗
2. **Conflitto**: `planner finalize planner-unification` → sistema elenca candidati, attende selezione; non procede autonomamente. ✓/✗
3. **Idempotenza**: due run successivi → primo appende, secondo è skip con `bubble-up: skip — già eseguito (idempotente)`. ✓/✗
4. **Catena single-hop**: `planner finalize planner-unification-finalize` → append in `docs/epics/planner-unification/technical-context.md`; nessun secondo hop automatico. ✓/✗

Se tutti passano senza modifiche ai reference: task chiuso. Se emergono regressioni: annota deviazioni, correggi i reference, ripeti il check specifico.

Subtask: nessuno necessario, esecuzione lineare.

---

Generato: 2026-06-02 | Task: planner-unification-finalize-004
