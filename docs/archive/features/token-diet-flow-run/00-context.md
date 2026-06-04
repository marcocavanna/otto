# Context — Feature: Riscrittura di flow-run (`token-diet-flow-run`)

<!-- Anchor --> **Tier**: feature · **Parent**: token-diet · **Bubble-up target**: docs/epics/token-diet/technical-context.md

**Progetto**: otto
**Epic**: token-diet
**Dipende da feature**: token-diet-foundation
**Tipo**: feature su progetto esistente

## Cosa fa la feature

Riscrive `skills/flow-run/SKILL.md` (body + description) applicando potatura + inglese, dimezzando il
footprint (~8.570 tok body, target ~17-19 KB da ~29 KB) **senza perdere alcun edge-case**. È la leva #1
dell'epic: il body si carica a ogni esecuzione di flow.

## Derivato dal codebase

- **Moduli/aree toccate**: solo `skills/flow-run/SKILL.md`.
- **Stack pertinente**: prompt Markdown + frontmatter YAML.
- **Convenzioni rilevate**: il body è denso di regole operative (escalation, biforcazione solo/team,
  dry-run policy, model-tiering, degradi conservativi) e linka `references/` (NON da modificare).
- **Build/test command**: `python3 scripts/measure-tokens.py` (delta) + gate foundation + dogfooding.

## Boundary e scope

- **In scope**: body + description di `flow-run` (forma del testo, lingua, struttura).
- **Fuori scope**:
  - Il **design file-based** e i prompt di spawn sottili (già corretti — `frozen.txt`).
  - Le `references/` di flow-run (~18 KB, on-demand).
  - Qualsiasi cambio di logica/semantica dell'orchestrazione.
- **Integrazione con l'esistente**: i link a `references/*.md` devono restare validi; hook e contratti
  `.flow/` invariati.

## Tracked assumptions

### ASSUMPTION-token-diet-flow-run-001
- **Descrizione**: target di riduzione.
- **Scelta**: ~17-19 KB (da ~29 KB), ovvero ~30-40% in meno, senza scendere a costo di edge-case.
- **Alternative valutate**: compressione più aggressiva (rischio regole perse) — rifiutata.
- **Impatta**: tasks-active.md
- **Status**: active
- **Data**: 2026-06-03

## Known risks

### RISK-token-diet-flow-run-001 — Edge-case di orchestrazione persi
- **Severità**: 🔴 alta
- **Descrizione**: flow-run è il file più rischioso (escalation, solo/team, dry-run policy, model-tiering,
  degradi, smoke-check model per-spawn). Una potatura distratta ne elimina silenziosamente.
- **Mitigazione**: gate foundation con checklist edge-case estratta dall'originale; dogfooding di un flow
  reale prima di chiudere.

### RISK-token-diet-flow-run-002 — Link a references rotti
- **Severità**: 🟡 media
- **Descrizione**: riscrivendo si possono perdere/alterare i path verso `references/model-tiering.md` ecc.
- **Mitigazione**: verifica che tutti i link relativi restino validi nel diff.

---
Generato: 2026-06-03 | Versione: 1
