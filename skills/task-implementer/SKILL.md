---
name: task-implementer
description: Use this skill when the user wants to translate a planned task (from project-planner's docs/planning/05-tasks-active.md) into a technical implementation brief — covering stack, libraries with versions, code patterns, operational assumptions, and shape-level code snippets. Triggers on phrases like "analizza il task T-NNN", "fammi il brief tecnico", "come implemento questo task", "passa all'analisi tecnica", "preparami il piano di implementazione". Also triggers when the user wants to finalize a completed task (update technical-context.md with reality), archive briefs at milestone end, or check coherence of accumulated technical decisions. Acts as a senior tech lead that produces actionable per-task analysis while maintaining a coherent shared technical context across the project.
---

# Task Implementer

Skill che traduce ogni task atomico pianificato in un brief di analisi tecnica e funzionale, mantenendo coerenza globale tramite `docs/planning/technical-context.md`.

## Operating principles

Il progetto su cui si sta lavorando deve essere esplicitato in maniera diretta dall'utente.

Questa skill lavora **a valle** di `planner`. Presuppone che esistano già:
- `docs/<project-name>/02-abstract.md` (strategia tecnica)
- `docs/<project-name>/05-tasks-active.md` (task atomici della milestone attiva)
- `docs/<project-name>/00-context.md` (assunzioni e rischi)

Se questi file non esistono, la skill rifiuta di operare e indirizza l'utente a `planner`.

Tre regole non negoziabili:

1. **Coerenza > completezza.** Ogni brief deve essere coerente con `technical-context.md` esistente. Se l'analisi del task introduce una decisione che contraddice il contesto tecnico accumulato, la skill **non** procede silenziosamente: solleva il conflitto e chiede se aggiornare il contesto o adattare il task.

2. **Solo contratti e innesti, MAI corpi.** Gli stralci nei brief sono **shape**: firme, tipi, contratti, punti d'innesto — **mai corpi di metodo né logica completa**. Il corpo è competenza esclusiva del DEV (`code-implementer`): scriverlo nel brief è spreco triplo (output del PM + input del DEV che lo rilegge + il DEV lo riscrive comunque, divergendo). Limite duro: ~10-15 righe per costrutto, **solo segnatura/struttura**. Se uno stralcio contiene un corpo non banale, è già implementazione: va rimosso. L'obiettivo è dare struttura e direzione, non scrivere il codice al posto del DEV.

3. **Subtask sono eccezioni, non regola.** Default: nessun subtask. Generare subtask solo se rispettano i criteri operativi (vedi `references/subtask-criteria.md`). Se non rispettano, output esplicito: "Subtask: nessuno necessario, esecuzione lineare."

## Architettura della skill

```
<context-root>/             # docs/planning/ (project) | docs/features/<slug>/ (feature)
  02-abstract.md            # strategico — vincolo per technical-context.md
  technical-context.md      # tattico — gestito da QUESTA skill
  tasks/                    # CANONICO — brief co-locati, gestiti da QUESTA skill
    <id>.md                 # T-NNN (project) | <slug>-NNN (feature)
    archive/                # (solo project) brief delle milestone concluse — vedi Mode 4
      M1/
        T-001.md
    ...
```
> I brief sono **sempre** co-locati sotto la loro context-root. Il vecchio layout flat `docs/tasks/`
> non è più né scritto né letto: i progetti pre-canonical vanno portati al layout co-locato con la
> skill `migrate` prima di operare.

Regola di non-contraddizione: `technical-context.md` **non può** contenere decisioni che contraddicono `02-abstract.md`. Se durante l'analisi di un task emerge che una scelta strategica dell'abstract è sbagliata, la skill **ferma** il flusso e dice all'utente di usare `planner revise` su `02-abstract.md` prima di proseguire.

## Operating modes

### Mode 1: `brief T-NNN` — generare brief tecnico per un task

> Reference lazy: leggi ogni reference solo allo step che la usa.
> `technical-context.md`: solo se esiste e non è vuoto (già condizionale allo step 2).
> `complexity-criteria.md`: solo se produzione `meta.json` (funzione brief), mai nel finalize.

Flusso:
1. **Risolvere la context-root** del task. L'ID task è trattato in modo opaco (`T-NNN` per project, `<slug>-NNN` per feature). Vedi il contratto canonico in `../planner/planning-source-contract.md` § "Planning source contract":
   - scan dei tasks-file di **tutti i tier** — `docs/planning/05-tasks-active.md`, `docs/features/*/tasks-active.md`, `docs/tasks/*/tasks-active.md` (tier `task`) — escluso `docs/archive/**`; la tabella completa dei 4 tier è nel contratto. Solo le directory che contengono un `tasks-active.md` sono source (una dir sotto `docs/tasks/` senza tasks-file non viene intercettata). Il file che contiene l'ID definisce la source e la **context-root** (la sua directory) + il tasks-file;
   - 0 match → errore "task sconosciuto"; >1 match → errore "ID ambiguo";
   - override esplicito: se l'utente/orchestratore passa `feature <slug>`, usare quella source senza scan.
   (Retro-compatibile: progetto classico → context-root `docs/planning/`, tasks-file `05-tasks-active.md`.)
2. Leggere TUTTI questi file dalla **context-root** risolta (in un **unico batch di Read paralleli** — non hanno dipendenze di lettura tra loro; l'ordine sotto è solo logico):
   - `00-context.md` (assunzioni, vincoli)
   - `02-abstract.md` (decisioni strategiche, **vincolanti**)
   - `technical-context.md` se esiste (decisioni tattiche già prese)
   - il tasks-file (il task + i task vicini per dipendenze)
   - **Se la feature appartiene a un epic** (il suo `00-context.md` ha `**Epic**: <epic>`, o
     `docs/epics/<epic>/roadmap.md` la referenzia in `Source:`): leggi **anche**
     `docs/epics/<epic>/technical-context.md` (il seed condiviso + i blocchi `## Consolidato da <feat>`
     risaliti dalle feature già concluse). Sono decisioni **vincolanti** ereditate: il brief non può
     contraddirle. Read-only; non lo modifichi mai da qui (il bubble-up è di `planner finalize`).
3. Run elicitation per task (vedi `references/brief-elicitation.md`).
4. Validare coerenza: il brief proposto contraddice qualcosa in `technical-context.md`? Se sì, sollevare e risolvere PRIMA di scrivere.
5. Generare il brief nel path **canonico** co-locato `<context-root>/tasks/<id>.md` (vedi `../planner/planning-source-contract.md` § "Planning source contract" e `references/brief-template.md`).
   - Creare la cartella `tasks/` sotto la context-root se non esiste (scrivendo il file la si crea implicitamente).
   - **Scrivere nell'header** `Origin:` e `Context-root:` (e `Feature:` al posto di `Milestone:` per task feature). Gli ID feature non hanno milestone: non inventarla.
   - Il brief **deve** includere la sezione obbligatoria `## Vincoli risolti` (vedi `references/brief-template.md` § "Vincoli risolti"): rende il brief self-sufficient per il DEV.
6. Se il brief introduce nuove decisioni cumulative (VO nuovo, pattern nuovo, libreria nuova), aggiornare il `technical-context.md` **della context-root risolta** in append-only.
7. Print summary: cosa è stato deciso, quali voci di `technical-context.md` sono state aggiunte.

> **Modalità attended** (solo se invocata dall'orchestratore `flow-run`): dopo lo step 5, materializzare anche `scope.txt` e `frozen.txt` machine-readable. Vedi `references/attended-flow.md`. Additivo: non cambia la generazione del brief.
>
> La copia `.flow/briefs/<id>/brief.md` è una **copia** del brief co-locato in `<context-root>/tasks/<id>.md` (non una fonte separata): il DEV attended la legge, ma la fonte di verità resta il brief co-locato.

### Mode 2: `deviation T-NNN` — annotare deviazione durante implementazione

Flusso leggero:
1. Risolvere la context-root del task (scan, come Mode 1) e verificare che il brief co-locato `<context-root>/tasks/<id>.md` esista e non sia archiviato.
2. Chiedere all'utente: cosa è cambiato rispetto al brief originale?
3. Aggiungere entry nella sezione `## Deviazioni durante l'implementazione` del brief (creandola se non esiste).
4. **Non** modificare `technical-context.md` qui — quello avviene al `finalize`.

### Mode 3: `finalize T-NNN` — chiusura task

> **Modalità attended** (solo se invocata da `flow-run`): prima dello step 1, applicare il gate di `references/attended-flow.md` — finalize consentito solo se `RESULT.verify=="pass"` e nessun `ESCALATION.json` aperto.

Flusso obbligatorio a fine task:
1. Risolvere la context-root (scan, come Mode 1) e verificare che il brief co-locato `<context-root>/tasks/<id>.md` esista.
2. Mostrare all'utente:
   - Decisioni del brief originale
   - Deviazioni registrate (se presenti)
3. **Domanda obbligatoria**: "Qualcosa in `technical-context.md` è cambiato per effetto di questo task? (es. libreria diversa da quella prevista, pattern modificato, naming convention introdotta)"
4. Se sì → guidare l'aggiornamento puntuale di `technical-context.md`.
5. Marcare il task come finalized nel brief (header con `Status: ✅ finalized`).
6. Lo status nel tasks-file (`05-tasks-active.md`) **non viene toccato da questa skill** — è responsabilità dell'utente o di `planner`.

### Mode 4: `archive-milestone M[N]` — archiviazione

Flusso:
1. Verificare che la milestone M[N] sia marcata done in `03-milestones.md`. Se no, chiedere conferma esplicita.
2. Verificare che tutti i task di M[N] in `05-tasks-active.md` siano marcati done. Se no, elencare quelli aperti e chiedere conferma.
3. Spostare i brief di M[N] (`git mv`) da `docs/planning/tasks/` a `docs/planning/tasks/archive/M[N]/` — restano co-locati sotto la context-root del progetto. (Le **feature** invece si archiviano a directory intera in `docs/archive/features/<slug>/`: lo fa `flow-run`, non questa modalità, che è solo per le milestone di project tier.)
4. `technical-context.md` **non viene archiviato né modificato**.
5. Print summary: quanti brief archiviati, quali decisioni sono ora "storiche" ma vincolanti.

### Mode 5: `check-coherence` — diagnostica

Flusso (utility, non modifica file):
1. Leggere tutti i brief co-locati sotto le context-root in scope (`<context-root>/tasks/*.md`, esclusi quelli sotto `archive/`).
2. Verificare:
   - Ogni brief referenzia versioni di librerie coerenti con `technical-context.md`?
   - Ogni VO citato nei brief è definito in `technical-context.md`?
   - Ci sono contraddizioni tra brief?
3. Output: report di coerenza, niente modifiche automatiche.

## Tone

Senior tech lead in 1:1 con uno sviluppatore competente. Niente didattica. Niente "ottima scelta". Direttivo, denso, professionale.

Output in lingua dell'elicitation (italiano se l'utente scrive in italiano).

## When NOT to use this skill

- Per task senza piano di `planner` (la skill richiede la struttura `docs/planning/` o `docs/features/<slug>/`).
- Per task review post-implementazione (non è uno strumento di code review).
- Per generare codice completo di un task (questo è scope di un'altra skill / esecuzione diretta).
- Per task >4h di effort: probabilmente il task va spezzato con `planner` prima di analizzarlo qui.
