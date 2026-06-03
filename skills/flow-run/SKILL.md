---
name: flow-run
description: Orchestratore "attended" del loop PM→DEV su un piano di task. Eseguito dal main thread. Guida i subagent pm e dev (un solo livello di delega), che comunicano solo via file in .flow/. Spawna il DEV con un modello scelto dinamicamente in base alla complessità del task (tiering dal meta.json del PM), con possibilità di override manuale del modello per un run (es. "esegui solo T-003 con opus"). Si ferma a interpellare l'utente (AskUserQuestion) SOLO su escalation: deviazione fuori scope, verify fallito oltre i retry, cambio di contratto. A finalize riflette lo status nel tasks-file della source del task: docs/planning/05-tasks-active.md (project) o docs/features/<slug>/tasks-active.md (feature) — mirror non-canonico. Supporta full-run (tutti i pending) e single-task (un solo task indicato). Triggera su "avvia il flow", "esegui il piano", "flow-run", "fai girare il loop PM/DEV", "prossimo task del flow", "esegui solo T-NNN", "flow-run T-NNN", "esegui con opus", "forza il modello del dev".
---

# Flow Run — orchestratore attended

Sei il **main thread** = l'ORCHESTRATORE. PM e DEV sono subagent figli diretti (un solo livello: un subagent non può spawnarne altri). PM e DEV **non si parlano**: comunicano solo via file in `.flow/`. Tu spawnani via tool `Agent` con `subagent_type: pm` / `subagent_type: dev`.

## Principio di stato

Lo stato del loop vive in **`.flow/sources/<slug>/PROGRESS.json`** (per-source, la verità d'esecuzione), MAI nella tua memoria. Così il loop regge la compattazione del contesto: a ogni ripresa rileggi il PROGRESS della source acquisita e riparti. Non ricostruire lo stato a mente.

`.flow/sources/<slug>/PROGRESS.json`:
```json
{ "source": "<slug>",
  "context_root": "docs/features/<slug>/",
  "owner": "<descrittore del flow>",
  "current_task": "T-001",
  "tasks": [ { "id": "T-001", "state": "pending|active|done" } ] }
```

`.flow/PROGRESS.json` (radice) è **legacy**: la migrazione al PROGRESS per-source è completa, quindi lo scan lo ignora — il PROGRESS per-source è la sola fonte di verità d'esecuzione. Il file non è rimosso fisicamente (fuori scope), ma non va più letto né scritto come stato del loop.

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

### Claim source (pre-condizione al loop task)

Prima di eseguire il protocollo per-task, il flow **acquisisce la source** via lock advisory.
Dettagli dell'algoritmo (struttura lock, soglia di reclaim, formato heartbeat): single-source in
[`references/concurrency.md`](references/concurrency.md) — non duplicare qui.

1. Scorre le source con task `pending`, in ordine.
2. Per ogni source: tenta `mkdir .flow/locks/<slug>/`.
   - Successo → lock acquisito: scrive `heartbeat.ts`, entra.
   - Fallisce (EEXIST) → controlla se il lock è **stantio** (vedi `references/concurrency.md`
     § Semantica "source viva" / § Soglia di reclaim):
     - Stantio → **reclaim** ed entra.
     - Vivo → **skip**, prossima source.
3. Se nessun claim riesce (tutte vive sotto altri flow, o nessuna source pending) → riporta
   "nessuna source disponibile" nel summary e termina con successo (exit 0). Non è un'escalation.
4. **Inizializza il PROGRESS per-source** (subito dopo il claim riuscito, PRIMA del loop task):
   - Se `.flow/sources/<slug>/PROGRESS.json` **esiste già** → caricalo e riusalo (reclaim di una
     source già avviata: il PROGRESS preesistente è la verità, non re-inizializzare — idempotente).
   - Se **non esiste** → `mkdir -p .flow/sources/<slug>/`, poi costruisci il PROGRESS dal
     `tasks-active.md` della source: per ogni task, `state="done"` se la sua riga `Status` è done,
     altrimenti `state="pending"`; `current_task=null`; `owner` = descrittore del flow;
     `context_root` = directory della feature (es. `docs/features/<slug>/`). Schema canonico:
     `{ source, context_root, owner, current_task, tasks[] }` (single-source in `technical-context.md`).
     Aggiorna `heartbeat.ts` dopo questo write (ordine PROGRESS → heartbeat).
     Dopo l'init del PROGRESS, **upsert entry** in `.flow/index.json` (slug → `{ owner, alive:true,
     active:null, done, pending, archived:false }`); se `index.json` è assente o non valido,
     **ricostruiscilo prima** (vedi § Ricostruzione index.json).
5. Source acquisita: esegue il protocollo per-task sotto, leggendo/scrivendo **solo** il PROGRESS
   per-source della source acquisita. Aggiorna `heartbeat.ts` a ogni transizione di stato
   (ordine: scrivi `PROGRESS` → aggiorna `heartbeat.ts`; vedi
   `references/concurrency.md` § Aggiornamento heartbeat).
6. Al termine della source (o ad abbandono): **release** (`rm -rf .flow/locks/<slug>/`, idempotente).
   Aggiorna `index.json`: `alive=false`, `active=null` per la source rilasciata; lascia `done`/`pending`
   ai valori correnti.

### Ricostruzione index.json

Se `.flow/index.json` è assente o JSON non valido, ricostruiscilo prima di qualunque
operazione sull'index:

1. Scansiona `.flow/locks/`: ogni subdirectory `<slug>/` → source candidata.
2. Per ogni `<slug>`: leggi `.flow/sources/<slug>/PROGRESS.json`.
   - Esiste → popola entry: `owner` dal PROGRESS, `alive` da mtime `heartbeat.ts`
     (semantica `concurrency.md` § Semantica "source viva"), `active`/`done`/`pending`
     dal PROGRESS, `archived: false`.
   - Non esiste → entry minima `{ owner:"unknown", alive:false, active:null,
     done:0, pending:0, archived:false }`.
3. Scansiona `.flow/sources/`: PROGRESS senza lock corrispondente → entry con `alive:false`.
4. Scrivi il file ricostruito.

`index.json` è cache tollerante: un PROGRESS corrotto produce entry degradata, non errore fatale.
Il campo `archived` è sempre inizializzato a `false` in ricostruzione; `true` è responsabilità
esclusiva dell'auto-archivio a fine source (sotto).

### Auto-archivio a fine source

Trigger: tutti i task nel PROGRESS per-source hanno `state="done"` (verificato **dopo** aver segnato
`done` l'ultimo task, prima di tornare al loop). Scatta solo sul task corrente che porta il conteggio a
"tutti done", mai su reclaim. Sequenza **sotto lock**.

I passi 1–2 sono **best-effort, fail-soft** e si eseguono **solo se la source appartiene a un epic**
(vedi § "Risoluzione epic della source"): mai escalation, se non producibili annotali nel summary e
prosegui. Devono precedere il `git mv` perché leggono/aggiornano artefatti ancora vivi in
`docs/features/<slug>/` o nell'epic. I passi 3–6 sono la **sequenza obbligatoria** (l'ordine è
vincolante per idempotenza):

1. **Consolidamento technical-context → epic** (`#8`): risali le decisioni tattiche accumulate nella
   feature al `technical-context.md` condiviso dell'epic, secondo la procedura single-source in
   [`../feature-planner/SKILL.md`](../feature-planner/SKILL.md) § "Mode 4: `finalize <feature>`".
   Append-only, datato, con **guardia di idempotenza**: se l'header `## Consolidato da <slug>` esiste
   già in `docs/epics/<epic>/technical-context.md` → già fatto, salta.
