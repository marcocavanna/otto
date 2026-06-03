---
Task: fast-path-solo-001
Feature: fast-path-solo
Origin: feature-planner
Context-root: docs/features/fast-path-solo/
Status: ✅ finalized
---

# fast-path-solo-001 — Mappa `complexity → execution-mode` in `model-tiering.md`

## Obiettivo

Estendere `skills/flow-run/references/model-tiering.md` con la quarta colonna `execution-mode` (valori `{solo, team}`), documentare degrado conservativo e override utente, aggiornare la sezione "Precedenza". Valutare opzionalmente la rinomina del file in `execution-tiering.md`.

## Vincoli risolti

- **`execution-mode` enum**: `{solo, team}` in 2.1.0. `inline` non presente — fuori scope (ASSUMPTION-fast-path-002). Il valore `promote` è aggiunto dalla feature `fast-path-promotion`, non qui.
- **Single-source**: `model-tiering.md` è l'**unico** posto dove `complexity → policy` è definita. La colonna `execution-mode` si aggiunge qui, non altrove. Gli altri file linkano.
- **Degrado conservativo** (ASSUMPTION-fast-path-005 epic): complessità assente, fuori-enum o illeggibile → `execution-mode = team`. MAI `solo` per degrado. Coerente con la logica fail-safe già applicata per modello/dry-run.
- **Override utente** (effimero): es. `"esegui T-003 in team"` / `"forza solo"` → vince sulla mappa, annotato nel summary del run. Non persistito. Stessa meccanica degli override modello/dry-run esistenti.
- **Rinomina file** (`model-tiering.md → execution-tiering.md`): opzionale. Va eseguita **solo se** tutti i link entranti reggono e vengono ripuntati nello stesso task. In caso contrario: aggiornare solo titolo/scopo interni, mantenere il nome. Nessun link orfano residuo dopo l'intervento (grep di verifica obbligatorio).
- **Precedenza**: la sezione esistente va estesa includendo `execution-mode` con la sua posizione gerarchica (override utente > mapping mappa > default `team`).
- Il contratto `complexity ∈ {trivial, standard, critical}` non viene ridefinito qui: è fonte autorevole `skills/planner/references/task-expansion.md` + `planning-source-contract.md`.

## File impattati

- `skills/flow-run/references/model-tiering.md` [edit] — aggiunta tabella `execution-mode`, sezione degrado aggiornata, override utente, Precedenza aggiornata; eventuale rinomina (con reindirizzamento link).
- Se rinomina: tutti i file che linkano `model-tiering.md` [edit] — aggiornamento riferimenti.

> Link entranti rilevati (17 file, da grep): `README.md`, feature/epic `technical-context.md` di `fast-path-*`, `fast-path-promotion/technical-context.md`, `docs/epics/fast-path/`, `skills/flow-run/SKILL.md`, `skills/task-implementer/` (2 file), `skills/migrate/` (3 file). La rinomina è rischiosa per volume: il DEV deve decidere basandosi sul grep a runtime.

## Shape

### Struttura attesa di `model-tiering.md` dopo il task

```markdown
# [Model tiering | Execution tiering] — policy complessità-driven (single source)

> **Single-source.** Questa è l'**unica** definizione delle policy guidate da `complexity`:
> il **modello** dei subagent, il **processo** (dry-run sì/no), e l'**execution-mode** (`solo`/`team`).
> Consumate da `flow-run` (vedi `skills/flow-run/SKILL.md`).

## Mappa

| `complexity` | modello DEV (alias) | dry-run | execution-mode |
|---|---|---|---|
| `trivial`  | `haiku`  | skip | `solo` |
| `standard` | `sonnet` | skip | `solo` |
| `critical` | `opus`   | run  | `team` |

## Precedenza (execution-mode)

override utente > mappa `model-tiering.md` > default `team`

- **override utente**: `"esegui in team"` / `"forza solo"` → effimero, vince su tutto, annotato nel summary.
- **mappa**: risoluzione a runtime da `complexity` via questa tabella.
- **default `team`**: se `meta.json` assente / `complexity` fuori-enum → `team` (fail-safe).

## Degrado graceful — execution-mode

`meta.json` assente / `complexity` fuori-enum / illeggibile → `execution-mode = team`.
MAI `solo` per degrado. `flow-run` annota nel summary quando applica il default.

## Enum execution-mode (2.1.0)

`{solo, team}`. `inline` riservato a release futura (ASSUMPTION-fast-path-002).
```

> Shape, non implementazione finale. La disposizione delle sezioni può variare; l'importante è che i contenuti descritti siano tutti presenti.

## Procedura di implementazione (DEV)

1. **Grep link entranti**: `grep -r "model-tiering" . --include="*.md" -l` → conta e lista i file.
2. **Decisione rinomina**: se i link sono ≤ N facilmente aggiornabili (giudizio del DEV) e tutti puntano al file, eseguire la rinomina + aggiornamento link in un'unica Edit; altrimenti mantenere il nome e aggiornare solo titolo/scopo interni.
3. **Edit `model-tiering.md`** (o `execution-tiering.md`):
   - Aggiorna l'header preamble (`> Single-source.`) aggiungendo `execution-mode`.
   - Aggiungi/trasforma la tabella `## Mappa` in formato a 4 colonne.
   - Aggiungi sezione `## Enum execution-mode (2.1.0)` (valori + nota su `inline`).
   - Aggiorna `## Precedenza` con il ramo `execution-mode`.
   - Aggiorna `## Degrado graceful` aggiungendo la riga `execution-mode = team` per fail-safe.
4. **Verifica link orfani**: `grep -r "model-tiering" . --include="*.md"` (se rinominato: nessun risultato deve puntare al vecchio nome).
5. **Lint visivo**: fence bilanciate, link interni risolvibili, nessuna duplicazione di regole già presenti in altri file.

## Deviazioni durante l'implementazione

- **Rinomina non eseguita**: 18 file `.md` linkano `model-tiering.md`, la maggior parte fuori scope (skills/migrate/*, skills/task-implementer/*, docs/*, README.md, skills/flow-run/SKILL.md). Rinomina avrebbe lasciato link orfani irrisolvibili in questo task. Applicato il fallback: aggiornati titolo/scopo interni, mantenuto il nome del file.
- **Tabella `## Mappa` a 3 colonne** (non 4): `complexity | modello DEV | execution-mode`. La colonna `dry-run` è rimasta nella sua tabella dedicata `## Dry-run` per evitare duplicazione. Contenuto equivalente allo shape, struttura più pulita.
- **Build skipped**: target markdown/skill, nessun build_command applicabile.

## Out of scope per questo task

- Lettura della `Complessità (ipotesi)` dal tasks-file a monte in `flow-run` — task fast-path-solo-003.
- Agente `solo` — task fast-path-solo-002.
- Modifiche alla struttura di `RESULT.json` o `ESCALATION.json`.
- Aggiunta del campo `promote` — feature `fast-path-promotion`.
- Policy dry-run/modello: **non vanno toccate**, la tabella le include per leggibilità ma la logica è già corretta e frozen.
- Rinomina del file **se** comporta link orfani irrisolvibili in questo task (in tal caso: aggiorna solo il titolo interno).
