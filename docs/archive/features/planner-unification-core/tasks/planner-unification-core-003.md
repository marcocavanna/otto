**Origin**: feature-planner
**Context-root**: docs/features/planner-unification-core/

# Brief — planner-unification-core-003: Implementare `tier-feature.md` (modo `plan`)

**Feature**: planner-unification-core
**Status**: ✅ finalized

---

## Obiettivo

Creare `skills/planner/references/tier-feature.md`: il reference tier-specifico che implementa il modo `plan` per il tier `feature`. Porta la logica di `feature-planner` (SKILL.md + feature-artifacts.md § "Mode 1: plan") in forma di reference tier-agnostico consumabile dal router di `skills/planner/SKILL.md`.

Il file è uno dei quattro `references/tier-{project,epic,feature,task}.md` dichiarati come TODO nel `SKILL.md` del planner unificato.

---

## Scope

### File impattati

- `skills/planner/references/tier-feature.md` [new] — reference tier-feature per il modo `plan`
- `skills/planner/SKILL.md` [edit] — rimuovere il TODO relativo a `tier-feature.md` nel commento `[TODO: references/tier-{project,epic,feature,task}.md — task 002/003/004/005/006]`, aggiungerlo come link attivo nella lista modi

### Out of scope per questo task

- `references/tier-project.md`, `tier-epic.md`, `tier-task.md` — altri tier, task separati
- Modo `expand` per il tier feature — rimandato alla feature `finalize`
- Modo `finalize` per il tier feature — rimandato alla feature `finalize`
- Modifiche a `artifact-contract.md`, `elicitation.md`, `critical-review.md`, `task-expansion.md` — già consolidati in core-002
- Modifiche ai file della skill `feature-planner` esistente — sola lettura, sorgente di porting

---

## Analisi tecnica

### Sorgente da portare

Logica sorgente in `skills/feature-planner/`:
- `SKILL.md` § "Mode 1: plan" — flusso in 8 passi (verifica repo, slug, check esistenza, derivazione codebase, elicitation, critica, generazione 4 file, summary)
- `feature-artifacts.md` — template dei 4 artefatti, contratto downstream

Il porting NON copia la sorgente: la **adatta** al pattern SKILL.md-sottile della skill `planner`:
- Il router (`SKILL.md`) ha già selezionato il tier e ottenuto la conferma → `tier-feature.md` parte direttamente dall'esecuzione, non dalla scelta/conferma
- I reference condivisi (`elicitation.md`, `critical-review.md`, `task-expansion.md`, `artifact-contract.md`) sono già canonici sotto `planner/references/`: il tier li referenzia via link, NON copia la loro logica

### Struttura del `tier-feature.md`

Il file deve contenere:

