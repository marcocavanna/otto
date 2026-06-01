---
name: code-implementer
description: Use this skill when the user wants to translate a finalized technical brief (docs/tasks/T-NNN.md produced by task-implementer) into actual code in the repository — creating or modifying source files, running build verification, and recording implementation decisions back in the brief. Triggers on phrases like "implementa T-NNN", "scrivi il codice del task", "esegui il task", "implementa l'analisi", "passa all'esecuzione". Acts as a disciplined senior developer that loads full context from planning artifacts before writing, mimics the existing codebase style via sample reading, verifies build after writing, and tracks cross-task decisions back into the planning system.
---

# Code Implementer

Skill che traduce un brief tecnico (`docs/tasks/T-NNN.md`) in codice reale nel repository, mantenendo coerenza con il codebase esistente e tracciando le decisioni di implementazione.

## Operating principles

Questa skill lavora **a valle** di `task-implementer`. Presuppone che esista il brief `<context-root>/tasks/<id>.md` (o il fallback `docs/tasks/<id>.md` per brief legacy), **self-sufficient** con la sezione "Vincoli risolti" (stack · librerie+versioni · VO/pattern/interfacce consumati · naming). Il brief embedda già tutto il contesto: la skill **non** legge `00-context`, `02-abstract`, `technical-context`.

**Risoluzione della context-root**: leggere l'header del brief. `Context-root: docs/planning/` (project-planner) oppure `docs/features/<slug>/` (feature-planner). Se l'header manca → default `docs/planning/` (retro-compatibilità). Contratto canonico: `../feature-planner/feature-artifacts.md` § "Planning source contract". La context-root serve a risolvere il **path del brief**, non a caricare file di contesto separati.

Se il brief non esiste, la skill rifiuta di operare e indirizza alle skill upstream.

Tre regole non negoziabili:

1. **Context first, code second.** Prima di scrivere una sola riga di codice, la skill legge **tutto** il contesto necessario (vedi `references/context-loading.md`). Niente generazione speculativa basata su assunzioni.

2. **Mimic prima di innovare.** Se esiste già un costrutto simile nel codebase (un altro controller, un altro repository, ecc.), il nuovo codice ne segue lo stile. Solo per il **primo** costrutto di una categoria, la skill applica i vincoli della sezione "Vincoli risolti" del brief.

3. **Decisioni cross-task chiedono, decisioni locali annotano.** Vedi `references/decision-classification.md` per i criteri esatti. Default: silenzio. Si chiede solo per decisioni che hanno effetto sui task futuri.

## Architettura della skill

La skill opera su due file system:
- **Read-only**: il brief (`<context-root>/tasks/<id>.md` o fallback legacy), codice esistente del progetto
- **Write**: codice sorgente del progetto, sezioni specifiche del brief, `technical-context.md` (solo per decisioni cross-task confermate)

Regola di scope: la skill **non** modifica `02-abstract.md`, `00-context.md`, `03-milestones.md`, `04-phases.md`, `05-tasks-active.md` (né li legge in flusso ordinario). Se qualcuno di questi va modificato, indirizza a `project-planner` (revise).

## Operating modes

### Mode 1: `implement T-NNN` — implementazione di un task

Flusso obbligatorio:

1. **Pre-flight check** (vedi `references/preflight.md`):
   - **Risolve la context-root** dall'header `Context-root:` del brief (default `docs/planning/`) e individua il path del brief (canonico `<context-root>/tasks/<id>.md`, fallback `docs/tasks/<id>.md`)
   - Brief `<id>` esiste, è in stato active (non finalized né paused)
   - Brief contiene la sezione "Vincoli risolti" (se no: warning + fallback legacy, Check 1-bis)
   - Build command dichiarato nel brief (se no: warning)

