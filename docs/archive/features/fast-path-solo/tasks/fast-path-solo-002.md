---
Task: fast-path-solo-002
Feature: fast-path-solo
Origin: feature-planner
Context-root: docs/features/fast-path-solo/
Status: ✅ finalized
---

# fast-path-solo-002 — Nuovo agente `agents/solo.md`

## Obiettivo

Creare `agents/solo.md`: agente autonomo che in un singolo spawn esegue analisi → materializzazione scope/frozen → implementazione → verifica → produzione artefatti versionati completi. Hook identici a `dev`. Nessun dry-run separato (ASSUMPTION-fast-path-solo-002).

## Vincoli risolti

- **Stack/formato**: Markdown con frontmatter YAML (stesso schema di `agents/dev.md`). Nessuna build.
- **Dipendenza completata**: `fast-path-solo-001` è finalized — `model-tiering.md` contiene già la colonna `execution-mode` con `trivial/standard → solo`, `critical → team`. L'agente `solo` è il ruolo a cui viene assegnato `execution-mode = solo`.
- **Hook identici a `dev`** (vincolo non-negoziabile, da `technical-context.md` § "Pattern architetturali"):
  - `PreToolUse(Write|Edit) → ${CLAUDE_PLUGIN_ROOT}/hooks/scope-check.sh`
  - `PreToolUse(Bash) → ${CLAUDE_PLUGIN_ROOT}/hooks/scope-check.sh`
  - `Stop → ${CLAUDE_PLUGIN_ROOT}/hooks/verify-gate.sh`
- **Tools**: `Read, Write, Edit, Bash, Grep, Glob` (identici a `dev`; no Agent — è una foglia).
- **Model default**: `sonnet` (sovrascritto per-spawn da `flow-run` con il modello derivato dalla complessità).
- **Risoluzione `SKILL_DIR`**: identica a `dev.md` (primo match tra `$CLAUDE_PLUGIN_ROOT/skills`, cache plugin, `./skills`, `./.claude/skills`). Anomalia → `ESCALATION.json` L3.
- **Lettura lazy delle skill**: `task-implementer` (analisi + materializzazione scope/frozen + produzione brief co-locato + append `technical-context.md`) e `code-implementer` (implement + verify). Non caricare upfront `build-verification.md`/`decision-classification.md` su task trivial/standard.
- **Fonte task**: PROGRESS per-source (`.flow/sources/<slug>/PROGRESS.json` → `current_task`) sotto lock (`flow_resolve_task` di `flow-lib.sh`). MAI `.flow/PROGRESS.json` radice (legacy).
- **Input dall'orchestratore**: modalità (`implement`) e TASK nel messaggio di spawn.
- **Bootstrap scope**: `scope-check.sh` consente `.flow/briefs/<TASK>/**` prima che `scope.txt` esista — riusato invariato (da `technical-context.md`).
- **Artefatti versionati** (contratto INVARIANTE in struttura): `<context-root>/tasks/<id>.md` con sezioni obbligatorie (Vincoli risolti · File impattati · Shape reale · Deviazioni · `Status: ✅ finalized`) + append `technical-context.md` se decisioni cumulative.
- **`RESULT.json`**: contratto invariato (`escalate`, `verify`, `deviations`). `escalate=true` se `ESCALATION.json` emesso.
- **Escalation**: su anomalia bloccante → `.flow/briefs/<TASK>/ESCALATION.json` `{ "level":"L2|L3", "reason":"..." }` e termina.
- **Override attended per decisioni cross-task**: `solo` NON può parlare con l'utente. Su contratto frozen / dipendenza nuova / pattern cross-task / conflitto strategico → `ESCALATION.json` e termina (stessa lista di trigger di `dev.md`).
- **Subtask**: nessuno necessario, esecuzione lineare.
- **`technical-context.md`**: l'agente lo scrive in append-only solo per decisioni cumulative proprie del task implementato — MAI per decisioni cross-task (quelle → escalation).

## File impattati

- `agents/solo.md` [new] — il nuovo agente

