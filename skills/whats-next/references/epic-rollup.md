# Epic roll-up — raggruppare le feature di un epic (additivo)

Estensione **opzionale e additiva** di `whats-next`. Se esistono `docs/epics/*/roadmap.md`, le feature `<epic>-<feat>` non si trattano più come piani piatti scollegati, ma come **figlie di un epic** con ordine e dipendenze inter-feature. Se non c'è nessun epic, questa logica non si applica: comportamento storico invariato.

Resta valido tutto il resto: read-only, `PROGRESS.json` canonico, drift segnalato mai corretto, priorità esposta non imposta.

## Cosa aggiunge la roadmap

`docs/epics/<epic>/roadmap.md` (layer **non-canonico**, vedi `../../planner/references/epic-artifacts.md`) dichiara per ogni feature figlia:
- `Source: docs/features/<epic>-<feat>/` (la feature source vera, canonica);
- `Dipende da feature: <epic>-<altra>` (dipendenze **inter-feature**);
- ordine sequenziale + fronti paralleli.

L'avanzamento e gli sbloccati **dei task** restano calcolati come sempre (`reconcile.md`) sui `tasks-active.md` delle feature source: la roadmap **non** è una fonte di stato per-task, solo di **struttura**.

## Scoperta epic

1. Glob `docs/epics/*/roadmap.md`. Per ciascuno: parse della lista feature (slug figlio, goal, `Dipende da feature`, `Source`).
2. Associa ogni source figlia al suo epic. Ordine dei segnali: **anchor `Parent`** in `00-context.md`/`technical-context.md` (autorevole, vale per qualsiasi tier: feature→epic, task→parent) → campo `Source`/slug della roadmap → fallback prefisso slug `<epic>-`. L'anchor vince perché è dichiarato nell'artefatto stesso; la roadmap conferma.
3. Feature `<epic>-*` **senza** corrispondenza in nessuna roadmap → trattale piatte e **segnalalo** (orphan rispetto all'epic). Non inventare appartenenze.

## Calcolo per-epic

- **Avanzamento epic** = somma dei task `✅` delle feature figlie / totale task delle figlie (conteggio; nota se effort-pesato cambia il quadro). NON usare lo `Status feature` della roadmap come verità: è advisory.
- **Feature sbloccata (a livello epic)** = tutte le sue `Dipende da feature` risultano **complete** (tutti i task della feature dipesa sono `done`, stato riconciliato). Questa è la sola risoluzione di dipendenze **inter-feature**: avviene **qui**, non nei downstream (che sono per-source).
- **Next dell'epic** = nella prima feature sbloccata secondo l'ordine di roadmap, il next-task di quella feature (calcolo `reconcile.md` standard). Fronti paralleli → più next possibili: esponili entrambi.

> Onestà: la dipendenza inter-feature la risolve solo `whats-next` per il **consiglio**. `flow-run` non la gata (sequencing advisory). Se l'utente lancia una feature non ancora sbloccata, il sistema non lo impedisce — segnalalo nel board, non bloccarlo.

## Ranking con epic (modalità global)

Le tre leve di `ranking.md` valgono, con l'epic come possibile unità:

- **WIP avanzato**: un **epic** ≳75% e fermo batte l'apertura di una nuova feature/epic ("chiudi l'epic <X>, è all'N%"). Vale anche per la singola feature figlia ferma e quasi chiusa.
- **Critical path**: tra le feature sbloccate dell'epic, privilegia quella da cui dipendono più feature successive (peso sul grafo inter-feature della roadmap).
- **Quick win**: invariato (task <2h sbloccato).

Resta un'**euristica esposta**: l'epic ordina, l'utente decide. Chiudi sempre ricordando che la scelta epic-vs-feature-vs-macro-plan è dell'utente.

## Output con epic

Nel **board**, raggruppa le feature sotto il loro epic con una riga di rollup:

```
EPIC payments-revamp — 42% (3/7 feature complete) — next sbloccato: payments-revamp-api
  ├ payments-revamp-foundation   ✅ 100%   —
  ├ payments-revamp-api          🔵 60%    next: payments-revamp-api-004
  ├ payments-revamp-ui           ⚪ 0%     bloccata da: api            ∥ reporting
  └ payments-revamp-reporting    ⚪ 0%     bloccata da: api            ∥ ui
```

Feature non appartenenti a nessun epic restano righe piatte come oggi.

## Stato figli archiviati

Se una feature figlia è archiviata (la sua directory non compare sotto `docs/features/` ma sotto `docs/archive/features/<slug>/`):
- Stato della feature = **done congelato** (tutti i task done).
- Per il rollup epic: contarla come completata al 100%.
- Non scansionare il suo `tasks-active.md` per task ancora aperti.
- Il path di lettura è `docs/archive/features/<slug>/tasks-active.md` — lettura sola, per sapere quanti task erano nella feature al momento dell'archivio e alimentare il conteggio del rollup.

Questo chiude RISK-topology-reconcile-001: una feature-figlia archiviata non blocca il rollup epic — è già done.

Coerenza con `reconcile.md`: se `index.json` riporta `archived=true` per uno slug, quello slug rientra in questa categoria — non aprire il suo `tasks-active.md` live, usa il path di archivio.

## Degradazioni oneste

- **Nessun `docs/epics/`** → niente roll-up: comportamento storico, non menzionare epic.
- **Roadmap presente ma feature source mancante** (`Source` punta a una dir inesistente) → segnala l'incoerenza, non inventare task.
- **Dipendenza inter-feature verso una feature inesistente** → anomalia: riportala, considera la feature bloccata.
- **`Status feature` della roadmap in disaccordo con l'avanzamento reale dei task** → fidati dei task (verità d'esecuzione), segnala il drift della roadmap (volatile, advisory). Non correggere: `whats-next` è read-only. Il marker roadmap lo aggiorna `flow-run` (mirror best-effort lungo il lifecycle), lo ripara `flow-sync` (riconciliazione roadmap, vedi la sua skill) e lo cura `epic-planner revise`.
