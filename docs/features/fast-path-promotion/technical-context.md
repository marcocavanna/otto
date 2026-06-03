# Technical context — Feature: Promozione pre-write `solo → team` (`fast-path-promotion`)

<!-- Anchor -->
**Tier**: feature
**Parent**: fast-path
**Bubble-up target**: docs/epics/fast-path/technical-context.md

> Seed da docs/epics/fast-path/technical-context.md
> Sezioni ereditate dal seed condiviso (vincolanti). Estensione append-only durante il flow; bubble-up al padre a `planner finalize`.

## Convenzioni di progetto
### Build & test
- build_command: `—`.
- test_command: `—` — verifica = dogfooding (task sottostimato → promozione osservabile) + lint reference.

## Pattern architetturali condivisi (dal seed epic)
- **Pre-write vs post-write**: l'escalation esistente (`ESCALATION.json` → step 7) è il canale **post-write**; la promozione (`RESULT.promote`) è il canale **pre-write**. Distinti e non sovrapposti.
- **Derivazione effimera dell'orchestratore**: la promozione non persiste nulla di durevole (è pre-write, working tree pulito).
- **Trigger misurabili**: modellati sui segnali di `skills/task-implementer/references/complexity-criteria.md` (segnale 1 = contratto cross-task; segnale 3 = numero file), valutati read-only.

## Value Objects / contratti condivisi (dal seed epic)
- **`RESULT.json`**: questa feature aggiunge i campi **`promote`** (bool) e **`promote_reason`** (stringa: trigger + misura). Letti da `flow-run` **prima** di `escalate`/`verify`. Schema esatto: da fissare a expand, allineato al contratto `RESULT.json` esistente.
- **`execution-mode`** `{solo, team}`: la promozione è la transizione `solo → team` (monodirezionale).
- **`complexity`** e **artefatti versionati**: invariati, consumati dal seed.

## Decisioni tattiche (fast-path-promotion)
> Append-only durante il flow. Vuota alla pianificazione: schema di `promote`, posizione del reference trigger, esiti del dogfooding di taratura si registrano qui.

_(nessuna decisione tattica ancora registrata)_

## Librerie e versioni
Nessuna libreria di terze parti. Tooling: `bash`, `jq`, `git`.

---
Generato: 2026-06-03 | Versione: 1
