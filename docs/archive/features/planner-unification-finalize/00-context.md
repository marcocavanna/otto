# Context — Feature: expand + finalize con bubble-up single-hop (`planner-unification-finalize`)

**Progetto**: otto
**Tipo**: feature su progetto esistente

<!-- Anchor --> **Tier**: feature · **Parent**: planner-unification · **Bubble-up target**: docs/epics/planner-unification/technical-context.md
**Epic**: planner-unification
**Dipende da feature**: planner-unification-core

## Cosa fa la feature

Aggiunge alla skill `planner` il modo `expand` unificato (risoluzione slug per tutti i tier, rigenerazione dei task) e il modo `finalize`, che POSSIEDE il bubble-up single-hop SELETTIVO: legge l'anchor `Bubble-up target`, valuta il sottoinsieme coerente che risale al padre diretto, esegue UN solo salto con append datato idempotente. Supersede il bubble-up grezzo feature→epic introdotto in otto 1.1.0 (copia integrale fatta da flow-run). Per contesto e obiettivi dell'epic vedi `docs/epics/planner-unification/{00-context,02-abstract,technical-context}.md`.

## Derivato dal codebase

- Moduli: `skills/planner/` [estende — aggiunge i modi `expand` e `finalize`]; la logica di finalize oggi è sparsa tra `skills/task-implementer/` e `skills/feature-planner/` (più il bubble-up grezzo in flow-run).
- Stack: markdown (skill Claude Code; prosa + bash, nessun build/compilazione).
- Build: —

## Boundary e scope

- In scope: modo `expand` unificato; modo `finalize`; bubble-up single-hop selettivo guidato dall'anchor.
- Out of scope: invocazione di `finalize` da flow-run [→ downstream]; cascading bubble-up multi-livello (promozione oltre il padre diretto resta manuale).
- Integrazione: `finalize` consuma l'Anchor schema e il contratto v2 prodotti dalle feature contract/core; l'invocazione da flow-run è demandata a una feature downstream dell'epic.

## Tracked assumptions

- ASSUMPTION-planner-unification-finalize-001: il bubble-up è di proprietà di `finalize` (single-hop selettivo), non più copia integrale lato flow-run.
- ASSUMPTION-planner-unification-finalize-002: la promozione di conoscenza oltre il padre diretto è manuale via `revise`, non automatica per cascading.

## Known risks

- RISK-planner-unification-finalize-001 🟡: doppio comportamento di bubble-up durante la transizione, finché flow-run non è aggiornato in downstream → mitigazione: la feature F4 dell'epic chiude la finestra ripuntando flow-run.
- RISK-planner-unification-finalize-002 🟡: la valutazione di "cosa risale" è un judgment soggettivo → mitigazione: append-only datato, nessuna cancellazione del contenuto del padre.

---
Generato: 2026-06-02 | Versione: 1
