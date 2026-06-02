# Artifact contract

> Reference condiviso della skill `planner`. Definisce gli **artefatti attesi per ciascun tier** e i loro
> template. **Tier-organizzato**: una sezione H2 per tier (`project` ⊃ `epic` ⊃ `feature` ⊃ `task`).
> Single-source: gli schemi già canonici altrove (anchor, schema task-entry, bundle task) sono **linkati,
> non duplicati**. Consumato dai reference tier-specifici `references/tier-{project,epic,feature,task}.md`.

Tutti i file sono in Markdown, nella lingua dell'elicitation.

## Regole trasversali

Valgono per ogni tier, salvo dove un template specifico le sovrascrive.

- Ogni file inizia con un **H1** che è il titolo del documento + l'identità dello scope (progetto / epic / feature / task).
- La coppia `00-context.md` + `technical-context.md` porta in testa la **riga anchor** (vedi `../anchor-schema.md`): obbligatoria per `epic`/`feature`/`task` inseriti in gerarchia; per `project` l'anchor ha `Parent: —` e `Bubble-up target: —`. Gli altri artefatti (`02-abstract.md`, `roadmap.md`, `milestones.md`, `tasks-active.md`) **non** portano l'anchor.
- Ogni file ha in fondo una riga `---` con metadata: `Generato: YYYY-MM-DD` e `Versione: N` (incrementata a ogni revise).
- Nessuna sezione filler. Se una sezione non ha contenuto reale dall'elicitation, va trattata come gap esplicito (vedi "Gestione gap").
- Riferimenti a tracked assumptions sempre nel formato `[ASSUMPTION-<slug>-NNN]` linkabili al `00-context.md` della source.

### Gestione gap

Se una sezione non ha contenuto sufficiente dall'elicitation:
- NON inventare. NON usare prosa generica.
- Inserire blocco esplicito:
  ```
  > ⚠ **Gap**: [cosa manca]
  > Decidere prima di [scope X / fase Y]. Vedi [ASSUMPTION-<slug>-NNN] in 00-context.md.
  ```

### Schema task-entry (rinvio)

Lo schema delle entry dei tasks-file (con il campo `Complessità (ipotesi)`) è **canonico** in `../planning-source-contract.md` § "Schema task-entry". Le regole operative di espansione sono in `task-expansion.md`. **Non duplicare lo schema** nei template qui sotto: i tasks-file lo applicano.

---

## Tier `project`

Sette artefatti in `docs/planning/`: `00-context`, `01-pitch`, `02-abstract`, `03-milestones`, `04-phases`, `05-tasks-active`, `README`. Elicitation completa (blocchi A-F).

### 00-context.md

Raccolta cruda dell'elicitation + assunzioni tracciate + rischi noti. **Fonte di verità** per gli altri artefatti.

```markdown
# Context — [Nome progetto]

<!-- Anchor --> **Tier**: project · **Parent**: — · **Bubble-up target**: —

## Input elicitato

### Problema e motivazione
- **Problema**: [A1]
- **Target**: [A2]
- **Why now**: [A3]
- **Concorrenza**: [A4]

### Forma e scope
- **Forma prodotto**: [B1]
- **Versione minima**: [B2]
- **Fuori scope**: [B3]

### Vincoli
- **Tempo/settimana**: [C1]
- **Deadline**: [C2]
- **Budget**: [C3]

### Stack e competenze
- **Stack scelto**: [D1]
- **Tecnologie ignote**: [D2]

### Successo
- **Metrica**: [E1]
- **Piano B**: [E2]

### Distribuzione (se applicabile)
- **Canali**: [F1]
- **Modello**: [F2]

## Tracked assumptions

### ASSUMPTION-001
- **Descrizione**: [...]
- **Scelta**: [...]
- **Alternative valutate**: [...]
- **Impatta**: 02-abstract.md, 03-milestones.md
- **Status**: active
- **Data**: YYYY-MM-DD

[ripetere per ogni assunzione]

## Known risks

### RISK-001 — [titolo]
- **Severità**: 🔴 alta | 🟡 media | 🟢 bassa
- **Descrizione**: [...]
- **Mitigazione proposta**: [...]
- **Impatta**: [artefatti]

[ripetere per ogni rischio]

---
Generato: YYYY-MM-DD | Versione: 1
```

### 01-pitch.md

Pitch del progetto. Massimo 1 pagina, denso, nessuna prosa promozionale.

