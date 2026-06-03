# Tier-epic — modo `plan`

> Reference tier-specifico della skill `planner`. Implementa il modo `plan` per il tier `epic`.
> Parte da una context-root **già selezionata** dal router (`SKILL.md`): la scelta del tier e la conferma
> dell'utente sono già avvenute. Questo file descrive l'esecuzione da quel punto in poi.
>
> Reference condivisi consumati (non duplicati qui):
> - Elicitation: `elicitation.md`
> - Critica: `critical-review.md`
> - Template artefatti: `artifact-contract.md` § "Tier `epic`"
> - Schema anchor: `../anchor-schema.md`
> - Contratto planning source: `../planning-source-contract.md`
> - Regole di decomposizione: `decomposition.md`
> - Template feature figlie + propagazione seed: `epic-artifacts.md`

---

## Flusso `plan <epic>`

Il flusso si compone di 7 passi in sequenza. La derivazione dal codebase **precede** l'elicitation.
La conferma della decomposizione **precede** la materializzazione degli artefatti.

### Passo 1 — Verifica prerequisiti

1. Verifica che la cwd sia un repo di progetto. Se ambiguo, chiedi conferma del path.
2. Deriva lo **slug** kebab-case dal nome epic (es. "Rifacimento area pagamenti" → `payments-revamp`).
   Conferma con l'utente se il mapping non è ovvio o se il nome è lungo/ambiguo.