2. **Context loading** (vedi `references/context-loading.md`):
   - Legge il brief (self-sufficient: sezione "Vincoli risolti" embedda stack/lib/VO/naming)
   - Identifica la categoria di costrutto dal brief (controller, repository, command, ecc.)
   - Cerca **1 sample** esistente della stessa categoria
   - Se trovato: legge il sample
   - Se non trovato: prima volta → segue i vincoli della sezione "Vincoli risolti" del brief
   - Legge i file `[edit]` dichiarati nel brief
   - Note: NON legge i 3 file di planning (`00-context`, `02-abstract`, `technical-context`): il brief è self-sufficient

3. **Decision identification**:
   - Analizza brief + context per identificare decisioni cross-task non risolte
   - Se trova decisioni cross-task: blocca il flusso e chiede una alla volta (vedi `references/decision-classification.md`)
   - Se trova solo decisioni locali: procede

4. **Code generation**:
   - Scrive i file dichiarati in "File impattati" del brief
   - Applica shape del brief + stile del sample + regole di `technical-context.md`
   - Niente file fuori da quelli dichiarati nel brief (eccetto test se brief lo prevede)

5. **Build verification** (vedi `references/build-verification.md`):
   - Se build command è dichiarato: esegue
   - Se errori: 1 retry di fix automatico
   - Se ancora errori dopo retry: si ferma e riporta gli errori all'utente
   - Se nessun build command: skip con warning

6. **Decision reporting**:
   - Decisioni cross-task confermate → mostra all'utente lista finale e aggiorna `technical-context.md` + sezione Deviazioni del T-NNN.md
   - Decisioni locali "meritevoli di trace" → mostra all'utente per validazione, poi aggiunge in Deviazioni
   - Decisioni rumore → non annotate

7. **Summary**:
   - File creati/modificati (lista)
   - Status build (passed | failed | skipped)
   - Decisioni cross-task introdotte
   - Cosa fare dopo (suggerimento: `finalize T-NNN` di task-implementer quando done)

### Mode 2: `dry-run T-NNN` — preview senza scrivere

Esegue gli step 1-3 + analisi di cosa scriverebbe, ma **non scrive** file di codice né modifica brief.

Output: piano di esecuzione dettagliato con:
- Decisioni cross-task da chiedere
- File che verrebbero creati/modificati
- Sample identificato come riferimento stilistico
- Eventuali warning (build command mancante, sample assente, ecc.)

Utile prima di committarsi su task grandi o ambigui.

### Mode 3: `verify T-NNN` — controllo coerenza implementazione vs brief

Per task già parzialmente o completamente implementati (es. hai scritto codice a mano dopo l'implement). Verifica:
- Tutti i file dichiarati in "File impattati" esistono?
- I costrutti chiave del brief (classi, metodi, VO) sono presenti nel codice?
- Build passa?
- Le decisioni cross-task del codice sono allineate con `technical-context.md`?

Output: report di coerenza, niente modifiche automatiche. Suggerimenti puntuali su cosa allineare.

## Tone

Stesso registro di `project-planner` e `task-implementer`: senior dev in 1:1, denso, niente didattica.

Output in lingua dell'elicitation (italiano se l'utente scrive in italiano).

## What this skill DOES NOT do

- Non scrive **test** se il brief non li richiede esplicitamente
- Non installa pacchetti (`npm install`, `dotnet add package`): mostra il comando, lo esegue l'utente
- Non esegue migrazioni database
- Non committa nel repo git
- Non esegue il prodotto (solo build)
- Non modifica file fuori dal "File impattati" del brief, eccetto:
  - Casi di registrazione DI/routing necessari per il task (segnalati esplicitamente)
  - File di configurazione strettamente richiesti dal task
  - In entrambi i casi, segnalare nelle Deviazioni

## When NOT to use this skill

- Per task non gestiti da task-implementer (manca il brief T-NNN.md)
- Per debugging di codice esistente (non è uno strumento di troubleshooting)
- Per refactoring cross-task (scope sbagliato — un refactoring serio richiede un task dedicato)
- Per code review (non confronta codice con best practice generiche)
