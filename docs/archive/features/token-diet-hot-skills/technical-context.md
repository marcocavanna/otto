# Technical context — Feature: Riscrittura skill calde (`token-diet-hot-skills`)

<!-- Anchor --> **Tier**: feature · **Parent**: token-diet · **Bubble-up target**: docs/epics/token-diet/technical-context.md

> Seed da docs/epics/token-diet/technical-context.md

## Convenzioni di progetto

### Build & test
- build_command: `—`
- test_command: `python3 scripts/measure-tokens.py` (delta per skill) + gate foundation

## Pattern architetturali

- Protocollo di compressione (vedi seed), un file alla volta. Le casistiche di reconciliation/join sono
  contratto frozen: comprimere prosa, non casi.

## Librerie e versioni

- Markdown / YAML. Plugin otto 2.1.0.

## Value Objects / contratti

- Invarianti dal seed + semantica reconciliation flow-sync, read-only whats-next, brief/decision di
  task/code-implementer + validità link a references.

---
Generato: 2026-06-03 | Versione: 1
