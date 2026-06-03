# Brief tecnico — planner-unification-finalize-001

**Origin**: feature-planner
**Context-root**: docs/features/planner-unification-finalize/
**Feature**: planner-unification-finalize
**Status**: ✅ finalized

---

## Obiettivo

Implementare il modo `expand` unificato nella skill `planner`. Il modo deve:

1. **Risolvere lo slug della source** per tutti i tier (project / epic / feature / task) usando il Planning source contract v2 (scan per directory, esclusione `docs/archive/**`); conflitto (>1 match) → chiede all'utente quale usare prima di procedere.
2. **Rigenerare `tasks-active.md`** partendo dal contesto aggiornato (abstract, context), preservando gli ID dei task esistenti (stabili — non si riassegnano).
3. **Backup obbligatorio** del tasks-file in `<tasks-file>.bak` prima di ogni sovrascrittura.
4. **Aggiornare `SKILL.md`** di `planner`: sostituire lo stub `> Rimandato — feature planner-unification-finalize` sotto `### expand <scope>` con il flusso reale, delegando la logica al reference `references/expand.md`.

---

## Analisi tecnica

### Flusso del modo `expand`

```
expand <scope>
  1. Risolvi slug/source
     - Scan tasks-file per tutti i tier (come da planning-source-contract.md § Algoritmo)
     - Esclude docs/archive/**
     - 0 match → errore "source sconosciuta: <scope>"
     - >1 match → elenca i candidati, chiede all'utente quale usare (non procede autonomamente)
     - 1 match → context-root confermata
  2. Leggi il contesto della source
     - 00-context.md, 02-abstract.md (se presente), technical-context.md
     - tasks-active.md attuale (per estrarre gli ID stabili)
  3. Backup
     - Copia tasks-active.md → tasks-active.md.bak (sovrascrive backup precedente)
     - Segnala il path del backup all'utente
  4. Raccolta contesto aggiornato
     - Elicitation leggera: "Lo scope è cambiato rispetto all'ultimo expand?
       Novità su vincoli, task aggiunti/rimossi, dipendenze cambiate?"
     - L'utente può rispondere "no" → si usa solo il contesto dei file esistenti
  5. Genera nuova versione tasks-active.md
     - Preserva gli ID esistenti per i task che rimangono
     - Nuovi task: ID progressivi dopo l'ultimo esistente (mai riciclare ID rimossi)
     - Applica schema canonico (planning-source-contract.md § Schema task-entry)
     - Emette campo `Complessità (ipotesi)` per ogni task (euristica in task-expansion.md)
  6. Scrivi tasks-active.md (sovrascrittura)
  7. Print summary: N task preservati, M aggiunti, K rimossi, path backup
```

### Reference `references/expand.md`

Nuovo file. Il SKILL.md lo referenzia con un singolo link; la logica operativa dettagliata è lì (pattern "SKILL.md sottile + reference lazy"). Shape della struttura:

```markdown
# Expand — Planner

> Letto da SKILL.md § "expand <scope>" allo step di rigenerazione tasks-file.
> Dipendenze: planning-source-contract.md (algoritmo risoluzione), task-expansion.md (regole task atomici + complessità).

## Step 1 — Risoluzione slug / source

[algoritmo scan per tutti i tier, gestione conflitto, back-compat anchor assente]

## Step 2 — Lettura contesto

[00-context.md + 02-abstract.md opzionale + technical-context.md + tasks-active.md corrente]

## Step 3 — Backup

[tasks-file.bak, sovrascrittura, segnalazione utente]

## Step 4 — Elicitation delta

[domanda leggera sullo scope; "no" → skip]

## Step 5-6 — Rigenerazione e scrittura

[preservazione ID, nuovi ID progressivi, schema canonico, campo Complessità (ipotesi)]

## Step 7 — Summary

[format: N preservati, M aggiunti, K rimossi, backup: <path>]
```

### Aggiornamento SKILL.md

La sezione `### expand <scope>` in `skills/planner/SKILL.md` attualmente è:

```markdown
### expand <scope>

> Rimandato — feature `planner-unification-finalize`.
```

Va sostituita con:

```markdown
### expand <scope>

Rigenera il tasks-file della source identificata da `<scope>` (slug o path parziale),
preservando gli ID stabili. Backup obbligatorio prima di sovrascrivere.
Logica completa: `references/expand.md`.
```

### Preservazione ID stabili

