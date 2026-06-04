# Context — Feature: Riscrittura agent dev/pm/solo (`token-diet-agents`)

<!-- Anchor --> **Tier**: feature · **Parent**: token-diet · **Bubble-up target**: docs/epics/token-diet/technical-context.md

**Progetto**: otto
**Epic**: token-diet
**Dipende da feature**: token-diet-foundation
**Tipo**: feature su progetto esistente

## Cosa fa la feature

Riscrive i body+description dei tre agent (`agents/dev.md` ~1.540, `agents/pm.md` ~1.438,
`agents/solo.md` ~2.259 tok) con potatura + inglese. Sono caricati a **ogni spawn**: su un full-run da N
task il risparmio è composto (12+ spawn su 6 task in modalità team).

## Derivato dal codebase

- **Moduli/aree toccate**: `agents/dev.md`, `agents/pm.md`, `agents/solo.md`.
- **Stack pertinente**: prompt Markdown + frontmatter (i `description` agent sono brevi: dev 74, pm 156,
  solo 126 char — già snelli; il guadagno è sul body).
- **Convenzioni rilevate**: gli agent dichiarano hook (`scope-check`/`verify-gate`) e contratti di
  comunicazione via file; `solo` ha gli stessi hook del DEV.
- **Build/test command**: `python3 scripts/measure-tokens.py` + gate foundation + dogfooding.

## Boundary e scope

- **In scope**: body + (eventuale ritocco) description dei tre agent.
- **Fuori scope**: tool list e contratti di comunicazione (solo forma del testo); flow-run.
- **Integrazione con l'esistente**: il comportamento atteso da flow-run (cosa scrivono in `.flow/`,
  quando emettono RESULT/ESCALATION) resta identico.

## Tracked assumptions

(nessuna assunzione fragile specifica; eredita ASSUMPTION-token-diet-001/002 dall'epic)

## Known risks

### RISK-token-diet-agents-001 — Perdita di un contratto agent↔orchestratore
- **Severità**: 🟡 media
- **Descrizione**: gli agent descrivono quando/cosa scrivere in `.flow/` (RESULT/ESCALATION) e i gate
  hook; comprimere può offuscare un passaggio atteso da flow-run.
- **Mitigazione**: gate foundation + verifica incrociata con la sezione "Spawn — cosa passare ai
  subagent" di flow-run; dogfooding.

---
Generato: 2026-06-03 | Versione: 1