```markdown
# Pitch — [Nome progetto]

## In una frase
[Sintesi in max 25 parole. Forma: "[Prodotto] è un [forma] per [target] che [risolve cosa] grazie a [come]."]

## Problema
[2-3 paragrafi. Concreto. Da A1+A2.]

## Soluzione
[2-3 paragrafi. Cosa fa il prodotto, non come è fatto. Da B2.]

## Target
[Chi è l'utente, quanti sono, come li raggiungi. Da A2+F1.]

## Differenziatore
[Da A4. Se nulla, dichiararlo: "Nessun differenziatore funzionale forte — il valore è in [X]".]

## Why now
[Da A3. Se debole, dichiararlo come tale.]

## Metrica di successo
[Da E1. Concreta e misurabile.]

## Cosa NON è
[Da B3. Esclusioni esplicite.]

---
Generato: YYYY-MM-DD | Versione: 1
```

### 02-abstract.md

Abstract tecnico. Per un dev senior. Niente intro su "cosa è X framework".

```markdown
# Abstract tecnico — [Nome progetto]

## Architettura proposta
[Componenti principali. Comunicazione tra essi. Diagramma testuale se utile.]

## Stack
- **Linguaggio/runtime**: [...]
- **Framework principale**: [...]
- **Database**: [...]
- **Infrastruttura**: [...]
- **Altri**: [...]

[Per ogni voce: una riga di motivazione. Se assunzione, marcare ASSUMPTION-NNN.]

## Trade-off tecnici principali
[2-4 trade-off espliciti.]

## Rischi tecnici
[Da D2 + critical review. Concretizzare.]

## Punti aperti
[Domande tecniche da chiudere durante l'execution. Linkate a milestone specifiche.]

## Esclusioni tecniche
[Pattern/feature/tooling esplicitamente non adottati e perché.]

---
Generato: YYYY-MM-DD | Versione: 1
```

### 03-milestones.md

Roadmap macro. **Sempre** alto livello. Mai task atomici qui.

```markdown
# Milestones — [Nome progetto]

Roadmap a milestone macro. Ogni milestone è un incremento di valore osservabile.

## M1 — [Nome — verbo + risultato osservabile]
- **Outcome**: [cosa l'utente/io vede di nuovo a fine milestone]
- **Definition of done**: [criterio binario di completamento]
- **Effort stimato**: [giorni di lavoro, in range — es. "8-12 giorni"]
- **Status**: 🔵 active | ⚪ planned | ✅ done | ⏸ paused

## M2 — [...]
[idem]

[Tipicamente 3-6 milestone. Mai >8.]

## Sequenziamento
[Una riga: M1 → M2 → M3, oppure note su dipendenze/parallelismi.]

## Milestone attiva corrente
**M1** (vedi `05-tasks-active.md` per task atomici)

---
Generato: YYYY-MM-DD | Versione: 1
```

Regole milestones: numero 3-6 (mai >8); ogni milestone **dimostrabile**; M1 include setup minimo + primo output utile (mai "M1: setup ambiente"); l'ultima milestone si allinea alla metrica di successo (E1).

### 04-phases.md

Fasi di lavoro orizzontali — tagliano le milestone in modo ortogonale.

```markdown
# Fasi di lavoro — [Nome progetto]

Le fasi rappresentano stati qualitativi del progetto. Una milestone può attraversare più fasi; una fase può contenere più milestone.

## Fase 0 — Spike & validazione (opzionale)
- **Quando**: prima di M1, solo se ci sono incertezze tecniche significative (vedi D2)
- **Output atteso**: PoC throw-away che risolve le incognite
- **Definition of done**: [...]

## Fase 1 — Foundation
- **Quando**: prevalentemente M1, parte di M2
- **Output atteso**: stack scelto funzionante, deploy minimo, dominio implementato
- **Definition of done**: [...]

## Fase 2 — Vertical slice
- **Quando**: M2-M3
- **Output atteso**: primo flusso utente end-to-end
- **Definition of done**: [...]

## Fase 3 — Beta usable
- **Quando**: M3-M4
- **Output atteso**: prodotto usabile dall'utente target in produzione
- **Definition of done**: [...]

## Fase 4 — Public release (se applicabile)
- **Quando**: ultima milestone
- **Output atteso**: prodotto pubblicato, primo flusso di acquisizione attivo
- **Definition of done**: [...]

---
Generato: YYYY-MM-DD | Versione: 1
```

Adattare le fasi al progetto (per tool personale Fase 4 può non esistere; per libreria: "API design / implementazione / docs+pubblicazione").

### 05-tasks-active.md