- **Criterio di match**: un task esistente è "lo stesso" se l'ID (`### <id> —`) non cambia.
- Un task può cambiare titolo, effort, DoD, dipendenze — l'ID rimane invariato.
- Task rimossi: l'ID viene definitivamente abolito (non riassegnato a nuovi task).
- Nuovi task: ID progressivo a partire da `max(ID esistenti) + 1` (formato slug-NNN).

### Gestione conflitto (>1 candidato)

```
expand planner-unification
→ Trovate 2 source con task contenenti "planner-unification":
  [1] docs/features/planner-unification-finalize/tasks-active.md
  [2] docs/epics/planner-unification/tasks-active.md
Quale source vuoi espandere? (1/2)
```

Non procedere fino alla selezione esplicita dell'utente.

---

## File impattati

| File | Stato | Note |
|---|---|---|
| `skills/planner/references/expand.md` | [new] | Reference del modo expand — logica operativa completa |
| `skills/planner/SKILL.md` | [edit] | Sostituire stub `### expand <scope>` con flusso reale + link a `expand.md` |

---

## Vincoli risolti

- **Stack**: Markdown + bash (skill Claude Code; nessun build/compilazione)
- **Librerie + versioni**: nessuna
- **VO/pattern/interfacce consumati** (da NON modificare):
  - Planning source contract v2 (`skills/planner/planning-source-contract.md`) — algoritmo scan, esclusione `docs/archive/**`, schema task-entry, schema ID opachi
  - Anchor schema (`skills/planner/anchor-schema.md`) — parsing `<!-- Anchor -->`, semantica back-compat
  - `task-expansion.md` (`skills/planner/references/task-expansion.md`) — euristica complessità, regole granularità, formato tasks-file
  - Pattern "SKILL.md sottile + reference lazy" — il SKILL.md delega la logica al reference
- **Naming convention**:
  - Reference: `skills/planner/references/<modo>.md` (kebab-case, lowercase)
  - Backup: `<tasks-file>.bak` (stesso path, estensione `.bak`)
  - Heading sezione SKILL.md: `### expand <scope>` (invariato)

---

## Decisioni tecniche

- **Elicitation delta leggera**: `expand` non è un `plan` da zero — l'utente conosce già il contesto. Una sola domanda ("lo scope è cambiato?") è sufficiente; in caso di "no" si usa solo il contesto dei file. Evita una re-elicitation completa che sarebbe ridondante.
- **Conflitto → chiede, non fallisce**: la risoluzione ambigua è un caso legittimo (slug parziale che batte su più source). L'utente ha l'informazione, il sistema no. Chiede anziché scegliere arbitrariamente.
- **Backup sovrascrive il precedente**: un solo `.bak` per tasks-file; non si accumula storia. Semplice, determinato, sufficiente per un undo manuale.
- **ID preservati per match esatto**: il titolo del task può cambiare (es. refactor descrittivo); l'ID è l'identificatore stabile. Impedisce il riciclo accidentale degli ID rimossi.

---

## Out of scope per questo task

- Modo `finalize` → planner-unification-finalize-002
- Bubble-up single-hop selettivo → planner-unification-finalize-003
- Invocazione di `expand` da flow-run o orchestratore
- Retrofit dell'anchor sulle source esistenti (→ feature release)
- Rimozione delle vecchie skill `*-planner`
- Modifica dei reference `tier-*.md` esistenti

---

## Dipendenze

- **Upstream**: planner-unification-core-007 ✅ finalized — router SKILL.md completo con tier-inference; la sezione `### expand <scope>` esiste già come stub

---

## Verifica

Dogfooding manuale:

1. Invocare `expand planner-unification-finalize` → source risolta correttamente (`docs/features/planner-unification-finalize/tasks-active.md`), backup creato, tasks-file rigenerato con ID preservati.
2. Invocare con slug ambiguo (es. `expand planner-unification`) → sistema elenca candidati e chiede selezione; non procede autonomamente.
3. Invocare `expand <slug-inesistente>` → errore "source sconosciuta".
4. Re-expand sulla stessa source → backup `.bak` aggiornato; tasks-file riscritto; ID task esistenti invariati.
5. Verificare che SKILL.md non contenga più lo stub "Rimandato"; il link `references/expand.md` risolve (file esiste).
6. Verifica `0 link orfani`: grep di `expand.md` in SKILL.md + file esiste.

Subtask: nessuno necessario, esecuzione lineare.

---

Generato: 2026-06-02 | Task: planner-unification-finalize-001
