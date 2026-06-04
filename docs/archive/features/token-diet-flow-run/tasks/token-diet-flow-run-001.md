# token-diet-flow-run-001 — Riscrittura `skills/flow-run/SKILL.md` (potatura + EN) con gate report

**Status: ✅ finalized**
**Origin**: token-diet-flow-run
**Context-root**: docs/features/token-diet-flow-run/
**Feature**: token-diet-flow-run

---

## Vincoli risolti

- **Stack**: Markdown + YAML frontmatter. Plugin otto 2.1.0.
- **Protocollo applicato**: compression-protocol.md (5 step): estrazione checklist EC → riscrittura (potatura + EN + liste) → trigger verbatim invariate → gate → annotation anomalie.
- **VO/interfacce consumate (frozen)**: design file-based (.flow/), schema RESULT.json/ESCALATION.json/PROGRESS.json/meta.json/scope.txt/frozen.txt, contratti heartbeat, link a references/* invariati.
- **Naming convention**: sezioni in testo denso EN; heading di sezioni operative in grassetto con numerazione (step 1, 1b, 2...); tabella spawn per chiarezza.
- **Trigger-phrase frontmatter**: invariate verbatim (stessa stringa del file originale).

## File impattati

- `skills/flow-run/SKILL.md` [edit]
- `docs/features/token-diet-flow-run/tasks/token-diet-flow-run-001.md` [new]

## Shape reale

```markdown
# Flow Run — orchestratore attended

You are the **main thread** = ORCHESTRATOR. PM and DEV are direct child subagents ...

## State principle
Loop state lives in `.flow/sources/<slug>/PROGRESS.json` (per-source, execution truth) ...
`.flow/PROGRESS.json` (root) is **legacy** — never read or write as loop state.

## Protocol (per task)
**1. ...** **1b. Resolve `execution-mode`** ... **2. Activate task BEFORE spawn** ...
> **Bifurcation**: if team → steps 3–6; if solo → § Solo branch.

### Team branch / Solo branch
S1. Derive model ... S2. Spawn `solo` → `implement` ... S3. Read RESULT.json ...
  promote==true → solo→team promotion (pre-write, clean tree): re-run from step 3 in team.
  escalate/verify-fail → go to 7 (post-write, never promote).
S4. Finalize gate (orchestrator) ...

## Spawn — what to pass to subagents
| Subagent | Prompt |
...

## Compression notes
- [NOTA] Sezioni "Risoluzione epic" e "Mirror roadmap" integrate nel flusso ...
```
(shape, non implementazione finale)

## Gate report — `skills/flow-run/SKILL.md`

Baseline pre-riscrittura: 2026-06-04 (scripts/token-baseline.json)
Checklist edge-case: **50 voci estratte** (EC-001…EC-050)

| EC | Esito | Note |
|----|-------|------|
| EC-001 | OK | |
| EC-002 | OK | |
| EC-003 | OK | |
| EC-004 | OK | |
| EC-005 | OK | |
| EC-006 | OK | |
| EC-007 | OK | |
| EC-008 | OK | |
| EC-009 | OK | |
| EC-010 | OK | |
| EC-011 | OK | |
| EC-012 | OK | |
| EC-013 | OK | |
| EC-014 | OK | |
| EC-015 | OK | |
| EC-016 | OK | |
| EC-017 | OK | |
| EC-018 | OK | |
| EC-019 | OK | |
| EC-020 | OK | EQUIVALENTE — ordine passi 3-6 auto-archivio espresso come lista numerata |
| EC-021 | OK | |
| EC-022 | OK | |
| EC-023 | OK | EQUIVALENTE — "NEVER solo" al posto di "MAI solo" (EN) |
| EC-024 | OK | |
| EC-025 | OK | |
| EC-026 | OK | |
| EC-027 | OK | |
| EC-028 | OK | EQUIVALENTE — "conservative fallback" al posto di "degrado conservativo" (EN) |
| EC-029 | OK | |
| EC-030 | OK | |
| EC-031 | OK | |
| EC-032 | OK | |
| EC-033 | OK | |
| EC-034 | OK | |
| EC-035 | OK | |
| EC-036 | OK | |
| EC-037 | OK | |
| EC-038 | OK | |
| EC-039 | OK | |
| EC-040 | OK | |
| EC-041 | OK | |
| EC-042 | OK | EQUIVALENTE — "Forward-only transitions" al posto di "Solo transizioni in avanti" |
| EC-043 | OK | |
| EC-044 | OK | |
| EC-045 | OK | |
| EC-046 | OK | |
| EC-047 | OK | |
| EC-048 | OK | |
| EC-049 | OK | |
| EC-050 | OK | |

**Diff semantico sezioni ad alto rischio:**
- §escalation (livelli L2/L3, ESCALATION.json, AskUserQuestion solo main): INVARIATO
- §biforcazione solo/team (execution-mode, degrado conservativo → team): INVARIATO
- §dry-run policy (run/skip per complessità, override): INVARIATO
- §model-tiering (derivazione + override + degrado a frontmatter): INVARIATO
- §finalize inline fast-path vs finalize PM: INVARIATO
- §auto-archivio 6-step (sequenza obbligatoria, idempotenza): EQUIVALENTE (integrazione sezioni epic nel flusso)
- §mirror tasks-file/roadmap: INVARIATO
- §solo→team promotion (pre-write, working tree pulito): INVARIATO
- §claim/lock/heartbeat: INVARIATO
- §ricostruzione index: INVARIATO
- §pre-check flow concorrente: INVARIATO
- §contratti machine-readable (schema JSON): INVARIATO

**Delta token:**
- description: 294 → 294 (0 tok, 0%)
- body: 8570 → 5251 (-3319 tok, -38.7%)
- totale: 8864 → 5545 (-3319 tok, **-37.5%**)

**Esito gate: PASS**
- 0 voci MANCANTE
- 0 sezioni DIVERGENTE
- Delta totale -37.5% >> soglia minima -20%

## Deviazioni

- Sezioni "Risoluzione epic della source" e "Mirror status sulla roadmap epic" erano sezioni stand-alone in fondo al file originale (fuori dal protocollo per-task). Nel riscritto sono integrate rispettivamente in § "Claim source" e nel corpo del protocollo — riduce la navigazione verticale senza modificare la semantica. Annotato in `## Compression notes` del file riscritto.
- Tabella "Spawn" introdotta per sostituire la lista puntata prosa — più leggibile, meno token.
- `build skipped`: il file target è Markdown puro, nessun build command applicabile. La verifica è stata il gate report + misura delta token.

---
Generato: 2026-06-04 | Versione: 1
