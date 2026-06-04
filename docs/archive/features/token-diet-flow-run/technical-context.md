# Technical context — Feature: Riscrittura di flow-run (`token-diet-flow-run`)

<!-- Anchor --> **Tier**: feature · **Parent**: token-diet · **Bubble-up target**: docs/epics/token-diet/technical-context.md

> Seed da docs/epics/token-diet/technical-context.md

## Convenzioni di progetto

### Build & test
- build_command: `—`
- test_command: `python3 scripts/measure-tokens.py` (delta su flow-run) + gate foundation + dogfooding flow reale

## Pattern architetturali

- Protocollo di compressione (vedi seed): estrai checklist edge-case → riscrivi (potatura + EN + liste) →
  trigger verbatim → gate → annota ambiguità senza correggere.
- flow-run-specifico: la checklist edge-case è particolarmente densa; trattarla come contratto frozen.

## Librerie e versioni

- Markdown / YAML. Plugin otto 2.1.0.

## Value Objects / contratti

- Invarianti dal seed (RESULT/ESCALATION, hook, `.flow/`, schema/anchor) + design file-based di flow-run +
  validità dei link a `references/`.

---
Generato: 2026-06-03 | Versione: 1
