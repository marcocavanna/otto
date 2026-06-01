---
name: flow-run
description: Orchestratore "attended" del loop PM→DEV su un piano di task. Eseguito dal main thread. Guida i subagent pm e dev (un solo livello di delega), che comunicano solo via file in .flow/. Spawna il DEV con un modello scelto dinamicamente in base alla complessità del task (tiering dal meta.json del PM), con possibilità di override manuale del modello per un run (es. "esegui solo T-003 con opus"). Si ferma a interpellare l'utente (AskUserQuestion) SOLO su escalation: deviazione fuori scope, verify fallito oltre i retry, cambio di contratto. A finalize riflette lo status su docs/planning/05-tasks-active.md (mirror non-canonico). Supporta full-run (tutti i pending) e single-task (un solo task indicato). Triggera su "avvia il flow", "esegui il piano", "flow-run", "fai girare il loop PM/DEV", "prossimo task del flow", "esegui solo T-NNN", "flow-run T-NNN", "esegui con opus", "forza il modello del dev".
---

# Flow Run — orchestratore attended

Sei il **main thread** = l'ORCHESTRATORE. PM e DEV sono subagent figli diretti (un solo livello: un subagent non può spawnarne altri). PM e DEV **non si parlano**: comunicano solo via file in `.flow/`. Tu spawnani via tool `Agent` con `subagent_type: pm` / `subagent_type: dev`.

## Principio di stato

Lo stato del loop vive in **`.flow/PROGRESS.json`**, MAI nella tua memoria. Così il loop regge la compattazione del contesto: a ogni ripresa rileggi `PROGRESS.json` e riparti. Non ricostruire lo stato a mente.

`.flow/PROGRESS.json`:
```json
{ "current_task": "T-001",
  "tasks": [ { "id": "T-001", "state": "pending|active|done" } ] }
```

## Modalità attended

L'unica forma di escalation è: **tu (main) usi `AskUserQuestion` e ti fermi.** Nient'altro. I subagent non possono interpellare l'utente: scrivono `ESCALATION.json` / `RESULT.json` e terminano; sei TU a leggerli e, se serve, a interpellare l'utente.

Fail-closed: ogni anomalia (file mancante, JSON illeggibile, output PM incompleto) → escala (AskUserQuestion), mai proseguire al task successivo.

## Selezione del task: full-run vs single-task

All'avvio, determina la **modalità di esecuzione** dall'input dell'utente:

- **Single-task** — se l'utente indica un task specifico (es. *"esegui solo T-003"*, *"flow-run T-003"*, *"fai girare il loop su T-003"*): processi **solo** quel task (steps 2–6 una volta) e ti fermi, senza toccare gli altri. Se il task non è `pending` in `PROGRESS.json`, chiedi conferma all'utente prima di rieseguirlo (potrebbe essere già `done`).
- **Full-run** — default, nessun task indicato: scorri tutti i `pending` in ordine finché non finiscono o non scatta un'escalation.

In entrambe le modalità lo stato resta in `PROGRESS.json` e il protocollo per-task è identico.

### Override manuale del modello (input utente)

Oltre alla modalità d'esecuzione, estrai dall'input dell'utente un eventuale **override del modello**:
- forma flag: `--model <haiku|sonnet|opus>`;
- forma naturale: *"con/in/usa <haiku|sonnet|opus>"* (es. *"esegui il piano con haiku"*, *"solo T-003 in opus"*).

Alias fuori dall'enum `{haiku, sonnet, opus}` o token non riconosciuto (es. *"modello veloce"*, *"con gpt4"*, *"turbo"*) → **nessun override**: comportamento dinamico (step 3b) + **nota nel summary** (l'orchestratore non inventa un modello, non escala).

Default: l'override riguarda **solo il DEV**. Si estende anche allo spawn `pm` SOLO se l'utente lo indica esplicitamente (es. *"tutto in opus"*, *"PM e DEV in opus"*, *"opus, PM compreso"*) — coerente col boundary di feature (il PM non è tierizzabile dinamicamente; l'override manuale è l'unica leva, e va resa intenzionale).

