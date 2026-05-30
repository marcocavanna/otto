# Reconciliation — matrice read+write del drift di stato

Matrice canonica di `flow-sync`: per ogni combinazione `(PROGRESS.state, tasks-file Status)` assegna una **classe** e un'**azione** deterministica. È il cuore decisionale della skill (*cosa* decidere); il *come* scrivere vive in `apply-protocol.md`. Reference dichiarativa: nessun runtime, solo specifica.

## Base di lettura (riuso, non duplicare)

Riusa la **gerarchia di verità** e la **mappatura stati** di `../../whats-next/references/reconcile.md`:

- **PROGRESS arbitro per gli ID che contiene**: se l'ID è in `.flow/PROGRESS.json`, lo stato canonico è il suo `state` lì. Solo per gli ID *assenti* si fa fallback sullo `Status` del tasks-file.
- Mappatura per ID presenti in entrambe le fonti: `pending ↔ ⚪ todo`, `active ↔ 🔵 in progress`, `done ↔ ✅ done`. `⏸ blocked` esiste **solo** nel tasks-file (stato dichiarato da utente/planner, mai prodotto da `flow-run`).
- Drift già enumerati lì (post-`expand`, done manuale, active a metà): qui si **estendono** con la dimensione di scrittura (classe + azione). La logica di lettura non si ridiscute né si riduplica.

Questa reference aggiunge **solo** la dimensione di scrittura. Per stabilire *quale* sia la verità di lettura, l'autorità resta `reconcile.md`.

## Domini degli assi

- `PROGRESS.state` ∈ `{ pending, active, done, ASSENTE }` — `ASSENTE` = ID non presente in `PROGRESS.tasks[]`.
- `tasks-file Status` ∈ `{ ⚪ todo, 🔵 in progress, ✅ done, ⏸ blocked, MANCANTE }` — `MANCANTE` = ID non presente nel tasks-file.

Progressione naturale (ordine totale usato per "avanti/indietro"): `todo (0) → in-progress (1) → done (2)`. `⏸ blocked` è **fuori** dalla progressione (non confrontabile per livello).

## Classi e azioni

| Classe | Quando | Azione |
|---|---|---|
| **in-sync** | le due fonti concordano sulla progressione | nessuna |
| **safe-repair** | entrambe presenti, PROGRESS *avanti*, file *indietro* nella progressione | **apply** (riflette PROGRESS sul file) |
| **import** | file `✅ done` ma ID **ASSENTE** in PROGRESS | **import** (aggiunge entry `done` a PROGRESS) |
| **ambiguous** | entrambe presenti e discordi in modo non risolvibile per progressione | **report** (mai sovrascrivere) |
| **orphan** | ID in PROGRESS ma **MANCANTE** nel file, o dipendenza → ID inesistente | **report** (anomalia) |

Regola direzionale (da `00-context.md` ASSUMPTION-flow-sync-001, `02-abstract.md` § Approccio): default PROGRESS→file (mirror, solo quando PROGRESS è avanti); file→PROGRESS **solo** per `done` assenti (import). La matrice *codifica* questa scelta, non la ridiscute.

## Matrice classe × azione

Righe = `PROGRESS.state`, colonne = `tasks-file Status`. Cella = `classe → azione`.

```text
                 | ⚪ todo (0)        | 🔵 in prog (1)    | ✅ done (2)        | ⏸ blocked        | MANCANTE
-----------------|-------------------|-------------------|-------------------|------------------|-------------------
pending (0)      | in-sync → nessuna | ambiguous → report| ambiguous → report| ambiguous → report| orphan → report
active  (1)      | safe-repair→apply | in-sync → nessuna | ambiguous → report| ambiguous → report| orphan → report
done    (2)      | safe-repair→apply | safe-repair→apply | in-sync → nessuna | ambiguous → report| orphan → report
ASSENTE          | (fallback lettura)| (fallback lettura)| import → import   | report (blocked) | (n/d)
```

Lettura della matrice:

