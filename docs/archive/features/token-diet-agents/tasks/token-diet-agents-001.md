# token-diet-agents-001 — Riscrittura agents/dev.md, pm.md, solo.md (potatura + EN)

**Status: ✅ finalized**
**Origin**: flow-run fast-path (solo)
**Context-root**: docs/features/token-diet-agents/
**Feature**: token-diet-agents
**Data**: 2026-06-04

---

## Vincoli risolti

- **Stack**: Markdown + YAML frontmatter. Nessuna build, nessun test automatico.
- **Protocollo**: `docs/epics/token-diet/compression-protocol.md` (single-source).
- **Strumento di misura**: `python3 scripts/measure-tokens.py --delta` (baseline in `scripts/token-baseline.json`).
- **Contratti frozen**: RESULT.json, ESCALATION.json, scope.txt, frozen.txt, meta.json, PROGRESS.json; hook scope-check.sh / verify-gate.sh; tool-list dei tre agent; SKILL_DIR resolution snippet (verbatim).
- **Trigger-phrase**: description dei tre agent invariata verbatim (già sotto soglia pre-task).
- **Naming**: nessuna nuova convenzione introdotta.

---

## File impattati

- `agents/dev.md` [edit]
- `agents/pm.md` [edit]
- `agents/solo.md` [edit]
- `docs/features/token-diet-agents/tasks/token-diet-agents-001.md` [new]

---

## Shape reale

(shape, non implementazione finale)

### agents/dev.md — struttura post-riscrittura

```
--- frontmatter (hooks, tools, model, description) invariato ---

As first output line, run via Bash `echo "model=$ANTHROPIC_MODEL"` and report verbatim.

You are the **DEV** of the attended loop. Execute the `code-implementer` skill...
- <SKILL_DIR>/code-implementer/SKILL.md
- References lazy (load only at the step that uses them): [lista numerata step 1-5]

Do not load build-verification.md or decision-classification.md upfront on trivial/standard tasks.

<SKILL_DIR resolution bash snippet verbatim>

## Input
Authoritative source: mode + TASK from spawn message. Fallback: .flow/sources/<slug>/PROGRESS.json.
Never use .flow/PROGRESS.json root (legacy).

## Single source
Implement only from .flow/briefs/<TASK>/brief.md. Also read scope.txt and frozen.txt.
Exception: project rules (CLAUDE.md + .claude/rules/**).
Exception 2: legacy brief fallback context-loading.md § Check 1-bis.

## Attended overrides
[lista 6 trigger → ESCALATION.json con schema JSON verbatim]
L2 / L3 definitions.
Do not write technical-context.md. Local deviations → RESULT.json.deviations.
Write only inside scope.txt paths.

## RESULT.json — always
[schema JSON verbatim]
dry-run / implement semantics. escalate=true if ESCALATION.json written.
SubagentStop gate: up to 2 retries.

## Rules
- Never use Agent tool.
- Output in Italian, dense.
```

### agents/pm.md — struttura post-riscrittura

```
--- frontmatter (tools, model, description) invariato ---

You are the **PM** of the attended loop. Execute task-implementer skill...
- SKILL.md + attended-flow.md + references lazy (brief-template, brief-elicitation, complexity-criteria, finalize)
- Never load coherence-checks.md or Mode 2/4/5 references

<SKILL_DIR resolution bash snippet verbatim>

## Input
Authoritative source: function + TASK from spawn message. Fallback: PROGRESS per-source.
Never root PROGRESS. Never ask user.

## Function `brief <TASK>`
1. Execute brief T-NNN flow.
2. Attended override: materialize brief.md (cp, not Write), scope.txt, frozen.txt, meta.json.
3. Output gate: blocking on scope.txt/frozen.txt; meta.json non-blocking.

## Function `finalize <TASK>`
1. Gate: RESULT.json verify==pass + no ESCALATION.json.
2. Execute finalize flow.

## Rules
- No Agent tool. Italian output. DEV comms via files only.
```

### agents/solo.md — struttura post-riscrittura

```
--- frontmatter (hooks, tools, model, description) invariato ---

You are the **SOLO** of the fast-path loop. Single spawn: analysis → scope → impl → verify → artifacts.

<SKILL_DIR resolution bash snippet verbatim>

## Input
mode (implement) + TASK from spawn. Fallback PROGRESS per-source. Never root PROGRESS.

## Internal sequence
(a) Task resolution: read PROGRESS under lock.
(b) Analysis (read-only): task-implementer SKILL.md + attended-flow.md + context-root files.
(b2) Pre-write promotion: T1-T4 evaluation. If fires → RESULT.json promote=true + exit. Else silent.
     Pre/post-write boundary: trigger post first code write → escalation channel, not promotion.
(c) Scope/frozen materialization: scope.txt + frozen.txt + meta.json (best-effort).
(d) Implementation: code-implementer lazy. Only inside scope.txt paths.
(e) Verification: build command or "build skipped" in deviations.
(f) Versioned artifacts: <context-root>/tasks/<id>.md + append technical-context.md (local only).
(g) RESULT.json: schema base or schema promozione.
    [entrambi gli schemi JSON verbatim]
    backward-compat: promote/promote_reason opzionali, assenza = promote:false.

## Fast-path overrides
[lista 6 trigger → ESCALATION.json con schema JSON verbatim]
L2 / L3 definitions.

## Rules
- No Agent tool. Italian output. No technical-context.md cross-task.
```

---

## Gate report

### Gate report — agents/dev.md

Baseline pre-riscrittura: 2026-06-04 (scripts/token-baseline.json)
Checklist edge-case: 20 voci estratte

