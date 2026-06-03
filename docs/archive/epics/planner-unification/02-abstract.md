# Abstract tecnico — Epic: Unificazione dei planner (`planner-unification`)

<!-- Anchor --> **Tier**: epic · **Parent**: — · **Bubble-up target**: —

## Approccio d'insieme
Collasso dei 3 planner in `skills/planner/` preservando **al byte** la tipologia di artefatti (`00-context`, `02-abstract`, `technical-context`, `tasks-active`/`roadmap`/`milestones`). Il valore non sta in nuovi formati ma in: (1) **un solo entry point** con routing del tier interno e confermato; (2) **anchor** che spostano l'informazione "chi è il padre / dove risalgono le decisioni" dai **dati** invece che dalla **logica** di flow-run; (3) **finalize** come unico proprietario del bubble-up, selettivo e a un salto. I downstream restano scanner per-directory di ID opachi: cambiano solo i path dei link, l'apprendimento di `docs/tasks/<slug>/` e l'invocazione di `planner finalize` da parte di `flow-run`.

## Decisioni tecniche condivise
- **Skill modulare**: `planner/SKILL.md` sottile; logica tier in `references/tier-*.md`; condivisi (`elicitation`, `critical-review`, `task-expansion`, `artifact-contract`) **relocati** da `project-planner/` e linkati single-source.
- **Planning source contract v2**: unica fonte di verità della risoluzione, **relocata** in `skills/planner/` (oggi in `feature-planner/feature-artifacts.md`). Aggiunge il tier `task` (`docs/tasks/<slug>/`) e gli **anchor**.
- **Schema anchor** (header di `00-context.md` e `technical-context.md`): `Tier`, `Parent`, `Bubble-up target`. Valori vuoti ammessi (`—`) per artefatti slegati.
- **Bubble-up single-hop selettivo**: `finalize` legge `Bubble-up target`, valuta il sottoinsieme **coerente** da far risalire, append-only datato con guardia di idempotenza. Catena: task→feature→epic→project, un hop per finalize.
- **Back-compat**: anchor assente ⇒ trattato come standalone (`Parent: —`), nessun bubble-up. I progetti pre-2.0.0 non si rompono; il retrofit è opt-in via `migrate`.

## Contratti da preservare
- **Planning source contract** (semantica di risoluzione: scan `docs/planning/` + `docs/features/*/` + `docs/epics/*/` [+ `docs/tasks/*/` nuovo], esclusione `docs/archive/**`, ID opachi unici, brief co-locato `<context-root>/tasks/<id>.md`).
- **Schema `.flow/`** (PROGRESS per-source, lock, index) e i mirror non-canonici (PROGRESS = verità d'esecuzione).
- **Tipologia e shape degli artefatti**: invariata per tutti i tier.
- **Modello attended di `flow-run`**: escalation solo via main thread; un solo livello di delega.

## Trade-off
- **Single-hop vs cascading**: rinunciamo alla risalita automatica multi-livello (più potente ma judgment-heavy/silenziosamente sbagliabile) in favore di un salto deterministico + promozione manuale via `revise`. Accettato.
- **Anchor come dato copiato vs link risolto a runtime**: l'anchor è un riferimento esplicito nell'header, non una risoluzione dinamica. Prezzo per non toccare il modello di lettura dei downstream.
- **Rimozione netta vs alias**: scelta la rimozione (meno superficie, coerente col major) accettando la rottura della muscle-memory dei trigger (assorbita dalla description di `planner`).

## Rischi tecnici cross-feature
- Ordine di migrazione **irreversibile** sui tool d'esecuzione (vedi RISK-001): toccarli per ultimi.
- Divergenza dei reference durante il porting (3 fonti → 1): la feature `core` deve **consolidare**, non copiare e basta.
- `flow-run` passa dall'append diretto (1.1.0) all'invocazione di `finalize`: doppio comportamento durante la transizione tra `finalize` (F3) e `downstream` (F4) → F4 chiude la finestra.

## Esclusioni tecniche
- Nessun nuovo formato di artefatto. Nessun cambiamento agli hook. Nessun cascading automatico del bubble-up oltre il padre diretto. Nessuna modifica al contratto `.flow/` o al modello di concorrenza.

---
Generato: 2026-06-02 | Versione: 1
