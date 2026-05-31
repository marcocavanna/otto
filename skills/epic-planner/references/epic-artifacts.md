# Epic artifacts — template + contratto di coordinamento

Template dei file generati da `epic-planner` e definizione del **layer di coordinamento non-canonico**. Markdown denso, niente filler, gestione gap come `../../project-planner/artifact-templates.md`.

---

## Epic coordination contract (NON-CANONICO)

> Questa sezione descrive il layer epic. La **fonte di verità della risoluzione** resta il *Planning source contract* in `../../feature-planner/feature-artifacts.md` § "Planning source contract" — **linkala, non duplicarla**.

L'epic produce:

- **Layer epic** in `docs/epics/<epic>/` — `00-context.md`, `02-abstract.md`, `technical-context.md` (seed condiviso), `roadmap.md`. **Non è una planning source**: niente `tasks-active.md`, mai risolto dallo scan downstream, nessun marker Status canonico.
- **N feature source** in `docs/features/<epic>-<feat>/` — **bundle standard** identici a quelli di `feature-planner` (i 4 file + ID `<epic>-<feat>-NNN`). Sono le uniche **source** dell'epic; i downstream le consumano invariate.

Mappatura mentale: `roadmap.md` sta alle feature figlie come `03-milestones.md` sta a `05-tasks-active.md` — **strategia macro vs esecuzione**.

### Limiti onesti (dichiarali, non fingere rigore)

- **Sequencing advisory, non enforced.** `roadmap.md` documenta l'ordine; `whats-next` (epic-aware) lo rispetta nel consiglio; `flow-run` **non** lo gata. L'utente resta l'arbitro della priorità (filosofia *attended*).
- **Niente risoluzione deps cross-source.** Il calcolo "sbloccato" dei downstream (`../../whats-next/references/reconcile.md` § "Calcolo sbloccato") è **per-source**: una `Dipende da: <altra-feature>-NNN` tra source diverse **non** viene valutata. Per questo le dipendenze tra feature stanno a livello **feature** in `roadmap.md`, non a livello task tra source.
- **`flow-run` è one-source-per-run.** L'epic copre più source: si esegue una feature figlia alla volta, in ordine di roadmap. Nessun "esegui l'epic intero" automatico in v1.

---

## docs/epics/<epic>/00-context.md

```markdown
# Context — Epic: [titolo] (`<epic>`)

**Progetto**: [nome repo/progetto]
**Tipo**: epic (più feature sequenziali) su progetto esistente

## Cosa realizza l'epic
[2-4 frasi: outcome d'insieme osservabile, chi lo usa, perché ora. NON un pitch di prodotto.]

## Derivato dal codebase
- **Aree/moduli toccati (d'insieme)**: [path/componenti]
- **Stack pertinente**: [solo ciò che l'epic usa]
- **Convenzioni rilevate**: [pattern/naming dai sample]
- **Build/test command**: [comando rilevato]

## Decomposizione in feature
[Riepilogo: la lista vive in roadmap.md; qui il razionale di confine.]
- **Criterio di split**: [perché queste feature e non altre]
- **Tronco comune**: [VO/contratti/infra condivisi → seed in technical-context.md]

## Boundary e scope d'insieme
- **In scope (epic)**: [...]
- **Fuori scope (epic)**: [...] (esplicito)
- **Integrazione con l'esistente**: [contratti da non rompere]

## Tracked assumptions (condivise)
### ASSUMPTION-<epic>-001
- **Descrizione**: [...]
- **Scelta**: [...]
- **Alternative valutate**: [...]
- **Impatta**: 02-abstract.md / technical-context.md / feature: [<epic>-feat, ...]
- **Status**: active
- **Data**: YYYY-MM-DD

## Known risks (cross-feature)
### RISK-<epic>-001 — [titolo]
- **Severità**: 🔴 | 🟡 | 🟢
- **Descrizione**: [...]
- **Mitigazione**: [...]

---
Generato: YYYY-MM-DD | Versione: 1
```

## docs/epics/<epic>/02-abstract.md

```markdown
# Abstract tecnico — Epic: [titolo] (`<epic>`)

## Approccio d'insieme
[Come l'epic si realizza dentro l'architettura esistente. Riusa ciò che c'è. Niente intro sui framework.]

## Decisioni tecniche condivise
[Scelte valide per TUTTE le feature: pattern comuni, nuovi VO/contratti introdotti dal tronco comune, strategie di migrazione/flag.]

## Contratti da preservare
[Interfacce/endpoint/schema esistenti che l'epic consuma ma NON deve rompere. Diventeranno frozen.txt lato flow nelle singole feature.]

## Trade-off
[1-3 trade-off d'insieme.]

## Rischi tecnici cross-feature
[Regressioni, ordine di migrazione, accoppiamenti pericolosi.]

## Esclusioni tecniche
[Cosa l'epic NON fa e perché.]

---
Generato: YYYY-MM-DD | Versione: 1
```

## docs/epics/<epic>/technical-context.md (SEED CONDIVISO)

