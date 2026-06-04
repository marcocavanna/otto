---
name: flow-run
description: Orchestratore "attended" del loop PM→DEV su un piano di task. Eseguito dal main thread. Guida i subagent pm e dev (un solo livello di delega), che comunicano solo via file in .flow/. Spawna il DEV con un modello scelto dinamicamente in base alla complessità del task (tiering dal meta.json del PM), con possibilità di override manuale del modello per un run (es. "esegui solo T-003 con opus"). Si ferma a interpellare l'utente (AskUserQuestion) SOLO su escalation: deviazione fuori scope, verify fallito oltre i retry, cambio di contratto. A finalize riflette lo status nel tasks-file della source del task: docs/planning/05-tasks-active.md (project) o docs/features/<slug>/tasks-active.md (feature) — mirror non-canonico. Supporta full-run (tutti i pending) e single-task (un solo task indicato). Triggera su "avvia il flow", "esegui il piano", "flow-run", "fai girare il loop PM/DEV", "prossimo task del flow", "esegui solo T-NNN", "flow-run T-NNN", "esegui con opus", "forza il modello del dev".
---

# Flow Run — orchestratore attended

You are the **main thread** = ORCHESTRATOR. PM and DEV are direct child subagents (one level only: a subagent cannot spawn others). PM and DEV do not communicate with each other — only via files in `.flow/`. Spawn via `Agent` tool with `subagent_type: pm` / `subagent_type: dev`.

## State principle

Loop state lives in **`.flow/sources/<slug>/PROGRESS.json`** (per-source, execution truth), never in memory. Re-read it on every resume.

```json
{ "source": "<slug>", "context_root": "docs/features/<slug>/",
  "owner": "<descriptor>", "current_task": "T-001",
  "tasks": [ { "id": "T-001", "state": "pending|active|done" } ] }
```

`.flow/PROGRESS.json` (root) is **legacy** — never read or write as loop state.

## Attended mode

- Only the main thread uses `AskUserQuestion`. Subagents write `ESCALATION.json` / `RESULT.json` and terminate; you read them and escalate if needed.
- Fail-closed: any anomaly (missing file, unreadable JSON, incomplete PM output) → escalate; never advance to next task.

## Execution mode selection

**Single-task** — user specifies a task (e.g. *"esegui solo T-003"*, *"flow-run T-003"*): process only that task (steps 2–6 once) and stop. If not `pending` in `PROGRESS.json`, ask confirmation before re-running.

**Full-run** — default: iterate all `pending` in order until done or escalation.

### Model override (user input)

Extract from user input:
- flag: `--model <haiku|sonnet|opus>`
- natural: *"con/in/usa <haiku|sonnet|opus>"*

