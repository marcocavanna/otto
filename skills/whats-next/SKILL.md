---
name: whats-next
description: Advisor read-only che risponde "cosa faccio adesso / dopo" su un progetto con piani di lavoro otto. Fa il join di tutti i piani attivi (macro-plan di project-planner + feature parallele di feature-planner), riconcilia lo stato reale d'esecuzione con `.flow/index.json` (veloce) o `.flow/sources/*/PROGRESS.json` (fallback per-source), e produce un board multi-piano + una raccomandazione ragionata (cosa è sbloccato ora, cosa è quasi finito, cosa è sul critical path) con comandi concatenabili verso flow-run. NON modifica nulla, NON decide la priorità tra piani: la espone e la motiva. Supporta query globali o scoped. Triggera su "whats-next", "cosa devo fare dopo/adesso", "prossimo step/task", "next", "a che punto sono", "prossimo sprint", "stato del piano", "whats-next nella milestone M[N]", "whats-next nella feature <slug>".
---

# Whats Next — advisor operativo read-only

Rispondi a **"cosa faccio adesso / dopo"** su un progetto che usa i piani di otto. Sei un **consigliere**, non un esecutore: `flow-run` esegue, tu indichi *cosa* e *perché*. Concatenabile: il tuo output finisce in `flow-run <id>`.

## Principio di stato

Non possiedi stato. Sei una **proiezione read-only** su artefatti che già esistono. Non scrivi MAI: né i piani, né `.flow/`, né il codice. Le descrizioni/dipendenze sono i tasks-file; la strategia è milestone/fasi. Tu fai solo il *join* e il ragionamento.

La verità d'esecuzione è **distribuita per-source**:
- `.flow/index.json` → vista aggregata (veloce); se presente, usarla come prima lettura.
- Fallback scan: `.flow/sources/*/PROGRESS.json` + `.flow/locks/*` → ricostituisce il quadro se index mancante o stantio.
- `.flow/PROGRESS.json` (legacy singleton) → retrocompat; se presente, usarlo SOLO per i source/ID che NON compaiono in nessuna source per-source.
- Nessun `.flow/` = nessun flusso mai eseguito (invariato).

## Principio di priorità (NON negoziabile)

Con un macro-plan + feature parallele **non esiste un "next" globale deterministico**: scegliere se spingere la milestone o chiudere una feature è una **decisione dell'utente**. Tu rendi deterministica la parte calcolabile (cosa è bloccato/sbloccato/quasi-finito/fermo) e **esponi** la parte di giudizio con una raccomandazione motivata. Non la imponi. L'utente decide; tu fornisci il comando pronto.

## Fonti dati (sola lettura)

- `docs/planning/05-tasks-active.md` — task atomici **della sola milestone attiva** (project source).
- `docs/planning/03-milestones.md` — stato macro delle milestone (🔵 active / ⚪ planned / ✅ done / ⏸ paused).
- `docs/features/*/tasks-active.md` — task delle feature parallele (feature source, campo `Feature`).
- `docs/tasks/*/tasks-active.md` — task standalone (**tier task**: una directory per task, 1 task-entry). Source canonica come le feature; compare nel board. La gerarchia col padre, se dichiarata, si legge dall'**anchor** (`Parent`/`Bubble-up target`) in `00-context.md`/`technical-context.md`.
- `docs/epics/*/roadmap.md` — **(opzionale, additivo)** coordinamento di un epic: raggruppa più feature `<epic>-<feat>` sotto un epic e ne dichiara ordine + dipendenze inter-feature. Layer **non-canonico**: se assente, le feature restano piatte (comportamento storico). Vedi `references/epic-rollup.md`.
- `.flow/index.json` — roll-up aggregato (`source → {owner, alive, active, done, pending, archived}`); se presente, primo punto di lettura.
- `.flow/sources/<slug>/PROGRESS.json` — verità per-source; fallback se index assente.
- `.flow/locks/<slug>/` — presenza della dir = source viva (lock attivo); usato nel fallback scan.
- `.flow/PROGRESS.json` — legacy singleton; retrocompat per ID non ancora migrati a una source per-source.

Formato task (identico project/feature, vedi `../planner/references/task-expansion.md` e `../planner/planning-source-contract.md`): ID, categoria, `Effort` (range ore), `Dipende da`, `Status` (⚪🔵✅⏸). ID globalmente unici (`T-NNN` project, `<slug>-NNN` feature) — trattali in modo **opaco**.

## Modalità — deriva dall'input utente

- **global** (default, nessuno scope): scopri TUTTI i piani attivi → board + raccomandazione cross-plan.
- **plan**: "…del piano / del progetto / del macro-plan" → solo `docs/planning/`.
- **milestone**: "…nella milestone M[N]" → vedi sotto (i task atomici esistono **solo** per la milestone attiva).
- **feature**: "…nella feature <slug>" → solo `docs/features/<slug>/`. Se lo slug non esiste o è ambiguo, elenca le feature disponibili e chiedi.
- **epic**: "…nell'epic <epic>" → le feature `<epic>-*` raggruppate via `docs/epics/<epic>/roadmap.md`, con next che rispetta la sequenza inter-feature. Vedi `references/epic-rollup.md`. Epic inesistente → elenca gli epic disponibili e chiedi.

