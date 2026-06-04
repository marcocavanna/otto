# Technical context — Feature: Baseline, protocollo, glossario e gate (`token-diet-foundation`)

<!-- Anchor --> **Tier**: feature · **Parent**: token-diet · **Bubble-up target**: docs/epics/token-diet/technical-context.md

> Seed da docs/epics/token-diet/technical-context.md

## Convenzioni di progetto

### Build & test
- build_command: `—`
- test_command: `python3 scripts/measure-tokens.py` (lo script è insieme deliverable e strumento di verifica)

## Pattern architetturali

- Artefatto = prompt (vedi seed). Frontmatter YAML `description` single-line o folded; body Markdown.
- Lo script deve replicare il metodo di misura usato in fase d'analisi (char/token ~3,4 it / ~4,0 en) e
  distinguere **always-on** (somma description) da **hot-path** (body per skill/agent).

## Librerie e versioni

- Python 3 stdlib (re, glob, os). Nessuna dipendenza esterna.

## Value Objects / contratti

- Output dello script: tabella per-artefatto + totali + (con baseline) delta. Formato stabile, così le
  feature successive lo citano nel proprio gate.

## Decisioni task token-diet-foundation-001

### Path canonici
- Script: `scripts/measure-tokens.py`
- Baseline: `scripts/token-baseline.json`

### Schema baseline (versione 1)
Campi: `version`, `method`, `totals` (`tokens_desc`, `tokens_body`), `artifacts` (keyed by `rel_path`,
valori: `tokens_desc`, `tokens_body`, `chars_desc`, `chars_body`, `lang_desc`, `lang_body`).
Le feature successive citano `totals.tokens_desc` (always-on) e `totals.tokens_body` (hot-path)
come riferimento per i delta del gate di accettazione.

### Lingua detection
Euristica: ≥3 hit di segnali lessicali italiani → `it`, altrimenti `en`. Separata per description e body.
Coerente con l'approccio dell'analisi iniziale; non modificare senza aggiornare la baseline.

### CLI
`--save` per generare/aggiornare baseline; `--delta` per confronto. Entrambi idempotenti
se run sullo stesso codebase.

## Decisioni task token-diet-foundation-002

### Path del documento di protocollo
- `docs/epics/token-diet/compression-protocol.md` — path definitivo (era "es." nell'abstract).
- Il documento è **single-source** per protocollo, metodo di estrazione checklist e criteri gate.
- Tutte le feature successive devono includere un gate report nel task brief (formato §3 del documento).

### Contratto gate report
Schema obbligatorio nelle feature di riscrittura:
- Voce checklist: `EC-NNN | <file>:<sezione> | <descrizione ≤ 20 parole>`
- Esiti checklist: `OK` / `EQUIVALENTE` / `DEGRADATO` / `MANCANTE`
- Esiti diff semantico: `INVARIATO` / `EQUIVALENTE` / `DIVERGENTE`
- Soglie vincolanti: 0 `MANCANTE`, 0 `DIVERGENTE`, delta token ≤ 0% (senza giustificazione)

---
Aggiornato: 2026-06-03 | Versione: 3 (post task-002)

---
Generato: 2026-06-03 | Versione: 1