- **Triangolo inferiore** (PROGRESS avanti, file indietro): le 3 celle `active×⚪`, `done×⚪`, `done×🔵` → **safe-repair**. Sono gli unici casi in cui si scrive sul file.
- **Diagonale**: `in-sync`.
- **Triangolo superiore** (file avanti rispetto a PROGRESS, es. `pending×🔵`, `active×✅`, `pending×✅`): **ambiguous**. PROGRESS è arbitro e dichiara uno stato *più indietro* del file → discordanza non risolvibile per mirror (riflettere PROGRESS sul file *retrocederebbe* il marker, mai consentito). Solo report.
- **Colonna `⏸ blocked`**: sempre **ambiguous** quando PROGRESS è presente con qualunque stato (blocked è dichiarazione esplicita, fuori progressione, mai sovrascritta). Con PROGRESS ASSENTE: **report** (blocked non è importabile).
- **Colonna `MANCANTE`** con PROGRESS presente: **orphan** (l'ID esiste nel loop ma il tasks-file non lo elenca più — tipica perdita post-`expand`).
- **Riga `ASSENTE`** su `⚪/🔵`: nessuna azione di scrittura. Per gli ID assenti da PROGRESS la verità di lettura è il tasks-file stesso (`reconcile.md` § "Multi-piano e `.flow`"): non c'è drift da risanare, solo stato non tracciato dal flow. L'unico caso che *agisce* è `✅` → import.
- `ASSENTE × MANCANTE`: ID inesistente in entrambe le fonti → fuori dominio (`n/d`).

## I 3 casi safe-repair (PROGRESS avanti, file indietro → apply)

Sono **esattamente tre**, e solo questi producono scrittura sul tasks-file:

1. `done × ⚪ todo` — PROGRESS completato, file mai aggiornato. Caso tipico **post-`expand`** (l'expand riscrive il tasks-file e azzera i marker a `⚪`, mentre `PROGRESS.json` resta `done`). → file `✅ done`.
2. `done × 🔵 in progress` — PROGRESS completato, file fermo a "in corso". → file `✅ done`.
3. `active × ⚪ todo` — PROGRESS in esecuzione, file ancora a todo. → file `🔵 in progress`.

Direzione **sempre** PROGRESS→file, **solo in avanti** nella progressione. Nessun altro accoppiamento è safe-repair: se il file è *avanti* su PROGRESS, è ambiguous (vedi sopra), perché riflettere significherebbe far *retrocedere* il marker.

## Regola import (✅ in file + ASSENTE in PROGRESS → import; e SOLO questo)

Unico caso file→PROGRESS. Condizione necessaria e sufficiente:

> il tasks-file marca l'ID `✅ done` **e** l'ID **non compare** in `PROGRESS.tasks[]`.

Azione: aggiunge a `PROGRESS.json` una entry conforme `{ "id": "<id>", "state": "done" }`, **senza alterare `current_task`** (vincolo da `technical-context.md` § Value Objects e RISK-flow-sync-002). Conservativo: marcato `imported`, sempre visibile in preview prima dell'apply (RISK-flow-sync-001 — non ufficializzare un `done` non verificato).

Nessun altro Status assente produce import: `ASSENTE × ⚪/🔵` resta non tracciato (nessuna scrittura), `ASSENTE × ⏸ blocked` è report, `ASSENTE × MANCANTE` è fuori dominio. L'import **non** promuove mai a `done` uno stato diverso da `✅`.

## ASSENTE ≠ CONFLITTO

L'assenza di **una** delle due fonti non è **mai** `ambiguous`. L'ambiguità nasce solo quando *entrambe* le fonti sono presenti e discordi in modo non risolvibile per progressione.

- ID presente nel file ma ASSENTE in PROGRESS → **import** (se `✅`) oppure **nessuna azione/fallback lettura** (se `⚪/🔵`) oppure **report** (se `⏸ blocked`). Mai ambiguous.
- ID presente in PROGRESS ma MANCANTE nel file → **orphan** → report. Mai ambiguous.

Motivazione: `ambiguous` significa "due verità presenti e in conflitto, non sovrascrivere". Con una sola fonte non c'è conflitto da arbitrare: c'è o un'integrazione conservativa (import) o un'anomalia da segnalare (orphan). Tenere distinti questi tre concetti evita che l'assenza di dato venga trattata come discordanza e blocchi azioni sicure (import) o ne inneschi di sbagliate (sovrascrittura).

## Orphan (ID in PROGRESS ma MANCANTE nel file; dipendenza → ID inesistente)

Due sorgenti di orphan, entrambe → **report** (mai scrittura):

1. **ID nel loop senza riga nel tasks-file** — `PROGRESS.tasks[]` contiene l'ID ma nessun tasks-file lo elenca. Probabile perdita da `expand` che ha rigenerato il file rimuovendo il task. Anomalia: il loop traccia uno stato per un task che il piano non descrive più.
2. **Dipendenza verso ID inesistente** — un task dichiara `Dipende da: <id>` ma `<id>` non esiste in nessuna fonte (né PROGRESS né tasks-file). Coerente con `reconcile.md` § "Calcolo sbloccato": dipendenza verso ID inesistente → anomalia, task considerato bloccato.

In entrambi i casi `flow-sync` **non corregge**: elenca l'anomalia perché la risoluzione richiede l'intervento del planner (`expand`/revise), fuori dallo scope di una skill di sola riconciliazione di stato.

## Riepilogo azioni

- **apply** (PROGRESS→file): solo i 3 casi safe-repair.
- **import** (file→PROGRESS): solo `✅` + ASSENTE.
- **nessuna**: in-sync, e `ASSENTE × ⚪/🔵` (fallback di lettura).
- **report**: ambiguous + orphan + `ASSENTE × ⏸ blocked`.

`apply` e `import` sono auto-applicabili (su conferma, modalità apply); `report` è solo elencato, mai scritto. Coerente con ASSUMPTION-flow-sync-002 (ripara i sicuri, segnala gli ambigui) e ASSUMPTION-flow-sync-003 (preview di default).
