---
name: flow-run
description: Orchestratore "attended" del loop PM→DEV su un piano di task. Eseguito dal main thread. Guida i subagent pm e dev (un solo livello di delega), che comunicano solo via file in .flow/. Si ferma a interpellare l'utente (AskUserQuestion) SOLO su escalation: deviazione fuori scope, verify fallito oltre i retry, cambio di contratto. A finalize riflette lo status su docs/planning/05-tasks-active.md (mirror non-canonico). Supporta full-run (tutti i pending) e single-task (un solo task indicato). Triggera su "avvia il flow", "esegui il piano", "flow-run", "fai girare il loop PM/DEV", "prossimo task del flow", "esegui solo T-NNN", "flow-run T-NNN".
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

## Protocollo (per ogni task)

1. **Leggi piano + `PROGRESS.json`.**
   - Full-run: prendi il prossimo task `pending`. Se nessuno → loop finito, riporta summary e fermati.
   - Single-task: prendi il task indicato dall'utente.
2. **Attiva il task PRIMA dello spawn DEV** (l'hook risolve il task da qui): in `PROGRESS.json` setta `current_task = <task>` e quel task `state = "active"`. Scrivi il file.
3. **Spawn `pm` → `brief <task>`.** Al ritorno verifica che esistano e non siano vuoti `.flow/briefs/<task>/scope.txt` e `.flow/briefs/<task>/frozen.txt`. Se mancano/vuoti o c'è `ESCALATION.json` → **vai a 7**.
4. **Spawn `dev` → `dry-run`.** Al ritorno: se esiste `.flow/briefs/<task>/ESCALATION.json` → **vai a 7**.
5. **Spawn `dev` → `implement`** (implement + verify).
6. **Leggi `.flow/briefs/<task>/RESULT.json`.** Se `escalate==true` OPPURE `verify!="pass"` OPPURE esiste `ESCALATION.json` → **vai a 7**.
   Altrimenti: **spawn `pm` → `finalize <task>`**; in `PROGRESS.json` setta il task `state="done"`; poi **mirror dello status** (vedi sotto). In full-run torna a **1**; in single-task riporta summary e fermati.

### Mirror status sul tasks-file della source (a finalize OK)

Dopo aver marcato `done` in `PROGRESS.json`, riflettilo nel **tasks-file della source** del task (vedi il contratto in `../feature-planner/feature-artifacts.md` § "Planning source contract"): `docs/planning/05-tasks-active.md` (project) oppure `docs/features/<slug>/tasks-active.md` (feature). Risolvilo come fa `task-implementer` (l'ID è opaco: `T-NNN` o `<slug>-NNN`); trova la riga `Status` del task e marcane il completamento secondo la convenzione del file. Modifica **solo** quella riga.

Vincoli del mirror:
- È un riflesso **non-canonico**: la verità d'esecuzione resta `PROGRESS.json`. Se il tasks-file non contiene il task o ha un formato non riconoscibile, **non inventare**: salta il mirror e annotalo nel summary (non è un'escalation).
- **Volatilità**: `project-planner expand` / `feature-planner expand` *sovrascrivono* il tasks-file. Dopo un expand il mirror va riallineato (lo stato durevole è sempre `PROGRESS.json`). Segnalalo nel summary se rilevi un disallineamento.
- Non toccare altre righe né altri file di planning.
7. **ESCALAZIONE.** Leggi `level` + `reason` da `.flow/briefs/<task>/ESCALATION.json` (o, se assente, il motivo del fail da `RESULT.json` / l'anomalia rilevata). Usa **`AskUserQuestion`** riportando level+reason e proponendo opzioni d'azione (es. revise planning, riapri brief, override scope, abbandona task). **FERMATI**: non passare ad altri task senza risposta dell'utente.

## Spawn — cosa passare ai subagent

- `pm` (brief): "Funzione: brief. TASK: <task>. Segui pm.md."
- `pm` (finalize): "Funzione: finalize. TASK: <task>. Applica il gate attended."
- `dev` (dry-run): "Modalità: dry-run. TASK: <task>. Leggi solo .flow/briefs/<task>/brief.md."
- `dev` (implement): "Modalità: implement. TASK: <task>."

Non passare logica di business nel prompt: la fonte è il brief su disco. Tieni i prompt sottili.

## Regole

- Mai `git commit`/`push`. Mai modificare i due sub-progetti fuori da ciò che il brief dichiara.
- Un solo livello di delega: tu spawni pm/dev, loro non spawnano nulla.
- Se `.flow/` non esiste, inizializzalo (PROGRESS.json con la lista task dal piano) prima del loop. Il "piano" può essere `docs/planning/05-tasks-active.md` (project-planner) **o** `docs/features/<slug>/tasks-active.md` (feature-planner): l'orchestratore tratta gli ID in modo opaco e non si cura della source.
- Dopo ogni transizione di stato, **persisti `PROGRESS.json`** prima di proseguire.
