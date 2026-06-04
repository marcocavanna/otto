# Context — Feature: Compattazione description skill rare (`token-diet-cold-skills`)

<!-- Anchor --> **Tier**: feature · **Parent**: token-diet · **Bubble-up target**: docs/epics/token-diet/technical-context.md

**Progetto**: otto
**Epic**: token-diet
**Dipende da feature**: token-diet-foundation
**Tipo**: feature su progetto esistente

## Cosa fa la feature

Compatta + traduce in inglese **solo le `description`** (always-on) di tre skill a invocazione rara:
`migrate`, `planner`, `critical-flow-analysis`. I body restano invariati (ROI basso, on-invoke raro).
Le trigger-phrase restano verbatim.

## Derivato dal codebase

- **Moduli/aree toccate**: frontmatter `description` di `skills/migrate/SKILL.md`,
  `skills/planner/SKILL.md`, `skills/critical-flow-analysis/SKILL.md`.
- **Stack pertinente**: YAML frontmatter (planner e migrate usano folded `>`/`>-`).
- **Convenzioni rilevate**: le description contengono lunghi elenchi di trigger (planner assorbe i trigger
  di project/epic/feature-planner) → load-bearing.
- **Build/test command**: `python3 scripts/measure-tokens.py` (delta description) + gate foundation.

## Boundary e scope

- **In scope**: solo le `description` delle 3 skill.
- **Fuori scope**: i body di queste skill; le references planner (~113 KB) — vedi RISK-token-diet-002
  dell'epic; flow-run, agent, skill calde.
- **Integrazione con l'esistente**: il motore di triggering deve continuare ad attivare le skill sugli
  stessi prompt → trigger verbatim.

## Tracked assumptions

(eredita ASSUMPTION-token-diet-001 — trigger verbatim — dall'epic)

## Known risks

### RISK-token-diet-cold-skills-001 — Triggering di planner indebolito
- **Severità**: 🟡 media
- **Descrizione**: la description di planner contiene molti trigger (assorbe 3 ex-skill); comprimerla può
  ridurre il match.
- **Mitigazione**: comprimere solo la prosa esplicativa; mantenere l'intero elenco trigger verbatim.

---
Generato: 2026-06-03 | Versione: 1
