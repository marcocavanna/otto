# Abstract tecnico — Feature: Riscrittura di flow-run (`token-diet-flow-run`)

## Approccio

Vedi `docs/epics/token-diet/02-abstract.md`. Specifico: applicare il protocollo di compressione della
foundation al file più grande e più rischioso del plugin, un solo file alla volta, con gate rinforzato.

## Moduli impattati

- `skills/flow-run/SKILL.md` — body riscritto (procedure → liste dense, prosa → EN, rationale ridondante
  rimosso) + description compattata/EN con trigger verbatim.

## Stack pertinente

- Markdown + YAML frontmatter.

## Contratti da preservare (→ frozen)

- Design file-based: PM/DEV via `.flow/`, prompt di spawn sottili, business logic su disco.
- Tutti gli edge-case: escalation (livelli, `ESCALATION.json`, AskUserQuestion solo dal main),
  biforcazione solo/team (`execution-mode` da complessità, degrado conservativo → team), dry-run policy
  (run/skip), model-tiering (derivazione + override manuale + degrado a frontmatter), finalize inline
  fast-path vs finalize PM, auto-archivio a fine source, mirror status nel tasks-file.
- Link relativi a `references/*.md`.

## Trade-off

- Dimezzare il footprint vs rischio regole perse → si privilegia la sicurezza (gate + dogfooding); se un
  edge-case non è comprimibile senza rischio, resta esteso.

## Rischi tecnici

- Vedi RISK-token-diet-flow-run-001/002.

## Esclusioni tecniche

- Niente refactor del design; niente touch alle references; niente cambio di comportamento.

---
Generato: 2026-06-03 | Versione: 1
