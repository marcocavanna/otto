# Technical context (shared) — Epic: Token diet del plugin otto (`token-diet`)

<!-- Anchor --> **Tier**: epic · **Parent**: — · **Bubble-up target**: —

## Convenzioni di progetto

### Build & test
- build_command: `—` (nessuna build: artefatti Markdown/YAML)
- test_command: `—` (nessun test automatico nel repo)
- verifica: **script di misura token** (foundation) + **diff semantico** + **checklist edge-case** + (per
  flow-run/agents) **dogfooding** di un flow reale.

## Pattern architetturali condivisi

- **Artefatto = prompt**: ogni `SKILL.md`/agent `.md` è un prompt caricato a runtime. `description`
  (frontmatter YAML, single-line o folded `>`/`>-`) = always-on; body Markdown = on-invoke/per-spawn.
- **Protocollo di compressione**: definito in `docs/epics/token-diet/compression-protocol.md` (single-source).
  Sintesi: (1) estrai checklist edge-case → (2) riscrivi (potatura + EN + liste) → (3) trigger-phrase verbatim
  → (4) gate (checklist coverage + diff semantico + delta token ≥ −20%) → (5) annota, non correggere.
  Ogni feature di riscrittura **deve includere un gate report** nel task brief (formato in `compression-protocol.md §3`).
- **Glossario IT→EN** (deliverable foundation): traduzione canonica dei termini di dominio otto
  (es. *task* → task, *brief*, *flow-run*, *escalation*, *dry-run*, *finalize*, *ramo solo/team*,
  *tasks-file*, *contratto*) per coerenza terminologica tra file.

## Value Objects / contratti condivisi

Invarianti per **tutte** le feature (mai da rompere nella riscrittura):
- `RESULT.json` / `ESCALATION.json` (contratti DEV↔orchestratore).
- Hook `scope-check` / `verify-gate`.
- Schema task-entry, anchor schema, layout `.flow/` (`PROGRESS.json`, `index.json`).
- Design file-based di flow-run e prompt di spawn sottili.
- Trigger-phrase di ogni skill/agent.

## Librerie e versioni

- Plugin otto 2.1.0 (`.claude-plugin/plugin.json`).
- Tokenizzazione di riferimento per la misura: stima ~3,4 char/token (it), ~4,0 (en); lo script della
  foundation fissa il metodo esatto e produce i numeri autorevoli (i valori in `00-context.md` sono stime).

---
Aggiornato: 2026-06-03 | Versione: 2 (post token-diet-foundation-002: link a compression-protocol.md)

## Consolidato da token-diet-foundation (2026-06-03)
> Decisioni durevoli risalite dalla feature `token-diet-foundation` a fine feature
> (bubble-up single-hop). Vincolanti per le feature successive.

### Path canonici (tooling foundation)
- Script di misura: `scripts/measure-tokens.py`
- Baseline: `scripts/token-baseline.json`
- Documento di protocollo (single-source): `docs/epics/token-diet/compression-protocol.md`

### Schema baseline (versione 1)
Campi: `version`, `method`, `totals` (`tokens_desc`, `tokens_body`), `artifacts` (keyed by `rel_path`,
valori: `tokens_desc`, `tokens_body`, `chars_desc`, `chars_body`, `lang_desc`, `lang_body`).
Le feature successive citano `totals.tokens_desc` (always-on) e `totals.tokens_body` (hot-path)
come riferimento per i delta del gate di accettazione.

### Contratto gate report (obbligatorio in ogni feature di riscrittura)
- Voce checklist: `EC-NNN | <file>:<sezione> | <descrizione ≤ 20 parole>`
- Esiti checklist: `OK` / `EQUIVALENTE` / `DEGRADATO` / `MANCANTE`
- Esiti diff semantico: `INVARIATO` / `EQUIVALENTE` / `DIVERGENTE`
- Soglie vincolanti: 0 `MANCANTE`, 0 `DIVERGENTE`, delta token ≤ 0% (senza giustificazione)
