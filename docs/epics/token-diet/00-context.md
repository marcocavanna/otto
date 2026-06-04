# Context — Epic: Token diet del plugin otto (`token-diet`)

<!-- Anchor --> **Tier**: epic · **Parent**: — · **Bubble-up target**: —

**Progetto**: otto (plugin Claude Code — skill/agent in Markdown)
**Tipo**: epic (più feature parallele) su progetto esistente

## Cosa realizza l'epic

Ridurre il footprint in token degli artefatti caricati a runtime — le `description` (always-on, in
contesto a ogni sessione) e i body delle skill/agent (on-invoke / per-spawn) — senza perdere alcuna
regola, edge-case o capacità di triggering. Outcome osservabile: stesso comportamento del plugin con
meno token consumati per sessione e per esecuzione di flow.

## Derivato dal codebase

- **Aree/moduli toccati (d'insieme)**: `skills/*/SKILL.md` (frontmatter `description` + body), `agents/*.md`.
- **Stack pertinente**: nessun codice eseguibile da modificare; gli artefatti sono prompt in Markdown +
  frontmatter YAML. Manifest in `.claude-plugin/plugin.json`.
- **Convenzioni rilevate**: convenzione otto "italiano per chat, inglese per codice/doc interni"; le
  `description` contengono **trigger-phrase** (spesso in italiano) che pilotano l'attivazione delle skill.
- **Build/test command**: nessuno script di test/lint nel repo. La verifica è **misurazione token
  (script baseline) + diff semantico + checklist edge-case** — definita dalla feature `foundation`.

## Misurazione baseline (stima, da consolidare in foundation)

Tokenizzazione italiana ~3,4 char/token. Sempre-on = somma delle 8 `description` ≈ **1.720 tok**.
Hot-path on-invoke / per-spawn:

| Artefatto | ~token (it) | Cadenza di caricamento |
|---|---|---|
| flow-run (body) | ~8.570 | ogni esecuzione di flow |
| task-implementer (body) | ~3.184 | on-invoke |
| flow-sync (body) | ~2.725 | on-invoke |
| whats-next (body) | ~2.612 | on-invoke |
| code-implementer (body) | ~2.254 | on-invoke |
| agent solo (body) | ~2.259 | per-spawn (ramo solo) |
| agent dev (body) | ~1.540 | per-spawn (ogni task team) |
| agent pm (body) | ~1.438 | per-spawn (ogni task team) |
| migrate / critical-flow / planner (body) | ~2.490 / ~1.272 / ~955 | on-invoke (rare) |

## Decomposizione in feature

La lista ordinata vive in `roadmap.md`; qui il razionale di confine.

- **Criterio di split**: per **proprietà di file**, così i fronti non si contendono lo stesso
  `SKILL.md`/agent. La `foundation` precede tutto (definisce il guardrail anti-regressione); gli altri
  fronti editano insiemi di file disgiunti e procedono in parallelo.
- **Tronco comune**: protocollo di compressione, script di misura token, glossario IT→EN dei termini di
  dominio, gate di accettazione → seed in `technical-context.md`, ereditato da tutte le feature.

## Boundary e scope d'insieme

- **In scope (epic)**: `description` + body delle skill `flow-run`, `task-implementer`, `flow-sync`,
  `whats-next`, `code-implementer`; body+desc degli agent `dev`/`pm`/`solo`; **solo** le `description`
  di `migrate`, `planner`, `critical-flow-analysis`.
- **Fuori scope (epic)**:
  - Il **design file-based** di `flow-run` (PM/DEV comunicano via `.flow/`, prompt di spawn sottili): è
    già corretto e **non si tocca**.
  - Le **references on-demand** (`skills/planner/references/` ~113 KB, `migrate/references/` ~54 KB, ecc.):
    caricate solo a skill in esecuzione, ROI basso e rischio alto su contratti/template. Vedi RISK-token-diet-002.
  - I **body** di `migrate`/`planner`/`critical-flow-analysis` (skill rare).
  - Qualsiasi cambiamento di **comportamento/semantica** delle skill: l'epic è puramente di compressione.
- **Integrazione con l'esistente**: le `description` sono consumate dal motore di triggering di Claude
  Code; i body sono caricati come prompt di sistema all'invocazione; gli agent come prompt del subagent.
  I contratti machine-readable (`.flow/`, schema task-entry, anchor) **non** cambiano.

## Tracked assumptions (condivise)

### ASSUMPTION-token-diet-001
- **Descrizione**: la lingua target degli artefatti riscritti è l'**inglese** per la prosa, ma le
  **trigger-phrase** (anche in italiano) restano **verbatim**.
- **Scelta**: prosa EN (migliore tokenizzazione + aderenza), trigger IT/EN preservati alla lettera.
- **Alternative valutate**: (a) tutto IT — meno efficiente; (b) tutto EN trigger compresi — rischio di
  degradare l'attivazione su prompt utente in italiano.
- **Impatta**: 02-abstract.md, technical-context.md, tutte le feature.
- **Status**: active
- **Data**: 2026-06-03

### ASSUMPTION-token-diet-002
- **Descrizione**: sizing feature in t-shirt size (S/M/L) indicativo; i task reali nascono a `expand`.
- **Scelta**: nessun effort numerico in roadmap.
- **Alternative valutate**: stima a ore — speculativa prima di `expand`.
- **Impatta**: roadmap.md
- **Status**: active
- **Data**: 2026-06-03

## Known risks (cross-feature)

### RISK-token-diet-001 — Perdita di regole/edge-case nella potatura
- **Severità**: 🔴 alta
- **Descrizione**: i body (specie `flow-run`) contengono edge-case densi (escalation, biforcazione
  solo/team, dry-run policy, model-tiering, degradi conservativi). Una compressione aggressiva può
  eliminarne silenziosamente.
- **Mitigazione**: la `foundation` impone un **gate di accettazione** = diff semantico + checklist
  edge-case estratta dal file originale; nessuna feature è `done` senza gate verde.

### RISK-token-diet-002 — Degrado del triggering comprimendo le `description`
- **Severità**: 🟡 media
- **Descrizione**: le `description` pilotano l'attivazione; comprimerle/tradurle può ridurre la
  precisione di match, soprattutto su prompt italiani.
- **Mitigazione**: preservare le trigger-phrase verbatim (ASSUMPTION-token-diet-001); comprimere solo la
  prosa esplicativa, non l'elenco trigger.

### RISK-token-diet-003 — Verifica solo proxy (nessun test automatico del triggering)
- **Severità**: 🟢 bassa
- **Descrizione**: non esiste un test che misuri l'aderenza/triggering reale post-riscrittura; la verifica
  è il proxy diff+checklist + giudizio.
- **Mitigazione**: dogfooding — eseguire un flow reale dopo le feature di flow-run/agents e osservare il
  comportamento; annotare eventuali regressioni.

---
Generato: 2026-06-03 | Versione: 1