3. **Guardia anti-overwrite**: se `docs/epics/<epic>/` esiste già → **rifiuta immediatamente**,
   indirizza a `revise <epic>` (per aggiornare un'assunzione/decisione condivisa) o
   `add-feature <epic>` (per aggiungere una feature all'epic). Non procedere oltre.

### Passo 2 — Derivazione dal codebase

Prima di chiedere all'utente, ispeziona il repo per inferire stack, convenzioni e build:

1. `CLAUDE.md` di root e dei sub-progetti (routing, stack, vincoli).
2. `.claude/assistant/{project,codebase,code}/00-summary.md` e i file linkati **pertinenti all'epic**
   (non ricaricare l'intero knowledge base — leggere solo ciò che è rilevante al dominio).
3. **1-2 file sample** delle aree toccate dall'epic (per inferire stile e pattern condivisi).
4. Build/test command: da `package.json`, `*.csproj`/`*.sln`, Makefile, script noti, o
   `.claude/assistant/code/*.md`.

Da questa ispezione pre-compila:
- Bozza del **technical-context condiviso** dell'epic (build_command, pattern, VO condivisi).
- Bozza di `02-abstract.md` (moduli toccati d'insieme, approccio).

Se l'ispezione è insufficiente (repo opaco, assenza di knowledge), dichiararlo esplicitamente e
passare a un'elicitation più estesa — non inventare convenzioni.

### Passo 3 — Elicitation

Delega a `elicitation.md` con profondità tier **`epic`**: blocchi **A** (A1-A3) e **B** (scope
d'insieme) obbligatori; blocco **C** advisory; blocco **D** come stack-check advisory (solo per
verificare coerenza con ciò che il codebase già ha, non per scegliere lo stack da zero).

Punti epic-specifici da coprire nell'elicitation (in aggiunta ai blocchi standard):
- Comportamento atteso **d'insieme** (outcome osservabile dell'epic completo).
- Boundary **inter-feature**: cosa appartiene a una feature e non a un'altra.
- Edge case di **sequencing** non desumibili dal codebase (dipendenze tecniche tra feature, migrazioni
  irreversibili, fronti che possono procedere in parallelo).

Regola chiave: **chiedi solo ciò che il codebase non ha rivelato**. Se la derivazione al Passo 2 ha
già coperto un punto, non ri-elicitarlo.

Per le regole di decomposizione dell'epic in feature sequenziali, vedi
`decomposition.md`.

### Passo 4 — Critica

Delega a `critical-review.md`. Per il tier `epic` sono applicabili i pattern: **1** (scope/effort
mismatch: se emerge 1 sola feature, non è un epic → redirecta a `feature-planner`), **3** (logica di
sequencing debole: ordine senza dipendenza tecnica reale), **4** (nessuna esclusione scope d'insieme),
**6** (scope che sconfina nel tier `project`: se servono milestone / pitch / market → redirecta a
`project-planner`).

Sollevare i problemi rilevati **prima** di generare gli artefatti. L'utente decide se mitigare o
procedere. Se procede, i problemi rossi/gialli vanno in `00-context.md` § "Known risks".

### Passo 5 — Decomposizione e conferma

Prima di materializzare, presenta all'utente la **lista ordinata delle feature figlie** per conferma
esplicita. Formato di presentazione (da `decomposition.md` §
"Output della decomposizione"):

```
Epic: <epic>  —  [outcome d'insieme]
Feature (ordine):
  1. <epic>-foundation   🏗️  [goal]   dep: —            size: S|M|L
  2. <epic>-api          💻  [goal]   dep: foundation   size: S|M|L
  3. <epic>-ui           💻  [goal]   dep: api          size: S|M|L   ∥ con (4)
  4. <epic>-reporting    💻  [goal]   dep: api          size: S|M|L   ∥ con (3)
DoD epic: [criterio binario d'insieme]
Fronti paralleli: {3, 4} dopo (2)
```

> **ASSUMPTION-008**: il sizing per feature è **t-shirt size** (S/M/L) indicativo, non effort numerico.
> I task reali nascono solo a `planner expand <feature>`: qualsiasi numero emesso qui sarebbe speculativo.

Attendere conferma esplicita prima di procedere al Passo 6.

### Passo 6 — Generazione degli artefatti

Genera gli artefatti in sequenza. Template completi: `artifact-contract.md` § "Tier `epic`".

#### 6.1 — Layer epic (`docs/epics/<epic>/`)

**`docs/epics/<epic>/00-context.md`**

Porta l'**anchor obbligatorio** subito dopo il titolo H1 (vedi `../anchor-schema.md`):

```
<!-- Anchor --> **Tier**: epic · **Parent**: <project-slug|—> · **Bubble-up target**: <docs/planning/technical-context.md|—>
```

Risoluzione `Parent` / `Bubble-up target`: scan di `docs/planning/technical-context.md`.
- File presente → `Parent: <project-slug>` e `Bubble-up target: docs/planning/technical-context.md`.
- File assente → epic standalone: `Parent: —` e `Bubble-up target: —`.

Contenuto: contesto epic, decomposizione in feature (razionale), boundary e scope d'insieme,
tracked assumptions condivise, known risks cross-feature. Template: `artifact-contract.md`
§ "Tier `epic`" `00-context.md (epic)`.

---

**`docs/epics/<epic>/02-abstract.md`**

**Non porta l'anchor** (vedi `../anchor-schema.md` § "Posizione": solo `00-context.md` e
`technical-context.md`).

Contenuto: approccio tecnico d'insieme, decisioni tecniche condivise (valide per **tutte** le
feature), contratti da preservare, trade-off d'insieme, rischi tecnici cross-feature, esclusioni.
Template: `artifact-contract.md` § "Tier `epic`" `02-abstract.md (epic)`.

---

**`docs/epics/<epic>/technical-context.md`** (seed condiviso)

Porta l'**anchor obbligatorio** con la stessa valorizzazione di `00-context.md`.

Contenuto: build_command, pattern architetturali condivisi, VO/contratti condivisi, librerie e
versioni. È il **seed** che le feature figlie ereditano (vedi §6.2 e
`epic-artifacts.md` § "Propagazione del seed").
Template: `artifact-contract.md` § "Tier `epic`" `technical-context.md (epic — seed condiviso)`.

---

**`docs/epics/<epic>/roadmap.md`**

**Non porta l'anchor** (vedi `../anchor-schema.md` § "Posizione").

Contenuto: outcome epic, DoD epic, elenco feature in ordine sequenziale con **t-shirt size
indicativo** (S/M/L), dipendenze inter-feature, fronti paralleli, note di sequencing.

> **ASSUMPTION-008**: il campo sizing usa `**Size**: S | M | L` (indicativo), **non**
> `**Effort**: [X-Yh] (~N task)`. Il campo `Effort` è omesso o marcato `da determinare a expand`.
> Motivazione: i task reali nascono a `expand`; un numero qui sarebbe speculativo e fuorviante.

Template: `artifact-contract.md` § "Tier `epic`" `roadmap.md (epic — coordinamento)`, con
`**Effort**: [X-Yh] (~N task)` sostituito da `**Size**: S | M | L`.

Esempio entry:
```
### <epic>-foundation — 🏗️ [titolo feature]
- **Goal**: [outcome osservabile]
- **Dipende da feature**: —
- **Size**: M  (indicativo — effort reale determinato a expand)
- **Status feature**: ⚪ planned
- **Source**: docs/features/<epic>-foundation/
```

#### 6.2 — Feature figlie (`docs/features/<epic>-<feat>/`)

Per ogni feature figlia confermata al Passo 5, genera il bundle standard di **4 file** in
`docs/features/<epic>-<feat>/`. Regole complete: `epic-artifacts.md`
§ "Feature figlie — generazione".

**`docs/features/<epic>-<feat>/00-context.md`**

Ancora obbligatorio con:
```
<!-- Anchor --> **Tier**: feature · **Parent**: <epic> · **Bubble-up target**: docs/epics/<epic>/technical-context.md
```

Aggiungere:
- `**Epic**: <epic>` nel frontmatter.
- `**Dipende da feature**: [<epic>-<feat-precedente> | —]` coerente con `roadmap.md`.

Template: `artifact-contract.md` § "Tier `feature`" `00-context.md (feature)`.

---

**`docs/features/<epic>-<feat>/02-abstract.md`**

Non porta l'anchor. Non ripete le decisioni condivise: le **referenzia**
(`vedi docs/epics/<epic>/02-abstract.md`) e aggiunge solo lo specifico della feature.

Template: `artifact-contract.md` § "Tier `feature`" `02-abstract.md (feature)`.

---

**`docs/features/<epic>-<feat>/technical-context.md`**

Ancora obbligatorio (stesso valorizzato di `00-context.md` del figlio).
Seedato dal condiviso: copia le sezioni rilevanti con intestazione:
```
> Seed da docs/epics/<epic>/technical-context.md
```

Per la logica di propagazione del seed (in giù alla materializzazione, in su a feature conclusa)
vedi `epic-artifacts.md` § "Propagazione del seed".

---

**`docs/features/<epic>-<feat>/tasks-active.md`** (shell — ASSUMPTION-009)

> **ASSUMPTION-009**: le feature figlie ricevono un `tasks-active.md` **shell** (stub "da espandere"),
> **zero task-entry autorevoli**. I task reali nascono solo a `planner expand <epic>-<feat>`.

La shell contiene:
1. **Intestazione standard** del tier `feature`:
   ```
   **Feature**: <epic>-<feat>
   **Effort totale stimato**: da determinare
   **Definition of done feature**: [goal sintetico della feature]
   ```
2. **Stub di espansione** (nessuna task-entry):
   ```
   > ⏳ Task da espandere. Eseguire `planner expand <epic>-<feat>` per generare i task atomici.
   ```
3. **Sezione `## Out of scope per questa feature`** con la voce:
   ```
   - Task atomici — determinati a expand.
   ```

Questo garantisce che il file sia una **planning source valida** (struttura coerente, intestazione
presente) senza ingannare il DEV con task fabricati.

### Passo 7 — Summary

Dopo aver scritto tutti gli artefatti:

1. **File generati**: lista completa (layer epic + bundle di ogni feature figlia).
2. **Decomposizione adottata**: ordine feature, dipendenze inter-feature, fronti paralleli.
3. **Assunzioni più fragili**: quelle con `Status: active` in `00-context.md` che dipendono da
   informazioni non confermate o non desumibili dal codebase.
4. **Prossimo passo**: `planner expand <epic>-<prima-feature>` per generare i task atomici della
   prima feature, poi `flow-run <epic>-<prima-feature>` per eseguire.

---

## Vincoli di scope

- Scrive **solo** sotto `docs/epics/<epic>/` e `docs/features/<epic>-*/`.
- Non tocca `docs/planning/`, altre feature/epic, né il codice sorgente.
- Non tocca le skill `*-planner` esistenti: `epic-planner` resta attiva in parallelo.
- **Non** crea mai `docs/epics/<epic>/tasks-active.md`: l'epic non è una planning source.
- I 4 file del layer epic hanno nome fisso: `00-context.md`, `02-abstract.md`,
  `technical-context.md`, `roadmap.md`.
- I 4 file di ogni feature figlia hanno nome fisso: `00-context.md`, `02-abstract.md`,
  `technical-context.md`, `tasks-active.md`.

---
Generato: 2026-06-02 | Task: planner-unification-core-005 | Feature: planner-unification-core
