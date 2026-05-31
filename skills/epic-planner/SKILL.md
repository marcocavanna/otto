---
name: epic-planner
description: Use this skill when the user wants to plan a LARGE implementation on an EXISTING project — too big for a single feature, but not a whole new project with product/market roadmap — by decomposing it into multiple LOGICAL, SEQUENTIAL features. Produces a thin non-canonical coordination layer in docs/epics/<epic>/ plus N STANDARD feature sources in docs/features/<epic>-<feat>/, each ready for task-implementer / code-implementer / flow-run with ZERO downstream changes. Triggers on phrases like "pianifica l'epic ...", "epic-planner", "scomponi questa implementazione grande in feature", "ho un lavoro grosso da spezzare in più feature", "plan an epic", "break this big work into sequential features". NOT for a single feature (use feature-planner) nor a greenfield project with pitch/milestones (use project-planner).
---

# Epic Planner — meta-planner per implementazioni grandi

Scompone una **implementazione grande** su un **progetto esistente** in più **feature logiche e sequenziali**. Sta **tra** `feature-planner` (1 feature, 1–8 task) e `project-planner` (progetto intero con pitch/milestone/market).

## Principio architetturale NON negoziabile

**Epic NON è una planning source.** È un **meta-planner / coordinatore**. Non possiede mai un `tasks-active.md` proprio, non viene mai risolto dallo scan dei downstream, non introduce un terzo *source type*.

Produce due cose:

1. **N feature source STANDARD**, materializzate **flat** in `docs/features/<epic>-<feat>/` (un livello, così lo scan downstream `docs/features/*/tasks-active.md` le trova già). Ognuna è identica a ciò che produce `feature-planner`: i 4 file canonici + ID task `<epic>-<feat>-NNN`.
2. Un **layer di coordinamento non-canonico** in `docs/epics/<epic>/`: contesto/abstract/technical-context condivisi + `roadmap.md` (ordine feature, dipendenze inter-feature, sequencing). È l'analogo di `03-milestones.md` per project-planner: **strategia, non esecuzione**.

Conseguenza diretta — **i downstream non cambiano**:
- `task-implementer` / `code-implementer`: i figli sono feature source normali, context-root risolta via scan come sempre.
- `flow-run`: gira gli ID in modo opaco; lanci una feature figlia alla volta, in ordine di roadmap.
- `flow-sync`: riconcilia PROGRESS↔Status per source; i figli sono source normali; `docs/epics/` non ha marker Status da sincronizzare.
- `whats-next`: legge **in più** (additivo) `docs/epics/*/roadmap.md` per raggruppare i figli sotto l'epic e rispettarne la sequenza; senza quel file degrada al comportamento piatto attuale.

> La sequenzialità è **advisory**: documentata in `roadmap.md`, rispettata da `whats-next` nel consiglio, guidata dall'utente verso `flow-run`. Non è gatata da `flow-run` (coerente con la filosofia *attended: l'utente decide la priorità*). Il contratto downstream non risolve dipendenze cross-source nel calcolo "sbloccato": vedi `references/epic-artifacts.md` § "Limiti onesti".

## Operating principles

Eredita i tre principi di `project-planner` (vedi `../project-planner/SKILL.md`): **no filler**, **assunzioni esplicite > guess impliciti**, **push back, don't validate**. Riusa senza duplicare:

- elicitation: `../project-planner/elicitation.md`, **scoped all'epic** (non re-elicitare l'intero progetto; deriva dal codebase ciò che il codice rivela, come `feature-planner`);
- critica preliminare: `../project-planner/critical-review.md`;
- granularità task **dentro ogni feature figlia**: `../project-planner/task-expansion.md` (1–4h, DoD binaria, verbo+oggetto, categorie 🏗️💻🧪📚🔬🚀🔧);
- template feature figlia: `../feature-planner/feature-artifacts.md` (i 4 file + Planning source contract — CANONICO).

Differenza chiave rispetto a `feature-planner`: qui il lavoro **non sta in una feature**, ma **non ha un pitch/market**. L'epic-planner aggiunge una dimensione che gli altri due non hanno: **la decomposizione in feature sequenziali coerenti** (vedi `references/decomposition.md`).

## Derivazione dal codebase (precede l'elicitation)

Come `feature-planner`, prima di chiedere ispeziona il repo per inferire stack/convenzioni/build:

1. `CLAUDE.md` di root e sub-progetti.
2. `.claude/assistant/{project,codebase,code}/00-summary.md` + file linkati pertinenti.
3. Sample di codice delle aree toccate (per stile/pattern).
4. Build/test command da `package.json` / `*.csproj` / `*.sln` / script noti.

Da qui pre-compili il **technical-context condiviso** dell'epic e la bozza di `02-abstract.md`. L'elicitation copre **solo i gap**: comportamento atteso d'insieme, boundary tra le feature, edge case, acceptance, vincoli non desumibili. Se l'ispezione è insufficiente, dillo e passa a elicitation più estesa — non inventare convenzioni.

