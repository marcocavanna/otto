# Technical context — Feature: Compattazione description skill rare (`token-diet-cold-skills`)

<!-- Anchor --> **Tier**: feature · **Parent**: token-diet · **Bubble-up target**: docs/epics/token-diet/technical-context.md

> Seed da docs/epics/token-diet/technical-context.md

## Convenzioni di progetto

### Build & test
- build_command: `—`
- test_command: `python3 scripts/measure-tokens.py` (delta description) + gate foundation

## Pattern architetturali

- Protocollo di compressione (vedi seed), applicato **solo** al campo `description`. Gestire frontmatter
  folded (`>`, `>-`) e single-line. Trigger-phrase verbatim.

## Librerie e versioni

- YAML / Markdown. Plugin otto 2.1.0.

## Value Objects / contratti

- Invarianti dal seed + elenco trigger di ciascuna skill (verbatim).

---
Generato: 2026-06-03 | Versione: 1
