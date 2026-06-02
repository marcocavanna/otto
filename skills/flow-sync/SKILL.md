---
name: flow-sync
description: Reconcile/repair del drift tra .flow/PROGRESS.json (stato d'esecuzione canonico) e i marker Status dei tasks-file (docs/planning/05-tasks-active.md, docs/features/*/tasks-active.md). Chiude il loop di whats-next: quella RILEVA il drift in sola lettura, flow-sync lo RIPARA. Preview di default (classifica e mostra i diff/entry proposti, NON scrive), apply su conferma esplicita. Ripara solo i casi sicuri (safe-repair PROGRESS→file) + import conservativo (file ✅ done ma ID assente in PROGRESS → entry done) + riconciliazione in avanti dello `Status feature` nelle roadmap epic (backstop del mirror best-effort di flow-run), segnala ambigui/orphan senza mai sovrascriverli. Scope global/plan/feature come whats-next, risoluzione context-root via scan (ID opachi). Triggera su "flow-sync", "riallinea lo stato", "ripara il drift", "sincronizza PROGRESS", "allinea PROGRESS e tasks-file", "fix dello stato dopo un expand", "riconcilia lo stato del piano".
---

# Flow Sync — reconcile/repair del drift di stato

Ripari il **drift** tra `.flow/PROGRESS.json` (stato d'esecuzione canonico) e i marker `Status` dei tasks-file. Chiudi il loop di `whats-next`: quella **rileva** il drift in sola lettura e ti rimanda qui; tu lo **classifichi** e, solo sui casi sicuri, lo **ripari**. Non sei un esecutore di task (`flow-run`) né un planner (`*-planner`): agisci solo sullo stato.

## Principio (PROGRESS arbitro per-source + auto solo sui sicuri + import conservativo)

Principio non negoziabile della skill (ASSUMPTION-flow-sync-001/002/003 — invariato; esteso):

- **PROGRESS arbitro per-source**: per ogni source attiva, la verità è `.flow/sources/<slug>/PROGRESS.json`. Per gli ID presenti nel suo `tasks[]` lo stato canonico è il loro `state`; per gli ID assenti, fallback sul `Status` del tasks-file della source.
- **Source archiviata → done congelata**: se `index.json` riporta `archived=true` per uno slug, tutti i suoi task sono trattati come `done`. Nessun repair né import: classificazione `in-sync` forzata, nessuna scrittura.
- **Fallback radice**: `.flow/PROGRESS.json` radice è back-compat per source non ancora migrate a layout per-source. Consultato solo se `.flow/sources/<slug>/PROGRESS.json` è assente per quello slug.
- **Auto solo sui drift sicuri**: si scrive **esclusivamente** dove la riconciliazione classifica `safe-repair` (mirror PROGRESS→file, solo in avanti nella progressione) o `import` (file `✅` + ID assente in PROGRESS). Tutto il resto è solo report.
- **Import conservativo**: il file→PROGRESS avviene **solo** per i `✅ done` assenti dal loop, marcati `imported` e sempre visibili in preview prima dell'apply (RISK-flow-sync-001).

La **matrice** (classe × azione) non si ridefinisce qui: è in `references/reconciliation.md`. Il **come** si scrive non si ridefinisce qui: è in `references/apply-protocol.md`.

## Scope e modalità

Scope come `whats-next` (`../whats-next/SKILL.md` § Modalità), risolto dall'input utente:

- **global** (default, nessuno scope): tutti i piani attivi.
- **plan**: "…del piano / del macro-plan" → solo `docs/planning/`.
- **feature**: "…nella feature <slug>" → solo `docs/features/<slug>/`. Slug inesistente/ambiguo → elenca le feature e chiedi.

Risoluzione context-root **via scan** (`docs/planning/05-tasks-active.md` + `docs/features/*/tasks-active.md`); ID globalmente unici e **opachi** (vedi `../feature-planner/feature-artifacts.md` § "Planning source contract"). Per ogni piano in scope: il suo tasks-file + `.flow/sources/<slug>/PROGRESS.json` (o `.flow/PROGRESS.json` radice come fallback se la source non ha ancora la directory per-source).

Modalità di esecuzione:

- **preview** (default): classifica e mostra i diff/entry proposti, **non scrive nulla**. Read-only al 100% (ASSUMPTION-flow-sync-003).
- **apply** (solo su conferma esplicita successiva alla preview): esegue le sole azioni auto-applicabili. `report` non scrive mai.

## Protocollo

1. **Scoperta.** In base alla modalità individua i piani in scope; per ciascuno:
   - Ricava lo `<slug>` della source (da tasks-file o `context_root`).
   - Cerca `.flow/sources/<slug>/PROGRESS.json`; se assente, fallback su `.flow/PROGRESS.json` radice.
   - Controlla `index.json`: se lo slug ha `archived=true`, non proseguire con la riconciliazione per quello slug (nessun repair/import, log "source archiviata — done congelata").
   - Nessun piano attivo trovato → dillo e suggerisci `project-planner`/`feature-planner`. Non inventare.
2. **Riconciliazione + classificazione.** La **lettura** (gerarchia di verità, mappatura stati, enumerazione drift) riusa `../whats-next/references/reconcile.md` — citala, non duplicarla. La **scrittura** aggiunge la dimensione classe + azione per ogni task secondo `references/reconciliation.md`: classi `in-sync` / `safe-repair` / `import` / `ambiguous` / `orphan`.
3. **Preview.** Report di classificazione (board per-task) + diff della riga `Status` per i `safe-repair` e entry proposta per gli `import`. Ambigui/orphan elencati come "non toccati" con la ragione. **NON scrive.**
4. **Apply** (su conferma): esegue `safe-repair` + `import` secondo la sequenza ordinata di `references/apply-protocol.md` (guardia globale su `PROGRESS.json` → backup tasks-file → riscrittura sola riga `Status` → append import → persist/rivalida). `current_task` intoccato.

La matrice, i 3 casi safe-repair, la regola import, il principio `ASSENTE ≠ CONFLITTO`, l'ordine di scrittura e le guardie **non** si ridefiniscono qui: si consultano `references/reconciliation.md` e `references/apply-protocol.md`.

## Riconciliazione roadmap epic (additivo)

Backstop del mirror **best-effort** di `flow-run` sullo `Status feature` della `roadmap.md` (vedi
`../flow-run/SKILL.md` § "Mirror status sulla roadmap epic"): se `flow-run` non l'ha aggiornato (crash
tra PROGRESS e roadmap, feature avviata senza flow-run, drift volatile), `flow-sync` lo ripara. Si
attiva **solo** se la source in scope appartiene a un epic.

- **Scoperta epic**: glob `docs/epics/*/roadmap.md`, source associata via riga `Source: docs/features/<slug>/`. 0 match → source standalone, **niente riconciliazione roadmap** (salta). >1 match → anomalia, report, nessuna scrittura.
- **Stato feature atteso** (derivato dallo stato riconciliato dei task della feature, stessa verità del rollup `whats-next`): tutti i task `done` (o `index.json` `archived=true`) → `✅ done`; almeno un task avviato/done ma non tutti → `🔵 active`; nessuno avviato → `⚪ planned`.
- **Classificazione** (granularità **feature**, non task), riusa la semantica safe/forward del task-level:
  - atteso **più avanti** della riga `Status feature` sul file → `safe-repair` (in avanti: `planned→active→done`). Apply riscrive **solo** quella riga.
  - atteso **uguale** → `in-sync`.
  - file **più avanti** dell'atteso (es. roadmap `done` ma esistono task non-done) → `ambiguous` → **report**, mai retrocedere (coerente con "Non retrocede mai un marker").
- **Scope di scrittura**: in apply tocca **solo** la riga `- **Status feature**: …` del blocco feature in `roadmap.md`. Niente altre righe, niente altri file dell'epic. Roadmap assente / blocco feature non individuabile / riga non riconoscibile → salta e segnala (read-only su quel caso). Backup del file come per i tasks-file.

La roadmap resta un riflesso **advisory**: la verità è `PROGRESS.json` + tasks-file. Questa riconciliazione allinea solo il documento umano, in avanti, sui casi sicuri.

## Output (report + comandi)

Board di classificazione per-task (in scope), seguita dai comandi pronti:

```text
id            | PROGRESS.state | file Status      | classe       | azione
--------------|----------------|------------------|--------------|--------
<slug>-003    | done           | ⚪ todo          | safe-repair  | apply  (→ ✅ done)
<slug>-004    | ASSENTE        | ✅ done          | import       | import (entry done, imported)
<slug>-005    | pending        | ✅ done          | ambiguous    | report (non toccato)
```

- In **preview**: la board + i diff/entry proposti + il comando per passare ad **apply** su conferma.
- Le derivazioni `PROGRESS.state → emoji/label`, la matrice e l'ordine di scrittura provengono da `references/reconciliation.md` / `references/apply-protocol.md`: non si ricalcolano qui.

Tono: senior, italiano denso, fail-closed, niente filler/cheerleading. Coerente con `flow-run`/`whats-next`.

## Regole di onestà sui gap (mutuate da whats-next)

- **`.flow/sources/<slug>/PROGRESS.json` assente E `.flow/PROGRESS.json` radice assente/illeggibile per quello slug** → dillo, non inventare. Senza PROGRESS non c'è arbitro per quella source: **niente safe-repair, niente import su quella source**. Suggerisci `flow-run` (proprietario dell'init del loop). Le altre source proseguono normalmente. Se il PROGRESS è presente ma illeggibile/schema invalido in apply → ABORT per quella source, 0 scritture su di essa (RISK-flow-sync-002).
- **Tasks-file in formato non riconoscibile / task (riga `Status`) non individuabile** → salta *quel* task e segnalalo, nessuna scrittura su di esso (read-only, RISK-flow-sync-003). Non blocca l'intero apply.
- **Drift volatile post-`expand`** → contestualizza: `project-planner`/`feature-planner` `expand` sovrascrivono il tasks-file azzerando i marker mentre `PROGRESS.json` resta. È il caso tipico `done × ⚪` (safe-repair). Lo stato durevole è sempre `PROGRESS.json`.

## Cosa NON fa

- **Non inizializza** `PROGRESS.json` da zero (è di `flow-run`).
- **Non esegue** task né li **espande** (è di `flow-run` / `project-planner` / `feature-planner`).
- **Non scrive codice**, non committa, non riformatta i tasks-file (tocca solo la riga `Status` dei task `safe-repair`).
- **Non altera** `current_task`, né i brief co-locati `<context-root>/tasks/<id>.md`, né altre righe del tasks-file.
- **Non decide la priorità** cross-plan e non raccomanda il "next" (è di `whats-next`).
- **Non retrocede** mai un marker: se il file è avanti su PROGRESS → `ambiguous` → report.
