**Origin**: feature-planner
**Context-root**: docs/features/planner-unification-core/
**Feature**: planner-unification-core
**Status**: ✅ finalized

---

# Brief tecnico — planner-unification-core-001

## Obiettivo

Creare `skills/planner/SKILL.md` — il router sottile della skill unificata. È il punto di ingresso unico che assorbe la muscle-memory utente dei 3 planner esistenti (`project-planner`, `epic-planner`, `feature-planner`), seleziona il tier corretto e delega la logica `plan` ai reference tier-specifici. I modi `expand`/`finalize` sono dichiarati ma rimandati alle feature successive.

---

## Vincoli risolti

**Stack**
- Markdown puro (file di skill Claude Code). Nessun build, nessuna dipendenza runtime.
- La skill è letta dall'agente (Claude) come sistema di istruzioni: la struttura deve essere navigabile in lettura lazy (header H2/H3, link espliciti a reference).

**Librerie + versioni**
- Nessuna. Stack: markdown + prosa + bash (dove utile negli snippet).

**VO/pattern/interfacce consumati — da NON modificare**
- `skills/planner/anchor-schema.md` — schema anchor (Tier/Parent/Bubble-up target). La `description` YAML e le sezioni del SKILL.md non devono ridefinirlo.
- `skills/planner/planning-source-contract.md` — contratto v2 di risoluzione context-root, incluso l'algoritmo scan e lo schema task-entry con `Complessità (ipotesi)`. Non duplicare qui.
- `skills/planner/task-bundle-spec.md` — spec del tier `task`. Non ridefinire il bundle qui.
- Taxonomy dei 4 tier (definita in `docs/epics/planner-unification/technical-context.md` § Taxonomy): `project ⊃ epic ⊃ feature ⊃ task`. Il router rispetta questa gerarchia per lo scaling up/down.

**Naming convention**
- Slug skill: `planner` (già esistente come directory).
- Modi della skill: `plan`, `expand`, `finalize` (lowercase, nessun sinonimo).
- Tier: `project`, `epic`, `feature`, `task` (lowercase, enum chiuso).
- Reference tier: `tier-{project,epic,feature,task}.md` sotto `planner/references/` (creati da 002/003/004/005/006).
- Reference condivisi: `elicitation.md`, `critical-review.md`, `task-expansion.md`, `artifact-contract.md` sotto `planner/references/` (creati da 002).

---

## Descrizione tecnica

### Struttura del file `skills/planner/SKILL.md`

Il file è composto da:

1. **Frontmatter YAML** — `name: planner` + `description:` che assorbe i trigger delle tre skill omonime.
2. **Principi operativi** — tre regole non negoziabili (no filler, assunzioni esplicite, push back): ereditate da `project-planner` verbatim o per riferimento. NIENTE inline: link a `references/elicitation.md`, `references/critical-review.md`.
3. **Scelta e conferma del tier** — la sezione centrale: inferenza del tier dal contesto (delegata a `references/tier-inference.md` che 007 creerà), default `feature`, proposta di scaling up/down, **conferma obbligatoria prima di generare artefatti**. In questo task la logica di inferenza è descritta inline (placeholder); 007 la materializzerà come reference.
4. **Modi della skill** — tre sezioni H3:
   - `plan <scope>` — **attivo**: dopo la conferma del tier, delega a `references/tier-<tier>.md`. [new]
   - `expand <scope>` — **dichiarato, rimandato**: stub "rimandato a feature `finalize`".
   - `finalize <scope>` — **dichiarato, rimandato**: stub "rimandato a feature `finalize`".
5. **Scope della skill** — cosa non fare (evitare duplicazione con le `*-planner` ancora esistenti).
6. **Vincoli di scope** — scrive solo sotto `docs/<tier-home>/<slug>/` per il tier attivo; non tocca mai il codice.

### Logica di scelta del tier (inline per ora, poi delegata a 007)

Il SKILL.md descrive la logica di inferenza senza implementarla come algoritmo separato (007 lo farà). La struttura inline che il DEV scrive:

```
shape — non implementazione finale

## Scelta del tier

1. Se l'utente passa un hint esplicito (`tier: <valore>` o "pianifica un epic") → usa quello.
2. Altrimenti, inferisci dal contesto:
   - esiste già un `docs/epics/<slug>/`? → probabile `epic`
   - scope menziona milestone/fasi/pitch? → `project`
   - scope è una singola funzionalità su progetto esistente → `feature` (default)
   - scope è un singolo task atomico con un solo deliverable → `task`
3. Proponi il tier inferito con una riga di spiegazione.
4. **OBBLIGATORIO**: chiedi conferma prima di procedere. Senza "sì" esplicito, non generare artefatti.
5. Offri scaling up/down: "o vuoi scalare a epic?" / "o preferisci restare a task?".
```

