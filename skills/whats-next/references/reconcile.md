# Reconcile — stato reale di un task

Determina lo stato d'esecuzione **vero** di ogni task facendo il join tra le fonti per-source e lo `Status` del tasks-file (descrittivo). Read-only: non correggi mai, riporti.

## Gerarchia di verità

Per un task `X` in source `<slug>`:

1. **Se `index.json` esiste e contiene `<slug>`:**
   - `archived=true` → source done congelata: tutti i suoi task sono `done`. Non aprire il `tasks-active.md` per task attivi; è legacy-reference per il rollup epic (vedi `epic-rollup.md`).
   - `alive=true, active=X` → X è in-progress per quella source.
   - Usa `{done, pending}` come contatori per il board; non come verità per-task (quella viene dal PROGRESS per-source).
2. **Se `.flow/sources/<slug>/PROGRESS.json` esiste** → stato canonico per ogni ID lì: `pending | active | done`.
3. **Se `.flow/PROGRESS.json` legacy esiste e contiene `X`** → usa quel dato per ID non presenti in nessuna source per-source (retrocompat per progetti non ancora migrati).
4. **Fallback finale** → `Status` del tasks-file: `⚪ todo | 🔵 in progress | ✅ done | ⏸ blocked`.

> Segnala drift se `index.json` e il PROGRESS per-source discordano sul medesimo ID (index è cache, PROGRESS per-source è verità).

Mappatura per uniformare il ragionamento:

| PROGRESS per-source (o legacy) | tasks-file Status | stato riconciliato |
|---|---|---|
| `done` | ✅ done | **done** |
| `active` | 🔵 in progress | **in-progress** |
| `pending` | ⚪ todo | **todo** |
| — | ⏸ blocked | **blocked** (esplicito) |

`blocked` esiste solo nel tasks-file: è uno stato dichiarato dall'utente/planner, non da `flow-run`. Trattalo come non-sbloccabile finché non rimosso.

## Drift — disallineamenti da riportare (mai correggere)

Segnala quando le fonti **non concordano** sullo stesso ID:

- `PROGRESS per-source: done` ma tasks-file `⚪ todo` / `🔵` → tipico **dopo un `expand`**: `project-planner expand` / `feature-planner expand` **sovrascrivono** il tasks-file e azzerano i marker, mentre il PROGRESS per-source resta. Verità = PROGRESS per-source. Nota: "mirror disallineato post-expand".
- tasks-file `✅ done` ma PROGRESS per-source `pending` / assente → completamento segnato a mano fuori dal flow. Verità incerta: riportalo come **da confermare**, non darlo per fatto.
- PROGRESS per-source `active` ma nessun `RESULT.json` → task lasciato a metà. Candidato forte per "riprendi prima di aprirne altri" (vedi `ranking.md`).
- `index.json` discorda da PROGRESS per-source sullo stesso ID → index è cache; verità = PROGRESS per-source. Segnala il disallineamento.

> **Riparazione**: questa sezione *rileva* il drift e non lo corregge mai (read-only). Per *risanarlo* c'è `flow-sync` (`skills/flow-sync/`): riusa questa stessa lettura/classificazione e aggiunge la dimensione di scrittura (safe-repair PROGRESS→file + import conservativo; ambigui/orphan solo segnalati). Preview di default, apply su conferma. Classi e azioni vivono in `flow-sync/references/{reconciliation,apply-protocol}.md` — qui non si duplicano.

## Assenza di `.flow/`

Nessun `.flow/index.json` né `.flow/sources/` né `.flow/PROGRESS.json` = il piano non è ancora mai stato eseguito via `flow-run`. Lo stato d'esecuzione **non è tracciato**: usa solo lo `Status` del tasks-file e dichiaralo esplicitamente nell'output ("stato non tracciato, mi baso sui marker del piano"). Non assumere che `⚪ todo` significhi "mai iniziato a mano".

## Multi-source e `.flow`

Gli ID sono globalmente unici. Ogni source ha il proprio `PROGRESS.json` sotto `.flow/sources/<slug>/`. Il legacy `.flow/PROGRESS.json` singleton può contenere task di source diverse (pre-migrazione). Regola: **per ogni ID, fidati del PROGRESS della sua source** se presente; usa il legacy solo per ID non ancora migrati; per tutti gli altri usa il fallback del tasks-file. Non assumere che un ID assente significhi `todo` se il tasks-file dice altro.

## Calcolo "sbloccato"

Un task è **sbloccato** sse: stato riconciliato == `todo` **E** ogni ID in `Dipende da` ha stato riconciliato == `done`. `Dipende da: —` → nessuna dipendenza, sbloccato se `todo`. Se una dipendenza punta a un ID inesistente → riportalo come anomalia, considera il task bloccato.
