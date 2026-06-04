# token-diet-hot-skills-001 — Riscrivere `skills/task-implementer/SKILL.md` (potatura + EN)

**Status: ✅ finalized**
**Origin:** flow-run: epic token-diet, feature hot-skills (full-run)
**Context-root:** docs/features/token-diet-hot-skills/
**Feature:** token-diet-hot-skills

---

## Vincoli risolti

- **Stack**: Markdown + YAML frontmatter. Nessuna dipendenza aggiuntiva.
- **Tool di misura**: `python3 scripts/measure-tokens.py` (proxy char/token ratio: IT 3.4, EN 4.0).
- **Protocollo**: `docs/epics/token-diet/compression-protocol.md` (5 step).
- **Contratti frozen**: trigger-phrase nella `description` invariate; sezioni obbligatorie del brief (`Vincoli risolti`, `Status: ✅ finalized`) preservate; schema `RESULT.json`/`ESCALATION.json` non toccati.
- **Lingua riscrittura**: inglese per tutta la prosa del body, eccetto la domanda obbligatoria del finalize (verbatim IT).
- **Naming**: nessuna naming convention introdotta.

---

## File impattati

- `skills/task-implementer/SKILL.md` [edit]

---

## Shape reale (post-implementazione)

Il file riscritto mantiene struttura a sezioni con header Markdown. Organizzazione:

```
# Task Implementer
## Prerequisites
## Non-negotiable rules  (3 regole, lista numerata)
## Non-contradiction invariant
## File layout          (code block, annotazioni inline)
## Modes
   ### Mode 1: `brief T-NNN`      (7 step + 2 note callout)
   ### Mode 2: `deviation T-NNN`  (4 step)
   ### Mode 3: `finalize T-NNN`   (gate callout + 6 step)
   ### Mode 4: `archive-milestone M[N]`  (5 step)
   ### Mode 5: `check-coherence`  (3 step)
## Tone
## When NOT to use
```

Shape, non implementazione finale.

---

## Gate report

### Gate report — skills/task-implementer/SKILL.md

Baseline pre-riscrittura: 2026-06-04 (scripts/token-baseline.json)
Checklist edge-case: 33 voci estratte

| EC | Esito | Note |
|----|-------|------|
| EC-001 | OK | Prerequisites + "refuse and redirect to `planner`" |
| EC-002 | OK | Rule 1, "do NOT proceed silently" |
| EC-003 | OK | Rule 2, 10–15 lines, body non banale → remove |
| EC-004 | OK | Rule 3, subtask default none, output esplicito |
| EC-005 | OK | Non-contradiction invariant, `planner revise` |
| EC-006 | OK | Layout: old flat non letto/scritto; usare `migrate` |
| EC-007 | OK | Tier scan, esclude `docs/archive/**` |
| EC-008 | OK | 0 match / >1 match → errori specifici |
| EC-009 | OK | Override esplicito `feature <slug>` |
| EC-010 | OK | Classic-project fallback |
| EC-011 | OK | Batch parallelo di lettura |
| EC-012 | OK | Epic context: anche `docs/epics/<epic>/technical-context.md`, binding read-only |
| EC-013 | OK | Validazione coerenza prima di scrivere |
| EC-014 | OK | Header `Origin:`, `Context-root:`, `Feature:` (non `Milestone:`) |
| EC-015 | OK | Sezione obbligatoria `## Vincoli risolti` |
| EC-016 | OK | Append-only a technical-context.md |
| EC-017 | OK | Attended: scope.txt + frozen.txt, additivo |
| EC-018 | OK | Copia `.flow/briefs/` vs fonte di verità co-locata |
| EC-019 | OK | Solo mode: brief post-implementazione, struttura identica a team |
| EC-020 | OK | Deviation: brief esiste e non archiviato |
| EC-021 | OK | Deviation: NON toccare technical-context.md |
| EC-022 | OK | Finalize attended gate: RESULT.verify + no ESCALATION.json |
| EC-023 | OK | Domanda obbligatoria finalize (verbatim IT) |
| EC-024 | OK | `Status: ✅ finalized` nell'header |
| EC-025 | OK | tasks-file NON toccato da questa skill |
| EC-026 | OK | Archive: milestone done + conferma esplicita se no |
| EC-027 | OK | Archive: task aperti → lista + conferma |
| EC-028 | OK | Archive: `git mv` path canonico |
| EC-029 | OK | Feature archive = flow-run, non Mode 4 |
| EC-030 | OK | technical-context.md non archiviato né modificato |
| EC-031 | OK | check-coherence utility, esclude `archive/`, nessuna modifica |
| EC-032 | OK | When NOT: >4h → split con `planner` |
| EC-033 | OK | Reference lazy: carica solo allo step che la usa |

Diff semantico sezioni ad alto rischio:
- §non-contraddizione: INVARIATO
- §mode1-context-root (scan, errori, override, fallback): EQUIVALENTE (EN, struttura lista)
- §mode1-epic (binding read-only, no bubble-up): INVARIATO
- §mode3-attended-gate: INVARIATO
- §mode3-finalize (domanda obbligatoria): INVARIATO
- §mode4-archive (git mv, feature esclusione, technical-context): INVARIATO
- §attended-mode (scope/frozen, copia vs verità): INVARIATO
- §solo-mode (post-impl, sezioni obbligatorie): INVARIATO

Delta token:
- description: 197 → 197 (0 tok, 0.0%)
- body:        3184 → 2117 (−1067 tok, −33.5%)
- totale:      3381 → 2314 (−1067 tok, −31.6%)

Esito gate: PASS

---

## Deviazioni

Nessuna deviazione rispetto al piano.

---

## Compression notes

Nessuna anomalia rilevata nel file originale.