Task atomici **solo** per la milestone attiva. Schema task-entry: `../planning-source-contract.md`. Regole: `task-expansion.md`.

```markdown
# Task attivi — [Nome progetto]

**Milestone attiva**: M1 — [nome]
**Effort totale stimato**: [X-Y ore]
**Definition of done milestone**: [da 03-milestones.md]

## Task

[Entry secondo lo schema canonico — vedi ../planning-source-contract.md § Schema task-entry]

## Note operative
[Ordini suggeriti, blocchi paralleli, riferimenti a spike.]

## Out of scope per questa milestone
[Cose rimandate, con riferimento a milestone futura.]

---
Generato: YYYY-MM-DD | Versione: 1 | Milestone: M1
```

### README.md

```markdown
# Planning — [Nome progetto]

## Stato
- **Milestone attiva**: M[N] — [nome]
- **Fase corrente**: Fase [N] — [nome]
- **Ultimo update**: YYYY-MM-DD

## Documenti

| File | Contenuto |
|------|-----------|
| [00-context.md](./00-context.md) | Contesto elicitato, assunzioni, rischi |
| [01-pitch.md](./01-pitch.md) | Pitch del progetto |
| [02-abstract.md](./02-abstract.md) | Abstract tecnico |
| [03-milestones.md](./03-milestones.md) | Roadmap macro |
| [04-phases.md](./04-phases.md) | Fasi di lavoro |
| [05-tasks-active.md](./05-tasks-active.md) | Task atomici milestone attiva |

## Come usare
- **Espandere una nuova milestone**: `expand M[N]`
- **Aggiornare un'assunzione**: `revise [artifact]`

---
Generato: YYYY-MM-DD | Versione: 1
```

---

## Tier `epic`

Layer di **coordinamento** in `docs/epics/<epic>/`: `00-context`, `02-abstract`, `technical-context` (seed condiviso), `roadmap`. Non è una planning source eseguibile direttamente: niente `tasks-active.md` proprio — l'epic genera **N feature figlie** (bundle standard di tier `feature`). Il contratto di coordinamento (limiti onesti su sequencing advisory, deps cross-source, one-source-per-run) è descritto in `skills/epic-planner/references/epic-artifacts.md` § "Epic coordination contract".

### 00-context.md (epic)

```markdown
# Context — Epic: [titolo] (`<epic>`)

<!-- Anchor --> **Tier**: epic · **Parent**: <project-slug|—> · **Bubble-up target**: <docs/planning/technical-context.md|—>

**Progetto**: [nome repo/progetto]
**Tipo**: epic (più feature sequenziali) su progetto esistente

## Cosa realizza l'epic
[2-4 frasi: outcome d'insieme osservabile, chi lo usa, perché ora. NON un pitch di prodotto.]

## Derivato dal codebase
- **Aree/moduli toccati (d'insieme)**: [path/componenti]
- **Stack pertinente**: [solo ciò che l'epic usa]
- **Convenzioni rilevate**: [pattern/naming dai sample]
- **Build/test command**: [comando rilevato]

## Decomposizione in feature
[Riepilogo: la lista vive in roadmap.md; qui il razionale di confine.]
- **Criterio di split**: [perché queste feature e non altre]
- **Tronco comune**: [VO/contratti/infra condivisi → seed in technical-context.md]

## Boundary e scope d'insieme
- **In scope (epic)**: [...]
- **Fuori scope (epic)**: [...] (esplicito)
- **Integrazione con l'esistente**: [contratti da non rompere]

## Tracked assumptions (condivise)
### ASSUMPTION-<epic>-001
- **Descrizione**: [...]
- **Scelta**: [...]
- **Alternative valutate**: [...]
- **Impatta**: 02-abstract.md / technical-context.md / feature: [<epic>-feat, ...]
- **Status**: active
- **Data**: YYYY-MM-DD

## Known risks (cross-feature)
### RISK-<epic>-001 — [titolo]
- **Severità**: 🔴 | 🟡 | 🟢
- **Descrizione**: [...]
- **Mitigazione**: [...]

---
Generato: YYYY-MM-DD | Versione: 1
```

### 02-abstract.md (epic)

