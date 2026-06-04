---
name: flow-sync
description: Reconcile/repair del drift tra .flow/PROGRESS.json (stato d'esecuzione canonico) e i marker Status dei tasks-file (docs/planning/05-tasks-active.md, docs/features/*/tasks-active.md). Chiude il loop di whats-next: quella RILEVA il drift in sola lettura, flow-sync lo RIPARA. Preview di default (classifica e mostra i diff/entry proposti, NON scrive), apply su conferma esplicita. Ripara solo i casi sicuri (safe-repair PROGRESS→file) + import conservativo (file ✅ done ma ID assente in PROGRESS → entry done) + riconciliazione in avanti dello `Status feature` nelle roadmap epic (backstop del mirror best-effort di flow-run), segnala ambigui/orphan senza mai sovrascriverli. Scope global/plan/feature come whats-next, risoluzione context-root via scan (ID opachi). Triggera su "flow-sync", "riallinea lo stato", "ripara il drift", "sincronizza PROGRESS", "allinea PROGRESS e tasks-file", "fix dello stato dopo un expand", "riconcilia lo stato del piano".
---

# Flow Sync — reconcile/repair state drift

Repair **drift** between `.flow/PROGRESS.json` (canonical execution state) and `Status` markers in tasks-files. Closes the `whats-next` loop: that skill **detects** drift read-only; you **classify** and **repair** safe cases only. Not a task executor (`flow-run`) nor a planner: acts on state only.

## Principles (non-negotiable)

- **PROGRESS is truth per-source**: truth is `.flow/sources/<slug>/PROGRESS.json`. IDs in its `tasks[]` → canonical `state`; absent IDs → fall back to tasks-file `Status`.
- **Archived source → frozen done**: `index.json` `archived=true` → all tasks treated as `done`. No repair, no import; classify `in-sync`, no writes.
- **Root fallback**: `.flow/PROGRESS.json` consulted only if `.flow/sources/<slug>/PROGRESS.json` is absent for that slug.
- **Auto only on safe drift**: write **exclusively** on `safe-repair` (PROGRESS→file, forward-only) or `import` (file `✅` + ID absent in PROGRESS). All else is report-only.
- **Conservative import**: file→PROGRESS only for `✅ done` absent from the loop, marked `imported`, always shown in preview before apply (RISK-flow-sync-001).

Class×action **matrix**: `references/reconciliation.md`. Write mechanics: `references/apply-protocol.md`. Not redefined here.

## Scope and modes

Scope mirrors `whats-next` (`../whats-next/SKILL.md` § Modes):

| Scope | Trigger | Path |
|---|---|---|
| **global** (default) | no qualifier | all active plans |
| **plan** | "…del piano" | `docs/planning/` |
| **feature** | "…nella feature \<slug\>" | `docs/features/<slug>/` |
| **task** | "…nel task \<slug\>" | `docs/tasks/<slug>/` |

Unknown/ambiguous slug → list and ask. Context-root resolved via scan; IDs globally unique and opaque (see `../planner/planning-source-contract.md`). Task-tier sources reconcile like feature sources; epic roadmap reconciliation is unchanged.

Execution modes:

- **preview** (default): classify and show diffs/entries, **writes nothing** (ASSUMPTION-flow-sync-003).
- **apply** (only on explicit confirmation after preview): execute auto-applicable actions only. `report` never writes.

## Protocol

1. **Discovery.** For each plan in scope: derive `<slug>`, look up `.flow/sources/<slug>/PROGRESS.json` (root fallback if absent), check `index.json` for `archived=true` (skip + log if true). No active plan found → say so, suggest `planner`, do not invent.
2. **Reconciliation + classification.** Reading reuses `../whats-next/references/reconcile.md` (reference, do not duplicate). Writing adds class + action per task per `references/reconciliation.md`: `in-sync` / `safe-repair` / `import` / `ambiguous` / `orphan`.
3. **Preview.** Board (per-task) + `Status` diffs for `safe-repair` + proposed entries for `import`. Ambiguous/orphan: "not touched" + reason. **Does not write.**
4. **Apply** (on confirmation): execute `safe-repair` + `import` per `references/apply-protocol.md` sequence (PROGRESS guard → backup → rewrite `Status` line → append import → persist/revalidate). `current_task` untouched.

Matrix, 3 safe-repair cases, import rule, `ABSENT ≠ CONFLICT`, write order and guards live in `references/reconciliation.md` and `references/apply-protocol.md`.

## Epic roadmap reconciliation (additive)

Backstop for `flow-run`'s best-effort mirror of `Status feature` in `roadmap.md`. **Activates only** if the source belongs to an epic.

- **Epic discovery**: glob `docs/epics/*/roadmap.md`, match via `Source: docs/features/<slug>/`. 0 matches → standalone, skip. >1 matches → anomaly, report, no writes.
- **Expected feature state**:
  - all tasks `done` (or `archived=true`) → `✅ done`
  - at least one started/done but not all → `🔵 active`
  - none started → `⚪ planned`
- **Classification** (feature granularity), reuses safe/forward semantics:
  - expected ahead → `safe-repair` (forward: `planned→active→done`). Apply rewrites **only** that line.
  - expected equal → `in-sync`.
  - file ahead of expected → `ambiguous` → **report only**, never retrograde.
- **Write scope**: in apply, touch **only** `- **Status feature**: …` in the feature block of `roadmap.md`. No other lines, no other epic files. Roadmap absent / block not locatable / line unrecognizable → skip and signal. Backup as for tasks-files.

## Output (board + commands)

```text
id            | PROGRESS.state | file Status      | class        | action
--------------|----------------|------------------|--------------|--------
<slug>-003    | done           | ⚪ todo          | safe-repair  | apply  (→ ✅ done)
<slug>-004    | ABSENT         | ✅ done          | import       | import (entry done, imported)
<slug>-005    | pending        | ✅ done          | ambiguous    | report (not touched)
```

In **preview**: board + diffs/entries + command to proceed to apply. Derivations, matrix and write order from `references/reconciliation.md` / `references/apply-protocol.md`.

Tone: senior, dense, fail-closed, no filler.

## Honesty rules on gaps

- **PROGRESS absent/unreadable for slug** (both per-source and root) → say so, no safe-repair/import on that source. Suggest `flow-run`. Other sources continue. In apply: unreadable/invalid schema → ABORT for that source, 0 writes (RISK-flow-sync-002).
- **Tasks-file unrecognizable / `Status` line not locatable** → skip that task, signal it, no write. Does not block apply (RISK-flow-sync-003).
- **Volatile drift post-`expand`** → contextualize: `planner expand` resets markers; PROGRESS remains. Typical: `done × ⚪` → safe-repair. PROGRESS is always the durable state.

## What flow-sync does NOT do

- **Does not initialize** `PROGRESS.json` (owned by `flow-run`).
- **Does not execute or expand** tasks (owned by `flow-run` / `planner`).
- **Does not write code**, does not commit, does not reformat tasks-files.
- **Does not alter** `current_task`, co-located briefs, or other tasks-file lines.
- **Does not decide** cross-plan priority or recommend next (owned by `whats-next`).
- **Never retrogrades** a marker: file ahead → `ambiguous` → report.
