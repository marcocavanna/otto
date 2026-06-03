# Brief tecnico — planner-unification-core-007

**Origin**: feature-planner
**Context-root**: docs/features/planner-unification-core/
**Feature**: planner-unification-core
**Status**: ✅ finalized

---

## Obiettivo

Materializzare `skills/planner/references/tier-inference.md` — il reference che implementa l'euristica di inferenza del tier e il meccanismo di conferma. Contestualmente, aggiornare `skills/planner/SKILL.md` rimuovendo il placeholder `[TODO: tier-inference.md — task 007]` e collegando il flusso al reference.

Il router in `SKILL.md` deve delegare a `tier-inference.md` per:
1. hint esplicito utente → tier diretto
2. euristica dal contesto (directory esistenti, keyword nello scope) → tier proposto + motivazione in 1 riga
3. offerta scaling up/down
4. conferma obbligatoria prima di generare

---

## Analisi tecnica

### Struttura del reference `tier-inference.md`

Il reference è letto lazily dal router (SKILL.md) solo al momento della scelta tier, in accordo con il pattern `SKILL.md sottile + reference lazy` di `technical-context.md`.

Shape (non implementazione finale):

```markdown
# Tier inference — Planner

> Letto dal router (SKILL.md § "Scelta del tier") solo allo step di selezione tier.
> Output: tier confermato ∈ {project, epic, feature, task}.

## Step 1 — Hint esplicito

Se l'utente passa un hint esplicito riconoscibile, usarlo direttamente:
- keyword nel testo: "pianifica un epic", "project plan", "project pitch", "fammi un task" → tier corrispondente
- sintassi esplicita: `tier: <valore>` o `plan epic <scope>`, `plan project <scope>`, ecc.
→ Se hint valido: proporre conferma (step 4) senza euristica.

## Step 2 — Euristica contestuale (solo se nessun hint esplicito)

Segnali, in ordine di peso:

1. **Directory esistenti**:
   - esiste `docs/epics/<slug>/`? → proponi `epic`
   - esiste `docs/projects/<slug>/`? → proponi `project`
   - esiste `docs/features/<slug>/`? → proponi `feature`
   - esiste `docs/tasks/<slug>/`? → proponi `task`
2. **Keyword nello scope**:
   - milestone / fasi / pitch / roadmap globale → `project`
   - epic / più feature / decomposizione → `epic`
   - singola funzionalità su progetto esistente → `feature` (default)
   - singolo deliverable atomico, fix, spike → `task`
3. **Default**: `feature` se nessun segnale è dirimente.

## Step 3 — Proposta con spiegazione

Formato output al momento della proposta:

> "Tier inferito: **<tier>** — <motivazione in 1 riga>.
> Vuoi procedere con questo tier, o preferisci [scaling-up → <tier+1>] / [scaling-down → <tier-1>]?"

Se il tier è `project` non offrire scaling up; se è `task` non offrire scaling down.

## Step 4 — Conferma obbligatoria

Attendere risposta esplicita dell'utente prima di generare qualsiasi artefatto.
- "sì" / "ok" / "procedi" → conferma accettata, delegare a `tier-<tier>.md`
- risposta che indica un tier diverso → rieseguire da step 1 con il nuovo tier
- nessuna risposta chiara → riproporre la scelta, non generare
```

### Aggiornamento SKILL.md

La sezione `## Scelta del tier` va aggiornata: il blocco inline (placeholder) viene rimosso e sostituito con un singolo riferimento al reference. Il testo della sezione diventa:

```markdown
## Scelta del tier

Default: `feature`. Scaling up: `feature → epic → project`. Scaling down: `feature → task`.

La logica di inferenza completa (hint esplicito, euristica contestuale, proposta con
motivazione, scaling up/down, conferma obbligatoria) è implementata in
`references/tier-inference.md`. Il router legge quel reference allo step di selezione
tier, prima di delegare a `references/tier-<tier>.md`.
```

---

## File impattati

| File | Stato | Note |
|---|---|---|
| `skills/planner/references/tier-inference.md` | [new] | Reference principale: euristica + conferma |
| `skills/planner/SKILL.md` | [edit] | Rimuovere placeholder TODO; puntare a `tier-inference.md` |

---

## Decisioni tecniche

- **Granularità dei segnali euristica**: i segnali di directory (`docs/epics/`, `docs/projects/`, `docs/features/`, `docs/tasks/`) sono trattati come indizi forti ma non determinanti in presenza di keyword contrastanti. La priorità va: hint esplicito > directory esistente > keyword > default.
- **Nessun lookup filesystem obbligatorio**: il reference descrive la logica, non impone al LLM una bash stat. Il LLM usa i segnali disponibili dal contesto conversazionale (path menzionati, artefatti citati).
- **Scaling up/down offerto solo ai tier adiacenti**: non si offrono salti di due livelli (es. da `task` direttamente a `epic`) per ridurre l'ambiguità della proposta.
- **Conferma obbligatoria sempre**: anche quando il hint esplicito è presente, si propone il tier e si aspetta conferma. Questo rispetta ASSUMPTION-planner-unification-core-002 (scaling confermato dall'utente SEMPRE).

---

## Out of scope per questo task

- Logica `expand`/`finalize` nel router → feature finalize
- Ripuntamento dei downstream (task-implementer, flow-run) al nuovo reference
- Modifica dei reference tier-*.md esistenti
- Rimozione delle vecchie skill `*-planner`
- Qualsiasi nuovo artefatto di output (il task produce solo il reference e aggiorna SKILL.md)

---

## Dipendenze

- **Upstream**: planner-unification-core-001 (SKILL.md esiste con placeholder) ✅ done
- **Nessun blocco downstream immediato** in questa feature; la feature `planner-unification-finalize` dipende da core-007 per il router completo.

---

## Verifica

Dogfooding manuale:
1. Invocare `planner` senza hint → verificare che il tier proposto sia `feature` con motivazione.
2. Invocare con keyword "project pitch" → tier `project` proposto.
3. Invocare con "pianifica un epic" → tier `epic` proposto.
4. Invocare con "fammi un task" → tier `task` proposto.
5. Rispondere con scaling up/down → verificare che la proposta cambi correttamente.
6. Verificare che senza conferma esplicita non vengano generati artefatti.
7. Verificare 0-link-orfani: `SKILL.md` non contiene più `[TODO: tier-inference.md]`; il link a `references/tier-inference.md` risolve.

Subtask: nessuno necessario, esecuzione lineare.

---

Generato: 2026-06-02 | Task: planner-unification-core-007