> Il seed che **tutte** le feature figlie ereditano. Da qui ogni `docs/features/<epic>-<feat>/technical-context.md` viene seedato (vedi "Propagazione del seed"). `task-implementer` poi estende il file del *figlio* in append-only, non questo.

```markdown
# Technical context (shared) — Epic: [titolo] (`<epic>`)

## Convenzioni di progetto
### Build & test
- build_command: `[comando rilevato]`
- test_command: `[se noto]`

## Pattern architetturali condivisi
[Pattern del codebase che tutte le feature dell'epic devono seguire — riferiti a file sample reali.]

## Value Objects / contratti condivisi
[VO/contratti introdotti dal tronco comune o esistenti consumati da più feature. Vincolanti per i figli.]

## Librerie e versioni
[Solo le librerie rilevanti per l'epic, con versione, se desumibili.]

---
Generato: YYYY-MM-DD | Versione: 1
```

## docs/epics/<epic>/roadmap.md (★ coordinamento)

> Analogo non-canonico di `03-milestones.md`. Ordine, dipendenze inter-feature, sequencing, DoD epic. **Letto da `whats-next` (epic-aware)**. Stato a granularità **feature** (derivato/manuale), non per-task: la verità per-task resta nei tasks-file + `PROGRESS.json`.

```markdown
# Roadmap — Epic: [titolo] (`<epic>`)

**Outcome epic**: [una frase]
**Definition of done epic**: [criterio binario d'insieme]
**Effort totale stimato**: [X-Y ore]

## Feature (ordine sequenziale)

### <epic>-foundation — 🏗️ [titolo feature]
- **Goal**: [outcome osservabile]
- **Dipende da feature**: —
- **Effort**: [X-Yh] (~N task)
- **Status feature**: ⚪ planned | 🔵 active | ✅ done | ⏸ paused
- **Source**: docs/features/<epic>-foundation/

### <epic>-api — 💻 [titolo feature]
- **Goal**: [...]
- **Dipende da feature**: <epic>-foundation
- **Effort**: [X-Yh] (~N task)
- **Status feature**: ⚪ planned
- **Source**: docs/features/<epic>-api/

[...]

## Fronti paralleli
[Es: {<epic>-ui, <epic>-reporting} dopo <epic>-api. Niente dipendenza reciproca.]

## Note di sequencing
[Razionale dell'ordine: cosa abilita cosa. Rischi d'ordine (migrazioni irreversibili, ecc.).]

---
Generato: YYYY-MM-DD | Versione: 1 | Epic: <epic>
```

> `Status feature` è un riflesso **non-canonico** e advisory (come il mirror di `flow-run`): aggiornalo a mano o in `revise`, ma la verità d'esecuzione resta `PROGRESS.json` + tasks-file dei figli. `whats-next` calcola l'avanzamento reale dai task, non da qui.

---

## Feature figlie — generazione

Ogni feature figlia è un **bundle standard** secondo `../../feature-planner/feature-artifacts.md`: i 4 file (`00-context.md`, `02-abstract.md`, `technical-context.md`, `tasks-active.md`), campo `Feature: <epic>-<feat>`, ID task `<epic>-<feat>-NNN`. Differenze rispetto a una feature standalone:

- **`00-context.md` del figlio** linka all'epic: `**Epic**: <epic>` + `**Dipende da feature**: [...]` (coerente con roadmap).
- **`02-abstract.md` del figlio** non ripete le decisioni condivise: le **referenzia** (`vedi docs/epics/<epic>/02-abstract.md`) e aggiunge solo lo specifico della feature.
- **`tasks-active.md` del figlio** dichiara nel `Definition of done feature` anche il contributo alla DoD epic.

### Propagazione del seed (technical-context)

`code-implementer` carica **solo** il `technical-context.md` della context-root del task (la feature figlia). Quindi le decisioni condivise **devono** comparire nel file del figlio, non solo nel seed epic.

Regola:
1. Alla materializzazione, il `technical-context.md` di ogni figlio è **seedato** dal `technical-context.md` condiviso (copia delle sezioni rilevanti per quella feature + intestazione `> Seed da docs/epics/<epic>/technical-context.md`).
2. `task-implementer` estende il file del **figlio** in append-only durante il flow (come sempre).
3. In `revise <epic>`, una decisione condivisa che cambia va **ri-propagata** ai `technical-context.md` dei figli impattati (append di una nota datata "superseded/aggiornato", non riscrittura silenziosa). Segnala nel diff quali figli sono stati toccati.

> Trade-off accettato: il seed è una **copia**, non un link risolto a runtime. È il prezzo per non toccare il contratto downstream (che legge un solo context-root). La coerenza cross-feature è responsabilità di `epic-planner` (seed + propagazione), non dei downstream.

## Numero di feature

Un epic tipico ha **2–6 feature**. 1 sola → è una feature (`feature-planner`). >~8 feature o serve roadmap di prodotto/milestone → è un progetto (`project-planner`).
