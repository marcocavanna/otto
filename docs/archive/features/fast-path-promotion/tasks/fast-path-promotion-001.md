---
Task: fast-path-promotion-001
Feature: fast-path-promotion
Context-root: docs/features/fast-path-promotion/
Origin: flow-run (solo, fast-path)
Status: ✅ finalized
---

# fast-path-promotion-001 — Lista trigger di promozione (reference single-source)

## Vincoli risolti

**Stack / tooling**
- Nessuna libreria di terze parti. Tooling: Markdown puro (nessun runtime).
- Nessun build command. Verifica = lint strutturale + coerenza con i reference linkati.

**Interfacce / contratti consumati**
- `skills/task-implementer/references/complexity-criteria.md` — segnali 1 e 3 (linkati, non duplicati).
- Schema `RESULT.json` (`promote`, `promote_reason`) — consumato da 002; schema non definito qui, definito da 002.
- `ASSUMPTION-fast-path-promotion-001/002/003` da `00-context.md` — vincolanti sul confine pre/post-write e sulla direzionalità `solo → team`.

**Collocazione decisa**
- Reference: `skills/flow-run/references/promotion-triggers.md` (punto aperto in `02-abstract.md`
  risolto: la lista è parte del flusso `flow-run`, non di `code-implementer`).
- Rationale: i trigger sono valutati dall'agente `solo` prima del ramo `team` (step S2 in `flow-run`);
  collocarli sotto `flow-run/references/` è coerente con il punto di consumo.

**Naming / convenzioni**
- Trigger identificati come T1–T4 (enum stabile, consumato da 002 per `promote_reason`).
- Soglie T1: `>3 file` su `trivial`, `>6 file` su `standard` (calibrabili via dogfooding).

## File impattati

| Path | Flag |
|---|---|
| `skills/flow-run/references/promotion-triggers.md` | [new] |
| `docs/features/fast-path-promotion/tasks/fast-path-promotion-001.md` | [new] |

## Shape reale

```markdown
# promotion-triggers.md (shape, non implementazione finale)

## Lista trigger (chiusa)

### T1 — Scope più ampio della complessità ipotizzata
Criterio + misura (>3 file su trivial, >6 su standard) + link a complexity-criteria.md segnale 3.

### T2 — Contratto cross-task non dichiarato
Criterio + misura (task pending che consuma l'artefatto modificato) + link a complexity-criteria.md segnale 1.

### T3 — Contraddizione con technical-context.md / 02-abstract.md
Criterio + misura (giudizio di coerenza, rimanda al PM).

### T4 — Ambiguità che richiede una decisione di contratto
Criterio + misura (punto aperto esplicito su aspetto che impatta altri task).

## Ciò che NON è un trigger di promozione
Fail post-write → ESCALATION.json, mai promote.
Tabella pre-write vs post-write (allineata a 02-abstract.md § Distinzione).

## Calibrazione
Bias rarità + riferimento a RISK-fast-path-promotion-001.
```

(~20 righe di struttura; il file reale è `skills/flow-run/references/promotion-triggers.md`.)

## Deviazioni

- **Soglie T1 per `standard` aggiunte** (non esplicitate nella DoD, ma necessarie per non lasciare
  il trigger privo di misura su task `standard`; la DoD cita solo il caso `trivial` come esempio).
  Deviazione locale, non cross-task: il valore `>6` è calibrabile e registrato per dogfooding.
- **Build skipped**: nessun build command dichiarato per questa feature. Verifica eseguita
  strutturalmente (link presenti, enum T1–T4 completo, sezione "Non promuove" presente, tabella
  pre/post-write allineata a `02-abstract.md`).