```markdown
# Abstract tecnico — Epic: [titolo] (`<epic>`)

## Approccio d'insieme
[Come l'epic si realizza dentro l'architettura esistente. Riusa ciò che c'è.]

## Decisioni tecniche condivise
[Scelte valide per TUTTE le feature: pattern comuni, nuovi VO/contratti del tronco comune, strategie di migrazione/flag.]

## Contratti da preservare
[Interfacce/endpoint/schema esistenti che l'epic consuma ma NON deve rompere. Diventeranno frozen.txt nelle singole feature.]

## Trade-off
[1-3 trade-off d'insieme.]

## Rischi tecnici cross-feature
[Regressioni, ordine di migrazione, accoppiamenti pericolosi.]

## Esclusioni tecniche
[Cosa l'epic NON fa e perché.]

---
Generato: YYYY-MM-DD | Versione: 1
```

### technical-context.md (epic — seed condiviso)

> Seed che **tutte** le feature figlie ereditano. La propagazione del seed (in giù alla materializzazione, in su a feature conclusa) è descritta in `skills/epic-planner/references/epic-artifacts.md` § "Propagazione del seed".

```markdown
# Technical context (shared) — Epic: [titolo] (`<epic>`)

<!-- Anchor --> **Tier**: epic · **Parent**: <project-slug|—> · **Bubble-up target**: <docs/planning/technical-context.md|—>

## Convenzioni di progetto
### Build & test
- build_command: `[comando rilevato]`
- test_command: `[se noto]`

## Pattern architetturali condivisi
[Pattern del codebase che tutte le feature dell'epic devono seguire — riferiti a file sample reali.]

## Value Objects / contratti condivisi
[VO/contratti del tronco comune o esistenti consumati da più feature. Vincolanti per i figli.]

## Librerie e versioni
[Solo le librerie rilevanti per l'epic, con versione, se desumibili.]

---
Generato: YYYY-MM-DD | Versione: 1
```

### roadmap.md (epic — coordinamento)

> Analogo non-canonico di `03-milestones.md`: ordine, dipendenze inter-feature, sequencing, DoD epic. Letto da `whats-next` (epic-aware). Status a granularità **feature** (advisory). Dettagli e semantica dello `Status feature` in `skills/epic-planner/references/epic-artifacts.md`.

```markdown
# Roadmap — Epic: [titolo] (`<epic>`)

**Outcome epic**: [una frase]
**Definition of done epic**: [criterio binario d'insieme]
**Effort totale stimato**: [X-Y ore]

## Feature (ordine sequenziale)

### <epic>-foundation — 🏗️ [titolo feature]
- **Goal**: [outcome osservabile]
- **Dipende da feature**: —
- **Effort**: [X-Yh] (~N task)
- **Status feature**: ⚪ planned | 🔵 active | ✅ done | ⏸ paused
- **Source**: docs/features/<epic>-foundation/

[...]

## Fronti paralleli
[Es: {<epic>-ui, <epic>-reporting} dopo <epic>-api. Niente dipendenza reciproca.]

## Note di sequencing
[Razionale dell'ordine: cosa abilita cosa. Rischi d'ordine.]

---
Generato: YYYY-MM-DD | Versione: 1 | Epic: <epic>
```

> **Feature figlie**: ogni figlia è un **bundle standard** di tier `feature` (vedi sotto), con `00-context.md` che linka all'epic (`**Epic**: <epic>`), `02-abstract.md` che referenzia le decisioni condivise senza ripeterle, e `technical-context.md` seedato dal seed condiviso. Regole complete in `skills/epic-planner/references/epic-artifacts.md` § "Feature figlie — generazione".

---

## Tier `feature`

Bundle standard di **4 file** in `docs/features/<slug>/`: `00-context`, `02-abstract`, `technical-context`, `tasks-active`. Elicitation ridotta (A1-A3, B scope; D solo stack-check). Tipicamente 1-8 task.

### 00-context.md (feature)

```markdown
# Context — Feature: [titolo feature] (`<slug>`)

<!-- Anchor --> **Tier**: feature · **Parent**: <epic-slug|—> · **Bubble-up target**: <docs/epics/<epic>/technical-context.md|—>

**Progetto**: [nome repo/progetto]
**Tipo**: feature su progetto esistente

## Cosa fa la feature
[2-4 frasi: comportamento osservabile, chi la usa, perché ora.]

## Derivato dal codebase
[Cosa è stato inferito ispezionando il repo, non chiesto all'utente.]
- **Moduli/aree toccate**: [path/componenti]
- **Stack pertinente**: [solo ciò che la feature usa]
- **Convenzioni rilevate**: [pattern/naming dai sample]
- **Build/test command**: [comando rilevato]

## Boundary e scope
- **In scope**: [...]
- **Fuori scope**: [...] (esplicito)
- **Integrazione con l'esistente**: [punti di contatto, contratti da non rompere]

## Tracked assumptions
### ASSUMPTION-<slug>-001
- **Descrizione**: [...]
- **Scelta**: [...]
- **Alternative valutate**: [...]
- **Impatta**: 02-abstract.md / tasks-active.md
- **Status**: active
- **Data**: YYYY-MM-DD

## Known risks
### RISK-<slug>-001 — [titolo]
- **Severità**: 🔴 | 🟡 | 🟢
- **Descrizione**: [...]
- **Mitigazione**: [...]

---
Generato: YYYY-MM-DD | Versione: 1
```

