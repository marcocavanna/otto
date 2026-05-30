# Reconcile — stato reale di un task

Determina lo stato d'esecuzione **vero** di ogni task facendo il join tra `.flow/PROGRESS.json` (canonico) e lo `Status` del tasks-file (descrittivo). Read-only: non correggi mai, riporti.

## Gerarchia di verità

Per un task `X`:

1. **Se `X` è in `.flow/PROGRESS.json`** → lo stato canonico è il suo `state` lì: `pending | active | done`.
2. **Altrimenti** → fallback sullo `Status` del tasks-file: `⚪ todo | 🔵 in progress | ✅ done | ⏸ blocked`.

Mappatura per uniformare il ragionamento:

| PROGRESS.json | tasks-file Status | stato riconciliato |
|---|---|---|
| `done` | ✅ done | **done** |
| `active` | 🔵 in progress | **in-progress** |
| `pending` | ⚪ todo | **todo** |
| — | ⏸ blocked | **blocked** (esplicito) |

`blocked` esiste solo nel tasks-file: è uno stato dichiarato dall'utente/planner, non da `flow-run`. Trattalo come non-sbloccabile finché non rimosso.

## Drift — disallineamenti da riportare (mai correggere)

Segnala quando le due fonti **non concordano** sullo stesso ID:

- `PROGRESS.json: done` ma tasks-file `⚪ todo` / `🔵` → tipico **dopo un `expand`**: `project-planner expand` / `feature-planner expand` **sovrascrivono** il tasks-file e azzerano i marker, mentre `PROGRESS.json` resta. Verità = `PROGRESS.json`. Nota: "mirror disallineato post-expand".
- tasks-file `✅ done` ma `PROGRESS.json: pending`/assente → completamento segnato a mano fuori dal flow. Verità incerta: riportalo come **da confermare**, non darlo per fatto.
- `PROGRESS.json: active` ma nessun `RESULT.json` → task lasciato a metà. Candidato forte per "riprendi prima di aprirne altri" (vedi `ranking.md`).

> **Riparazione**: questa sezione *rileva* il drift e non lo corregge mai (read-only). Per *risanarlo* c'è `flow-sync` (`skills/flow-sync/`): riusa questa stessa lettura/classificazione e aggiunge la dimensione di scrittura (safe-repair PROGRESS→file + import conservativo; ambigui/orphan solo segnalati). Preview di default, apply su conferma. Classi e azioni vivono in `flow-sync/references/{reconciliation,apply-protocol}.md` — qui non si duplicano.

## Assenza di `.flow/PROGRESS.json`

Nessun `.flow` = il piano non è ancora mai stato eseguito via `flow-run`. Lo stato d'esecuzione **non è tracciato**: usa solo lo `Status` del tasks-file e dichiaralo esplicitamente nell'output ("stato non tracciato, mi baso sui marker del piano"). Non assumere che `⚪ todo` significhi "mai iniziato a mano".

## Multi-piano e `.flow`

Gli ID sono globalmente unici, quindi un singolo `.flow/PROGRESS.json` può contenere task di source diverse, oppure essere stato (ri)scritto dall'ultimo `flow-run`. Regola: **fidati di `PROGRESS.json` solo per gli ID che effettivamente contiene**; per gli altri usa il fallback. Non assumere che un ID assente significhi `todo` se il tasks-file dice altro.

## Calcolo "sbloccato"

Un task è **sbloccato** sse: stato riconciliato == `todo` **E** ogni ID in `Dipende da` ha stato riconciliato == `done`. `Dipende da: —` → nessuna dipendenza, sbloccato se `todo`. Se una dipendenza punta a un ID inesistente → riportalo come anomalia, considera il task bloccato.
