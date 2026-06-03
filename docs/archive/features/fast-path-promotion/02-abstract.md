# Abstract tecnico — Feature: Promozione pre-write `solo → team` (`fast-path-promotion`)

> Decisioni condivise dell'epic: **vedi `docs/epics/fast-path/02-abstract.md`** e `docs/epics/fast-path/technical-context.md` (seed). Dipende da `fast-path-solo` (il percorso `solo`, l'agente, il ramo orchestratore). Qui solo lo specifico.

## Approccio (specifico feature)
Tre innesti:

1. **Step di pre-analisi read-only in `agents/solo.md`**. Prima di **qualunque** Write/Edit di codice, l'agente valuta la lista trigger (ASSUMPTION-fast-path-promotion-001: T1 scope, T2 contratto cross-task, T3 contraddizione col contesto vincolante, T4 ambiguità di contratto). La valutazione usa solo Read/Grep/Glob (read-only). È lo **stesso** materiale che l'agente leggerebbe comunque per analizzare il task: il costo marginale è il giudizio esplicito sui trigger, non una lettura extra.

2. **Campo `promote` in `RESULT.json`**. Se un trigger scatta: l'agente scrive `RESULT.json` con `promote=true` + `promote_reason` (quale trigger, con la misura: es. "T1: 5 file impattati su task trivial") e **termina senza scrivere codice né brief**. Se nessun trigger scatta: prosegue come `fast-path-solo` (`promote` assente/false).

3. **Gestione in `flow-run`**. Al ritorno dell'agente `solo`, **prima** del gate del finalize, l'orchestratore controlla `RESULT.promote`:
   - `promote==true` → **re-run del task in `team`**: re-imposta il protocollo per-task standard (spawn `pm` brief → … → finalize) per lo **stesso** task, annota la promozione + il motivo nel summary. Monodirezionale (`solo → team`); il working tree è pulito (pre-write), quindi nessun cleanup.
   - altrimenti → gate del finalize invariato (come `fast-path-solo`).
   - Precedenza: `promote` è valutato **prima** di `escalate`/`verify` perché è il caso pre-write (se l'agente ha promosso, non ha implementato né verificato).

## Distinzione pre-write vs post-write (vincolo)
| Segnale | Quando | Canale | Esito |
|---|---|---|---|
| `RESULT.promote` | **pre-write** (nessun codice toccato) | `RESULT.json` | re-run in `team`, working tree pulito |
| `RESULT.escalate` / `verify!=pass` / `ESCALATION.json` | **post-write** (codice toccato) | step 7 (`AskUserQuestion`) | escalation utente, **mai** promozione |

I fail post-write **non** promuovono mai (ASSUMPTION-fast-path-promotion-002): eviterebbero un re-run su working tree sporco.

## Punti aperti (per l'expand)
- Dove vive la **lista trigger** (reference sotto `skills/flow-run/references/` vs `skills/code-implementer/`): single-source, linkata dall'agente `solo`.
- Schema esatto del campo `promote`/`promote_reason` in `RESULT.json` (allineare al contratto `RESULT.json` esistente letto da `flow-run`).
- Se serve un cap al numero di promozioni per task (verosimilmente no: la promozione è terminale `solo → team`, non iterativa).

## Esclusioni (feature)
- Promozione `inline → solo` (inline fuori scope), `team → solo`, auto-tuning dei trigger.
- Modifica della semantica dei fail post-write.

---
Generato: 2026-06-03 | Versione: 1
