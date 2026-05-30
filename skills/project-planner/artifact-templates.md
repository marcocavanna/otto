# Artifact templates

Template e regole per i 7 file generati. Tutti in Markdown, nella lingua dell'elicitation.

## Regole trasversali

- Ogni file inizia con un H1 che è il titolo del documento + il nome del progetto.
- Ogni file ha in fondo una sezione `---` con metadata: `Generato: YYYY-MM-DD` e `Versione: N` (incrementata a ogni revise).
- Nessuna sezione filler. Se una sezione non ha contenuto reale dall'elicitation, va trattata come gap esplicito (vedi "Gestione gap" sotto).
- Riferimenti a tracked assumptions sempre nel formato `[ASSUMPTION-NNN]` linkabili al file `00-context.md`.

## Gestione gap

Se una sezione non ha contenuto sufficiente dall'elicitation:
- NON inventare. NON usare prose generica.
- Inserire blocco esplicito:
  ```
  > ⚠ **Gap**: [cosa manca]
  > Decidere prima di [milestone X / fase Y]. Vedi [ASSUMPTION-NNN] in 00-context.md.
  ```

---

## 00-context.md

Raccolta cruda dell'elicitation + assunzioni tracciate + rischi noti. Questo file è la **fonte di verità** per tutti gli altri.

```markdown
# Context — [Nome progetto]

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

---

## 01-pitch.md

Pitch del progetto. Massimo 1 pagina, denso, nessuna prosa promozionale.

```markdown
# Pitch — [Nome progetto]

## In una frase
[Sintesi del progetto in max 25 parole. Forma: "[Prodotto] è un [forma] per [target] che [risolve cosa] grazie a [come]."]

## Problema
[2-3 paragrafi. Concreto. Niente "in un mondo sempre più digitale". Da A1+A2.]

## Soluzione
[2-3 paragrafi. Cosa fa il prodotto, non come è fatto. Da B2.]

## Target
[Chi è l'utente, quanti sono, come li raggiungi. Da A2+F1.]

## Differenziatore
[Cosa ti rende diverso da quello che esiste. Da A4. Se nulla, dichiararlo: "Nessun differenziatore funzionale forte — il valore è in [X]" — onestà > marketing.]

## Why now
[Da A3. Se debole, dichiararlo come tale.]

## Metrica di successo
[Da E1. Concreta e misurabile.]

## Cosa NON è
[Da B3. Esclusioni esplicite.]

---
Generato: YYYY-MM-DD | Versione: 1
```

---

## 02-abstract.md

Abstract tecnico. Per un dev senior. Niente intro su "cosa è X framework".

```markdown
# Abstract tecnico — [Nome progetto]

## Architettura proposta
[Descrizione concisa. Componenti principali. Comunicazione tra essi. Diagramma testuale se utile.]

## Stack
- **Linguaggio/runtime**: [...]
- **Framework principale**: [...]
- **Database**: [...]
- **Infrastruttura**: [...]
- **Altri**: [...]

[Per ogni voce: una riga di motivazione. Se assunzione, marcare ASSUMPTION-NNN.]

## Trade-off tecnici principali
[2-4 trade-off espliciti. Es: "Sceglierei SQLite anziché Postgres per semplicità deploy, accettando di rifattorizzare se i dati superano [soglia]".]

## Rischi tecnici
[Da D2 + critical review. Tecnologie ignote, integrazioni rischiose, prestazioni ipotetiche. Concretizzare.]

## Punti aperti
[Domande tecniche non ancora risolte che andranno chiuse durante l'execution. Linkate a milestone specifiche.]

## Esclusioni tecniche
[Pattern/feature/tooling esplicitamente non adottati e perché. Es: "Niente microservizi", "Niente auth SSO in v1".]

---
Generato: YYYY-MM-DD | Versione: 1
```

---

## 03-milestones.md

Roadmap macro. **Sempre** alto livello. Mai task atomici qui.

```markdown
# Milestones — [Nome progetto]

Roadmap a milestone macro. Ogni milestone è un incremento di valore osservabile (non un set di task tecnici).

## M1 — [Nome — verbo + risultato osservabile]
- **Outcome**: [cosa l'utente/io vede di nuovo a fine milestone]
- **Definition of done**: [criterio binario di completamento]
- **Effort stimato**: [giorni di lavoro, in range — es. "8-12 giorni"]
- **Status**: 🔵 active | ⚪ planned | ✅ done | ⏸ paused

## M2 — [...]
[idem]

## M3 — [...]
[idem]

[Tipicamente 3-6 milestone. Mai >8.]

## Sequenziamento
[Una riga: M1 → M2 → M3, oppure note su dipendenze/parallelismi se rilevanti.]

## Milestone attiva corrente
**M1** (vedi `05-tasks-active.md` per task atomici)

---
Generato: YYYY-MM-DD | Versione: 1
```

## Regole per milestones

- Numero: 3-6, mai più di 8.
- Ogni milestone deve essere **dimostrabile**, non solo "completata internamente".
- M1 deve includere il setup minimo + un primo output utile. NON "M1: setup ambiente".
- L'ultima milestone deve allinearsi alla metrica di successo (E1).

---

## 04-phases.md

Fasi di lavoro orizzontali — non sostituiscono le milestone, le tagliano in modo ortogonale.

```markdown
# Fasi di lavoro — [Nome progetto]

Le fasi rappresentano stati qualitativi del progetto. Una milestone può attraversare più fasi; una fase può contenere più milestone.

## Fase 0 — Spike & validazione (opzionale)
- **Quando**: prima di M1, solo se ci sono incertezze tecniche significative (vedi D2)
- **Output atteso**: PoC throw-away che risolve le incognite tecniche
- **Definition of done**: [...]

## Fase 1 — Foundation
- **Quando**: prevalentemente M1, parte di M2
- **Output atteso**: stack scelto funzionante, deploy minimo, dominio del problema implementato
- **Definition of done**: [...]

## Fase 2 — Vertical slice
- **Quando**: M2-M3
- **Output atteso**: primo flusso utente end-to-end funzionante
- **Definition of done**: [...]

## Fase 3 — Beta usable
- **Quando**: M3-M4
- **Output atteso**: il prodotto è usabile dall'utente target (anche solo te stesso) in produzione
- **Definition of done**: [...]

## Fase 4 — Public release (se applicabile)
- **Quando**: ultima milestone
- **Output atteso**: prodotto pubblicato, primo flusso di acquisizione utenti attivo
- **Definition of done**: [...]

---
Generato: YYYY-MM-DD | Versione: 1
```

Adattare le fasi al progetto. Per un tool puramente personale, Fase 4 può non esistere. Per una libreria, possono diventare "Fase 1: API design", "Fase 2: implementazione", "Fase 3: docs+pubblicazione".

---

## 05-tasks-active.md

Task atomici **solo** per la milestone attiva corrente. Vedi `task-expansion.md` per le regole.

Template iniziale (post-init, prima di expand):

```markdown
# Task attivi — [Nome progetto]

**Milestone attiva**: M1 — [nome]

> Questo file contiene task atomici solo per la milestone corrente.
> Per espandere una nuova milestone in task atomici, chiedimi `expand M2` (o l'ID desiderato).

[Lista task atomici della M1 — generata anche in init perché M1 è auto-attiva]

---
Generato: YYYY-MM-DD | Versione: 1
```

---

## README.md

Indice e stato corrente.

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

- **Espandere una nuova milestone in task atomici**: `expand M[N]`
- **Aggiornare un'assunzione**: `revise [artifact]`

---
Generato: YYYY-MM-DD | Versione: 1
```
