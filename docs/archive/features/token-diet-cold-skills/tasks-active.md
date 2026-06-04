# Task attivi — Feature: Compattazione description skill rare (`token-diet-cold-skills`)

**Feature**: token-diet-cold-skills
**Effort totale stimato**: 1-2 ore
**Definition of done feature**: `description` di `migrate`, `planner`, `critical-flow-analysis`
compattate + EN, delta token misurato, trigger-phrase 100% preservate verbatim. Body invariati.

## Task

### token-diet-cold-skills-001 — 💻 [impl] Compattare le `description` di migrate/planner/critical-flow-analysis

- **Effort**: 1-2h
- **Definition of done**: solo il campo `description` (frontmatter YAML) di
  `skills/migrate/SKILL.md`, `skills/planner/SKILL.md`, `skills/critical-flow-analysis/SKILL.md`
  compattato + tradotto in inglese applicando `docs/epics/token-diet/compression-protocol.md`. Vincolo
  critico: **tutte le trigger-phrase preservate verbatim** (anche italiane) — comprimere solo la prosa
  esplicativa, non l'elenco trigger. Body **non toccati**. Gestire frontmatter single-line e folded
  (`>`/`>-`). Gate report (0 `MANCANTE`, 0 `DIVERGENTE`, delta description ≤ 0%). Misura delta con
  `python3 scripts/measure-tokens.py --delta` (NON `--save`).
- **Dipende da**: —
- **Complessità (ipotesi)**: trivial
- **Status**: ✅ done

## Note operative

- Intervento minimale a basso rischio (solo frontmatter). Un solo spawn `solo`/`haiku`.
- Il rischio principale è il triggering (planner assorbe molti trigger): elenco trigger verbatim.

## Out of scope per questa feature

- Body delle skill cold; references planner; flow-run, agent, skill calde.

---
Generato: 2026-06-03 | Versione: 2 | Feature: token-diet-cold-skills