## Shape

### `agents/solo.md` — struttura attesa

```markdown
---
name: solo
description: agente autonomo fast-path. In un singolo spawn esegue analisi + implementazione + verifica + produzione artefatti versionati.
tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
hooks:
  PreToolUse:
    - matcher: "Write|Edit"
      hooks: [{ type: command, command: "${CLAUDE_PLUGIN_ROOT}/hooks/scope-check.sh" }]
    - matcher: "Bash"
      hooks: [{ type: command, command: "${CLAUDE_PLUGIN_ROOT}/hooks/scope-check.sh" }]
  Stop:
    - hooks: [{ type: command, command: "${CLAUDE_PLUGIN_ROOT}/hooks/verify-gate.sh" }]
---

Sei il **SOLO** del loop fast-path. In un singolo spawn esegui: analisi del task → materializzazione scope/frozen → implementazione → verifica → produzione artefatti versionati completi.

`<SKILL_DIR>` NON è un path fisso. Risolvilo a runtime (primo match vince):

```bash
SKILL_DIR="$(for d in "$CLAUDE_PLUGIN_ROOT/skills" ~/.claude/plugins/cache/*/otto/*/skills ./skills ./.claude/skills; do [ -d "$d/task-implementer" ] && echo "$d" && break; done)"
```

Se resta vuoto: scrivi `.flow/briefs/<TASK>/ESCALATION.json` con `{ "level":"L3", "reason":"skill task-implementer non trovata: plugin otto non installato correttamente" }` e termina.

## Input

L'orchestratore ti passa la **modalità** (`implement`) e il **TASK** nel messaggio di spawn.
Se manca, risolvilo dal PROGRESS per-source della source attiva (`.flow/sources/<slug>/PROGRESS.json` → `current_task`), MAI dal `.flow/PROGRESS.json` radice (legacy).

## Sequenza interna (un solo spawn, nessun dry-run separato)

### (a) Risoluzione task

Leggi `.flow/sources/<slug>/PROGRESS.json` sotto lock (`flow_resolve_task` di `flow-lib.sh`) per confermare il TASK corrente e la context-root della source attiva.

### (b) Analisi (read-only)

Leggi le istruzioni di `task-implementer` lazy:
- `<SKILL_DIR>/task-implementer/SKILL.md`
- `<SKILL_DIR>/task-implementer/attended-flow.md`

Poi leggi dalla context-root:
- `00-context.md`
- `02-abstract.md`
- `technical-context.md` (se esiste)
- il tasks-file (il task + vicini per dipendenze)

### (c) Materializzazione scope/frozen

Prima di qualsiasi scrittura di codice, materializza in `.flow/briefs/<TASK>/`:
- `scope.txt` — glob dei file scrivibili (uno per riga, niente commenti, niente YAML)
- `frozen.txt` — interfacce/VO/contratti da non toccare (uno per riga)
- `meta.json` — `{ "complexity": "...", "category": "..." }` (best-effort, non bloccante)

Il bootstrap di `scope-check.sh` consente `.flow/briefs/<TASK>/**` prima che `scope.txt` esista.

### (d) Implementazione (gate-ata)

Leggi le istruzioni di `code-implementer` lazy:
- `<SKILL_DIR>/code-implementer/SKILL.md`
- reference solo allo step che le usa (non caricare `build-verification.md`/`decision-classification.md` upfront su trivial/standard)

Implementa SOLO dentro i path di `scope.txt`. Se `scope-check.sh` blocca un path → è fuori scope → valuta escalation.

### (e) Verifica

Esegui la verifica come da `code-implementer`. Se build_command dichiarato: eseguilo. Se assente: annota `"build skipped: <motivo>"` in `deviations`.

### (f) Produzione artefatti versionati

Scrivi `<context-root>/tasks/<id>.md` completo con sezioni obbligatorie:
- **Vincoli risolti** (stack, librerie, VO/pattern/interfacce consumati, naming)
- **File impattati** (path esatti con `[new]`/`[edit]`)
- **Shape reale** (shape post-implementazione, ~20-30 righe per costrutto, marcato "shape, non implementazione finale")
- **Deviazioni** (rispetto al piano iniziale)
- Header: `Status: ✅ finalized`

Se ci sono decisioni cumulative (nuovo VO, pattern, libreria, convenzione): append a `<context-root>/technical-context.md`.

### (g) RESULT.json

Scrivi SEMPRE `.flow/briefs/<TASK>/RESULT.json`:

```json
{ "verify": "pass | fail", "deviations": ["..."], "escalate": false }
```

- `verify="pass"` se implement+verify ok o build skipped per assenza toolchain.
- `verify="fail"` se build fallisce dopo retry.
- `escalate=true` se hai scritto `ESCALATION.json`.

## Override attended (decisioni cross-task)

NON puoi parlare con l'utente. Su:
- modifica a interfaccia/VO/contratto in `frozen.txt`
- nuova dipendenza/libreria non in `technical-context.md`
- nuovo pattern/VO/convenzione cross-task
- impatto cross-task, conflitto con `02-abstract.md`
- boundary multi-tenant o sicurezza
- più di 3 decisioni cross-task

→ **NON risolvere e NON chiedere**. Scrivi `.flow/briefs/<TASK>/ESCALATION.json`:
```json
{ "level": "L2 | L3", "reason": "<motivo conciso e azionabile>" }
```
e termina con summary `ESCALATION: <motivo>`.

## Regole

- Mai usare il tool Agent (non disponibile, vietato): sei una foglia.
- Output in italiano, denso. Summary finale: file toccati, stato build/verify, eventuale `ESCALATION:`.
- Non scrivere `technical-context.md` per decisioni cross-task (→ escalation).
- Non leggere `docs/tasks/`, `00-context.md`, `02-abstract.md` fuori dalla sequenza (b): il brief è già nella sequenza self-sufficient.
```

> Shape, non implementazione finale. La struttura delle sezioni può variare; il contenuto descritto deve essere presente integralmente.

## Procedura di implementazione (DEV)

1. **Crea `agents/solo.md`** — nuovo file, nessun file da rinominare o modificare in questo task.
2. **Frontmatter YAML**: copia lo schema da `agents/dev.md` con `name: solo`, `description` sintetica, `tools` identici, `model: sonnet`, hook identici (matcher e command path invariati).
3. **Corpo istruzioni**: segui lo shape sopra. Struttura a sezioni con heading chiari. Priorità: la sequenza interna `(a)→(g)` deve essere esplicita e ordinata.
4. **Verifica hook**: i path `${CLAUDE_PLUGIN_ROOT}/hooks/scope-check.sh` e `${CLAUDE_PLUGIN_ROOT}/hooks/verify-gate.sh` devono essere identici a `agents/dev.md` — nessun nuovo hook, nessuna variante.
5. **Lint visivo**: fence markdown bilanciate, nessun link interno rotto, coerenza con il frontmatter di `dev.md`.
6. **Nessun file aggiuntivo**: questo task produce SOLO `agents/solo.md`. `model-tiering.md`, `flow-run/SKILL.md`, `task-implementer/` sono out of scope.

## Out of scope per questo task

- Lettura della `Complessità (ipotesi)` a monte e ramo `solo` in `flow-run/SKILL.md` — task fast-path-solo-003.
- Contratto artefatti modalità `solo` in `task-implementer/SKILL.md` — task fast-path-solo-004.
- Dogfooding end-to-end — task fast-path-solo-005.
- Modifica a `model-tiering.md` (completato da fast-path-solo-001, frozen).
- Modifica a `agents/dev.md`, `agents/pm.md`, hook bash (`scope-check.sh`, `verify-gate.sh`).
- Modifica alla struttura di `RESULT.json` o `ESCALATION.json` (contratto invariato).
- Campo `promote` in `RESULT.json` — feature `fast-path-promotion`.
- Modalità `dry-run` separata (ASSUMPTION-fast-path-solo-002: in `solo` non esiste dry-run).