## Protocollo

1. **Scoperta.** In base alla modalità, individua i piani in scope. Per ciascuno trova il tasks-file e (se c'è) `.flow/index.json` o `.flow/sources/<slug>/PROGRESS.json`. Se non esiste nessun piano → dillo e suggerisci `project-planner`/`feature-planner`. Non inventare.
2. **Riconciliazione stato** per ogni task — vedi `references/reconcile.md`. Se `index.json` è presente, carica per ogni source `{owner, alive, active, done, pending, archived}`; usa quel dato come pre-filtro prima di aprire i PROGRESS per-source. Source con `archived=true` → tutte le sue done congelate; non accedere al suo `tasks-active.md` per task attivi. Canonico per-task = PROGRESS per-source (o legacy singleton per ID non migrati); fallback = `Status` del tasks-file. Ogni **drift** va riportato, mai corretto (sei read-only).
3. **Calcolo per-piano:**
   - parse task → {id, categoria, effort, deps, stato-riconciliato}
   - **sbloccati** = stato `todo` **e** tutte le `Dipende da` risultano `done`
   - **next del piano** = tra gli sbloccati, quello con peso di critical-path maggiore (n. di task che dipendono da esso); a parità, ordine del file
   - **avanzamento** = ✅ / totale (per conteggio; nota se effort-pesato cambia il quadro)
   - **blockers** = task `⏸` o `todo` con deps non soddisfatte (indica da cosa dipendono)
4. **Roll-up gerarchico** (additivo) — la gerarchia padre→figlio (feature→epic, task→parent) si ricava dall'**anchor** (`Parent`) degli artefatti, con il campo `Source` della roadmap come conferma/fallback. Se esistono `docs/epics/*/roadmap.md`, raggruppa le feature sotto il loro epic, calcola l'avanzamento dai task reali e rispetta l'ordine/dipendenze inter-feature. Vedi `references/epic-rollup.md`. Senza anchor né roadmap, le source restano piatte.
5. **Ranking cross-plan** (solo modalità global) — vedi `references/ranking.md`: WIP-avanzato → critical-path macro-plan → quick-win. È **euristica esposta**, non verità. Con epic presenti, l'unità di ranking può essere l'epic (vedi `epic-rollup.md`).
6. **Output a 3 livelli** (vedi sotto).

### Milestone scoped — caso speciale

`05-tasks-active.md` contiene task atomici **solo della milestone attiva**. Quindi:
- Milestone richiesta == attiva → mostra i suoi task (come modalità plan).
- Milestone richiesta != attiva → **non esistono task atomici**: mostra solo il macro da `03-milestones.md` (outcome, DoD, effort range, status) e dillo esplicitamente: *"M[N] non è la milestone attiva: niente task atomici. Per espanderla: `project-planner expand M[N]`."* Non inventare task.

## Output — 3 livelli, dal più immediato allo strategico

1. **Board** — tabella di tutti i piani in scope: nome, % avanzamento, next sbloccato, blockers/⚠. Stato riconciliato (segnala drift).
2. **Raccomandazione ragionata** — 1-3 mosse con il **perché** (sblocca N task / chiude una feature ferma / sul critical path / quick win). In global applica il ranking; in scope è il next del piano.
3. **Comandi concatenabili** — per ogni mossa proposta: `flow-run <id>` pronto da copiare.

Tono: senior, denso, niente filler, niente cheerleading. Coerente con `flow-run`/`project-planner`.

## Regole di onestà (gap espliciti — la skill non finge rigore)

- **Niente dipendenze dichiarate** (`Dipende da: —` ovunque) → "nessuna dipendenza dichiarata: ordino per fase/categoria, non per critical-path."
- **Effort è un range** → lo sprint/orizzonte è euristico, non garantito. Dillo.
- **`.flow/index.json` e `.flow/sources/` assenti** → "stato d'esecuzione non tracciato (nessun `.flow`): uso lo `Status` del piano, che può non riflettere il lavoro reale." (copertura: sia schema per-source sia legacy singleton assenti).
- **Drift PROGRESS per-source ↔ tasks-file** → riportalo (volatile dopo un `expand`, che sovrascrive il tasks-file). Non risolverlo: sei read-only. Per **ripararlo** usa `flow-sync` (`skills/flow-sync/`): preview di default, apply su conferma — ripara i drift sicuri + import conservativo, segnala gli ambigui/orphan. whats-next rileva, flow-sync ripara.
- **Tasks-file in formato non riconoscibile / task mancante** → non inventare: salta e annotalo.

## Cosa NON fa

- Non scrive nulla (no piani, no `.flow`, no codice, no commit).
- Non decide la priorità macro-vs-feature: la motiva e lascia scegliere.
- Non espande milestone né genera task (è compito di `project-planner`/`feature-planner`).
- Non esegue task (è compito di `flow-run`).