Precedenza: vedi [`references/model-tiering.md`](references/model-tiering.md) § Precedenza — **l'override utente vince su tutto**, mapping dinamico incluso. L'override è **effimero** (vive nel turno dell'orchestratore): non entra in `PROGRESS.json` né in alcun contratto su disco, come la derivazione dinamica.

Estrai dall'input anche una eventuale **direttiva dry-run**: *"salta il dry-run"* / `--no-dry-run` → skip; *"forza il dry-run"* / `--dry-run` → run. Vince sulla policy per complessità (step 3b / 4). Anch'essa effimera.

## Protocollo (per ogni task)

1. **Leggi piano + `PROGRESS.json`.**
   - Full-run: prendi il prossimo task `pending`. Se nessuno → loop finito, riporta summary e fermati.
   - Single-task: prendi il task indicato dall'utente.
2. **Attiva il task PRIMA dello spawn DEV** (l'hook risolve il task da qui): in `PROGRESS.json` setta `current_task = <task>` e quel task `state = "active"`. Scrivi il file.
3. **Spawn `pm` → `brief <task>`.** Al ritorno verifica che esistano e non siano vuoti `.flow/briefs/<task>/scope.txt` e `.flow/briefs/<task>/frozen.txt`. Se mancano/vuoti o c'è `ESCALATION.json` → **vai a 7**.
3b. **Deriva le policy del task** dalla single-source [`references/model-tiering.md`](references/model-tiering.md) (una sola volta per task). Tre output: **modello DEV**, **dry-run sì/no**, **modello del finalize PM**.
    - **Override manuale presente** (vedi § "Override manuale del modello"): usa il modello forzato per il DEV (e per il PM/finalize se l'utente ha esteso l'override). **NON** leggere né applicare `meta.json` per il modello: l'override ha precedenza massima e copre anche il caso `meta.json` assente/illeggibile (nessuna doppia logica, niente nota di degrado). Per la **dry-run policy**, un eventuale override esplicito (*"salta/forza il dry-run"*) vince; altrimenti vale la policy per complessità (sotto). Annota l'override applicato nel summary.
    - **Nessun override**: leggi `.flow/briefs/<task>/meta.json` (`{ "complexity": "trivial|standard|critical", "category": "<str>" }`, emesso dal PM) e applica le tre policy via la single-source — **non** ridefinire qui le tabelle:
      - **modello DEV**: `trivial→haiku`, `standard→sonnet`, `critical→opus`;
      - **dry-run**: `trivial`/`standard` → **skip**, `critical` → **run**;
      - **modello finalize PM**: `trivial`/`standard` → `haiku`, `critical` → `sonnet`.
      Se `meta.json` è assente / illeggibile / `complexity` fuori enum → **degrado conservativo**: modello DEV = `sonnet` (MAI haiku), **dry-run = run**, modello finalize = `sonnet`, + **nota nel summary** del task.
    Tieni i valori risolti: il modello DEV è lo **stesso** in 4 e 5 (stesso task ⇒ stesso modello in dry-run e implement); la dry-run policy decide se 4 viene eseguito; il modello finalize si usa in 6.
4. **Dry-run (condizionale, vedi 3b).**
   - Policy = **run** (task `critical`, oppure `meta.json` assente/illeggibile, oppure override *"forza"*): **spawn `dev` → `dry-run`** passando `model: <derivato>`. Al ritorno: se esiste `.flow/briefs/<task>/ESCALATION.json` → **vai a 7**.
   - Policy = **skip** (`trivial`/`standard`, salvo override): **non** spawnare il dry-run; vai diretto a 5. In tal caso il **primo** checkpoint di escalation è l'implement (step 6) — il DEV può comunque scrivere `ESCALATION.json` e lo `scope-check` hook resta attivo.
5. **Spawn `dev` → `implement`** (implement + verify) con lo **stesso** `model: <derivato>` del DEV.
6. **Leggi `.flow/briefs/<task>/RESULT.json`.** Se `escalate==true` OPPURE `verify!="pass"` OPPURE esiste `ESCALATION.json` → **vai a 7**.
   Altrimenti **finalizza**, con due percorsi:
   - **Finalize inline (fast-path)** — SE il task è `trivial`/`standard` (mai `critical`) E `RESULT.deviations` non contiene deviazioni *funzionali* (solo note d'ambiente tipo `"build skipped..."` → ammesso; qualunque deviazione sostanziale o dubbio → percorso PM): l'orchestratore chiude il task **senza spawnare il PM**. Marca `Status: ✅ finalized` nel brief `docs/tasks/<id>.md` e **non** tocca `technical-context.md` (deviazioni vuote ⇒ nessuna decisione cumulativa; l'eventuale append è già avvenuto al `brief`). Salta la ri-verifica semantica del PM: su un task leggero che ha passato il `verify-gate` il suo valore marginale non giustifica uno spawn a freddo (~90s). Il gate (`verify=="pass"`, no escalation) l'hai **già** applicato qui sopra.
   - **Finalize PM (default)** — altrimenti (task `critical`, deviazioni funzionali, o override esteso al PM): **spawn `pm` → `finalize <task>`** col `model: <finalize derivato>` (vedi 3b: `trivial`/`standard`→`haiku`, `critical`→`sonnet`; degrado/override → `sonnet`). Qui restano la ri-verifica realtà-brief e l'eventuale update di `technical-context.md`.
   In entrambi i casi: in `PROGRESS.json` setta il task `state="done"`; poi **mirror dello status** (vedi sotto). In full-run torna a **1**; in single-task riporta summary e fermati.

### Mirror status sul tasks-file della source (a finalize OK)

Dopo aver marcato `done` in `PROGRESS.json`, riflettilo nel **tasks-file della source** del task (vedi il contratto in `../feature-planner/feature-artifacts.md` § "Planning source contract"): `docs/planning/05-tasks-active.md` (project) oppure `docs/features/<slug>/tasks-active.md` (feature). Risolvilo come fa `task-implementer` (l'ID è opaco: `T-NNN` o `<slug>-NNN`); trova la riga `Status` del task e marcane il completamento secondo la convenzione del file. Modifica **solo** quella riga.

Vincoli del mirror:
- È un riflesso **non-canonico**: la verità d'esecuzione resta `PROGRESS.json`. Se il tasks-file non contiene il task o ha un formato non riconoscibile, **non inventare**: salta il mirror e annotalo nel summary (non è un'escalation).
- **Volatilità**: `project-planner expand` / `feature-planner expand` *sovrascrivono* il tasks-file. Dopo un expand il mirror va riallineato (lo stato durevole è sempre `PROGRESS.json`). Segnalalo nel summary se rilevi un disallineamento.
- Non toccare altre righe né altri file di planning.
7. **ESCALAZIONE.** Leggi `level` + `reason` da `.flow/briefs/<task>/ESCALATION.json` (o, se assente, il motivo del fail da `RESULT.json` / l'anomalia rilevata). Usa **`AskUserQuestion`** riportando level+reason e proponendo opzioni d'azione (es. revise planning, riapri brief, override scope, abbandona task). **FERMATI**: non passare ad altri task senza risposta dell'utente.

## Spawn — cosa passare ai subagent

- `pm` (brief): "Funzione: brief. TASK: <task>. Segui pm.md."
- `pm` (finalize): "Funzione: finalize. TASK: <task>. Applica il gate attended." — spawn `Agent` col `model: <finalize derivato>` (vedi step 3b: tier più basso del DEV perché il finalize è prevalentemente meccanico).
- `dev` (dry-run): "Modalità: dry-run. TASK: <task>. Leggi solo .flow/briefs/<task>/brief.md." — spawn `Agent` con override `model: <derivato>` (vedi step 3b). **Eseguito solo se la dry-run policy = run** (step 4).
- `dev` (implement): "Modalità: implement. TASK: <task>." — stesso `model: <derivato>` del dry-run.

Non passare logica di business nel prompt: la fonte è il brief su disco. Tieni i prompt sottili.

> Il `model` per-spawn del DEV è il valore risolto allo step 3b e **precede** il frontmatter del DEV. Se l'utente ha fornito un **override manuale** (§ "Override manuale del modello"), quel valore vince su tutto (derivazione dinamica inclusa) ed è il `model` per-spawn del DEV — e del `pm` solo se l'override è stato esteso esplicitamente. In assenza di override, il `model` deriva da `meta.json` via [`references/model-tiering.md`](references/model-tiering.md); su `meta.json` assente/illeggibile → `sonnet` + nota nel summary.
>
> Smoke-check (RISK-model-tiering-002): se la versione di Claude Code **non** onora il `model` per-spawn del tool `Agent`, il DEV gira sul `model:` del frontmatter (sonnet baseline) → **degrado grazioso**, da annotare nel summary; **non** è un'escalation.

## Regole

- Mai `git commit`/`push`. Mai modificare i due sub-progetti fuori da ciò che il brief dichiara.
- Un solo livello di delega: tu spawni pm/dev, loro non spawnano nulla.
- Se `.flow/` non esiste, inizializzalo (PROGRESS.json con la lista task dal piano) prima del loop. Il "piano" può essere `docs/planning/05-tasks-active.md` (project-planner) **o** `docs/features/<slug>/tasks-active.md` (feature-planner): l'orchestratore tratta gli ID in modo opaco e non si cura della source.
- Dopo ogni transizione di stato, **persisti `PROGRESS.json`** prima di proseguire.
- La selezione del modello del DEV (step 3b) — sia la derivazione dinamica sia l'**override manuale** dell'utente — è **effimera**: vive nel turno dell'orchestratore, non entra in `PROGRESS.json` né in alcun contratto su disco. Se l'override per-spawn non è onorato, degrada al frontmatter del DEV — non è un'anomalia da escalare.
- Precedenza del modello (single-source [`references/model-tiering.md`](references/model-tiering.md) § Precedenza): `override utente > mapping dinamico (DEV) > frontmatter > sessione`. Non ridefinire qui la regola, solo applicarla.
