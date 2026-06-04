# Task attivi — Feature: Riscrittura agent dev/pm/solo (`token-diet-agents`)

**Feature**: token-diet-agents
**Effort totale stimato**: 2-3 ore
**Definition of done feature**: `agents/{dev,pm,solo}.md` riscritti (potatura + EN), delta token
misurato, checklist edge-case 100% ritrovabile, contratto agent↔orchestratore preservato, gate report
nel brief.

## Task

### token-diet-agents-001 — 💻 [impl] Riscrivere `agents/{dev,pm,solo}.md` (potatura + EN) con gate report

- **Effort**: 2-3h
- **Definition of done**: i tre file `agents/dev.md`, `agents/pm.md`, `agents/solo.md` riscritti
  applicando il protocollo di `docs/epics/token-diet/compression-protocol.md`: (1) estrazione checklist
  edge-case per ciascun file (quando/cosa scrivere in `.flow/` — RESULT.json, ESCALATION.json,
  scope.txt/frozen.txt; hook `scope-check`/`verify-gate`; `solo` condivide gli hook del DEV; coerenza
  con la sezione spawn di flow-run); (2) riscrittura potatura + inglese con procedure in liste;
  (3) eventuali trigger/`description` invariati verbatim; (4) gate report nel brief con soglie rispettate
  (0 `MANCANTE`, 0 `DIVERGENTE`, delta token ≤ 0% per ogni file); (5) tool-list, hook e protocollo di
  comunicazione **invariati**. Misura delta con `python3 scripts/measure-tokens.py --delta`.
- **Dipende da**: —
- **Complessità (ipotesi)**: standard
- **Status**: ⚪ todo

## Note operative

- Task unico sui 3 file (coesi: stesso protocollo, stessi contratti, file piccoli) → un solo spawn
  `solo`/`sonnet`. Gate report con voci EC separate per file.
- Ambiguità/bug nelle regole originali → **annotare, non correggere**.

## Out of scope per questa feature

- Tool-list, hook, protocollo di comunicazione (solo forma del testo).
- flow-run e le skill.

---
Generato: 2026-06-03 | Versione: 2 | Feature: token-diet-agents