**1. Derivazione dal codebase** (precede l'elicitation)
Portato da `feature-planner/SKILL.md` § "Derivazione dal codebase": i 4 passi di ispezione (CLAUDE.md, assistant/, sample codice, build/test command). Pre-compila `technical-context.md` e bozza `02-abstract.md`. Chiede solo i gap.

**2. Elicitation**
Delega a `references/elicitation.md` con profondità tier `feature`: blocchi obbligatori A (A1-A3) e B (scope); D come stack-check advisory. Porta la regola "contesto derivato dal codebase, non ri-elicitato da zero".

**3. Critica**
Delega a `references/critical-review.md` con applicabilità per tier `feature`.

**4. Generazione dei 4 artefatti**
Delega i template a `references/artifact-contract.md` § "Tier `feature`". Il tier-feature specifica:
- la directory di output: `docs/features/<slug>/`
- la regola slug: kebab-case dal nome feature, conferma se non ovvio
- la guardia anti-overwrite: se `docs/features/<slug>/` esiste → rifiuta, indirizza a `expand`/`revise`
- i 4 file: `00-context.md`, `02-abstract.md`, `technical-context.md`, `tasks-active.md`
- l'anchor obbligatorio su `00-context.md` e `technical-context.md`: `Tier: feature`, `Parent: <epic-slug|—>`, `Bubble-up target: <docs/epics/<epic>/technical-context.md|—>` — link a `../anchor-schema.md`
- risoluzione epic: se la feature è figlia di un epic (rilevabile da `docs/epics/*/roadmap.md`), popolare `Parent` e `Bubble-up target`; altrimenti `—`

**5. Estensione `technical-context.md` in append-only**
Se il plan introduce decisioni cumulative (nuovo VO, pattern, libreria), aggiungere al `technical-context.md` della feature. Regola già in SKILL.md del task-implementer ma valida anche per il planner: il tier-feature la porta esplicitamente.

**6. Summary**
Task creati, assunzioni più fragili, prossimo passo (`flow-run` o `task-implementer brief <slug>-NNN`).

### Modifica a `SKILL.md`

Nel blocco `### plan <scope>` rimuovere la riga:
```
[TODO: references/tier-{project,epic,feature,task}.md — task 002/003/004/005/006]
```
e sostituire con link puntuale per il tier feature materializzato:
```
Per tier `feature`: vedi `references/tier-feature.md`.
```
(Il TODO per i tier non ancora materializzati resta invariato; il TODO complessivo viene aggiornato per riflettere che `tier-feature.md` è ora attivo.)

### Vincoli di porting

- **Porting, non riscrittura**: il flusso di `feature-planner` ha prodotto piani validi; il tier-feature lo porta fedelmente, senza introdurre logica nuova.
- **Single-source**: nessuna duplicazione dei reference condivisi. Il tier li linka; non li inlina.
- **Anchor obbligatorio**: ogni `00-context.md` e `technical-context.md` generato da `tier-feature.md` porta l'anchor nel formato canonico di `../anchor-schema.md`.
- **`Parent`/`Bubble-up target`**: la risoluzione epic è per scan di `docs/epics/*/roadmap.md`; se 0 match → `—`; se >1 match → chiedere disambiguazione esplicita.
- **Campo `Complessità (ipotesi)`** nei task-entry: obbligatorio per ogni task generato in `tasks-active.md`; euristica in `references/task-expansion.md` § "Assegnazione `Complessità (ipotesi)`".

---

## Vincoli risolti

- **Stack**: Markdown (skill Claude Code); bash per glob/scan dove indicato nelle note operative del reference
- **Librerie + versioni**: nessuna
- **VO/pattern/interfacce consumati** (da NON modificare):
  - `skills/planner/anchor-schema.md` — formato anchor canonico
  - `skills/planner/planning-source-contract.md` — schema task-entry, path brief co-locato
  - `skills/planner/references/artifact-contract.md` § "Tier `feature`" — template 4 file
  - `skills/planner/references/elicitation.md` — blocchi domande, livello per tier
  - `skills/planner/references/critical-review.md` — pattern di rischio, applicabilità per tier
  - `skills/planner/references/task-expansion.md` — regole granularità, complessità, anti-pattern
  - `skills/feature-planner/SKILL.md` e `feature-artifacts.md` — sorgente in sola lettura
- **Naming convention**: `tier-feature.md` (kebab, prefisso `tier-`, nome tier); link via path relativo `../anchor-schema.md`, `../planning-source-contract.md` ecc. (pattern già in artifact-contract.md e planning-source-contract.md)

---

## Verifica (DoD)

- `skills/planner/references/tier-feature.md` esiste e implementa il flusso `plan` completo per il tier feature (derivazione codebase → elicitation → critica → generazione 4 file → summary)
- Il file delega ai reference condivisi tramite link, senza duplicare la loro logica
- Il flusso produce artefatti con anchor corretto (`Tier: feature`, `Parent`, `Bubble-up target`)
- `skills/planner/SKILL.md` linka `tier-feature.md` come reference attivo (TODO parzialmente risolto)
- Verifica manuale (dogfooding): lanciare `planner plan <una feature di test>`, selezionare tier `feature`, seguire il flusso guidato da `tier-feature.md` e verificare che i 4 artefatti vengano generati con anchor coerente in `docs/features/<slug>/`
- Nessun link orfano tra `tier-feature.md` e i reference condivisi

---

Generato: 2026-06-02 | Task: planner-unification-core-003 | Feature: planner-unification-core
