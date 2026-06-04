---
name: whats-next
description: Advisor read-only che risponde "cosa faccio adesso / dopo" su un progetto con piani di lavoro otto. Fa il join di tutti i piani attivi (piani di progetto e feature generati da `planner`), riconcilia lo stato reale d'esecuzione con `.flow/index.json` (veloce) o `.flow/sources/*/PROGRESS.json` (fallback per-source), e produce un board multi-piano + una raccomandazione ragionata (cosa è sbloccato ora, cosa è quasi finito, cosa è sul critical path) con comandi concatenabili verso flow-run. NON modifica nulla, NON decide la priorità tra piani: la espone e la motiva. Supporta query globali o scoped. Triggera su "whats-next", "cosa devo fare dopo/adesso", "prossimo step/task", "next", "a che punto sono", "prossimo sprint", "stato del piano", "whats-next nella milestone M[N]", "whats-next nella feature <slug>".
---

# Whats Next — read-only operational advisor

Answer **"what do I do now / next"** on a project using otto plans. You are a **counselor**, not an executor: `flow-run` executes, you indicate *what* and *why*. Output is concatenable: `flow-run <id>`.

## State principle

Read-only projection over existing artifacts. Never write: no plans, no `.flow/`, no code.

Execution truth is **distributed per-source**:
- `.flow/index.json` — aggregated roll-up; use as first read if present.
- Fallback: `.flow/sources/*/PROGRESS.json` + `.flow/locks/*/` (dir present = source alive).
- `.flow/PROGRESS.json` — legacy singleton; use only for IDs absent from any per-source source.
- No `.flow/` = no flow ever executed.

## Priority principle (non-negotiable)

With macro-plan + parallel features, **no deterministic global "next" exists**. Make the calculable part deterministic (blocked/unblocked/almost-done/stalled), expose the judgment part with a motivated recommendation. Never impose. User decides; you provide the ready command.

## Data sources (read-only)

- `docs/planning/05-tasks-active.md` — atomic tasks of the active milestone only.
- `docs/planning/03-milestones.md` — milestone states (🔵 active / ⚪ planned / ✅ done / ⏸ paused).
- `docs/features/*/tasks-active.md` — parallel feature tasks.
- `docs/tasks/*/tasks-active.md` — standalone task-tier; parent hierarchy via `Parent` anchor in `00-context.md`.
- `docs/epics/*/roadmap.md` — **(optional, additive)** epic coordination: groups `<epic>-<feat>` features, declares inter-feature order/deps. If absent, features stay flat. See `references/epic-rollup.md`.
- `.flow/index.json` — roll-up `source → {owner, alive, active, done, pending, archived}`; first read.
- `.flow/sources/<slug>/PROGRESS.json` — per-source truth; fallback if index absent.
- `.flow/locks/<slug>/` — dir present = source alive (fallback scan).
- `.flow/PROGRESS.json` — legacy singleton; retrocompat for non-migrated IDs.

Task format (project/feature identical, see `../planner/references/task-expansion.md` and `../planner/planning-source-contract.md`): ID, category, `Effort` (hour range), `Dipende da`, `Status` (⚪🔵✅⏸). IDs globally unique — treat opaquely.

## Modes

- **global** (default): all active plans → board + cross-plan recommendation.
- **plan**: "…del piano / del progetto / del macro-plan" → only `docs/planning/`.
- **milestone**: "…nella milestone M[N]" → special case below.
- **feature**: "…nella feature <slug>" → only `docs/features/<slug>/`. Slug missing/ambiguous: list available and ask.
- **epic**: "…nell'epic <epic>" → `<epic>-*` features via `docs/epics/<epic>/roadmap.md`. Epic not found: list available and ask. See `references/epic-rollup.md`.

## Protocol

1. **Discovery.** Identify in-scope plans. Find each tasks-file + `.flow/index.json` or per-source PROGRESS. No plan → say so and suggest `planner`. Never invent.
2. **State reconciliation** per task — see `references/reconcile.md`.
   - If `index.json` present: load per-source `{..., archived}` as pre-filter before opening PROGRESS. Source with `archived=true`: done tasks frozen; skip its `tasks-active.md` for active tasks.
   - Canonical per-task = per-source PROGRESS (or legacy singleton for non-migrated IDs); fallback = tasks-file `Status`.
   - Report every **drift**; never correct (read-only).
3. **Per-plan computation:**
   - Parse → `{id, category, effort, deps, reconciled-state}`
   - **Shell / unexpanded source** (no real task entries): not executable → next action is `planner expand <slug>`. Flag on board.
   - **Unblocked** = `todo` + all deps `done`
   - **Plan next** = highest critical-path weight among unblocked; tie → file order
   - **Progress** = ✅ / total
   - **Blockers** = `⏸` or `todo` with unsatisfied deps
4. **Hierarchical roll-up** (additive) — parent→child from `Parent` anchor; roadmap `Source` as fallback. Group features under epic if `docs/epics/*/roadmap.md` exists; respect inter-feature order/deps. See `references/epic-rollup.md`. No anchor/roadmap → sources flat.
5. **Cross-plan ranking** (global only) — see `references/ranking.md`: WIP-advanced → macro critical-path → quick-win. Exposed heuristic, not truth. With epics, ranking unit can be the epic.
6. **3-level output** (see below).

### Milestone scoped — special case

`05-tasks-active.md` has atomic tasks for the **active milestone only**:
- Requested == active → show its tasks (as plan mode).
- Requested ≠ active → **no atomic tasks**: show macro from `03-milestones.md` only; state: *"M[N] is not the active milestone: no atomic tasks. To expand: `planner expand M[N]`."* Do not invent tasks.

## Output — 3 levels

1. **Board** — all in-scope plans: name, % progress, next unblocked, blockers/⚠. Flag drift.
2. **Motivated recommendation** — 1-3 moves with **why** (unblocks N / closes stalled feature / critical path / quick win). Global: apply ranking; scoped: plan next.
3. **Concatenable commands** — ready-to-copy per move:
   - Expanded source + unblocked tasks → `flow-run <id>`
   - Shell/unexpanded → `planner expand <slug>`
   - Not yet planned → `planner <description>`

Tone: senior, dense, no filler, no cheerleading.

## Honesty rules (explicit gaps)

- **No declared deps** (`Dipende da: —`) → warn; order by phase/category, not critical-path.
- **Effort is a range** → horizon is heuristic, not guaranteed. Say so.
- **No `.flow/`** → warn; use tasks-file `Status` (may not reflect actual work).
- **Drift PROGRESS ↔ tasks-file** → report; never fix. To repair: use `flow-sync` (preview default, apply on confirmation — repairs safe drifts, flags ambiguous/orphan). whats-next detects, flow-sync repairs.
- **Tasks-file unrecognized / task missing** → skip and annotate; never invent.

## What this skill does NOT do

- Write anything (no plans, no `.flow/`, no code, no commits).
- Decide macro-vs-feature priority (motivates, lets user choose).
- Expand milestones or generate tasks (`planner`'s job).
- Execute tasks (`flow-run`'s job).
