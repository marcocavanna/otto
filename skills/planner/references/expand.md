# Expand — Planner

> Letto da `SKILL.md` § "expand <scope>" allo step di rigenerazione del tasks-file.
> Dipendenze: `../planning-source-contract.md` (algoritmo risoluzione, schema task-entry),
> `task-expansion.md` (euristica complessità, regole granularità).

---

## Step 1 — Risoluzione slug / source

**Input**: `<scope>` — slug parziale o completo, oppure path parziale.

**Algoritmo** (da `../planning-source-contract.md` § "Algoritmo di risoluzione"):

1. Scan per directory di tutti i tasks-file per i 4 tier:
   - `project` → `docs/planning/05-tasks-active.md`
   - `epic` → `docs/epics/*/tasks-active.md`
   - `feature` → `docs/features/*/tasks-active.md`
   - `task` → `docs/tasks/*/tasks-active.md`
2. Esclude `docs/archive/**` dallo scan.
3. Per ogni tasks-file trovato: controlla se la directory (o il path del file) contiene `<scope>` come sottostringa o se corrisponde esattamente allo slug.
4. Esito:
   - **0 match** → errore: `"source sconosciuta: <scope>"`. Interrompi.
   - **1 match** → context-root confermata; procedi al Step 2.
   - **>1 match** → elenca i candidati e chiedi selezione esplicita (vedi sotto). Non procedere autonomamente.

**Gestione conflitto (>1 candidato)**:

```
expand planner-unification
→ Trovate 2 source con "<scope>" nel path:
  [1] docs/features/planner-unification-finalize/tasks-active.md
  [2] docs/epics/planner-unification/tasks-active.md
Quale source vuoi espandere? (1/2)
```

Non procedere fino alla selezione esplicita dell'utente.

---

## Step 2 — Lettura contesto

Dalla context-root risolta, leggi:

1. `00-context.md` — contesto, assunzioni, known risks.
2. `02-abstract.md` — se presente (opzionale); ignora silenziosamente se assente.
3. `technical-context.md` — build_command, pattern, VO, convenzioni.
4. tasks-file corrente (`tasks-active.md` / `05-tasks-active.md`) — per estrarre gli **ID stabili** dei task esistenti e il loro stato.

**Estrazione ID stabili**: scansiona ogni riga `### <id> —` nel tasks-file corrente; costruisci la mappa `{ id → titolo, status }` da preservare.

---

## Step 3 — Backup

Prima di ogni sovrascrittura:

1. Copia il tasks-file in `<tasks-file>.bak` (stesso path, estensione `.bak` aggiunta).
   - Sovrascrive il backup precedente se esiste (si mantiene un solo `.bak`).
2. Segnala all'utente il path del backup:
   ```
   Backup creato: docs/features/<slug>/tasks-active.md.bak
   ```

---

## Step 4 — Elicitation delta

Domanda leggera sullo scope; **non** è una re-elicitation completa (quella spetta a `plan`):

```
Lo scope di <slug> è cambiato rispetto all'ultimo expand?
Novità su vincoli, task aggiunti/rimossi, dipendenze cambiate? (o "no" per usare solo il contesto dei file)
```

- Risposta **"no"** (o equivalente) → salta l'aggiornamento contestuale; usa solo i file letti al Step 2.
- Risposta con delta → integra le informazioni fornite nel contesto prima di generare.

---

## Step 5 — Rigenerazione tasks-active.md

Applica le regole di `task-expansion.md` (granularità, anti-pattern, schema canonico) per generare la nuova versione del tasks-file.

**Preservazione ID stabili**:

- Un task esistente è "lo stesso" se il suo ID (`### <id> —`) non cambia.
- Il titolo, l'effort, il DoD, le dipendenze e la complessità *possono* cambiare; l'ID rimane invariato.
- Task rimossi: l'ID è **definitivamente abolito** — non riassegnarlo mai a un task nuovo.
- Task invariati che l'utente non ha toccato: preserva l'intero blocco senza modifiche (incluso `Status`).

**Nuovi task**:

- ID progressivi a partire da `max(ID esistenti) + 1` (formato `<slug>-NNN`, es. `planner-unification-finalize-006`).
- Non riciclare ID di task rimossi.

**Schema canonico** di ogni entry (da `../planning-source-contract.md` § "Schema task-entry"):

```markdown
### <id> — <emoji> [<tipo>] <titolo>

- **Effort**: <X-Yh>
- **Definition of done**: <concreta, binaria, verificabile>
- **Dipende da**: <id> | —
- **Complessità (ipotesi)**: trivial | standard | critical
- **Status**: ⚪ todo | 🔵 in progress | ✅ done | ⏸ blocked
```

Il campo `Complessità (ipotesi)` è **obbligatorio** per ogni task; euristica di assegnazione in `task-expansion.md` § "Assegnazione `Complessità (ipotesi)`".

**Intestazione del tasks-file** (da preservare o rigenerare secondo il tier):

- `feature` → riga `**Feature**: <slug>`
- `project` → riga `**Milestone attiva**: M[N] — [nome]`
- `task` → riga `**Tier**: task`

---

## Step 6 — Scrittura

Sovrascrivi il tasks-file con la nuova versione generata al Step 5.

Il path da scrivere è quello identificato al Step 1 (la source risolta).

---

## Step 7 — Summary

Output finale obbligatorio:

```
Expand completato per <slug>:
- <N> task preservati (ID invariati)
- <M> task aggiunti (<slug>-NNN … <slug>-MMM)
- <K> task rimossi (<id1>, <id2>, …)
- Backup: <path>.bak
```

Se non ci sono task aggiunti, rimossi o preservati, esplicitare `0` per ciascuna categoria.

---

Generato: 2026-06-02 | Task: planner-unification-finalize-001
