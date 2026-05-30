# Feature artifacts — template + contratto downstream

Template dei 4 file generati in `docs/features/<slug>/` e definizione **canonica** del contratto che i downstream (`task-implementer`, `code-implementer`, `flow-run`) usano per risolvere il contesto di un task. Markdown denso, niente filler, regole di gap come `../project-planner/artifact-templates.md`.

---

## Planning source contract (CANONICO)

> Questa sezione è la fonte di verità del meccanismo di risoluzione. `task-implementer` e `code-implementer` vi puntano. Non duplicarla altrove: linkarla.

Una **planning source** = una directory **context-root** che contiene:

- `00-context.md`
- `02-abstract.md`
- `technical-context.md` (può essere seedato da feature-planner; `task-implementer` lo estende append-only)
- un file lista-task:
  - **project source**: `docs/planning/05-tasks-active.md` → context-root = `docs/planning/`
  - **feature source**: `docs/features/<slug>/tasks-active.md` → context-root = `docs/features/<slug>/`

**Task ID**: stringa **globalmente unica**, trattata in modo opaco dai downstream:
- project: `T-NNN`
- feature: `<slug>-NNN` (es. `user-export-001`)

**Risoluzione della context-root per un task `X`** (la fa `task-implementer` in `brief X`):
1. Scan di `docs/planning/05-tasks-active.md` + `docs/features/*/tasks-active.md`.
2. Il file la cui lista contiene `X` definisce la source; context-root = la sua directory; tasks-file = quel file.
3. 0 match → errore "task sconosciuto". >1 match → errore "ID ambiguo" (gli ID devono essere unici).
4. Override esplicito ammesso: l'utente/orchestratore può passare la source (`feature <slug>`), saltando lo scan.

**Header del brief** (`docs/tasks/<id>.md`, scritto da `task-implementer`, letto da `code-implementer`):
```
**Origin**: project-planner | feature-planner
**Context-root**: docs/planning/ | docs/features/<slug>/
```
`code-implementer` carica `00-context.md`/`02-abstract.md`/`technical-context.md` da `Context-root`. Se l'header manca → default `docs/planning/` (retro-compatibilità con i brief storici).

I brief vivono **sempre** in `docs/tasks/<id>.md` (namespace condiviso): per questo l'unicità degli ID è obbligatoria.

---

## 00-context.md (feature)

```markdown
# Context — Feature: [titolo feature] (`<slug>`)

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

## 02-abstract.md (feature)

```markdown
# Abstract tecnico — Feature: [titolo] (`<slug>`)

## Approccio
[Come si realizza la feature dentro l'architettura esistente. Niente intro sui framework. Riusa ciò che c'è.]

## Moduli impattati
- [path/modulo] — [cosa cambia]

## Stack pertinente
- [solo le voci rilevanti per QUESTA feature; il resto è già nel progetto]

## Contratti da preservare
[Interfacce/endpoint/schema esistenti che la feature consuma ma NON deve rompere. Diventeranno frozen.txt lato flow.]

## Trade-off
[1-3 trade-off espliciti specifici della feature.]

## Rischi tecnici
[Integrazioni rischiose, regressioni possibili, prestazioni.]

## Esclusioni tecniche
[Cosa NON si fa in questa feature e perché.]

---
Generato: YYYY-MM-DD | Versione: 1
```

## technical-context.md (seed)

> Seed minimale: serve a `code-implementer` (build_command) e a dargli i pattern da seguire. `task-implementer` lo estende in append-only man mano.

```markdown
# Technical context — Feature: [titolo] (`<slug>`)

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

## tasks-active.md (feature)

> Stesso formato per-task di `../project-planner/task-expansion.md`, così `task-implementer` lo parsa identico. Niente milestone: campo `Feature`.

```markdown
# Task attivi — Feature: [titolo] (`<slug>`)

**Feature**: <slug>
**Effort totale stimato**: [X-Y ore]
**Definition of done feature**: [criterio binario d'insieme]

## Task

### <slug>-001 — 💻 [impl] [verbo + oggetto specifico]
- **Effort**: 2-3h
- **Definition of done**: [concreta, binaria, verificabile]
- **Dipende da**: —
- **Status**: ⚪ todo | 🔵 in progress | ✅ done | ⏸ blocked

### <slug>-002 — 🧪 [test] [...]
- **Effort**: 1-2h
- **Definition of done**: [...]
- **Dipende da**: <slug>-001
- **Status**: ⚪ todo

[...]

## Note operative
[Ordine suggerito, blocchi paralleli, riferimenti a spike.]

## Out of scope per questa feature
[Cose rimandate, con link a feature/task futuri se noti.]

---
Generato: YYYY-MM-DD | Versione: 1 | Feature: <slug>
```

## Numero di task

Una feature è piccola per definizione: tipicamente **1-8 task**. Se supera ~10, probabilmente non è una singola feature → valuta `project-planner` (milestone) o split in più feature.
