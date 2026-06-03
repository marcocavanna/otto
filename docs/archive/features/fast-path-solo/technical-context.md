# Technical context — Feature: Modalità `solo` (`fast-path-solo`)

<!-- Anchor -->
**Tier**: feature
**Parent**: fast-path
**Bubble-up target**: docs/epics/fast-path/technical-context.md

> Seed da docs/epics/fast-path/technical-context.md
> Le sezioni sotto sono ereditate dal seed condiviso dell'epic (vincolanti). `task-implementer`/agente `solo` estendono **questo** file in append-only durante il flow; il bubble-up al padre avviene a `planner finalize`.

## Convenzioni di progetto
### Build & test
- build_command: `—` (Markdown + hook bash; nessuna build).
- test_command: `—` — verifica = dogfooding + lint manuale dei reference.

## Pattern architetturali condivisi (dal seed epic)
- **Asse `complexity → policy` single-source** in `skills/flow-run/references/model-tiering.md`: questa feature vi aggiunge la colonna `execution-mode`. Gli altri file linkano, non duplicano.
- **Derivazione effimera dell'orchestratore**: l'`execution-mode` è risolto nel turno, mai persistito (come modello/dry-run).
- **Enforcement per ruolo via hook di frontmatter**: solo i subagent ereditano `scope-check`/`verify-gate`. L'agente `solo` DEVE dichiarare gli stessi hook di `dev` (vincolo non-negoziabile della sicurezza).
- **Risoluzione task sotto lock** (`flow-lib.sh` § `flow_resolve_task`) e **bootstrap dello scope** (`scope-check.sh` consente `.flow/briefs/<TASK>/*` prima di `scope.txt`): riusati invariati dall'agente `solo`.

## Value Objects / contratti condivisi (dal seed epic)
- **`complexity`** `{trivial, standard, critical}` — consumare, non ridefinire (fonti in seed epic).
- **`execution-mode`** `{solo, team}` (2.1.0) — definito qui via mappa in `model-tiering.md`.
- **Artefatti versionati del task** (INVARIANTI in struttura): `<context-root>/tasks/<id>.md` + append `technical-context.md`. In `solo` cambia solo l'ordine di produzione (ASSUMPTION-fast-path-003).
- **`RESULT.json`**: contratto invariato in questa feature (`escalate`, `verify`, `deviations`). Il campo `promote` lo aggiunge `fast-path-promotion`.

## Decisioni tattiche (fast-path-solo)
> Sezione append-only popolata durante il flow da `task-implementer`/agente `solo`. Vuota alla pianificazione: le decisioni di dettaglio (forma messaggi di spawn, esito rinomina file mappa, naming dei costrutti) si registrano qui durante l'esecuzione.

### fast-path-solo-001 — finalized 2026-06-03

- **Rinomina `model-tiering.md → execution-tiering.md`**: NON eseguita. Grep runtime: 18 file `.md` con riferimento al vecchio nome, la maggior parte fuori scope (skills/migrate, skills/task-implementer, docs, README, skills/flow-run/SKILL.md). Aggiornato solo titolo/scopo interno del file — nessun link orfano introdotto.
- **Struttura tabella `## Mappa`**: 3 colonne (`complexity | modello DEV | execution-mode`), non 4. La colonna `dry-run` è rimasta nella sua tabella dedicata `## Dry-run`. Struttura più pulita, nessun doppione; contenuto equivalente allo shape del brief.
- **Tutte le sezioni richieste presenti**: `## Enum execution-mode (2.1.0)`, `## Precedenza — execution-mode` (override utente > mappa > default team), degrado `execution-mode = team` nella sezione `## Degrado graceful`. Nessun link orfano, nessuna regola duplicata.

## Librerie e versioni
Nessuna libreria di terze parti. Tooling: `bash`, `jq`, `git`. Modelli via alias (`haiku`/`sonnet`/`opus`).

---
Generato: 2026-06-03 | Versione: 1

### fast-path-solo-001: mappa `complexity → execution-mode` (brief)
- **File target**: `skills/flow-run/references/model-tiering.md` (rinomina opzionale a `execution-tiering.md` — decision demandata al DEV con grep runtime dei link entranti).
- **Colonna aggiunta**: `execution-mode ∈ {solo, team}` affianca le colonne modello/dry-run nella tabella principale.
- **Degrado**: complessità assente/fuori-enum/illeggibile → `execution-mode = team` (fail-safe, coerente con il pattern dry-run esistente).
- **Override utente**: effimero, annotato nel summary, stessa meccanica degli override modello esistenti.
- **Sezione "Precedenza"**: estesa con `execution-mode` (override utente > mappa > default team).
- **Decisione rinomina**: differita a runtime del task — il DEV decide dopo il grep (se link orfani irrisolvibili: solo aggiornamento titolo/scopo interno).

### fast-path-solo-002: agente `solo` (brief)
- **File target**: `agents/solo.md` [new] — unico file del task.
- **Frontmatter**: identico a `agents/dev.md` (`tools`, `hooks`, `model: sonnet`). Nome `solo`, description sintetica.
- **Sequenza interna**: (a) risoluzione task sotto lock → (b) analisi read-only → (c) materializzazione `scope.txt`/`frozen.txt`/`meta.json` → (d) implementazione gate-ata → (e) verifica → (f) produzione artefatti versionati completi (`<context-root>/tasks/<id>.md` finalized + append `technical-context.md`) → (g) `RESULT.json`.
- **Nessun dry-run separato**: ASSUMPTION-fast-path-solo-002 — analisi e implementazione nello stesso contesto.
- **Override attended**: lista trigger identica a `dev.md` (frozen/cross-task/sicurezza → `ESCALATION.json` + termina).
- **Contratto artefatto**: `<context-root>/tasks/<id>.md` con sezioni obbligatorie invariate (Vincoli risolti · File impattati · Shape reale · Deviazioni · `Status: ✅ finalized`).

### fast-path-solo-003: ramo `solo` nel protocollo di `flow-run` (esecuzione manuale)
- **File target**: `skills/flow-run/SKILL.md` [edit] (+19/-1), 4 innesti: passo `1b` (risoluzione `execution-mode` a monte), biforcazione + wrapper "Ramo `team`", nuova § "Ramo `solo`" (S1–S4), riga `solo` in § "Spawn".
- **Lettura complessità a monte**: dal tasks-file (campo `Complessità (ipotesi)`), al passo di selezione/attivazione, prima di ogni spawn. Degrado → `team`. Effimero (non in `PROGRESS.json`).
- **Non-regressione `team`**: i passi 3–6 sono **incapsulati** sotto "Ramo `team`", non riscritti — non-regressione per costruzione.
- **Decisione: `promote` predisposto ma inerte** — il ramo S3 definisce il punto d'innesto della promozione `solo → team` (pre-write) e la distinzione dai fail post-write, ma il campo `RESULT.promote` è introdotto solo da `fast-path-promotion`. Placeholder di contratto, zero logica attiva: riduce la churn quando arriverà la feature successiva.
- **Esecuzione manuale** (RISK-fast-path-001): editato il file direttamente dal main thread, non via `flow-run` (si modificava l'orchestratore stesso).