### 02-abstract.md (feature)

```markdown
# Abstract tecnico — Feature: [titolo] (`<slug>`)

## Approccio
[Come si realizza la feature dentro l'architettura esistente. Riusa ciò che c'è.]

## Moduli impattati
- [path/modulo] — [cosa cambia]

## Stack pertinente
- [solo le voci rilevanti per QUESTA feature; il resto è già nel progetto]

## Contratti da preservare
[Interfacce/endpoint/schema esistenti che la feature consuma ma NON deve rompere. Diventeranno frozen.txt.]

## Trade-off
[1-3 trade-off specifici della feature.]

## Rischi tecnici
[Integrazioni rischiose, regressioni possibili, prestazioni.]

## Esclusioni tecniche
[Cosa NON si fa in questa feature e perché.]

---
Generato: YYYY-MM-DD | Versione: 1
```

### technical-context.md (feature — seed)

> Seed minimale: serve a `code-implementer` (build_command) e ai pattern da seguire. `task-implementer` lo estende in append-only.

```markdown
# Technical context — Feature: [titolo] (`<slug>`)

<!-- Anchor --> **Tier**: feature · **Parent**: <epic-slug|—> · **Bubble-up target**: <docs/epics/<epic>/technical-context.md|—>

## Convenzioni di progetto
### Build & test
- build_command: `[comando rilevato dal codebase]`
- test_command: `[se noto]` (opzionale)

## Pattern architetturali
[Pattern già adottati nel codebase che questa feature deve seguire — riferiti a file sample reali.]

## Librerie e versioni
[Solo le librerie rilevanti per la feature, con versione, se desumibili.]

## Value Objects / contratti
[VO o contratti esistenti che la feature consuma. Vincolanti.]

---
Generato: YYYY-MM-DD | Versione: 1
```

> Per le feature figlie di un epic: il seed copia le sezioni rilevanti del `technical-context.md` condiviso dell'epic con intestazione `> Seed da docs/epics/<epic>/technical-context.md`. Vedi `skills/epic-planner/references/epic-artifacts.md` § "Propagazione del seed".

### tasks-active.md (feature)

Schema task-entry: `../planning-source-contract.md` § "Schema task-entry". Regole di espansione: `task-expansion.md`.

```markdown
# Task attivi — Feature: [titolo] (`<slug>`)

**Feature**: <slug>
**Effort totale stimato**: [X-Y ore]
**Definition of done feature**: [criterio binario d'insieme]

## Task

[Entry secondo lo schema canonico — vedi ../planning-source-contract.md § Schema task-entry]

## Note operative
[Ordine suggerito, blocchi paralleli, riferimenti a spike.]

## Out of scope per questa feature
[Cose rimandate, con link a feature/task futuri se noti.]

---
Generato: YYYY-MM-DD | Versione: 1 | Feature: <slug>
```

---

## Tier `task`

Bundle **intenzionalmente leggero** in `docs/tasks/<slug>/`: `00-context`, `technical-context` (entrambi con anchor obbligatorio e `Parent` valorizzato), `tasks-active` (esattamente **1** task-entry). Niente roadmap/milestones/phases. `02-abstract.md` opzionale.

> La spec completa del bundle (file obbligatori/opzionali/non ammessi, regola binaria d'uso, seed del technical-context, checklist di conformità, esempio verbatim) è **canonica** in `../task-bundle-spec.md`. **Non duplicarla qui**: i template del tier `task` sono lì.

Punti di contatto con questo contratto:
- I due file con anchor (`00-context.md`, `technical-context.md`) seguono `../anchor-schema.md` con `Tier: task` e `Parent` **sempre** valorizzato (mai `—`: il tier `task` ha per definizione un parent).
- La singola task-entry in `tasks-active.md` segue lo schema canonico di `../planning-source-contract.md` § "Schema task-entry", incluso il campo `Complessità (ipotesi)`.