Alias outside `{haiku, sonnet, opus}` → **no override** + note in summary (don't escalate).

Default: override applies to **DEV only**. Extends to PM only if user says so explicitly (e.g. *"tutto in opus"*, *"PM e DEV in opus"*).

Precedence: see [`references/model-tiering.md`](references/model-tiering.md) § Precedenza — user override wins over all. Override is **ephemeral** (current turn only; never persisted).

Extract also a **dry-run directive**: *"salta il dry-run"* / `--no-dry-run` → skip; *"forza il dry-run"* / `--dry-run` → run. Wins over complexity policy. Also ephemeral.

### Pre-check: concurrent flow (advisory, non-blocking)

**Once at startup, before claim**: scan `.flow/locks/*/heartbeat.ts`; a lock is **alive** if `now - mtime < 300s` (see [`references/concurrency.md`](references/concurrency.md)).

- No live lock → proceed to claim.
- At least one live lock → **`AskUserQuestion`**: report slug(s) + owner, warn parallel flows unsupported (may corrupt state). Options: **Cancel (recommended)** / **Proceed anyway** (user assumes risk). On cancel → exit cleanly without claiming. On proceed → annotate in summary.

> False positive on resume (heartbeat still fresh): "Proceed" is correct. This is an advisory, not a hard lock.

### Claim source

Before the task loop, **acquire the source** via advisory lock. Algorithm details: single-source in [`references/concurrency.md`](references/concurrency.md).

1. Scan sources with `pending` tasks, in order.
2. For each: `mkdir .flow/locks/<slug>/`.
   - Success → lock acquired: write `heartbeat.ts`, enter.
   - EEXIST → check if stale (see `references/concurrency.md` § Soglia di reclaim):
     - Stale → **reclaim**, enter.
     - Live → **skip**, next source.
3. No claim succeeds → report "nessuna source disponibile", exit with success (not escalation).
4. **Init PROGRESS** (immediately after claim, before task loop):
   - Exists → load and reuse (idempotent on reclaim; never re-initialize).
   - Missing → `mkdir -p .flow/sources/<slug>/`; build from `tasks-active.md`: `state="done"` if Status row is done, else `"pending"`; `current_task=null`; fill `owner`/`context_root`. Write order: PROGRESS → `heartbeat.ts`. Then upsert entry in `.flow/index.json` (slug → `{ owner, alive:true, active:null, done, pending, archived:false }`); if `index.json` missing or invalid, **reconstruct first** (see § Reconstruct index.json).
5. Execute task protocol below; read/write only the per-source PROGRESS. Update `heartbeat.ts` on every state transition (order: PROGRESS → heartbeat; see `references/concurrency.md` § Aggiornamento heartbeat).
6. On source completion or abandon: **release** (`rm -rf .flow/locks/<slug>/`, idempotent). Update `index.json`: `alive=false`, `active=null`.

### Reconstruct index.json

If `.flow/index.json` missing or invalid:

1. Scan `.flow/locks/`: each `<slug>/` is a candidate source.
2. For each `<slug>`: read `.flow/sources/<slug>/PROGRESS.json`.
   - Exists → populate entry: `owner` from PROGRESS, `alive` from `heartbeat.ts` mtime, `active`/`done`/`pending` from PROGRESS, `archived:false`.
   - Missing → minimal entry `{ owner:"unknown", alive:false, active:null, done:0, pending:0, archived:false }`.
3. Scan `.flow/sources/`: PROGRESS without matching lock → entry with `alive:false`.
4. Write reconstructed file.

`index.json` is a fault-tolerant cache: a corrupt PROGRESS produces a degraded entry, not a fatal error. `archived` always initializes to `false` here; `true` is set only by auto-archive.

### Auto-archive at source end

**Trigger**: all tasks in per-source PROGRESS have `state="done"` after marking the last task done. Never on reclaim. Sequence **under lock**.

Steps 1–2 are **best-effort, fail-soft** and run **only if the source belongs to an epic** (see § Resolve source epic). Never escalate on failure; annotate in summary and continue. Steps 1–2 must precede `git mv` because they read/update artefacts still live in `docs/features/<slug>/`.

Steps 3–6 are the **mandatory sequence** (order is binding for idempotency):

1. **Consolidate technical-context → parent** (`#8`): run **`planner finalize <slug>`** (single-source: [`../planner/references/finalize.md`](../planner/references/finalize.md) § "Bubble-up single-hop selettivo") in **attended mode** — automatic selection of all coherent `## Decisioni tattiche …` sections. Append-only, dated, with **idempotency guard** (`## Consolidato da <slug>` already present → skip).
2. **Mirror epic roadmap → done** (`#10`): set this feature's `Status feature` row in `docs/epics/<epic>/roadmap.md` to `✅ done` (see § Mirror epic roadmap). Idempotent (set, not append).
3. **`git mv`** `docs/features/<slug>/` → `docs/archive/features/<slug>/` (`mkdir -p docs/archive/features/` first).
   - Recovery: DST exists + SRC missing → already moved, skip. Both exist → write `ESCALATION.json` `{ "level":"L2", "reason":"archivio parziale non recuperabile: SRC e DST coesistono" }` and abort.
   - `git mv` fails (source untracked) → `mv` fallback, annotate in summary.
4. **Clean** `.flow/sources/<slug>/` and `.flow/briefs/<task>/` for all source tasks (`#11`, `rm -rf`, idempotent).
5. **Release lock** (`rm -rf .flow/locks/<slug>/`, idempotent).
6. **Update `index.json`**: `archived=true`, `alive=false`, `active=null`. If missing/corrupt: reconstruct first (§ Reconstruct index.json) then update.

Never commit. Annotate in summary: "Source `<slug>` archiviata in `docs/archive/features/<slug>/`. Commit NON eseguito."

## Protocol (per task)

**1. Read plan + per-source PROGRESS.**
- Full-run: take next `pending` task. If none → all done: run auto-archive, then end source and report.
- Single-task: take the user-indicated task.

**1b. Resolve `execution-mode`** (once per task, before any spawn) from single-source [`references/model-tiering.md`](references/model-tiering.md) § "Mappa". Read **`Complessità (ipotesi)`** from the task row in the source tasks-file: `trivial`/`standard` → **`solo`**; `critical` → **`team`**.

- **Conservative fallback**: complexity missing/unreadable/out-of-enum, or task row unresolvable → **`team`** (NEVER `solo`) + note in summary.
- **User override** (*"esegui in team"*, *"forza solo"*, `--mode <solo|team>`) → wins, ephemeral, annotated.

`execution-mode` is ephemeral — never persisted.

**2. Activate task BEFORE spawn**: set `current_task = <task>` and `state = "active"` in per-source PROGRESS. Write file, then update `heartbeat.ts` (order: PROGRESS → heartbeat). Update `index.json`: `active = <task>`, updated counts.

**Mirror epic roadmap → active** (`#10`, best-effort, fail-soft): if source belongs to an epic and its `Status feature` is still `⚪ planned`, set to `🔵 active`. Only planned→active; if already active/done, do not touch. Standalone source or unresolved roadmap → skip silently.

---

> **Bifurcation by `execution-mode`**: if **`team`** → execute steps 3–6 below. If **`solo`** → jump to § Solo branch.

---

### Team branch (`execution-mode == team`)

**3. Spawn `pm` → `brief <task>`.** On return: verify `.flow/briefs/<task>/scope.txt` and `.flow/briefs/<task>/frozen.txt` exist and are not empty. Missing/empty or `ESCALATION.json` present → go to **7**.

**3b. Derive task policies** from single-source [`references/model-tiering.md`](references/model-tiering.md) (once per task). Three outputs: **DEV model**, **dry-run policy**, **finalize PM model**.

- **Manual override present**: use forced model for DEV. Do NOT read `meta.json` for model — override has maximum precedence. For dry-run: explicit override (*"salta/forza"*) wins; otherwise use complexity policy below. Annotate in summary.
- **No override**: read `.flow/briefs/<task>/meta.json`. Apply policies via single-source:
  - DEV model: `trivial→haiku`, `standard→sonnet`, `critical→opus`
  - dry-run: `trivial`/`standard` → **skip**, `critical` → **run**
  - finalize PM model: `trivial`/`standard` → `haiku`, `critical` → `sonnet`
  - `meta.json` missing/unreadable/`complexity` out-of-enum → **conservative fallback**: DEV=`sonnet` (NEVER haiku), dry-run=`run`, finalize=`sonnet` + note in summary.

DEV model is **the same** in steps 4 and 5 (same task = same model).

**4. Dry-run (conditional, see 3b).**
- Policy = **run** (critical, or meta.json absent/unreadable, or *"forza"* override): **spawn `dev` → `dry-run`** with `model: <derived>`. On return: `ESCALATION.json` exists → go to **7**.
- Policy = **skip** (trivial/standard, no override): skip spawn; go to 5. First escalation checkpoint is implement.

**5. Spawn `dev` → `implement`** (implement + verify) with the **same** `model: <derived>` as the DEV.

**6. Read `.flow/briefs/<task>/RESULT.json`.** If `escalate==true` OR `verify!="pass"` OR `ESCALATION.json` present → go to **7**.

Otherwise **finalize** via one of two paths:

- **Finalize inline (fast-path)** — IF task is `trivial`/`standard` AND `RESULT.deviations` contains no functional deviations (environment-only notes like `"build skipped..."` allowed; any substantive deviation or doubt → PM path): the orchestrator closes the task without spawning PM. Resolve the on-disk brief path from `Context-root:` in `.flow/briefs/<task>/brief.md` header: canonical path `<context-root>/tasks/<id>.md` (missing `Context-root:` → default `docs/planning/`). Mark `Status: ✅ finalized` in the resolved brief. Do NOT touch `technical-context.md`.
- **Finalize PM (default)** — otherwise (critical task, functional deviations, or override extended to PM): **spawn `pm` → `finalize <task>`** with `model: <finalize derived>`. PM re-verifies reality vs brief and may update `technical-context.md`.

In both cases: set `state="done"` in per-source PROGRESS, write file, update `heartbeat.ts` (order: PROGRESS → heartbeat), then **mirror status** (see below). In full-run, after marking last task done: if all tasks `done` → run § Auto-archive; else return to **1**. In single-task: report summary and stop.

---

### Solo branch (`execution-mode == solo`)

Replaces steps 3–6 with a single spawn. No `pm brief`, no separate dry-run. The `solo` agent has the **same hooks** as DEV (`scope-check`/`verify-gate`) — writes are gated, verify is enforced. See `agents/solo.md`.

**S1. Derive model** from `Complessità (ipotesi)` via [`references/model-tiering.md`](references/model-tiering.md) § "Mappa" (`trivial→haiku`, `standard→sonnet`; user override / fallback as for DEV). `solo` never runs on `critical` (those resolve to `team` in 1b).

**S2. Spawn `solo` → `implement`** (`subagent_type: solo`, `model: <derived>`). In one context the agent: analyzes → materializes `scope.txt`/`frozen.txt` in `.flow/briefs/<task>/` → implements (gated) → verifies → **produces versioned artefacts**: `<context-root>/tasks/<id>.md` complete (Vincoli risolti · File impattati · Shape · Deviazioni · `Status: ✅ finalized`) + append `technical-context.md` if cumulative decisions → emits `RESULT.json`.

**S3. Read `.flow/briefs/<task>/RESULT.json`.**
- **`promote==true`** → **solo→team promotion** (pre-write, clean working tree): re-run **this same task** from step **3** in team (execute 3 → 3b → 4 → 5 → 6 without touching PROGRESS or marking done). Annotate: `"PROMOTED <task>: <promote_reason> → re-eseguito in team"`. Evaluated **before** `escalate`/`verify`.
- Else: **`escalate==true` OR `verify!="pass"` OR `ESCALATION.json` present** → go to **7** (post-write fail; never promote).

**S4. Finalize gate (orchestrator).** Gate passed (`verify=="pass"`, no escalation): brief is already finalized (written by agent in S2; orchestrator spawns no finalize). Set `state="done"` in per-source PROGRESS, write file, update `heartbeat.ts`, then **mirror status** (same procedure as team branch). Full-run: if all done → § Auto-archive; else return to **1**. Single-task: report summary and stop.

---

### Mirror status on source tasks-file (at finalize OK)

After marking `done` in `PROGRESS.json`, reflect it in the source **tasks-file** (see contract in `../planner/planning-source-contract.md` § "Planning source contract"): `docs/planning/05-tasks-active.md` or `docs/features/<slug>/tasks-active.md`. Find the task's `Status` row and mark completion per file convention. **Modify only that row.**

Constraints:
- Non-canonical mirror: execution truth stays in `PROGRESS.json`. Task not found or unrecognizable format → skip, annotate in summary (not escalation).
- `planner expand` overwrites the tasks-file; after expand, mirror needs re-alignment (durable state is always `PROGRESS.json`). Signal in summary if drift detected.

### Resolve source epic

Best-effort: glob `docs/epics/*/roadmap.md`; for each, search for a line `Source: docs/features/<slug>/` referencing this source.

- 0 matches → standalone source: no roadmap mirror, no technical-context consolidation. Skip silently.
- 1 match → use that epic for roadmap mirror and consolidation.
- >1 matches → anomaly (slug in multiple roadmaps): skip both epic operations, annotate in summary. Don't escalate.

### Mirror epic roadmap (best-effort)

`Status feature` is a **non-canonical, advisory** reflection (execution truth stays in PROGRESS + tasks-file). Update best-effort, fail-soft.

- **planned → active**: first task activation (step 2), if still `⚪ planned`.
- **active → done**: auto-archive (step 2 of sequence).

Constraints:
- In `docs/epics/<epic>/roadmap.md`, find the feature block (`### <slug> — …`) and modify **only** its `- **Status feature**: …` row.
- **Forward-only** transitions: never revert. If state is already equal or more advanced, do not touch.
- Roadmap missing, feature not found, or row format unrecognizable → skip, annotate. Not an escalation.

**7. ESCALATION.** Read `level` + `reason` from `.flow/briefs/<task>/ESCALATION.json` (or, if absent, the fail reason from `RESULT.json` / detected anomaly). Use **`AskUserQuestion`** reporting level+reason and proposing action options (e.g. revise planning, reopen brief, override scope, abandon task). **STOP**: do not advance to other tasks without user response.

## Spawn — what to pass to subagents

| Subagent | Prompt |
|---|---|
| `pm` brief | `"Funzione: brief. TASK: <task>. Segui pm.md."` |
| `pm` finalize | `"Funzione: finalize. TASK: <task>. Applica il gate attended."` — spawn with `model: <finalize derived>` |
| `dev` dry-run | `"Modalità: dry-run. TASK: <task>. Leggi solo .flow/briefs/<task>/brief.md."` — with `model: <derived>`. **Run only if dry-run policy = run.** |
| `dev` implement | `"Modalità: implement. TASK: <task>."` — same `model: <derived>` as dry-run |
| `solo` implement | `"Modalità: implement. TASK: <task>."` — `subagent_type: solo`, `model: <derived>`. Single spawn only. |

Keep prompts thin. Business logic source is the on-disk brief.

> DEV model for spawn precedes the DEV frontmatter. Manual override wins over dynamic derivation. On meta.json absent/unreadable → `sonnet` + note. Smoke-check (RISK-model-tiering-002): if Claude Code does not honor the per-spawn model, DEV runs on frontmatter model (sonnet baseline) → graceful degradation, annotate in summary; not an escalation.

## Archive convention

Concluded features and epics are archived under:
- `docs/archive/features/<slug>/` — archived features
- `docs/archive/epics/<slug>/` — archived epics

`docs/archive/**` is excluded from resolution scans (context-root and tasks-file). Archived tasks are never `pending`. Source: `skills/planner/planning-source-contract.md`.

## Rules

- Never `git commit`/`push`. Never modify sub-projects beyond what the brief declares.
- One delegation level only: you spawn pm/dev; they spawn nothing.
- If `.flow/` does not exist, initialize it (PROGRESS.json from task plan) before the loop.
- After every state transition: **persist per-source PROGRESS** (`.flow/sources/<slug>/PROGRESS.json`) — then `heartbeat.ts` — before continuing.
- DEV model selection (step 3b) — dynamic derivation and manual override — is **ephemeral**: never enters PROGRESS.json or any on-disk contract. If per-spawn override not honored, degrades to DEV frontmatter — not an anomaly to escalate.

## Compression notes

- [NOTA] Sezione "Risoluzione epic della source" e "Mirror status sulla roadmap epic" erano sezioni separate in fondo al file originale; qui integrate nel flusso per ridurre la navigazione verticale. Semantica identica.
