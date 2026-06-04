# Abstract tecnico — Feature: Compattazione description skill rare (`token-diet-cold-skills`)

## Approccio

Vedi `docs/epics/token-diet/02-abstract.md`. Intervento minimale e a basso rischio: solo i frontmatter
`description`, prosa EN + compatta, trigger verbatim. Nessun body.

## Moduli impattati

- `skills/migrate/SKILL.md` — solo `description` (folded `>`).
- `skills/planner/SKILL.md` — solo `description` (folded `>-`, ricca di trigger).
- `skills/critical-flow-analysis/SKILL.md` — solo `description`.

## Stack pertinente

- YAML frontmatter (gestire folded e single-line).

## Contratti da preservare (→ frozen)

- Elenco completo delle trigger-phrase di ciascuna skill, verbatim.

## Trade-off

- Guadagno modesto (parte di ~1.720 tok always-on) ma a rischio quasi nullo → vale come chiusura
  "always-on" dell'epic.

## Rischi tecnici

- Vedi RISK-token-diet-cold-skills-001.

## Esclusioni tecniche

- Niente body, niente references, niente cambio di semantica.

---
Generato: 2026-06-03 | Versione: 1
