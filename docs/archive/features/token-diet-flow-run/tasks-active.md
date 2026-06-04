# Task attivi — Feature: Riscrittura di flow-run (`token-diet-flow-run`)

**Feature**: token-diet-flow-run
**Effort totale stimato**: 3-4 ore
**Definition of done feature**: `skills/flow-run/SKILL.md` riscritto (potatura + EN), delta token
misurato (target ~17-19 KB da ~29 KB), checklist edge-case 100% ritrovabile, link a references validi,
gate report nel brief, dogfooding di un flow reale senza regressioni.

## Task

### token-diet-flow-run-001 — 💻 [impl] Riscrivere `skills/flow-run/SKILL.md` (potatura + EN) con gate report

- **Effort**: 3-4h
- **Definition of done**: `skills/flow-run/SKILL.md` riscritto applicando il protocollo di
  `docs/epics/token-diet/compression-protocol.md`: (1) estrazione della checklist edge-case dal file
  originale (escalation L*/AskUserQuestion solo-main, biforcazione solo/team, dry-run policy run/skip,
  model-tiering + override + degrado a frontmatter, finalize inline vs PM, auto-archivio 6-step,
  mirror tasks-file/roadmap, risoluzione epic, claim/lock/heartbeat, ricostruzione index, pre-check flow
  concorrente); (2) riscrittura potatura + inglese con procedure in liste; (3) **trigger-phrase del
  frontmatter `description` verbatim**; (4) gate report nel brief con soglie rispettate (0 `MANCANTE`,
  0 `DIVERGENTE`, delta token ≤ 0%); (5) link relativi a `references/*.md` tutti validi. Misura delta con
  `python3 scripts/measure-tokens.py --delta`. Design file-based e prompt di spawn sottili **invariati**.
- **Dipende da**: —
- **Complessità (ipotesi)**: standard
- **Status**: ✅ done

## Note operative

- Task unico end-to-end: un solo file ad alta coesione → un solo spawn `solo`/`sonnet`.
- Safety-net: gate report (compression-protocol §3) + **dogfooding** (un flow reale dopo la riscrittura)
  prima di considerare chiusa la leva #1.
- Se emergono ambiguità o possibili bug nelle regole originali → **annotare, non correggere** (fuori
  scope di questo epic).

## Out of scope per questa feature

- References di flow-run (`skills/flow-run/references/`), design file-based, prompt di spawn.
- Altre skill/agent.

---
Generato: 2026-06-03 | Versione: 2 | Feature: token-diet-flow-run
