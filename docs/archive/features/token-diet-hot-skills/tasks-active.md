# Task attivi — Feature: Riscrittura skill calde (`token-diet-hot-skills`)

**Feature**: token-diet-hot-skills
**Effort totale stimato**: 8-12 ore
**Definition of done feature**: body+desc di `task-implementer`, `flow-sync`, `whats-next`,
`code-implementer` riscritti (potatura + EN), delta token misurato per ciascuno, checklist edge-case
100% ritrovabile, link a references validi, gate report per task.

## Task

### token-diet-hot-skills-001 — 💻 [impl] Riscrivere `skills/task-implementer/SKILL.md` (potatura + EN)

- **Effort**: 2-3h
- **Definition of done**: `skills/task-implementer/SKILL.md` (body+desc) riscritto col protocollo
  `docs/epics/token-diet/compression-protocol.md`: checklist edge-case (contratti brief/finalize/decision,
  meta.json, modi) → riscrittura potatura+EN+liste → trigger-phrase `description` verbatim → gate report
  (0 `MANCANTE`, 0 `DIVERGENTE`, delta ≤ 0%) → link a `references/` validi. Delta via
  `python3 scripts/measure-tokens.py --delta`.
- **Dipende da**: —
- **Complessità (ipotesi)**: standard
- **Status**: ✅ done

### token-diet-hot-skills-002 — 💻 [impl] Riscrivere `skills/flow-sync/SKILL.md` (potatura + EN)

- **Effort**: 2-3h
- **Definition of done**: `skills/flow-sync/SKILL.md` (body+desc) riscritto col protocollo. Attenzione
  agli edge-case di reconciliation (safe-repair PROGRESS→file, import conservativo, preview/apply,
  ambigui/orphan, riconciliazione in avanti roadmap). Gate report + trigger verbatim + link validi.
- **Dipende da**: —
- **Complessità (ipotesi)**: standard
- **Status**: ✅ done

### token-diet-hot-skills-003 — 💻 [impl] Riscrivere `skills/whats-next/SKILL.md` (potatura + EN)

- **Effort**: 2-3h
- **Definition of done**: `skills/whats-next/SKILL.md` (body+desc) riscritto col protocollo. Preservare
  la logica read-only del join multi-source e i fallback (index.json vs PROGRESS per-source). Gate
  report + trigger verbatim + link validi.
- **Dipende da**: —
- **Complessità (ipotesi)**: standard
- **Status**: ✅ done

### token-diet-hot-skills-004 — 💻 [impl] Riscrivere `skills/code-implementer/SKILL.md` (potatura + EN)

- **Effort**: 2-3h
- **Definition of done**: `skills/code-implementer/SKILL.md` (body+desc) riscritto col protocollo.
  Preservare il contratto brief→codice e la decision-classification. Gate report + trigger verbatim +
  link validi.
- **Dipende da**: —
- **Complessità (ipotesi)**: standard
- **Status**: ✅ done

## Note operative

- Un task per file → gate isolati, full-run sequenziale, tutti `solo`/`sonnet`.
- Ambiguità/bug nelle regole originali → **annotare, non correggere**.

## Out of scope per questa feature

- References delle skill (`skills/*/references/`), skill cold, flow-run, agent.

---
Generato: 2026-06-03 | Versione: 2 | Feature: token-diet-hot-skills
