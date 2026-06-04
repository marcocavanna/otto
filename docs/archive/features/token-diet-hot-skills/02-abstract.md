# Abstract tecnico — Feature: Riscrittura skill calde (`token-diet-hot-skills`)

## Approccio

Vedi `docs/epics/token-diet/02-abstract.md`. Quattro file skill, ognuno riscritto e gate-ato in modo
indipendente (candidati naturali a task atomici separati a expand).

## Moduli impattati

- `skills/task-implementer/SKILL.md` — body+desc.
- `skills/flow-sync/SKILL.md` — body+desc (attenzione: reconciliation/preview-apply densa).
- `skills/whats-next/SKILL.md` — body+desc (join multi-source, fallback).
- `skills/code-implementer/SKILL.md` — body+desc (contratto brief/decision).

## Stack pertinente

- Markdown + YAML frontmatter.

## Contratti da preservare (→ frozen)

- Semantica di reconciliation di flow-sync (safe-repair PROGRESS→file, import conservativo, segnalazione
  ambigui/orphan, preview-default/apply-su-conferma).
- Logica read-only di whats-next (join, riconciliazione stato, nessuna scrittura).
- Contratti di brief/finalize/decision di task-implementer e code-implementer.
- Link a `references/`.

## Trade-off

- Quattro file in una feature L → a expand conviene un task per file per gate isolati.

## Rischi tecnici

- Vedi RISK-token-diet-hot-skills-001.

## Esclusioni tecniche

- Niente touch a references; niente cambio di semantica.

---
Generato: 2026-06-03 | Versione: 1
