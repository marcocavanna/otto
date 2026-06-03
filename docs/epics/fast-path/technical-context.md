# Technical context (shared) — Epic: Fast Path — esecuzione `solo` (`fast-path`)

<!-- Anchor -->
**Tier**: epic
**Parent**: —
**Bubble-up target**: —

> Seed condiviso ereditato da **tutte** le feature figlie. Ogni `docs/features/fast-path-*/technical-context.md` è seedato da qui; `task-implementer`/agente `solo` estendono il file del *figlio* in append-only, non questo.

## Convenzioni di progetto
### Build & test
- build_command: `—` (plugin di solo Markdown + hook bash; nessuna build).
- test_command: `—` — verifica = **dogfooding** (pianificare + eseguire end-to-end via le skill) + lint manuale dei reference (fence bilanciate, link interni risolvibili, single-source non duplicate).

### Stile dei reference / skill
- `SKILL.md` **sottile** (router + principi), logica nei `references/` a **lettura lazy** (leggi il reference solo allo step che lo usa).
- **Single-source**: un contratto/una mappa vive in un solo file ed è **linkato**, mai duplicato. Modificare la fonte, non le copie.
- Prosa **densa**, niente filler, niente didattica. Italiano per i contenuti, inglese dove la convenzione del file lo impone.

## Pattern architetturali condivisi
- **Asse `complexity → policy` (single-source)**: `skills/flow-run/references/model-tiering.md` è l'**unico** posto dove `complexity ∈ {trivial, standard, critical}` mappa su policy. Oggi: modello DEV, dry-run sì/no, modello finalize. Questo epic aggiunge la quarta colonna **`execution-mode`**. Gli altri file **linkano** la mappa, non la ridefiniscono.
- **Derivazione effimera dell'orchestratore**: modello, dry-run e (nuovo) `execution-mode` sono risolti da `flow-run` **nel turno**, NON persistiti in `PROGRESS.json` né in alcun contratto su disco. Stessa filosofia per tutti e tre/quattro.
- **Enforcement per ruolo via hook di frontmatter**: le scritture dei subagent sono gate-ate da hook registrati nel **frontmatter dell'agente** (`agents/dev.md` → `scope-check.sh` PreToolUse + `verify-gate.sh` Stop). NON sono hook globali (`hooks/hooks.json` registra solo SessionStart/UserPromptSubmit). **Conseguenza vincolante**: solo un **subagent** eredita la rete di sicurezza; il main-thread no. Il nuovo agente `solo` DEVE dichiarare gli stessi hook di `dev`.
- **Risoluzione task sotto lock**: `hooks/flow-lib.sh` § `flow_resolve_task` risolve il task attivo dalla source sotto lock (`.flow/sources/<slug>/PROGRESS.json` → `current_task`), **indipendentemente dal tipo di subagent**. L'agente `solo` ne beneficia senza modifiche.
- **Bootstrap dello scope**: `scope-check.sh` consente sempre la scrittura sotto `.flow/briefs/<TASK>/` (anche prima che `scope.txt` esista), per permettere a un agente self-sufficient di materializzare i propri contratti prima di toccare il codice. L'agente `solo` lo sfrutta: scrive `scope.txt`/`frozen.txt` per primo, poi il codice resta gate-ato.

## Value Objects / contratti condivisi
- **`complexity`**: enum chiuso `{trivial, standard, critical}`. Fonte autorevole dell'euristica di assegnazione a priori: `skills/planner/references/task-expansion.md` § "Assegnazione `Complessità (ipotesi)`". Fonte dell'autovalutazione del PM: `skills/task-implementer/references/complexity-criteria.md`. Schema del campo nel task-entry: `skills/planner/planning-source-contract.md` § "Schema task-entry". **Da consumare, non ridefinire.**
- **`execution-mode`** (NUOVO, definito da questo epic): enum `{solo, team}` in 2.1.0 (`inline` riservato a release futura, ASSUMPTION-fast-path-002). Mappa da `complexity`: vedi `model-tiering.md` (esteso da `fast-path-solo`).
- **Artefatti versionati del task** (INVARIANTI): `<context-root>/tasks/<id>.md` con sezioni obbligatorie (`Vincoli risolti` · `File impattati` · `Shape` · `Deviazioni durante l'implementazione` · header `Status`); append a `<context-root>/technical-context.md` per decisioni cumulative. Contratto: `skills/task-implementer/references/brief-template.md` + `planning-source-contract.md` § "Vincoli risolti". **La modalità di esecuzione non ne cambia la struttura, solo l'ordine di produzione (ASSUMPTION-fast-path-003).**
- **`RESULT.json`** (lato agente): contratto del risultato d'implementazione letto da `flow-run` (`escalate`, `verify`, `deviations`). `fast-path-promotion` vi aggiunge il segnale **`promote`** (read-only, pre-write) — vedi `docs/features/fast-path-promotion/technical-context.md`.
- **`ESCALATION.json`**: contratto invariato; resta il canale dei fail **post-write**. La promozione `solo → team` **non** passa da qui (è pre-write, via `RESULT.promote`).

## Librerie e versioni
Nessuna libreria di terze parti. Tooling: `bash`, `jq`, `git` (già assunti dagli hook esistenti). Modelli (alias, non ID pinned, per resilienza ai version-bump): `haiku`/`sonnet`/`opus` mappati da `complexity` in `model-tiering.md`.

## Consolidato da fast-path-promotion
> Bubble-up single-hop a `planner finalize` (auto, flow-run). Data: 2026-06-03.

### DECISION-fast-path-promotion-001 — Collocazione reference lista trigger
- **Decisione**: il reference `promotion-triggers.md` è collocato in `skills/flow-run/references/`.
- **Rationale**: i trigger sono valutati dall'agente `solo` **prima** del ramo `team` (step S2 in `flow-run`); la collocazione è coerente col punto di consumo. Alternativa scartata: `skills/code-implementer/` (il file non è consumato dal DEV ma dall'agente solo come pre-analisi del ramo flow-run).
- **Impatta**: `agents/solo.md`, `skills/flow-run/SKILL.md`.

### DECISION-fast-path-promotion-002 — Soglie numeriche T1
- **Decisione**: T1 misura `>3 file` su task `trivial`, `>6 file` su task `standard`. Calibrabili via dogfooding.
- **Rationale**: soglie derivate dal segnale 3 di `complexity-criteria.md` (`>3` file = alto); su `standard` la soglia è alzata perché il task per definizione ha estensione media (2-3 file) e il bias deve essere verso la rarità (RISK-fast-path-promotion-001).
- **Impatta**: `skills/flow-run/references/promotion-triggers.md` § T1.

---
Generato: 2026-06-03 | Versione: 1