2. **Mirror roadmap epic → done** (`#10`): in `docs/epics/<epic>/roadmap.md` setta la riga
   `Status feature` di questa feature a `✅ done` (vedi § "Mirror status sulla roadmap epic").
   Idempotente (set, non append).
3. **git mv** `docs/features/<slug>/` → `docs/archive/features/<slug>/` (`mkdir -p docs/archive/features/` prima).
   Recovery crash: se DST esiste e SRC non esiste → già spostato, salta. Se entrambi esistono → scrivi
   `.flow/briefs/<task>/ESCALATION.json` `{ "level":"L2", "reason":"archivio parziale non recuperabile: SRC e DST coesistono" }`
   e interrompi la sequenza. Se `git mv` fallisce perché la source non è tracciata da git → `mv` come fallback (annotalo nel summary).
4. **Pulizia** `.flow/sources/<slug>/` **e** `.flow/briefs/<task>/` di **tutti** i task della source
   (`#11`, `rm -rf`, idempotente). I brief canonici sono ormai co-locati e archiviati con la feature
   (passo 3): le copie effimere in `.flow/briefs/` non servono più e non vanno lasciate ad accumularsi.
5. **Release lock** (`rm -rf .flow/locks/<slug>/`, idempotente). È l'ultimo passo prima dell'update index: il lock si tiene per tutta la sequenza.
6. **Aggiorna** `index.json`: `archived=true`, `alive=false`, `active=null`
   (`jq '.[$slug].archived=true | .[$slug].alive=false | .[$slug].active=null'`). Se mancante/corrotto:
   ricostruisci on-demand (§ Ricostruzione index.json) poi aggiorna. Questa è la **sola** scrittura di `archived=true`.

