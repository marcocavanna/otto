# Technical context — Feature: Riscrittura agent dev/pm/solo (`token-diet-agents`)

<!-- Anchor --> **Tier**: feature · **Parent**: token-diet · **Bubble-up target**: docs/epics/token-diet/technical-context.md

> Seed da docs/epics/token-diet/technical-context.md

## Convenzioni di progetto

### Build & test
- build_command: `—`
- test_command: `python3 scripts/measure-tokens.py` (delta su agents) + gate foundation + dogfooding

## Pattern architetturali

- Protocollo di compressione (vedi seed). Per gli agent: la sezione che descrive le scritture in `.flow/`
  e i gate hook è contratto frozen — comprimere la prosa, non i fatti.

## Librerie e versioni

- Markdown / YAML. Plugin otto 2.1.0.

## Value Objects / contratti

- Invarianti dal seed + contratto agent↔orchestratore (RESULT/ESCALATION, scope.txt/frozen.txt, hook
  condivisi solo/DEV).

---
Generato: 2026-06-03 | Versione: 1