Il SKILL.md NON deve implementare l'euristica completa (quella è di 007). Basta la struttura sopra come placeholder esplicito con rimando a `TODO: references/tier-inference.md (task 007)`.

### `description` YAML — assorbimento trigger

La `description` deve essere una stringa che fa scattare la skill per tutti gli intent che prima andavano ai 3 planner. Shape:

```yaml
description: >-
  Use this skill when the user wants to plan anything on a project or codebase —
  from a standalone task to a full project. Absorbs the triggers of project-planner,
  epic-planner and feature-planner. Triggers on: "pianifica", "ho un'idea per",
  "voglio strutturare", "fammi i task per", "plan a feature", "plan an epic",
  "scomponi in feature", "plan this project", "project plan", "project pitch",
  "fammi da PM", "feature-planner", "epic-planner", "project-planner".
  Defaults to tier `feature` if scope is ambiguous; always confirms before generating.
```

### File impattati

- `skills/planner/SKILL.md` [new]

### Out of scope per questo task

- Logica di inferenza tier completa (task 007): in questo task è uno stub inline.
- I reference tier-specifici `tier-{project,epic,feature,task}.md` (task 003/004/005/006).
- Il consolidamento dei reference condivisi `elicitation.md`, `critical-review.md`, etc. (task 002).
- La creazione di `references/tier-inference.md` (task 007).
- Qualunque modifica alle skill `*-planner` esistenti.
- I modi `expand` e `finalize` (stub dichiarativo nel SKILL.md è sufficiente).

---

## Shape di riferimento

```markdown
shape — non implementazione finale

---
name: planner
description: >-
  Use this skill when the user wants to plan anything on a project or codebase ...
  [trigger list dei 3 planner + "defaults to tier feature"]
---

# Planner

Skill unificata di planning su 4 tier (project / epic / feature / task).
Assorbe `project-planner`, `epic-planner`, `feature-planner`.

## Principi operativi

Eredita i tre principi di `project-planner`:
1. **No filler.** ...
2. **Assunzioni esplicite > guess impliciti.** ...
3. **Push back, non validare.** ...

Elicitation: `references/elicitation.md`. Critica: `references/critical-review.md`.

## Scelta del tier

Default: `feature`. Scaling up: `epic` → `project`. Scaling down: `task`.

[logica inline / placeholder → TODO: references/tier-inference.md (task 007)]

**Conferma obbligatoria**: prima di generare artefatti, proporre il tier e attendere "sì"
esplicito dall'utente.

## Modi

### plan <scope>

Dopo la conferma del tier → delega a `references/tier-<tier>.md`.
[TODO: tier-{project,epic,feature,task}.md — task 002/003/004/005/006]

### expand <scope>

> Rimandato — feature `planner-unification-finalize`.

### finalize <scope>

> Rimandato — feature `planner-unification-finalize`.

## Vincoli di scope

Scrive solo sotto `docs/<tier-home>/<slug>/`. Non tocca il codice, mai.
Non tocca le skill `*-planner` esistenti (restano attive in parallelo).

## Tone

Senior PM/tech-lead in 1:1. Denso, niente didattica, niente cheerleading. Lingua dell'elicitation.
```

---

## Dipendenze e sequenza

- **Dipende da**: `planner-unification-contract-002` — i file contratto (`anchor-schema.md`, `planning-source-contract.md`, `task-bundle-spec.md`) devono esistere in `skills/planner/` prima di linkare da SKILL.md. Sono già presenti (feature `contract` conclusa).
- **Sblocca**: task 002 (reference condivisi), task 007 (inferenza tier) — entrambi dipendono dall'esistenza di `SKILL.md` come struttura di riferimento.

## Definition of done (verificabile)

- `skills/planner/SKILL.md` esiste.
- La `description` YAML contiene i trigger di tutti e tre i planner omonimous (`project-planner`, `epic-planner`, `feature-planner`).
- La sezione "Scelta del tier" descrive: default `feature`, scaling up/down, conferma obbligatoria.
- La sezione "Modi" ha tre H3: `plan`, `expand`, `finalize`; gli ultimi due hanno stub "rimandato".
- Il file linka (anche come TODO) `references/elicitation.md`, `references/critical-review.md`, `references/tier-<tier>.md`.
- NESSUN contenuto dei reference è inlinato nel SKILL.md (principio lazy).
- Il file non ridefinisce lo schema anchor né il contratto v2 (linka i canonici).
