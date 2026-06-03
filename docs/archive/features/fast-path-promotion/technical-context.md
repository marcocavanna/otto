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

### DECISION-fast-path-promotion-001 — Collocazione reference lista trigger
- **Decisione**: il reference `promotion-triggers.md` è collocato in `skills/flow-run/references/`.
- **Rationale**: i trigger sono valutati dall'agente `solo` **prima** del ramo `team` (step S2 in `flow-run`); la collocazione è coerente col punto di consumo. Alternativa scartata: `skills/code-implementer/` (il file non è consumato dal DEV ma dall'agente solo come pre-analisi del ramo flow-run).
- **Impatta**: `agents/solo.md` (link da includere), `skills/flow-run/SKILL.md` (già referenzia `references/`). **Data**: 2026-06-03

### DECISION-fast-path-promotion-002 — Soglie numeriche T1
- **Decisione**: T1 misura `>3 file` su task `trivial`, `>6 file` su task `standard`. Calibrabili via dogfooding.
- **Rationale**: soglie derivate dal segnale 3 di `complexity-criteria.md` (`>3` file = alto); su `standard` la soglia è alzata perché il task per definizione ha estensione media (2-3 file) e il bias deve essere verso la rarità (RISK-fast-path-promotion-001).
- **Impatta**: `skills/flow-run/references/promotion-triggers.md` § T1. **Data**: 2026-06-03

## Librerie e versioni
Nessuna libreria di terze parti. Tooling: `bash`, `jq`, `git`.

---
Generato: 2026-06-03 | Versione: 1
