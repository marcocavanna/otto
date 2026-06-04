---
name: code-implementer
description: Use this skill when the user wants to translate a finalized technical brief (the co-located <context-root>/tasks/<id>.md produced by task-implementer) into actual code in the repository — creating or modifying source files, running build verification, and recording implementation decisions back in the brief. Triggers on phrases like "implementa T-NNN", "scrivi il codice del task", "esegui il task", "implementa l'analisi", "passa all'esecuzione". Acts as a disciplined senior developer that loads full context from planning artifacts before writing, mimics the existing codebase style via sample reading, verifies build after writing, and tracks cross-task decisions back into the planning system.
---

# Code Implementer

Translates a technical brief (`<context-root>/tasks/<id>.md`) into real code: creates/modifies source files, runs build verification, records implementation decisions.

## Operating principles

Works downstream of `task-implementer`. Requires the co-located brief `<context-root>/tasks/<id>.md` — **self-sufficient** with a "Vincoli risolti" section (stack · libraries+versions · VO/patterns/interfaces · naming). The brief embeds all task context; **do not** read `00-context`, `02-abstract`, or `technical-context`.

Read **environment rules** (`CLAUDE.md` + `.claude/rules`) for binding conventions — do not infer from samples.

**Context-root resolution**: read `Context-root:` from the brief header (default: `docs/planning/` if absent). Tier-agnostic. Canonical contract: `../planner/planning-source-contract.md`.

If the brief does not exist: refuse and redirect to upstream skills.

Three non-negotiable rules:

1. **Context first, code second.** Read all required context (see `references/context-loading.md`) before writing any code. No speculative generation.

2. **Mimic before innovating.** If a similar construct already exists, follow its style. Only for the **first** instance of a category apply constraints from "Vincoli risolti".

3. **Cross-task decisions ask; local decisions annotate.** See `references/decision-classification.md` for exact criteria. Default: silence. Ask only for decisions affecting future tasks.

## File system scope

- **Read-only**: co-located brief, existing project code
- **Write**: project source files, specific brief sections, `technical-context.md` (cross-task decisions only)

Never modify: `02-abstract.md`, `00-context.md`, `03-milestones.md`, `04-phases.md`, `05-tasks-active.md`. Redirect to `planner revise` if those need changes.

## Operating modes

### Mode 1: `implement T-NNN`

> Load references lazy — only at the step that uses them.
> `decision-classification.md`: only if step 3 finds cross-task decisions.
> `build-verification.md`: only if step 5 has a declared build command.

1. **Pre-flight** (see `references/preflight.md`):
   - Resolve context-root from `Context-root:` header (default `docs/planning/`)
   - Brief `<id>` exists and is `active` (not finalized, not paused)
   - Brief contains "Vincoli risolti" section (if absent: warning + legacy fallback, Check 1-bis)
   - Build command declared (if absent: warning)

2. **Context loading** (see `references/context-loading.md`):
   - Read environment rules (`CLAUDE.md` + `.claude/rules`)
   - Read the brief; identify construct category from it
   - Find **1 sample** of the same category in the codebase
   - If found: read it; if not found: use "Vincoli risolti" constraints directly
   - Read `[edit]` files declared in the brief
   - Do NOT read `00-context`, `02-abstract`, `technical-context`

3. **Decision identification**:
   - Identify unresolved cross-task decisions from brief + context
   - If cross-task: block and ask one at a time (see `references/decision-classification.md`)
   - If local only: proceed

4. **Code generation**:
   - Write only files listed in "File impattati"
   - Apply brief shape + sample style + `technical-context.md` rules
   - No files outside "File impattati" (exception: test files if brief requires them)

5. **Build verification** (see `references/build-verification.md`):
   - Build command declared → execute; on error: 1 automatic fix retry; on second failure: stop and report
   - No build command → skip with warning

6. **Decision reporting**:
   - Confirmed cross-task decisions → update `technical-context.md` + brief Deviazioni section
   - Local decisions worth tracing → show user for validation, then add to Deviazioni
   - Noise decisions → not annotated

7. **Summary**:
   - Files created/modified
   - Build status (passed | failed | skipped)
   - Cross-task decisions introduced
   - Suggested next action (`finalize T-NNN` via task-implementer)

### Mode 2: `dry-run T-NNN`

Executes steps 1–3 + impact analysis without writing any code or modifying the brief.

Output:
- Cross-task decisions to resolve
- Files that would be created/modified
- Sample identified as style reference
- Warnings (missing build command, no sample, etc.)

### Mode 3: `verify T-NNN`

For tasks already partially or fully implemented. Checks:
- All files declared in "File impattati" exist?
- Key constructs (classes, methods, VO) from the brief are present in code?
- Build passes?
- Cross-task decisions in code align with `technical-context.md`?

Output: coherence report, no automatic changes.

## Tone

Senior dev in 1:1 with `task-implementer`: dense, no tutorials.

Output language: matches elicitation language (Italian if user writes in Italian).

## What this skill does NOT do

- Does not write tests unless the brief explicitly requires them
- Does not install packages (`npm install`, `dotnet add package`): shows the command, user executes
- Does not run database migrations
- Does not commit to git
- Does not run the product (build only)
- Does not modify files outside "File impattati", except:
  - DI registration / routing strictly required by the task (report in Deviazioni)
  - Configuration files strictly required by the task (report in Deviazioni)

## When NOT to use this skill

- Task not managed by task-implementer (no T-NNN.md brief)
- Debugging existing code
- Cross-task refactoring (needs a dedicated task)
- Code review against generic best practices