## Operating modes

### Mode 1: `plan <epic>` — decomporre l'epic (default)

1. Verifica che la cwd sia un repo di progetto. Se ambiguo, chiedi conferma del path.
2. Deriva lo **slug epic** kebab-case (es. "Rifacimento area pagamenti" → `payments-revamp`). Conferma se non ovvio.
3. Se `docs/epics/<epic>/` esiste già → **rifiuta overwrite**, indirizza a `revise <epic>` o `add-feature <epic>`.
4. **Derivazione dal codebase** (sopra) → bozze di technical-context condiviso + abstract.
5. **Elicitation breve** sui gap (`../project-planner/elicitation.md`, scoped epic).
6. **Critica** (`../project-planner/critical-review.md`): lo scope è davvero un epic e non una feature singola o un progetto intero? Le feature sono coese e sequenziabili o è un sacco di cose scollegate? Solleva PRIMA di generare.
7. **Decomposizione in feature** (`references/decomposition.md`): produci la lista ordinata di feature figlie con goal, confine, dipendenze inter-feature, effort. **Presentala all'utente per conferma prima di materializzare i bundle.**
8. **Genera gli artefatti** (`references/epic-artifacts.md`):
   - `docs/epics/<epic>/00-context.md` — contesto epic + assunzioni condivise + rischi cross-feature.
   - `docs/epics/<epic>/02-abstract.md` — approccio tecnico d'insieme, decisioni condivise, contratti da preservare.
   - `docs/epics/<epic>/technical-context.md` — **seed condiviso** (build_command, VO/pattern comuni).
   - `docs/epics/<epic>/roadmap.md` — ordine feature, dipendenze inter-feature, sequencing, DoD epic.
   - per ogni feature figlia: `docs/features/<epic>-<feat>/` con i 4 file standard (`feature-artifacts.md`), `technical-context.md` **seedato dal condiviso** (vedi sotto), ID task `<epic>-<feat>-NNN`.
9. Summary: feature create + ordine, assunzioni più fragili, prossimo passo (`whats-next` per il board, o `flow-run <epic>-<feat0>-001` per partire dalla prima feature).

### Mode 2: `add-feature <epic>` — aggiungere una feature all'epic

1. Leggi `docs/epics/<epic>/{00-context,02-abstract,technical-context,roadmap}.md`.
2. Materializza una nuova feature figlia `docs/features/<epic>-<feat>/` (bundle standard, seed dal condiviso).
3. Aggiorna `roadmap.md`: inserisci la feature nell'ordine giusto, dichiara le sue dipendenze inter-feature. Non riusare uno slug figlio per una feature diversa.

### Mode 3: `revise <epic>` — aggiornare quando un'assunzione/decisione condivisa cambia

1. Chiedi quale assunzione/decisione condivisa è cambiata e il nuovo valore.
2. Trova in `00-context.md` / `technical-context.md` quali artefatti **e quali feature figlie** dipendono da essa.
3. Aggiorna in place il layer epic; **propaga** ai `technical-context.md` dei figli impattati (re-seed mirato, append-only — vedi `epic-artifacts.md` § "Propagazione del seed"). Marca l'assunzione vecchia come superseded, aggiungi la nuova con data.
4. Stampa un diff summary: cosa nel layer epic, quali figli toccati.

> Per **ri-espandere i task di una singola feature figlia** usa direttamente `feature-planner expand <epic>-<feat>`: è una feature source standard. Epic-planner non duplica quella logica.

## Vincoli di scope

- Scrive **solo** sotto `docs/epics/<epic>/` e `docs/features/<epic>-*/`. Mai `docs/planning/`, mai codice, mai i file di altre feature/epic.
- **Non** è una source: non crea mai `docs/epics/<epic>/tasks-active.md`.
- Slug figli **flat e prefissati**: `docs/features/<epic>-<feat>/`. ID task `<epic>-<feat>-NNN`, **globalmente unici** (requisito del Planning source contract).
- Una feature figlia che supera ~10 task non è una feature → ri-decomponi l'epic (più feature) o promuovi a `project-planner`.

## Quando NON usare epic-planner

- Una **singola** feature su progetto esistente → `feature-planner`.
- Un **progetto nuovo** con pitch/market/milestone → `project-planner`.
- Tradurre un task in brief tecnico → `task-implementer`. Scrivere codice → `code-implementer`. Eseguire → `flow-run`.
- Decidere "cosa faccio dopo" tra le feature dell'epic → `whats-next` (epic-aware).

## Tone

Senior PM/tech-lead in 1:1, denso, niente didattica, niente cheerleading. Lingua dell'elicitation (italiano se l'utente scrive in italiano).
