---
name: feature-planner
description: Use this skill when the user wants to plan a SINGLE feature on an EXISTING project (not a whole new project), producing one or more atomic tasks (no milestones) ready for task-implementer / code-implementer / flow-run. Triggers on phrases like "pianifica la feature X", "feature-planner", "voglio aggiungere la feature ...", "fammi i task per questa feature", "plan a feature", "scope this feature into tasks". Behaves like project-planner (guided elicitation, surfaces assumptions, pushes back on weaknesses) but scoped to one feature on a codebase that already exists. Derives technical context from the existing codebase + a short elicitation. Writes a per-feature, isolated artifact set in docs/features/<slug>/.
---

# Feature Planner

Sotto-skill di `project-planner`, scoped a **una singola feature** su un **progetto esistente**. Stesso comportamento (elicitation guidata, assunzioni esplicite, push-back sui punti deboli), ma:

- **niente milestone / fasi / pitch**: produce solo contesto + abstract + technical-context + task atomici;
- **contesto derivato dal codebase** esistente + elicitation breve, non da zero;
- **namespace isolato per feature**: `docs/features/<slug>/`;
- output **conforme al contratto downstream** (vedi `references/feature-artifacts.md` § "Planning source contract"), così `task-implementer`, `code-implementer` e `flow-run` lo consumano **senza modifiche di sostanza** (solo un additivo di risoluzione context-root già cablato nei downstream).

## Operating principles

Eredita i tre principi di `project-planner` (vedi `../project-planner/SKILL.md`): **no filler**, **assunzioni esplicite > guess impliciti**, **push back, don't validate**. Applica le stesse regole di elicitation e critica:

- elicitation: segui `../project-planner/elicitation.md` ma **scoped alla sola feature** (non re-elicitare l'intero progetto);
- critica preliminare: segui `../project-planner/critical-review.md`;
- granularità task: segui `../project-planner/task-expansion.md` (regole 1-4h, DoD binaria, verbo+oggetto, categorie 🏗️💻🧪📚🔬🚀🔧).

Differenza chiave: il contesto **non si elicita da zero**. Prima si **deriva dal codebase**, poi si chiede solo ciò che il codice non rivela.

## Derivazione dal codebase (precede l'elicitation)

Prima di chiedere all'utente, ispeziona il repo per inferire stack/convenzioni/build:

1. `CLAUDE.md` di root e dei sub-progetti (routing, stack, vincoli).
2. `.claude/assistant/{project,codebase,code}/00-summary.md` e i file linkati pertinenti alla feature.
3. Sample di codice della stessa categoria della feature (1-2 file rappresentativi) per stile/pattern.
4. Build/test command: da `package.json`, `*.csproj`/`*.sln`, script noti, o knowledge in `.claude/assistant/code`.

Da qui pre-compila `technical-context.md` (build_command, pattern, convenzioni) e bozza di `02-abstract.md`. Poi l'elicitation copre **solo i gap**: comportamento atteso, boundary, edge case, acceptance, vincoli non desumibili dal codice.

Se l'ispezione è insufficiente (repo opaco, niente knowledge), dillo e passa a elicitation più estesa — non inventare convenzioni.

## Operating modes

### Mode 1: `plan <feature>` — pianificare una feature (default)

1. Verifica che la cwd sia un repo di progetto. Se ambiguo, chiedi conferma del path.
2. Deriva lo **slug** kebab-case dal nome feature (es. "Export utenti CSV" → `user-export`). Conferma con l'utente se non ovvio.
3. Se `docs/features/<slug>/` esiste già → **rifiuta overwrite**, indirizza a `revise <feature>` o `expand <feature>`.
4. **Derivazione dal codebase** (sopra) → bozze di technical-context + abstract.
5. **Elicitation breve** sui gap (`../project-planner/elicitation.md`, scoped).
6. **Critica** del materiale elicitato (`../project-planner/critical-review.md`): scope sproporzionato? boundary poco chiari? rischi non detti? Solleva PRIMA di generare.
7. Genera in `docs/features/<slug>/` i **4 file** (vedi `references/feature-artifacts.md`):
   - `00-context.md` — contesto feature + tracked assumptions + rischi.
   - `02-abstract.md` — abstract tecnico della feature: moduli toccati, approccio, integrazione, esclusioni.
   - `technical-context.md` — **seed** tattico: build_command, pattern/convenzioni da seguire (riferiti al codebase). `task-implementer` lo estende in append-only.
   - `tasks-active.md` — 1..N task atomici, **ID `<slug>-NNN`**, nessuna milestone (campo `Feature: <slug>`).
8. Summary: task creati, assunzioni più fragili, prossimo passo (`flow-run` o `task-implementer brief <slug>-NNN`).

### Mode 2: `expand <feature>` — rigenerare/estendere i task della feature

1. Leggi `docs/features/<slug>/{00-context,02-abstract,technical-context}.md`.
2. (Ri)genera i task atomici in `tasks-active.md` secondo `../project-planner/task-expansion.md`. Backup `tasks-active.md.bak` prima di sovrascrivere.
3. Mantieni gli ID `<slug>-NNN` stabili dove possibile; non riusare un ID per un task diverso.

### Mode 3: `revise <feature>` — aggiornare quando un'assunzione cambia

1. Chiedi quale assunzione è cambiata e il nuovo valore.
2. Trova in `00-context.md` quali artefatti dipendono da essa.
3. Aggiorna in place gli artefatti interessati, preservando struttura. Marca l'assunzione vecchia come superseded, aggiungi la nuova con data.
4. Stampa un diff summary.

## Vincoli di scope

- Scrive **solo** sotto `docs/features/<slug>/`. Mai `docs/planning/`, mai codice, mai i file degli altri sub-progetti.
- Non genera milestone/fasi/pitch: non è project-planner. Per un progetto intero usa `project-planner`.
- ID task **globalmente unici** (`<slug>-NNN`): è il requisito che permette ai downstream di risolvere la context-root via scan, senza parametri extra. Vedi `references/feature-artifacts.md` § "Planning source contract".

## Tone

Stesso registro di project-planner: senior PM/tech-lead in 1:1, denso, niente didattica, niente cheerleading. Lingua dell'elicitation.

## When NOT to use

- Per pianificare un progetto intero da zero → `project-planner`.
- Per tradurre un task già pianificato in brief tecnico → `task-implementer`.
- Per scrivere il codice di un task → `code-implementer`.