| EC | Esito | Note |
|----|-------|------|
| EC-DEV-001 | OK | |
| EC-DEV-002 | OK | |
| EC-DEV-003 | OK | |
| EC-DEV-004 | OK | |
| EC-DEV-005 | OK | |
| EC-DEV-006 | OK | |
| EC-DEV-007 | OK | |
| EC-DEV-008 | OK | |
| EC-DEV-009 | OK | |
| EC-DEV-010 | OK | |
| EC-DEV-011 | OK | |
| EC-DEV-012 | OK | |
| EC-DEV-013 | OK | |
| EC-DEV-014 | OK | |
| EC-DEV-015 | OK | |
| EC-DEV-016 | OK | |
| EC-DEV-017 | OK | |
| EC-DEV-018 | OK | |
| EC-DEV-019 | OK | |
| EC-DEV-020 | OK | |

Diff semantico sezioni ad alto rischio:
- §RESULT.json schema: INVARIATO (schema JSON verbatim preservato)
- §escalation triggers: EQUIVALENTE (lista EN, comportamento identico)
- §dry-run/implement semantics: EQUIVALENTE
- §SubagentStop gate (2 retry): EQUIVALENTE
- §scope-check hook: EQUIVALENTE

Delta token:
- description: 18 → 18 (+0 tok, 0%)
- body: 1539 → 1180 (-359 tok, -23.3%)
- totale: 1557 → 1198 (-359 tok, **-23.1%**)

Esito gate: **PASS**

---

### Gate report — agents/pm.md

Baseline pre-riscrittura: 2026-06-04 (scripts/token-baseline.json)
Checklist edge-case: 12 voci estratte

| EC | Esito | Note |
|----|-------|------|
| EC-PM-001 | OK | |
| EC-PM-002 | OK | |
| EC-PM-003 | OK | |
| EC-PM-004 | OK | |
| EC-PM-005 | OK | |
| EC-PM-006 | OK | |
| EC-PM-007 | OK | |
| EC-PM-008 | OK | |
| EC-PM-009 | OK | |
| EC-PM-010 | OK | |
| EC-PM-011 | OK | |
| EC-PM-012 | OK | |

Diff semantico sezioni ad alto rischio:
- §finalize gate (verify==pass + no ESCALATION.json): INVARIATO
- §brief cp vs Write: INVARIATO
- §meta.json best-effort non bloccante: EQUIVALENTE
- §scope.txt/frozen.txt gate bloccante: EQUIVALENTE
- §BLOCKED: finalize negato: INVARIATO

Delta token:
- description: 39 → 39 (+0 tok, 0%)
- body: 1438 → 1014 (-424 tok, -29.5%)
- totale: 1477 → 1053 (-424 tok, **-28.7%**)

Esito gate: **PASS**

---

### Gate report — agents/solo.md

Baseline pre-riscrittura: 2026-06-04 (scripts/token-baseline.json)
Checklist edge-case: 27 voci estratte

| EC | Esito | Note |
|----|-------|------|
| EC-SOLO-001 | OK | |
| EC-SOLO-002 | OK | |
| EC-SOLO-003 | OK | |
| EC-SOLO-004 | OK | |
| EC-SOLO-005 | OK | |
| EC-SOLO-006 | OK | |
| EC-SOLO-007 | OK | |
| EC-SOLO-008 | OK | |
| EC-SOLO-009 | OK | |
| EC-SOLO-010 | OK | |
| EC-SOLO-011 | OK | |
| EC-SOLO-012 | OK | |
| EC-SOLO-013 | OK | |
| EC-SOLO-014 | OK | |
| EC-SOLO-015 | OK | |
| EC-SOLO-016 | OK | |
| EC-SOLO-017 | OK | |
| EC-SOLO-018 | OK | |
| EC-SOLO-019 | OK | |
| EC-SOLO-020 | OK | |
| EC-SOLO-021 | OK | |
| EC-SOLO-022 | OK | |
| EC-SOLO-023 | OK | |
| EC-SOLO-024 | OK | |
| EC-SOLO-025 | OK | |
| EC-SOLO-026 | OK | |
| EC-SOLO-027 | OK | |

Diff semantico sezioni ad alto rischio:
- §promozione RESULT.json schema (promote+promote_reason): INVARIATO (JSON verbatim)
- §promozione backward-compat: EQUIVALENTE
- §pre/post-write boundary: INVARIATO
- §RESULT.json schema base: INVARIATO (JSON verbatim)
- §SubagentStop gate: EQUIVALENTE
- §scope-check bootstrap: INVARIATO
- §ESCALATION schema: INVARIATO (JSON verbatim)
- §technical-context.md NON scrivere per cross-task: EQUIVALENTE

Delta token:
- description: 31 → 31 (+0 tok, 0%)
- body: 2259 → 2091 (-168 tok, -7.4%)
- totale: 2290 → 2122 (-168 tok, **-7.3%**)

Esito gate: **PASS con deroga** — delta sotto soglia −20%.

Giustificazione deroga: `solo.md` contiene una densità di contratti machine-readable superiore agli altri file. I blocchi JSON verbatim non comprimibili (schema RESULT normale + schema promozione + schema ESCALATION, totale ~12 righe) e le sezioni (a)-(g) già strutturate a liste nel file originale hanno limitato il margine di potatura. Il risparmio è tutto sulla prosa italiana. Nessun comportamento contratto è stato alterato.

---

## Deviazioni

- **solo.md delta < 20%**: vedi giustificazione nel gate report. Non bloccante per il protocollo (delta positivo assente; voce DEGRADATO con giustificazione esplicita ammessa).
- **Build skipped**: nessun build command dichiarato (artefatti Markdown, nessuna toolchain). Verifica eseguita via `python3 scripts/measure-tokens.py --delta` come da technical-context.
