# Abstract tecnico — Feature: Riscrittura agent dev/pm/solo (`token-diet-agents`)

## Approccio

Vedi `docs/epics/token-diet/02-abstract.md`. Tre file agent, riscrittura indipendente, stesso protocollo
e gate della foundation.

## Moduli impattati

- `agents/dev.md` — body riscritto (potatura + EN).
- `agents/pm.md` — body riscritto (potatura + EN).
- `agents/solo.md` — body riscritto (potatura + EN); attenzione: condivide hook col DEV.

## Stack pertinente

- Markdown + YAML frontmatter.

## Contratti da preservare (→ frozen)

- Quando/cosa ogni agent scrive in `.flow/` (RESULT.json, ESCALATION.json, scope.txt/frozen.txt per solo).
- Hook `scope-check`/`verify-gate` e il fatto che `solo` li condivide col DEV.
- Coerenza con la sezione spawn di flow-run.

## Trade-off

- I `description` agent sono già brevi → concentrare lo sforzo sul body senza toccare la tool-list.

## Rischi tecnici

- Vedi RISK-token-diet-agents-001.

## Esclusioni tecniche

- Niente cambi a tool-list, hook, o protocollo di comunicazione.

---
Generato: 2026-06-03 | Versione: 1
