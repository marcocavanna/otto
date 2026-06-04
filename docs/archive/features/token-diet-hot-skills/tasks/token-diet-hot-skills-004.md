# token-diet-hot-skills-004 — Riscrivere `skills/code-implementer/SKILL.md` (potatura + EN)

Status: ✅ finalized
Origin: flow-run / epic token-diet / feature hot-skills
Context-root: docs/features/token-diet-hot-skills/

## Vincoli risolti

- Stack: Markdown + YAML frontmatter. Plugin otto 2.1.0.
- Protocollo: `docs/epics/token-diet/compression-protocol.md` v1 (5 step obbligatori).
- Contratti frozen: contratto brief→codice (self-sufficient "Vincoli risolti"), decision-classification (cross-task vs locale), build-verification (1 retry), context-loading (reference lazy), preflight (brief active check).
- Trigger-phrase nella `description`: preservate verbatim (invariante).
- Link a `references/` (context-loading, preflight, decision-classification, build-verification): validi e invariati.
- Naming convention: sezioni EN; trigger-phrase IT invariate.

## File impattati

- `skills/code-implementer/SKILL.md` [edit]
- `docs/features/token-diet-hot-skills/tasks/token-diet-hot-skills-004.md` [new]

## Shape reale

```markdown
# Code Implementer

## Operating principles
[brief self-sufficient; no 00-context/02-abstract/technical-context; context-root default docs/planning/]
[3 non-negotiable rules: context first / mimic before innovating / cross-task ask · local annotate]

## File system scope
[read-only: brief + existing code | write: source + brief sections + technical-context.md cross-task]
[never modify: planning files → planner revise]

## Mode 1: implement T-NNN
[lazy references; 7 steps: preflight / context-loading / decision-id / code-gen / build / decision-report / summary]

## Mode 2: dry-run T-NNN
[steps 1-3 + analysis; no writes]

## Mode 3: verify T-NNN
[coherence report; no writes]

## What this skill does NOT do
[no tests unless brief requires / no package install / no migrations / no git commit / no out-of-scope files]
```
(shape, non implementazione finale)

## Gate report

### Gate report — skills/code-implementer/SKILL.md

Baseline pre-riscrittura: 2026-06-04
Checklist edge-case: 20 voci estratte

| EC | Esito | Note |
|----|-------|------|
| EC-001 | OK | "do not read 00-context, 02-abstract, or technical-context" esplicito |
| EC-002 | OK | "default: docs/planning/ if absent" |
| EC-003 | OK | "If the brief does not exist: refuse and redirect to upstream" |
| EC-004 | OK | "No speculative generation" |
| EC-005 | OK | "If a similar construct already exists, follow its style. Only for the first instance…" |
| EC-006 | OK | "If cross-task: block and ask one at a time" |
| EC-007 | OK | "If local only: proceed" |
| EC-008 | OK | "No files outside File impattati" |
| EC-009 | OK | "on error: 1 automatic fix retry; on second failure: stop and report" |
| EC-010 | OK | "No build command → skip with warning" |
| EC-011 | OK | "Confirmed cross-task decisions → update technical-context.md + brief Deviazioni" |
| EC-012 | OK | Mode 2: "without writing any code or modifying the brief" |
| EC-013 | OK | "shows the command, user executes" |
| EC-014 | OK | "Does not commit to git" |
| EC-015 | OK | "Does not run database migrations" |
| EC-016 | OK | "Does not write tests unless the brief explicitly requires them" |
| EC-017 | OK | "Does not modify files outside File impattati, except DI/routing → report in Deviazioni" |
| EC-018 | OK | "Load references lazy — only at the step that uses them" |
| EC-019 | OK | "Brief is active (not finalized, not paused)" |
| EC-020 | OK | "if not found: use Vincoli risolti constraints directly" |

Diff semantico sezioni ad alto rischio:
- §operating-principles (self-sufficient brief, no planning reads): INVARIATO
- §context-root resolution (default retro-compat): INVARIATO
- §decision-classification (cross-task block/ask, local proceed): EQUIVALENTE (lista puntata)
- §build-verification (1 retry, stop on second fail): EQUIVALENTE
- §code-gen scope (solo File impattati): INVARIATO
- §dry-run (no writes): INVARIATO
- §what-not-do (no tests/install/migrate/commit): EQUIVALENTE (lista puntata)

Delta token:
- description: 175 → 175 (0 tok, 0%)
- body:        2253 → 1369 (-884 tok, -39.2%)
- totale:      2428 → 1544 (-884 tok, **-36.4%**)

Esito gate: **PASS**

## Deviazioni

- Nessuna deviazione rispetto al piano. Delta description = 0 (description preservata verbatim con trigger-phrase; soglia 20% calcolata sul totale artefatto, ampiamente soddisfatta a -36.4%).
- "File system scope" estratto come sezione separata dall'originale (era distribuito tra operating principles e what-not-do): migliora leggibilità senza perdere semantica.

## Compression notes

Nessuna anomalia rilevata nell'originale.
