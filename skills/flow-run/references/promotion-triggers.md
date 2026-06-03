# Promotion triggers — lista chiusa e misurabile

> **Single-source.** Questa è l'unica definizione dei trigger di promozione pre-write `solo → team`.
> Consumata da `agents/solo.md` (step di pre-analisi read-only, prima di qualunque Write/Edit).
> Gli altri file linkano qui; non ridefinire né duplicare questa lista.

## Scopo

L'agente `solo`, prima di toccare il codice, valuta questi trigger in modalità **read-only**
(solo Read / Grep / Glob). Se almeno uno scatta: emette `RESULT.json` con `promote=true` +
`promote_reason` e **termina senza scrivere codice né brief**. `flow-run` ri-esegue il task
in `team` (working tree pulito, idempotente).

Se nessun trigger scatta: la pre-analisi è silenziosa e l'agente prosegue normalmente.

---

## Lista trigger (chiusa)

### T1 — Scope più ampio della complessità ipotizzata

**Criterio**: il task richiederebbe di toccare un numero di file, o un'area del codebase,
incongruente con la `Complessità (ipotesi)` dichiarata nel tasks-file.

**Misura (valutabile read-only)**:
- Su un task classificato `trivial`: più di **3 file** da modificare, **oppure** i file sono
  in un'area del codebase non ovviamente legata al task (es. tocca codice infrastrutturale
  non previsto dal titolo del task).
- Su un task classificato `standard`: più di **6 file** da modificare, oppure i file
  coinvolgono aree cross-feature non citate nel task.
- Fonte dei segnali: segnale 3 di
  [`../../task-implementer/references/complexity-criteria.md`](../../task-implementer/references/complexity-criteria.md)
  (numero file impattati).

**Quando NON scatta**: il conteggio rientra nei limiti sopra e l'area dei file è coerente
con il titolo e la descrizione del task.

---

### T2 — Contratto cross-task non dichiarato

**Criterio**: l'implementazione del task introdurrebbe o modificherebbe un Value Object,
un'interfaccia, un formato di file / contratto (es. schema `RESULT.json`, `ESCALATION.json`,
`meta.json`) consumato da **altri** task non ancora implementati — e questa dipendenza
**non** è già esplicitata nel tasks-file (campo `Dipende da`) o in `technical-context.md`.

**Misura (valutabile read-only)**:
- Identificare i VO / interfacce / formati toccati dal task leggendo il tasks-file e il
  contesto (`00-context.md`, `technical-context.md`).
- Scansionare il tasks-file alla ricerca di altri task `pending` che consumano gli stessi
  artefatti.
- Se esiste almeno un task `pending` che dipende dall'artefatto modificato e la dipendenza
  non è dichiarata → T2 scatta.
- Fonte dei segnali: segnale 1 di `complexity-criteria.md` (il più forte verso `critical`).

**Quando NON scatta**: il contratto toccato è già consumato solo da task già `done`, oppure
la dipendenza è esplicitamente dichiarata nel tasks-file, oppure il task non introduce
nessun contratto nuovo (consume-only di contratti esistenti).

---

### T3 — Contraddizione con `technical-context.md` o `02-abstract.md`

**Criterio**: la comprensione del task (come derivata dalla sua descrizione + DoD +
contesto) confligge con una decisione **vincolante** presente in `technical-context.md`
o `02-abstract.md` della context-root.

**Misura (valutabile read-only)**:
- Leggere `technical-context.md` e `02-abstract.md` (già fatto nell'analisi del task).
- Se l'implementazione richiede di contraddire una decisione marcata come vincolante
  (es. cambiare un'interfaccia congelata, violare un'assunzione dichiarata) senza che
  il tasks-file lo preveda esplicitamente → T3 scatta.
- Giudizio di coerenza: proprietà del PM (`task-implementer`, regola 1).

**Quando NON scatta**: l'implementazione è coerente col contesto accumulato, oppure la
deviazione è già esplicitamente prevista nel tasks-file.

---

### T4 — Ambiguità che richiede una decisione di contratto

**Criterio**: il task, come descritto, lascia aperta una decisione che determina il
contratto pubblico di un artefatto (schema, naming, localizzazione, comportamento
osservabile da altri task) e che l'agente `solo` non può risolvere in sicurezza da solo.

**Misura (valutabile read-only)**:
- La DoD del task o il contesto contiene un punto aperto esplicito (es. "da decidere a
  expand", "candidato", "da allineare") su un aspetto che condiziona ciò che altri task
  consumano.
- Oppure la descrizione del task è ambigua su **quale** comportamento implementare in un
  punto che ha impatto sul contratto.
- L'agente non può risolvere l'ambiguità con la lettura del contesto disponibile.

**Quando NON scatta**: l'ambiguità riguarda solo dettagli d'implementazione interni (naming
di variabile locale, struttura interna di un file non consumata da altri), oppure il
contesto fornisce già una risposta sufficientemente precisa.

---

## Ciò che NON è un trigger di promozione

I fail **post-write** — build/verify falliti, deviazione di scope rilevata a scrittura
**avvenuta**, cambio di contratto emerso durante l'implementazione — **non promuovono mai**.
Restano sul canale escalation esistente (`ESCALATION.json` → step 7 di `flow-run`).

Promuovere dopo una scrittura significherebbe un re-run su working tree sporco
(ASSUMPTION-fast-path-promotion-002). La promozione è il canale **pre-write**; l'escalation
è il canale **post-write**. I due canali sono distinti e non sovrapposti.

| Segnale | Quando | Canale | Esito |
|---|---|---|---|
| `RESULT.promote` | pre-write (nessun codice toccato) | `RESULT.json` | re-run in `team`, working tree pulito |
| `RESULT.escalate` / `verify!=pass` / `ESCALATION.json` | post-write (codice toccato) | step 7 | escalation utente, mai promozione |

---

## Calibrazione (RISK-fast-path-promotion-001)

Bias verso la **rarità**: il planner sovrastima in dubbio (`task-expansion.md`).
I trigger devono scattare solo quando la sottostima è rilevata in modo misurabile,
non per principio di cautela. Un task classificato `standard` che tocca 4 file in
un'area coerente col titolo non promuove.

La taratura di T1 (soglie numeriche) è derivata dal segnale 3 di `complexity-criteria.md`
e può essere aggiustata dopo dogfooding — registrare la deviazione in
`docs/features/fast-path-promotion/technical-context.md`.

---

*Single-source consumata da `agents/solo.md`. Versione: 1. Data: 2026-06-03.*
