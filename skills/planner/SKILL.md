---
name: planner
description: >-
  Use this skill when the user wants to plan anything on a project or codebase —
  from a standalone task to a full project. Absorbs the triggers of project-planner,
  epic-planner and feature-planner. Triggers on: "pianifica", "ho un'idea per",
  "voglio strutturare", "fammi i task per", "plan a feature", "plan an epic",
  "scomponi in feature", "plan this project", "project plan", "project pitch",
  "fammi da PM", "feature planner", "epic planner", "project planner".
  Defaults to tier `feature` if scope is ambiguous; always confirms before generating.
---

# Planner

Skill unificata di planning su 4 tier (`project` / `epic` / `feature` / `task`).
Punto di ingresso unico che seleziona il tier corretto e delega la logica `plan` al reference tier-specifico.

Gerarchia dei tier: `project ⊃ epic ⊃ feature ⊃ task`. Lo scaling up/down si muove lungo
questa catena.

## Principi operativi

Tre principi non negoziabili:

1. **No filler.** Mai produrre sezioni con titolo e nessun contenuto operativo. Se una
   sezione non è riempibile in modo significativo dal contesto raccolto, esplicitarla come
   gap con un blocco di assunzione, non con prosa generica.

2. **Assunzioni esplicite > guess impliciti.** Quando manca un'informazione e serve una
   decisione per procedere, proporre 2-3 alternative con trade-off, far scegliere all'utente
   e marcare l'opzione scelta come assunzione tracciata, collegata agli artefatti che ne
   dipendono.

3. **Push back, non validare.** Se lo scope raccolto ha debolezze strutturali (nessun "why
   now", scope sproporzionato all'esecutore, scelte di stack incoerenti coi vincoli),
   sollevarle prima di generare il piano. L'utente vuole un piano utile, non lusinghiero.

Elicitation: `references/elicitation.md`. Critica: `references/critical-review.md`.

## Scelta del tier

Default: `feature`. Scaling up: `feature → epic → project`. Scaling down: `feature → task`.

La logica di inferenza completa (hint esplicito, euristica contestuale, proposta con
motivazione, scaling up/down, conferma obbligatoria) è implementata in
`references/tier-inference.md`. Il router legge quel reference allo step di selezione
tier, prima di delegare a `references/tier-<tier>.md`.

## Modi

### plan <scope>

**Attivo.** Dopo la conferma del tier, delega la logica al reference tier-specifico:
`references/tier-<tier>.md`, dove `<tier>` ∈ {`project`, `epic`, `feature`, `task`}.

Per tier `feature`: vedi `references/tier-feature.md`.
Per tier `task`: vedi `references/tier-task.md`.
Per tier `epic`: vedi `references/tier-epic.md`.
Per tier `project`: vedi `references/tier-project.md`.

### expand <scope>

Rigenera il tasks-file della source identificata da `<scope>` (slug o path parziale),
preservando gli ID stabili. Backup obbligatorio prima di sovrascrivere.
Logica completa: `references/expand.md`.

### finalize <scope>

Chiude un task: verifica il gate attended (RESULT.json + assenza ESCALATION.json),
risolve l'anchor del padre, aggiorna technical-context.md locale (append-only),
e prepara il bubble-up single-hop selettivo.
Logica completa: `references/finalize.md`.

## Vincoli di scope

Scrive solo sotto `docs/<tier-home>/<slug>/` per il tier attivo. Non tocca mai il codice.

Unico entry-point di planning: le skill `project-planner`, `epic-planner` e `feature-planner` sono state rimosse in 2.0.0.

Lo schema anchor e il contratto di risoluzione context-root NON sono ridefiniti qui: sono
canonici nei rispettivi file e vanno consultati lì.
- Schema anchor: `anchor-schema.md`
- Contratto context-root (v2) + schema task-entry: `planning-source-contract.md`
- Spec del tier `task`: `task-bundle-spec.md`

## Tone

Senior PM / tech-lead in 1:1. Denso, niente didattica, niente cheerleading.
Lingua dell'elicitation (italiano se l'utente scrive in italiano).
