# Technical context — Feature: expand + finalize con bubble-up single-hop (`planner-unification-finalize`)

> Seed da docs/epics/planner-unification/technical-context.md

<!-- Anchor --> **Tier**: feature · **Parent**: planner-unification · **Bubble-up target**: docs/epics/planner-unification/technical-context.md
**Epic**: planner-unification
**Dipende da feature**: planner-unification-core

## Convenzioni di progetto

### Build & test

- build_command: `—`
- Verifica: dogfooding manuale (skill markdown+bash, nessun build/compilazione; "test" = esecuzione/uso manuale dei modi `expand` e `finalize`).

## Pattern architetturali

- Append-only datato idempotente: il bubble-up aggiunge al padre un blocco `## Consolidato da <slug> (YYYY-MM-DD)`; guardia di idempotenza per evitare duplicazioni su re-run.
- Single-source: `expand` e `finalize` vivono in `skills/planner/`, consolidando la logica oggi sparsa tra task-implementer/feature-planner; nessuna duplicazione.

## Value Objects / contratti

Consuma (definiti dalle feature contract/core):

- **Anchor schema**: campi `Tier`, `Parent`, `Bubble-up target`; anchor assente o `Parent —` ⇒ source standalone, nessuna risalita.
- **Planning source contract v2**: risoluzione context-root per i 4 tier, esclusione `docs/archive/**`, ID opachi.

Definisce QUI (deliverable di questa feature):

- **Procedura finalize/bubble-up**: gate attended (verify==pass, nessuna escalation) → lettura `Bubble-up target` dall'anchor → risoluzione anchor del padre → selezione del sottoinsieme coerente da risalire → append-only datato idempotente, UN solo hop. Supersede il bubble-up grezzo (copia integrale) di otto 1.1.0.

## Decisioni introdotte da planner-unification-finalize-001 (expand)

- **Reference `skills/planner/references/expand.md`**: logica operativa completa del modo `expand`; SKILL.md lo referenzia con un link singolo (pattern SKILL.md sottile + reference lazy).
- **Elicitation delta leggera**: in `expand` una sola domanda ("lo scope è cambiato?") è sufficiente; nessuna re-elicitation completa.
- **Conflitto risoluzione slug → chiede, non fallisce**: in caso di >1 candidato l'utente sceglie esplicitamente; il sistema non procede autonomamente.
- **Backup tasks-file**: un solo `.bak` per tasks-file (sovrascrive il precedente); path: `<tasks-file>.bak`.
- **ID stabili**: match per ID esatto; titolo modificabile; ID rimossi mai riassegnati; nuovi ID progressivi da `max(esistenti)+1`.

## Decisioni introdotte da planner-unification-finalize-002 (finalize: gate + anchor)

- **Reference `skills/planner/references/finalize.md`**: logica operativa completa del modo `finalize`; SKILL.md lo referenzia con un link singolo (pattern SKILL.md sottile + reference lazy).
- **Gate attended come prima operazione**: RESULT.json (verify==pass) + assenza ESCALATION.json verificati prima di qualunque modifica. Fail early, fail loud.
- **Separazione gate+anchor (002) da bubble-up effettivo (003)**: 002 risolve il `Bubble-up target` e finalizza localmente; 003 esegue la risalita. Boundary netto tra infrastruttura e contenuto.
- **No-op esplicito per source standalone**: `Bubble-up target: —` o anchor assente → finalizzazione locale senza errori; no-op segnalato nel summary (non silenzioso).
- **Parsing anchor deterministico**: `grep '<!-- Anchor -->'` + estrazione campo `Bubble-up target`; compatibile bash 5, robusto al separatore `·` (U+00B7).
- **tasks-active.md non toccato da finalize**: responsabilità dell'utente o di project-planner; coerente con task-implementer.

## Decisioni introdotte da planner-unification-finalize-003 (bubble-up single-hop selettivo)

- **Step 9 additivo a `finalize.md`**: il bubble-up è implementato come Step 9, non modifica gli Step 1-8 esistenti; boundary netto tra infrastruttura (002) e contenuto (003).
- **Guardia idempotenza via heading senza data**: `grep "## Consolidato da <slug>"` senza la data — identifica la risalita già eseguita indipendentemente dalla data; la data nel heading è solo documentativa.
- **Selezione guidata dall'utente, non automatica**: il sistema propone il candidato completo; la decisione finale è dell'utente. Evita propagazioni opache (RISK-planner-unification-finalize-002).
- **Copia fedele, non riassunto**: le sezioni selezionate sono copiate integralmente nel target; nessuna sintesi o riscrittura.
- **Un solo hop deterministico**: bubble-up al padre diretto via `Bubble-up target`; nessun cascading automatico; promozione oltre il padre = manuale via `revise`.
- **Nota "supersede 1.1.0" nel reference**: documentata in `finalize.md` come nota architetturale (non in SKILL.md); il router resta sottile.

---
Generato: 2026-06-02 | Versione: 1
