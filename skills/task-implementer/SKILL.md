---
name: task-implementer
description: Use this skill when the user wants to translate a planned task (from project-planner's docs/planning/05-tasks-active.md) into a technical implementation brief — covering stack, libraries with versions, code patterns, operational assumptions, and shape-level code snippets. Triggers on phrases like "analizza il task T-NNN", "fammi il brief tecnico", "come implemento questo task", "passa all'analisi tecnica", "preparami il piano di implementazione". Also triggers when the user wants to finalize a completed task (update technical-context.md with reality), archive briefs at milestone end, or check coherence of accumulated technical decisions. Acts as a senior tech lead that produces actionable per-task analysis while maintaining a coherent shared technical context across the project.
---

# Task Implementer

Translates each planned atomic task into a technical brief; maintains global coherence via `technical-context.md`.

## Prerequisites

Requires (from the resolved context-root):
- `00-context.md` — assumptions, risks
- `02-abstract.md` — strategic decisions (binding)
- tasks-file — active task list

If missing → refuse and redirect to `planner`.

## Non-negotiable rules

1. **Coherence > completeness.** If a brief decision contradicts `technical-context.md`, do NOT proceed silently — raise and resolve the conflict before writing.
2. **Shape only, no bodies.** Snippets in briefs: signatures, types, contracts, insertion points — no method bodies or full logic (that is DEV scope). Hard limit: ~10–15 lines per construct, structure only. A snippet with a non-trivial body is already implementation: remove it.
3. **Subtasks are exceptions.** Default: none. Generate only if criteria in `references/subtask-criteria.md` are met. If not → output explicitly: `"Subtask: nessuno necessario, esecuzione lineare."`

## Non-contradiction invariant

`technical-context.md` must not contradict `02-abstract.md`. If analysis reveals a flawed strategic choice → stop, tell the user to run `planner revise` on `02-abstract.md` before continuing.

## File layout (managed by this skill)

```
<context-root>/             # docs/planning/ (project) | docs/features/<slug>/ (feature) | docs/tasks/<slug>/ (task-tier)
  02-abstract.md            # strategic — constrains technical-context.md
  technical-context.md      # tactical — owned by this skill
  tasks/
    <id>.md                 # T-NNN (project) | <slug>-NNN (feature/task-tier)
    archive/                # project only — concluded milestone briefs (Mode 4)
      M1/
        T-001.md
```

Briefs are always co-located under their context-root. The old flat `docs/tasks/` layout is not read or written. Run `migrate` on pre-canonical projects before operating.

---

## Modes

### Mode 1: `brief T-NNN`

> Load each reference lazily — only at the step that uses it. Load `technical-context.md` only if it exists and is non-empty. Load `complexity-criteria.md` only when producing `meta.json`.

1. **Resolve context-root.** Scan tasks-files across all tiers — `docs/planning/05-tasks-active.md`, `docs/features/*/tasks-active.md`, `docs/tasks/*/tasks-active.md` — excluding `docs/archive/**`. Only directories containing a `tasks-active.md` are sources. The file containing the ID defines the source, context-root, and tasks-file.
   - 0 matches → error "task sconosciuto"; >1 match → error "ID ambiguo".
   - **Explicit override (preferred)**: if caller passes `context_root: <path>` (e.g. from orchestrator spawn prompt), set context-root directly — **skip the scan**. More reliable than scanning when called from flow-run.
   - **Feature override**: if caller passes `feature <slug>`, use `docs/features/<slug>/` as context-root without scanning.
   - Classic-project fallback: context-root = `docs/planning/`, tasks-file = `05-tasks-active.md`.
2. **Read in a single parallel batch** (no read dependencies):
   - `00-context.md`
   - `02-abstract.md` (binding)
   - `technical-context.md` (if exists)
   - tasks-file (current task + neighbors for dependencies)
   - If the feature belongs to an epic (`00-context.md` has `**Epic**: <epic>`, or `docs/epics/<epic>/roadmap.md` references it): **also read** `docs/epics/<epic>/technical-context.md`. Binding, read-only — never modify from here (bubble-up is `planner finalize`).
3. Run elicitation (`references/brief-elicitation.md`).
4. Validate coherence against `technical-context.md` — resolve conflicts **before** writing.
5. Write the brief at the canonical co-located path `<context-root>/tasks/<id>.md` (`references/brief-template.md`). Create `tasks/` under context-root if absent.
   - Header must include `Origin:` and `Context-root:`. For feature tasks: use `Feature:`, never `Milestone:` — do not invent a milestone.
   - Brief must include the mandatory section `## Vincoli risolti` (makes the brief self-sufficient for the DEV).
6. If the brief introduces cumulative decisions (new VO, pattern, library) → append-only to `technical-context.md` of the resolved context-root.
7. Print summary: decisions made, entries added to `technical-context.md`.

> **Attended mode** (flow-run only): after step 5, also materialize `scope.txt` and `frozen.txt`. See `references/attended-flow.md`. Additive — does not change brief generation. The `.flow/briefs/<id>/brief.md` file is a copy of the co-located brief; source of truth remains the co-located file.

> **Solo mode** (when task runs as `solo` via flow-run): the co-located brief `<context-root>/tasks/<id>.md` is produced by the `solo` agent **after** implementation, reflecting reality. Structure is identical to `team` (mandatory sections: `Vincoli risolti · File impattati · Shape · Deviazioni · Status: ✅ finalized`). The PM does not produce a separate pre-brief. See `references/attended-flow.md` and `agents/solo.md`.

### Mode 2: `deviation T-NNN`

1. Resolve context-root (scan, as Mode 1). Verify the co-located brief `<context-root>/tasks/<id>.md` exists and is not archived.
2. Ask: what changed from the original brief?
3. Append entry to section `## Deviazioni durante l'implementazione` (create if absent).
4. Do NOT modify `technical-context.md` here — that happens at finalize.

### Mode 3: `finalize T-NNN`

> **Attended gate** (flow-run only): before step 1, check `.flow/briefs/<TASK>/RESULT.json` (`verify == "pass"`) and absence of open `ESCALATION.json`. If either fails → block finalize.

1. Resolve context-root (scan, as Mode 1). Verify the co-located brief exists.
2. Show: original brief decisions + recorded deviations.
3. **Mandatory question:** "Qualcosa in `technical-context.md` è cambiato per effetto di questo task? (es. libreria diversa da quella prevista, pattern modificato, naming convention introdotta)"
4. If yes → guide targeted update of `technical-context.md`.
5. Mark brief header: `Status: ✅ finalized`.
6. Do NOT touch the tasks-file — user's or `planner`'s responsibility.

### Mode 4: `archive-milestone M[N]`

1. Verify M[N] is marked done in `03-milestones.md`; if not → ask explicit confirmation.
2. Verify all M[N] tasks in `05-tasks-active.md` are done; if not → list open tasks and ask confirmation.
3. `git mv` briefs from `docs/planning/tasks/` to `docs/planning/tasks/archive/M[N]/` — stay co-located under the project context-root. (Feature archive is a full-directory operation in `docs/archive/features/<slug>/`, done by `flow-run`, not this mode.)
4. `technical-context.md` is NOT archived or modified.
5. Print summary: briefs archived, decisions now historical but still binding.

### Mode 5: `check-coherence`

Utility — no file modifications.
1. Read all co-located briefs (`<context-root>/tasks/*.md`, excluding `archive/`).
2. Check: library versions consistent with `technical-context.md`? All referenced VOs defined? Contradictions between briefs?
3. Output coherence report only.

---

## Tone

Senior tech lead 1:1 with a competent developer. No didactics. No "great choice". Direct, dense, professional.

Output language follows elicitation language (Italian if the user writes in Italian).

## When NOT to use

- Tasks without a `planner` plan (requires `docs/planning/` or `docs/features/<slug>/`).
- Post-implementation code review.
- Generating complete production code for a task.
- Tasks with effort >4h — split with `planner` first.