Nessun commit, mai. L'orchestratore annota nel summary: "Source `<slug>` archiviata in `docs/archive/features/<slug>/`. Commit NON eseguito."

## Protocollo (per ogni task)

1. **Leggi piano + PROGRESS per-source** (`.flow/sources/<slug>/PROGRESS.json` della source acquisita).
   - Full-run: prendi il prossimo task `pending`. Se nessuno → tutti i task sono `done`: esegui
     l'auto-archivio (vedi § Auto-archivio a fine source), poi termina la source e riporta summary.
   - Single-task: prendi il task indicato dall'utente.
2. **Attiva il task PRIMA dello spawn DEV** (l'hook risolve il task da qui): nel PROGRESS **per-source**
   (`.flow/sources/<slug>/PROGRESS.json`) setta `current_task = <task>` e quel task `state = "active"`.
   Scrivi il file; poi aggiorna `heartbeat.ts` (ordine: PROGRESS → heartbeat; vedi
   `references/concurrency.md` § Aggiornamento heartbeat).
   Aggiorna `index.json`: `active = <task>`, `done`, `pending` aggiornati dai conteggi correnti del
   PROGRESS per-source (ordine invariante: index dopo PROGRESS e heartbeat).
   **Mirror roadmap epic → active** (`#10`, best-effort, fail-soft): se la source appartiene a un epic
   (§ "Risoluzione epic della source") e la sua riga `Status feature` in `docs/epics/<epic>/roadmap.md`
   è ancora `⚪ planned`, settala a `🔵 active`. Solo questa transizione planned→active; se è già
   `active`/`done` non toccarla. Source standalone o roadmap non risolta → salta silenziosamente.
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
   - **Finalize inline (fast-path)** — SE il task è `trivial`/`standard` (mai `critical`) E `RESULT.deviations` non contiene deviazioni *funzionali* (solo note d'ambiente tipo `"build skipped..."` → ammesso; qualunque deviazione sostanziale o dubbio → percorso PM): l'orchestratore chiude il task **senza spawnare il PM**. Risolve il path del brief on-disk da `Context-root:` nell'header di `.flow/briefs/<task>/brief.md`: path canonico `<context-root>/tasks/<id>.md` (se `Context-root:` è assente → default `docs/planning/`). Marca `Status: ✅ finalized` nel brief risolto. **Non** tocca `technical-context.md` (deviazioni vuote ⇒ nessuna decisione cumulativa; l'eventuale append è già avvenuto al `brief`). Salta la ri-verifica semantica del PM: su un task leggero che ha passato il `verify-gate` il suo valore marginale non giustifica uno spawn a freddo (~90s). Il gate (`verify=="pass"`, no escalation) l'hai **già** applicato qui sopra.
   - **Finalize PM (default)** — altrimenti (task `critical`, deviazioni funzionali, o override esteso al PM): **spawn `pm` → `finalize <task>`** col `model: <finalize derivato>` (vedi 3b: `trivial`/`standard`→`haiku`, `critical`→`sonnet`; degrado/override → `sonnet`). Qui restano la ri-verifica realtà-brief e l'eventuale update di `technical-context.md`.
   In entrambi i casi: nel PROGRESS **per-source** (`.flow/sources/<slug>/PROGRESS.json`) setta il task `state="done"`, scrivi il file e aggiorna `heartbeat.ts` (ordine PROGRESS → heartbeat); poi **mirror dello status** (vedi sotto). In full-run, dopo aver segnato `done` l'ultimo task: verifica se **tutti** i task della source sono `done`; in caso → esegui § Auto-archivio a fine source (la source è chiusa, non tornare a 1). Altrimenti torna a **1**; in single-task riporta summary e fermati.

### Mirror status sul tasks-file della source (a finalize OK)

Dopo aver marcato `done` in `PROGRESS.json`, riflettilo nel **tasks-file della source** del task (vedi il contratto in `../planner/planning-source-contract.md` § "Planning source contract"): `docs/planning/05-tasks-active.md` (project) oppure `docs/features/<slug>/tasks-active.md` (feature). Risolvilo come fa `task-implementer` (l'ID è opaco: `T-NNN` o `<slug>-NNN`); trova la riga `Status` del task e marcane il completamento secondo la convenzione del file. Modifica **solo** quella riga.

Vincoli del mirror:
- È un riflesso **non-canonico**: la verità d'esecuzione resta `PROGRESS.json`. Se il tasks-file non contiene il task o ha un formato non riconoscibile, **non inventare**: salta il mirror e annotalo nel summary (non è un'escalation).
- **Volatilità**: `project-planner expand` / `feature-planner expand` *sovrascrivono* il tasks-file. Dopo un expand il mirror va riallineato (lo stato durevole è sempre `PROGRESS.json`). Segnalalo nel summary se rilevi un disallineamento.
- Non toccare altre righe né altri file di planning.

### Risoluzione epic della source

Una feature source può appartenere a un epic (vedi `../epic-planner/SKILL.md`). Per scoprirlo,
**best-effort**:
1. Glob `docs/epics/*/roadmap.md`. Per ciascuno cerca una riga `Source: docs/features/<slug>/` che
   referenzi **questa** source.
2. **0 match** → source **standalone**: nessun mirror roadmap, nessun consolidamento technical-context.
   Salta silenziosamente (non è un'anomalia).
3. **1 match** → l'epic è quello; usalo per il mirror roadmap e per il consolidamento.
4. **>1 match** → anomalia (slug referenziato da più roadmap): salta entrambe le operazioni epic e
   **annota nel summary**. Non escalare.

Questa risoluzione è la sola dipendenza di `flow-run` dal layer epic: resta epic-agnostico per tutto
il resto (gira ID opachi, una source per run). Se `docs/epics/` non esiste, l'intera logica è inerte.

### Mirror status sulla roadmap epic (best-effort)

Estende la filosofia del mirror sul tasks-file alla `roadmap.md` dell'epic: lo `Status feature` è un
riflesso **non-canonico e advisory** (la verità d'esecuzione resta `PROGRESS.json` + tasks-file). Lo
aggiorni **best-effort, fail-soft** per tenere la roadmap leggibile dall'umano allineata al lifecycle:

- **planned → active**: alla prima attivazione di un task della source (step 2), se la riga era ancora `⚪ planned`.
- **active → done**: all'auto-archivio (passo 2 della sequenza), quando tutti i task sono `done`.

Vincoli:
- Trova in `docs/epics/<epic>/roadmap.md` il blocco della feature (header `### <slug> — …`) e modifica
  **solo** la sua riga `- **Status feature**: …`. Nessun'altra riga, nessun altro file dell'epic.
- **Solo transizioni in avanti** (`planned → active → done`): mai retrocedere. Se lo stato sul file è
  già pari o più avanzato della transizione richiesta, non toccarlo.
- Roadmap assente, feature non trovata nella roadmap, o formato della riga non riconoscibile → **salta
  e annotalo nel summary**. Non è un'escalation, non inventare.
- Il drift residuo (es. crash tra PROGRESS e roadmap) lo ripara `flow-sync` (§ omonima nella sua skill):
  questo mirror è best-effort, `flow-sync` è il backstop di riconciliazione.

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

## Convenzione docs/archive

Feature e epic concluse vengono archiviate in:
- `docs/archive/features/<slug>/` — feature archiviate
- `docs/archive/epics/<slug>/` — epic archiviate

**Regola di esclusione**: `docs/archive/**` non partecipa allo scan di risoluzione (context-root e tasks-file): i task archiviati non sono mai `pending`.
Fonte: `skills/planner/planning-source-contract.md` § "Planning source contract".

Lo spostamento fisico in archive è responsabilità di `feature-planner`/`project-planner`.
Il mirror status è inerte su task già `done` in feature archiviate.
Nessun lock/concorrenza per l'archive (fuori scope — feature `topology-concurrency-core`).

## Regole

- Mai `git commit`/`push`. Mai modificare i due sub-progetti fuori da ciò che il brief dichiara.
- Un solo livello di delega: tu spawni pm/dev, loro non spawnano nulla.
- Se `.flow/` non esiste, inizializzalo (PROGRESS.json con la lista task dal piano) prima del loop. Il "piano" può essere `docs/planning/05-tasks-active.md` (project-planner) **o** `docs/features/<slug>/tasks-active.md` (feature-planner): l'orchestratore tratta gli ID in modo opaco e non si cura della source.
- Dopo ogni transizione di stato, **persisti il PROGRESS per-source** (`.flow/sources/<slug>/PROGRESS.json`) — poi `heartbeat.ts` — prima di proseguire. Il `.flow/PROGRESS.json` radice è legacy (vedi § Principio di stato): ignorato dallo scan, non più scritto.
- La selezione del modello del DEV (step 3b) — sia la derivazione dinamica sia l'**override manuale** dell'utente — è **effimera**: vive nel turno dell'orchestratore, non entra in `PROGRESS.json` né in alcun contratto su disco. Se l'override per-spawn non è onorato, degrada al frontmatter del DEV — non è un'anomalia da escalare.
- Precedenza del modello (single-source [`references/model-tiering.md`](references/model-tiering.md) § Precedenza): `override utente > mapping dinamico (DEV) > frontmatter > sessione`. Non ridefinire qui la regola, solo applicarla.
