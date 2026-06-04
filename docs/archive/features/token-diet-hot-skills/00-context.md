# Context — Feature: Riscrittura skill calde (`token-diet-hot-skills`)

<!-- Anchor --> **Tier**: feature · **Parent**: token-diet · **Bubble-up target**: docs/epics/token-diet/technical-context.md

**Progetto**: otto
**Epic**: token-diet
**Dipende da feature**: token-diet-foundation
**Tipo**: feature su progetto esistente

## Cosa fa la feature

Riscrive body + description delle quattro skill frequentemente invocate: `task-implementer` (~3.184),
`flow-sync` (~2.725), `whats-next` (~2.612), `code-implementer` (~2.254 tok body). Potatura + inglese,
edge-case preservati.

## Derivato dal codebase

- **Moduli/aree toccate**: `skills/task-implementer/SKILL.md`, `skills/flow-sync/SKILL.md`,
  `skills/whats-next/SKILL.md`, `skills/code-implementer/SKILL.md`.
- **Stack pertinente**: prompt Markdown + frontmatter YAML; queste skill linkano `references/` (NON da
  modificare).
- **Convenzioni rilevate**: flow-sync ha logica di reconciliation densa (safe-repair, import, drift);
  whats-next ha regole di join multi-source; code/task-implementer hanno contratti di brief/decision.
- **Build/test command**: `python3 scripts/measure-tokens.py` + gate foundation.

## Boundary e scope

- **In scope**: body + description delle 4 skill (forma/lingua/struttura).
- **Fuori scope**: le rispettive `references/` (on-demand); flow-run, agent, skill cold; ogni cambio di
  semantica.
- **Integrazione con l'esistente**: link a `references/` validi; contratti `.flow/`, schema task-entry,
  PROGRESS invariati.

## Tracked assumptions

(eredita ASSUMPTION-token-diet-001/002 dall'epic)

## Known risks

### RISK-token-diet-hot-skills-001 — Edge-case di reconciliation/join persi
- **Severità**: 🟡 media
- **Descrizione**: flow-sync (safe-repair vs ambigui/orphan, preview/apply) e whats-next (riconciliazione
  per-source, fallback) hanno casistiche fitte; la potatura può eliminarne.
- **Mitigazione**: gate foundation con checklist per ciascun file; queste skill sono read-only o a basso
  rischio operativo, ma vanno comunque diffate.

---
Generato: 2026-06-03 | Versione: 1
