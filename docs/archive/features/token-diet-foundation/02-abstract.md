# Abstract tecnico — Feature: Baseline, protocollo, glossario e gate (`token-diet-foundation`)

## Approccio

Vedi `docs/epics/token-diet/02-abstract.md` per l'approccio d'insieme. Specifico di questa feature:
produrre i tre deliverable che rendono la riscrittura **verificabile** e **coerente**.

## Moduli impattati

- `scripts/measure-tokens.py` (nuovo) — misura description+body per ogni `skills/*/SKILL.md` e `agents/*.md`,
  emette tabella + totali (always-on vs hot-path) e, dato un baseline salvato, il **delta**.
- Documento di protocollo/glossario/checklist (path da definire a expand, es.
  `docs/epics/token-diet/compression-protocol.md` o sotto la feature) — single-source per i fronti.

## Stack pertinente

- Python 3, stdlib only (regex per il frontmatter, niente dipendenze).

## Contratti da preservare

- Lo script è **read-only** sugli artefatti; non li modifica.

## Trade-off

- Stima token vs tokenizer reale: si accetta il proxy (delta comparativo affidabile) per evitare
  dipendenze pesanti.

## Rischi tecnici

- Parsing dei frontmatter folded (`>`, `>-`) e single-line: gestire entrambi (già visto in analisi).

## Esclusioni tecniche

- Nessuna integrazione CI; lo script è invocabile a mano (la verifica dell'epic è manuale/dogfooding).

---
Generato: 2026-06-03 | Versione: 1
