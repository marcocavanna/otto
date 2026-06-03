# Tier inference — Planner

> Reference del router (`SKILL.md` § "Scelta del tier"). Letto lazily allo step di selezione tier,
> prima di delegare a `references/tier-<tier>.md`.
> Output: tier confermato ∈ {`project`, `epic`, `feature`, `task`}.

---

## Step 1 — Hint esplicito

Se l'utente passa un hint esplicito riconoscibile, usarlo direttamente senza eseguire l'euristica:

- keyword nel testo: "pianifica un epic", "project plan", "project pitch", "fammi un task",
  "plan an epic", "plan a project", "plan a task" → tier corrispondente
- sintassi esplicita: `tier: <valore>`, `plan epic <scope>`, `plan project <scope>`,
  `plan task <scope>`, `plan feature <scope>`

Se l'hint è valido: andare direttamente allo **Step 3** (proposta con spiegazione) e poi allo
**Step 4** (conferma obbligatoria), senza passare per l'euristica.

---

## Step 2 — Euristica contestuale (solo se nessun hint esplicito)

Valuta i segnali disponibili dal contesto conversazionale (path menzionati, artefatti citati,
descrizione dello scope). Non è richiesto un lookup obbligatorio del filesystem: usa i segnali
già presenti nella conversazione.

Priorità decrescente:

1. **Directory esistenti** (segnale forte):
   - esiste `docs/epics/<slug>/`? → proponi `epic`
   - esiste `docs/projects/<slug>/`? → proponi `project`
   - esiste `docs/features/<slug>/`? → proponi `feature`
   - esiste `docs/tasks/<slug>/`? → proponi `task`

2. **Keyword nello scope** (segnale medio):
   - milestone / fasi / pitch / roadmap globale → `project`
   - epic / più feature / decomposizione in feature / backlog strutturato → `epic`
   - singola funzionalità su progetto esistente → `feature` (default)
   - singolo deliverable atomico, fix, spike → `task`

3. **Default**: `feature` se nessun segnale è dirimente.

Priorità finale in caso di conflitto: hint esplicito > directory esistente > keyword > default.

---

## Step 3 — Proposta con spiegazione

Presentare il tier inferito con una motivazione in una riga:

> "Tier inferito: **\<tier\>** — \<motivazione in 1 riga\>.
> Vuoi procedere con questo tier, o preferisci [scaling-up → \<tier+1\>] / [scaling-down → \<tier-1\>]?"

Regole scaling:
- Se il tier è `project`: non offrire scaling up (è il massimo).
- Se il tier è `task`: non offrire scaling down (è il minimo).
- Offrire solo i tier **adiacenti** (nessun salto di due livelli, es. `task → epic` diretto).

---

## Step 4 — Conferma obbligatoria

Attendere risposta esplicita dell'utente prima di generare qualsiasi artefatto.

| Risposta utente | Azione |
|---|---|
| "sì" / "ok" / "procedi" / conferma implicita chiara | Tier accettato → delegare a `tier-<tier>.md` |
| Indica un tier diverso (es. "meglio un epic") | Rieseguire da Step 1 con il nuovo tier |
| Indica scaling up/down (es. "scala a epic") | Rieseguire da Step 1 con il tier adiacente indicato |
| Nessuna risposta chiara | Riproporre la scelta, **non generare** |

La conferma è obbligatoria **sempre**, anche quando il hint esplicito è presente.
Questo rispetta ASSUMPTION-planner-unification-core-002: lo scaling è sempre confermato
dall'utente prima di generare artefatti.
