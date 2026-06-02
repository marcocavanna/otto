# Tier-project — modo `plan`

> Reference tier-specifico della skill `planner`. Implementa il modo `plan` per il tier `project`.
> Parte da una context-root **già selezionata** dal router (`SKILL.md`): la scelta del tier e la conferma
> dell'utente sono già avvenute. Questo file descrive l'esecuzione da quel punto in poi.
>
> Reference condivisi consumati (non duplicati qui):
> - Elicitation: `elicitation.md`
> - Critica: `critical-review.md`
> - Espansione task: `task-expansion.md`
> - Template artefatti: `artifact-contract.md` § "Tier `project`"
> - Schema anchor: `../anchor-schema.md`
> - Contratto planning source: `../planning-source-contract.md`

---

## Flusso `plan <project>`

Il flusso si compone di 7 passi in sequenza. La derivazione dal codebase **precede** l'elicitation.
La conferma delle milestone proposte **precede** la materializzazione degli artefatti.

### Passo 1 — Verifica prerequisiti

1. Verifica che la cwd sia un repo di progetto (presenza di `.git`, `package.json`, `*.csproj`,
   `*.sln`, `Cargo.toml`, ecc.). Se ambiguo, chiedi conferma del path.

2. **Guardia anti-overwrite**: se `docs/planning/` esiste già → **rifiuta immediatamente**,
   indirizza a `revise` (per aggiornare un'assunzione: futuro modo del router unificato) o a
   `expand` (per espandere una milestone: futuro modo del router unificato). Non procedere oltre.

### Passo 2 — Derivazione dal codebase

Prima di chiedere all'utente, ispeziona il repo per inferire stack, convenzioni e build:

1. `CLAUDE.md` di root e dei sub-progetti (routing, stack, vincoli).
2. `.claude/assistant/{project,codebase,code}/00-summary.md` e i file linkati **pertinenti al
   progetto** (non ricaricare l'intero knowledge base — leggere solo ciò che è rilevante).
3. **1-2 file sample** delle aree toccate (per inferire stile e pattern esistenti).
4. Build/test command: da `package.json`, `*.csproj`/`*.sln`, Makefile, script noti, o
   `.claude/assistant/code/*.md`.

Da questa ispezione pre-compila:
- Bozza del **technical-context** di progetto (build_command, pattern, convenzioni).
- Bozza di `02-abstract.md` (architettura proposta, stack, approccio).

Se l'ispezione è insufficiente (repo opaco, assenza di knowledge), dichiararlo esplicitamente e
passare a un'elicitation più estesa — non inventare convenzioni.

### Passo 3 — Elicitation

Delega a `elicitation.md` con profondità tier **`project`**: blocchi **A** (A1-A4), **B**, **C**,
**D**, **E** obbligatori; blocco **F** opzionale (solo se il progetto ha distribuzione/monetizzazione
come componente esplicita).

Regola chiave: **chiedi solo ciò che il codebase non ha rivelato**. Se la derivazione al Passo 2 ha
già coperto un punto (es. stack, build command, convenzioni di naming), non ri-elicitarlo.

### Passo 4 — Critica

Delega a `critical-review.md`. Per il tier `project` sono applicabili **tutti i pattern 1-9**.
Pattern **obbligatori**: 1 (scope/effort mismatch), 2 (why-now debole), 3 (nessuna analisi
concorrenza), 4 (nessuna esclusione di scope). Pattern **advisory**: 5, 6, 7, 8, 9.

Sollevare i problemi rilevati **prima** di generare gli artefatti. L'utente decide se mitigare o
procedere. Se procede, i problemi rossi/gialli vanno in `00-context.md` § "Known risks".

### Passo 5 — Conferma milestone proposte

Prima di materializzare, presenta all'utente le **milestone proposte** per conferma esplicita.
Formato di presentazione:

```
Progetto: <nome>  —  [outcome finale osservabile]
Milestone (ordine):
  M1 — [nome] — [outcome osservabile]   effort: [range]
  M2 — [nome] — [outcome osservabile]   effort: [range]
  ...
Milestone attiva corrente: M1
```

> Nota: il numero tipico di milestone è 3-6. Mai >8. M1 deve includere setup minimo + primo output
> utile (mai "M1: setup ambiente" come unico contenuto). L'ultima milestone deve allinearsi alla
> metrica di successo (E1 dall'elicitation).

Attendere conferma esplicita prima di procedere al Passo 6. Se l'utente vuole modificare la
decomposizione, iterare qui fino ad accordo raggiunto.

### Passo 6 — Generazione dei 7 artefatti

Genera i 7 file in `docs/planning/`. Template completi: `artifact-contract.md` § "Tier `project`".

#### 6.1 — `00-context.md`

Raccolta cruda dell'elicitation + assunzioni tracciate + rischi noti. Porta l'**anchor
obbligatorio** subito dopo il titolo H1 (vedi `../anchor-schema.md` § "Formato canonico"):

```
<!-- Anchor --> **Tier**: project · **Parent**: — · **Bubble-up target**: —
```

Il tier `project` è radice della gerarchia: `Parent` e `Bubble-up target` sono sempre `—`
[ASSUMPTION-planner-unification-core-006-001].

Template: `artifact-contract.md` § "Tier `project`" `00-context.md`.

#### 6.2 — `01-pitch.md`

Pitch del progetto. Massimo 1 pagina, denso, nessuna prosa promozionale.
**Non porta l'anchor** (vedi `../anchor-schema.md` § "Posizione").

Template: `artifact-contract.md` § "Tier `project`" `01-pitch.md`.

#### 6.3 — `02-abstract.md`

Abstract tecnico: architettura proposta, stack, trade-off, rischi tecnici, esclusioni.
**Non porta l'anchor** (vedi `../anchor-schema.md` § "Posizione").

Usa la bozza derivata al Passo 2 come punto di partenza; integra con l'elicitation del Passo 3.

Template: `artifact-contract.md` § "Tier `project`" `02-abstract.md`.

#### 6.4 — `03-milestones.md`

Roadmap macro. **Sempre** alto livello: mai task atomici qui. Milestone confermate al Passo 5.
**Non porta l'anchor** (vedi `../anchor-schema.md` § "Posizione").

Regole milestones: 3-6 (mai >8); ogni milestone **dimostrabile**; M1 include setup minimo + primo
output utile; l'ultima milestone si allinea alla metrica di successo (E1).

Template: `artifact-contract.md` § "Tier `project`" `03-milestones.md`.

#### 6.5 — `04-phases.md`

Fasi di lavoro orizzontali — tagliano le milestone in modo ortogonale. Adattare al progetto
specifico (Fase 4 può non esistere per tool personali; per librerie: design/impl/docs/pubblicazione).
**Non porta l'anchor** (vedi `../anchor-schema.md` § "Posizione").

Template: `artifact-contract.md` § "Tier `project`" `04-phases.md`.

#### 6.6 — `README.md`

Indice del planning: stato corrente, milestone attiva, link a tutti i file.
**Non porta l'anchor** (vedi `../anchor-schema.md` § "Posizione").

Template: `artifact-contract.md` § "Tier `project`" `README.md`.

#### 6.7 — `05-tasks-active.md`

Task atomici **solo** per la milestone M1 (default: prima milestone della roadmap).

Intestazione obbligatoria (non porta l'anchor — vedi `../anchor-schema.md` § "Posizione"):
```
**Milestone attiva**: M1 — [nome]
**Effort totale stimato**: [X-Y ore]
**Definition of done milestone**: [da 03-milestones.md]
```

Campi obbligatori per ogni task-entry: schema canonico in `../planning-source-contract.md`
§ "Schema task-entry". Il campo `Complessità (ipotesi)` è **obbligatorio** per ogni entry
[ASSUMPTION-planner-unification-core-006-003]; euristica di assegnazione: `task-expansion.md`
§ "Assegnazione `Complessità (ipotesi)`".

Numero tipico per scope foundation (M1): 15-25 task. Se supera 30 → sollevare il punto con
l'utente prima di salvare: lo scope è probabilmente troppo grande per una singola milestone.

Delega completa a `task-expansion.md` per: granularità, anti-pattern, categorie, spike,
composizione attesa, formato delle entry.

Template: `artifact-contract.md` § "Tier `project`" `05-tasks-active.md`.

### Passo 7 — Summary

Dopo aver scritto tutti e 7 gli artefatti:

1. **File generati**: lista completa con path (`docs/planning/`).
2. **Milestone decomposte**: ordine, effort stimato, milestone attiva.
3. **Task M1**: numero di task generati, effort totale, composizione per categoria.
4. **Assunzioni più fragili**: quelle con `Status: active` in `00-context.md` che dipendono da
   informazioni non confermate o non desumibili dal codebase.
5. **Prossimo passo**: `flow-run <slug-primo-task>` (se il progetto usa il flow orchestrator)
   oppure `task-implementer brief <slug>-001` (se si vuole il brief manuale per il primo task).

---

## Vincoli di scope

- Scrive **solo** sotto `docs/planning/`.
- Non tocca `docs/epics/`, `docs/features/`, `docs/tasks/`, né il codice sorgente.
- Non tocca le skill `*-planner` esistenti: `project-planner` resta attiva in parallelo.
- I 7 file hanno nome fisso: `00-context.md`, `01-pitch.md`, `02-abstract.md`, `03-milestones.md`,
  `04-phases.md`, `05-tasks-active.md`, `README.md`.
- Il modo `revise` (aggiornare un'assunzione) e il modo `expand` standalone (espandere una
  milestone diversa dall'attiva senza rigenerare tutto) **non** sono implementati qui — appartengono
  a modi futuri del router unificato (feature `planner-unification-finalize`)
  [ASSUMPTION-planner-unification-core-006-002].

---
Generato: 2026-06-02 | Task: planner-unification-core-006 | Feature: planner-unification-core
