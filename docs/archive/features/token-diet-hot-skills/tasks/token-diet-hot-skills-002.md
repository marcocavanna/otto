# token-diet-hot-skills-002 — Riscrivere `skills/flow-sync/SKILL.md` (potatura + EN)

**Status: ✅ finalized**
**Origin:** flow-run: epic token-diet, feature hot-skills (full-run)
**Context-root:** docs/features/token-diet-hot-skills/
**Feature:** token-diet-hot-skills

---

## Vincoli risolti

- **Stack**: Markdown + YAML frontmatter. Nessuna dipendenza aggiuntiva.
- **Tool di misura**: `python3 scripts/measure-tokens.py` (proxy char/token ratio: IT 3.4, EN 4.0).
- **Protocollo**: `docs/epics/token-diet/compression-protocol.md` (5 step).
- **Contratti frozen**: trigger-phrase nella `description` invariate; semantica reconciliation (safe-repair PROGRESS→file, import conservativo, preview-default/apply-su-conferma, ambigui/orphan); link a `references/reconciliation.md` e `references/apply-protocol.md` validi.
- **Lingua riscrittura**: inglese per tutta la prosa del body.
- **Naming**: nessuna naming convention introdotta.

---

## File impattati

- `skills/flow-sync/SKILL.md` [edit]

---

## Shape reale (post-implementazione)

Struttura a sezioni Markdown:

```
# Flow Sync — reconcile/repair state drift
  (paragrafo intro, 2 righe)

## Principles (non-negotiable)
  (5 bullet: PROGRESS-per-source, archived, root-fallback, safe-drift, import)
  (riferimento a references/reconciliation.md e apply-protocol.md)

## Scope and modes
  (tabella scope: global/plan/feature/task)
  (nota slug ambiguo + context-root via scan)
  (2 bullet: preview/apply)

## Protocol
  (4 step numerati: discovery/reconciliation/preview/apply)
  (nota finale su references)

## Epic roadmap reconciliation (additive)
  (4 bullet: epic-discovery, expected-state, classification, write-scope)

## Output (board + commands)
  (tabella ASCII esempio)
  (nota derivazioni)

## Honesty rules on gaps
  (3 bullet: PROGRESS assente, tasks-file non riconoscibile, drift post-expand)

## What flow-sync does NOT do
  (6 bullet negativi)
```

Shape, non implementazione finale.

---

## Gate report

### Gate report — skills/flow-sync/SKILL.md

Baseline pre-riscrittura: 2026-06-04 (scripts/token-baseline.json)
Checklist edge-case: 38 voci estratte

| EC | Esito | Note |
|----|-------|------|
| EC-001 | OK | preview default: "writes nothing" + description invariata |
| EC-002 | OK | "only on explicit confirmation after preview" |
| EC-003 | OK | §Principles: PROGRESS-per-source, IDs in tasks[] → state |
| EC-004 | OK | archived=true → all tasks done, no repair/import, in-sync |
| EC-005 | OK | root fallback: solo se per-source assente |
| EC-006 | OK | auto solo su safe-repair + import, tutto il resto report-only |
| EC-007 | OK | import: solo ✅ done assenti, marcati imported |
| EC-008 | OK | import sempre in preview prima di apply |
| EC-009 | OK | matrix non ridefinita: references/reconciliation.md |
| EC-010 | OK | scope global/plan/feature/task (tabella) |
| EC-011 | OK | slug ambiguo → list and ask |
| EC-012 | OK | context-root via scan + opaque IDs |
| EC-013 | OK | root fallback se no per-source directory (§Protocol step 1) |
| EC-014 | OK | archived=true → skip + log |
| EC-015 | OK | no active plan → say so, suggest planner, do not invent |
| EC-016 | OK | riconciliazione riusa whats-next/references/reconcile.md |
| EC-017 | OK | apply secondo apply-protocol.md sequence |
| EC-018 | OK | current_task untouched |
| EC-019 | OK | roadmap: activates only if source belongs to epic |
| EC-020 | OK | epic discovery via glob + Source: docs/features/<slug>/ |
| EC-021 | OK | 0 matches → standalone skip; >1 → anomaly report no writes |
| EC-022 | OK | stati attesi: all done → ✅; at least one started → 🔵; none → ⚪ |
| EC-023 | OK | file ahead → ambiguous → report only, never retrograde |
| EC-024 | OK | apply tocca solo riga "Status feature" nel blocco feature |
| EC-025 | OK | roadmap assente/blocco non locatable → skip and signal |
| EC-026 | OK | backup come per tasks-files |
| EC-027 | OK | board classificazione per-task (tabella ASCII) |
| EC-028 | OK | preview: board + diffs/entries + command to proceed |
| EC-029 | OK | PROGRESS assente/unreadable → no safe-repair/import su source |
| EC-030 | OK | PROGRESS illeggibile in apply → ABORT per source, 0 writes |
| EC-031 | OK | tasks-file non riconoscibile → salta task, non blocca apply |
| EC-032 | OK | drift post-expand contestualizzato: PROGRESS durable state |
| EC-033 | OK | non inizializza PROGRESS (owned by flow-run) |
| EC-034 | OK | non esegue/espande task (owned by flow-run/planner) |
| EC-035 | OK | non scrive codice, non committa, non riformatta |
| EC-036 | OK | non altera current_task, briefs, altre righe tasks-file |
| EC-037 | OK | non decide priorità cross-plan né raccomanda next |
| EC-038 | OK | non retrocede mai un marker: file ahead → ambiguous → report |

Diff semantico sezioni ad alto rischio:
- §principles (PROGRESS-per-source, archived, fallback, safe-repair, import): EQUIVALENTE (EN, lista puntata)
- §import-conservativo: EQUIVALENTE (EN, condensato in bullet)
- §protocol (discovery, archived check, reconciliation, apply): EQUIVALENTE (EN, lista numerata)
- §roadmap-reconciliation (scoperta, stati, classificazione, write-scope): EQUIVALENTE (EN, lista puntata)
- §honesty-gaps (PROGRESS assente, tasks-file invalido, post-expand): EQUIVALENTE (EN, lista puntata)
- §cosa-non-fa (6 vincoli negativi): EQUIVALENTE (EN, lista puntata)
- §references-link (reconciliation.md, apply-protocol.md, reconcile.md): INVARIATO

Delta token:
- description: 280 → 280 (+0 tok, 0.0%)
- body:        2724 → 1773 (−951 tok, −34.9%)
- totale:      3004 → 2053 (−951 tok, **−31.7%**)

Esito gate: PASS

---

## Deviazioni

Nessuna deviazione rispetto al piano.

---

## Compression notes

Nessuna anomalia rilevata nel file originale.
