# token-diet-hot-skills-003 — Riscrivere `skills/whats-next/SKILL.md` (potatura + EN)

Status: ✅ finalized
Origin: flow-run / epic token-diet / feature hot-skills
Context-root: docs/features/token-diet-hot-skills/

## Vincoli risolti

- Stack: Markdown + YAML frontmatter. Plugin otto 2.1.0.
- Protocollo: `docs/epics/token-diet/compression-protocol.md` v1 (5 step obbligatori).
- Contratti frozen: semantica read-only di whats-next, logica join multi-source, fallback per-source, legacy singleton retrocompat, escalation a flow-sync per drift.
- Trigger-phrase nella `description`: preservate verbatim (invariante).
- Link a `references/` (reconcile, ranking, epic-rollup): validi e invariati.
- Naming convention: sezioni EN in snake_case / titolo EN; trigger-phrase IT invariate.

## File impattati

- `skills/whats-next/SKILL.md` [edit]
- `docs/features/token-diet-hot-skills/tasks/token-diet-hot-skills-003.md` [new]

## Shape reale

```markdown
# Whats Next — read-only operational advisor

## State principle
Read-only projection over existing artifacts. Never write: no plans, no .flow/, no code.
[fallback chain: index.json → per-source PROGRESS → legacy singleton → nessun .flow/]

## Data sources (read-only)
[tabella sorgenti con ruolo per-riga; include roadmap opzionale+additiva, locks/ per fallback scan]

## Modes
[global / plan / milestone / feature / epic — slug/epic inesistente: lista e chiedi]

## Protocol
1. Discovery
2. State reconciliation (index pre-filtro, archived skip, drift report-only)
3. Per-plan computation (shell source → planner expand, unblocked, next, blockers)
4. Hierarchical roll-up (Parent anchor, roadmap fallback, epic grouping)
5. Cross-plan ranking (euristica esposta)
6. 3-level output

### Milestone scoped — special case
[active: show tasks / non-active: solo macro, no invent, suggerisci planner expand]

## Output — 3 levels
[Board / Motivated recommendation / Concatenable commands]

## Honesty rules (explicit gaps)
[no-deps / effort-range / no-.flow / drift / tasks-file unrecognized]

## What this skill does NOT do
[no write / no priority decision / no expand / no execute]
```
(shape, non implementazione finale)

## Gate report

### Gate report — skills/whats-next/SKILL.md

Baseline pre-riscrittura: 2026-06-04 (baseline salvata con `--save` prima del task)
Checklist edge-case: 24 voci estratte

| EC | Esito | Note |
|----|-------|------|
| EC-001 | OK | "Never write: no plans, no .flow/, no code" |
| EC-002 | OK | index.json first read + fallback scan espliciti |
| EC-003 | OK | legacy singleton: "only for IDs absent from any per-source source" |
| EC-004 | OK | "No .flow/ = no flow ever executed" |
| EC-005 | OK | "no deterministic global 'next' exists" |
| EC-006 | OK | roadmap "(optional, additive)…If absent, features stay flat" |
| EC-007 | OK | locks/: "dir present = source alive (fallback scan)" |
| EC-008 | OK | "Slug missing/ambiguous: list available and ask" |
| EC-009 | OK | "Epic not found: list available and ask" |
| EC-010 | OK | shell source: "next action is planner expand <slug>. Flag on board" |
| EC-011 | OK | index pre-filtro: "load per-source {…, archived} as pre-filter" |
| EC-012 | OK | archived=true: "done tasks frozen; skip its tasks-active.md for active tasks" |
| EC-013 | OK | "Report every drift; never correct (read-only)" |
| EC-014 | OK | sezione Milestone scoped: solo macro per milestone non attiva |
| EC-015 | OK | "Do not invent tasks" esplicito |
| EC-016 | OK | comandi: "Shell/unexpanded → planner expand <slug>" |
| EC-017 | OK | "Not yet planned → planner <description>" |
| EC-018 | OK | "warn; order by phase/category, not critical-path" |
| EC-019 | OK | "horizon is heuristic, not guaranteed. Say so" |
| EC-020 | OK | "warn; use tasks-file Status (may not reflect actual work)" |
| EC-021 | OK | drift → flow-sync "preview default, apply on confirmation — repairs safe drifts, flags ambiguous/orphan" |
| EC-022 | OK | "skip and annotate; never invent" |
| EC-023 | OK | "parent→child from Parent anchor; roadmap Source as fallback" |
| EC-024 | OK | "Exposed heuristic, not truth" |

Diff semantico sezioni ad alto rischio:
- §read-only (state principle): INVARIATO
- §state-reconciliation (fallback, archived, drift): EQUIVALENTE (lista puntata sostituisce prosa)
- §milestone-scoped: EQUIVALENTE
- §honesty-rules: EQUIVALENTE (lista puntata, stessa copertura)
- §comandi-concatenabili: EQUIVALENTE

Delta token:
- description: 239 → 239 (0 tok, 0%)
- body:        2611 → 1764 (-847 tok, -32.4%)
- totale:      2850 → 2003 (-847 tok, **-29.7%**)

Esito gate: **PASS**

## Deviazioni

- Nessuna deviazione rispetto al piano. Delta description = 0 (la description è stata preservata verbatim con le trigger-phrase; la soglia del 20% è calcolata sul totale artefatto, soddisfatta).
- Tabella data sources mantenuta (struttura a tabella riduce token rispetto al formato precedente a prosa mista).

## Compression notes

Nessuna anomalia rilevata nell'originale.
