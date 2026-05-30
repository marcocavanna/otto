# Apply protocol — scrittura sicura del repair di stato

Specifica *come* `flow-sync` **scrive** in modalità `apply`. Consuma la classificazione di `./reconciliation.md` (*cosa* fare per ogni task) e definisce la **sequenza ordinata**, le **guardie** e i **side effect ammessi** della fase di scrittura. Reference dichiarativa: nessun runtime, solo specifica del protocollo d'esecuzione — non lo implementa.

## Ambito

Scrive **solo** per le due azioni auto-applicabili di `./reconciliation.md`:

- `apply` (safe-repair) → riflette `PROGRESS.state` sulla **sola riga `Status`** del task nel tasks-file della source. Esattamente i 3 casi safe-repair (`done×⚪`, `done×🔵`, `active×⚪`).
- `import` (`✅ done` nel file + ID **ASSENTE** in `PROGRESS.json`) → aggiunge una entry `{ "id": "<id>", "state": "done" }` a `PROGRESS.tasks[]`.

`report` (ambiguous, orphan, `ASSENTE × ⏸ blocked`) **non scrive mai**: è solo elencato. `in-sync` e `ASSENTE × ⚪/🔵` non producono alcuna azione.

Non riclassifica nulla: la matrice `(PROGRESS.state × tasks-file Status) → (classe, azione)` è autorità di `./reconciliation.md`. Qui si esegue ciò che è già `apply`/`import`.

**Default = preview.** Senza conferma esplicita dell'utente, `flow-sync` mostra il piano e non scrive (ASSUMPTION-flow-sync-003, `00-context.md`).

## Preview (default)

La preview enumera, per ogni task in scope, cosa accadrebbe — **senza scrivere nulla**:

- **safe-repair** → `(<id>, classe, apply)` con il **diff della riga `Status`**: `- **Status**: <prima>` → `- **Status**: <dopo>`.
- **import** → `(<id>, classe, import)` con la **entry proposta** `{ "id": "<id>", "state": "done" }` da appendere a `PROGRESS.tasks[]`, marcata `imported` (RISK-flow-sync-001: un `done` non verificato deve essere visibile prima dell'apply).
- **ambiguous** / **orphan** / `ASSENTE × ⏸ blocked` → elencati come **"non toccati"**, con la ragione. Nessun diff, nessuna proposta di scrittura.

`apply` avviene **solo** su conferma esplicita successiva alla preview. La preview è read-only al 100%.

## Apply — sequenza ordinata

L'ordine è vincolante (fail-closed: la guardia globale precede ogni scrittura).

0. **Guardia globale — PROGRESS.json.** Leggi e valida `.flow/PROGRESS.json` contro lo schema `{ "current_task": "<id>", "tasks": [ { "id", "state" } ] }` (`technical-context.md` § Value Objects). Validazione con `python3 -m json.tool` / `jq`. Se illeggibile o schema non valido → **ABORT totale**, **0 scritture** (RISK-flow-sync-002). Segnala il rifiuto, non toccare nulla.
1. **Backup.** Per ogni tasks-file che verrà toccato da almeno un safe-repair: crea `<tasks-file>.bak` **una sola volta** prima della prima modifica a quel file (ASSUMPTION-flow-sync-004, coerente con `expand`). Un tasks-file senza safe-repair non viene né toccato né backuppato.
2. **safe-repair (PROGRESS→file).** Per ogni task `apply`: individua il blocco del task per ID nel tasks-file, riscrivi **solo** la riga `- **Status**: ...`. La derivazione `PROGRESS.state → emoji+label` è quella di `./reconciliation.md` / `technical-context.md` § Value Objects ("Riga Status tasks-file") — non ridefinita qui. Nessun'altra riga del blocco né del file viene toccata.
3. **import (file→PROGRESS).** Per ogni task `import`: appendi `{ "id": "<id>", "state": "done" }` a `PROGRESS.tasks[]`. `current_task` **INTOCCATO** (RISK-flow-sync-002). Nessun altro campo modificato.
4. **Persisti e rivalida.** Scrivi `PROGRESS.json` preservando schema e ordine delle chiavi; rivalida l'output (`python3 -m json.tool` / `jq`). Se la rivalidazione fallisce, segnala come anomalia (il `.bak` dei tasks-file e lo stato pre-scrittura restano la rete di recupero).

## Guardie

| condizione | azione | effetto |
|---|---|---|
| `PROGRESS.json` illeggibile / schema invalido | **ABORT totale** | 0 scritture, rifiuto segnalato (RISK-flow-sync-002) |
| tasks-file in formato non riconoscibile | **skip quel task** | segnala, nessuna scrittura su quel file (RISK-flow-sync-003) |
| riga `Status` del task non individuabile | **skip quel task** | segnala, nessuna scrittura (read-only come `whats-next`) |
| stato già allineato (in-sync) | **no-op** | nessun diff, nessun backup (idempotenza) |
| azione = `report` (ambiguous / orphan / `ASSENTE × ⏸ blocked`) | **nessuna scrittura** | solo elencato in preview/output |

Le guardie 2 e 3 sono **per-task**: un tasks-file anomalo o una riga `Status` non individuabile salta *quel* task, non l'intero apply (a differenza della guardia globale 0). Comportamento identico al read-only di `whats-next` (RISK-flow-sync-003).

## Idempotenza

Ri-eseguire `apply` su uno stato già allineato è un **no-op**:

- Un task `in-sync` non genera né diff né backup del suo tasks-file.
- Un `import` già presente in `PROGRESS.tasks[]` non è più `import` (l'ID non è più ASSENTE → la matrice lo riclassifica): nessun append duplicato.
- Una riga `Status` già al valore target non viene riscritta (nessun diff).

Conseguenza: `apply` su un progetto già in-sync non crea backup, non modifica file, non altera `PROGRESS.json`. Eseguibile ripetutamente senza effetti cumulativi.

## Contratto di scrittura della riga Status

```text
# nel tasks-file, individua il blocco del task per ID, poi modifica SOLO:
- **Status**: <emoji+label derivata da PROGRESS.state>   # unica riga modificata
# nessun'altra riga del blocco né del file viene toccata
```

Le derivazioni `PROGRESS.state → emoji/label` (`active → 🔵 in progress`, `done → ✅ done`) provengono da `./reconciliation.md` § "Base di lettura" e `technical-context.md` § Value Objects: **non ridefinirle qui**, citarle. Solo il sottoinsieme safe-repair è in gioco: la scrittura porta sempre il marker *in avanti* nella progressione `todo→in-progress→done`, mai indietro.

## Cosa NON tocca

- **`current_task`** in `PROGRESS.json`: mai alterato, nemmeno durante l'import (RISK-flow-sync-002).
- **Righe del tasks-file diverse dalla riga `Status`** del task in scope: mai toccate. Nessun refactoring del file, nessuna riformattazione.
- **`docs/tasks/<id>.md`** (namespace dei brief): mai toccato (`02-abstract.md` § Contratti da preservare).
- **Retrocessione di un marker**: vietata per costruzione — il protocollo scrive solo dove `./reconciliation.md` ha classificato `apply`/`import`, ovvero solo in avanti nella progressione. Se il file è *avanti* su PROGRESS → la matrice è `ambiguous` → `report`, qui non si scrive.

## Riferimenti

- Classificazione consumata: `./reconciliation.md` (matrice classe × azione; 3 casi safe-repair; regola import; ASSENTE ≠ CONFLITTO; orphan).
- Contratti vincolanti: `../../../docs/features/flow-sync/technical-context.md` § Value Objects (schema `PROGRESS.json`, riga `Status`).
- Assunzioni: ASSUMPTION-flow-sync-003 (preview di default), ASSUMPTION-flow-sync-004 (backup + scrittura idempotente sola riga Status) — `00-context.md`.
- Rischi mitigati: RISK-flow-sync-002 (corruzione stato loop → no `current_task`, backup, idempotenza, rifiuto se illeggibile), RISK-flow-sync-003 (tasks-file anomalo → skip+segnala), RISK-flow-sync-001 (import marcato `imported`, visibile in preview).
- Convenzione mirror riusata: `../../flow-run/SKILL.md` § "Mirror status sul tasks-file della source".
