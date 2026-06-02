# Abstract tecnico — Feature: expand + finalize con bubble-up single-hop (`planner-unification-finalize`)

<!-- Anchor --> **Tier**: feature · **Parent**: planner-unification · **Bubble-up target**: docs/epics/planner-unification/technical-context.md

## Approccio

Riusa le decisioni condivise dell'epic: vedi `docs/epics/planner-unification/02-abstract.md`. `expand` unifica la rigenerazione dei task per tutti i tier; `finalize` legge il campo `Bubble-up target` dall'anchor della source corrente e, se presente, esegue un singolo hop di risalita verso il padre diretto. Nessun build, deliverable interamente in markdown sotto `skills/planner/`.

## Moduli impattati

- `skills/planner/` [estende]: aggiunta dei modi `expand` e `finalize`.
- `skills/task-implementer/`, `skills/feature-planner/`: origine della logica di finalize oggi sparsa, consolidata in `planner`.
- flow-run: NON toccato qui (il ripuntamento dell'invocazione è downstream).

## Contratti da preservare

- Pattern append-only datato + guardia di idempotenza già usato in 1.1.0 (heading `## Consolidato da <slug> (YYYY-MM-DD)`, skip se già presente).
- Gate attended: `finalize` procede solo con `verify == pass` e nessuna escalation aperta.
- Anchor schema e Planning source contract v2 come single source (consumati, non ridefiniti).

## Trade-off

- Single-hop vs cascading multi-livello: il single-hop mantiene il bubble-up deterministico e revisionabile, evitando propagazioni a catena non controllate; la promozione oltre il padre resta manuale via `revise` (preferito a un cascading automatico opaco).

## Rischi tecnici

- Coesistenza temporanea col bubble-up grezzo 1.1.0 finché flow-run non è ripuntato → finestra chiusa dalla feature downstream dell'epic.
- Drift se l'anchor `Bubble-up target` punta a un target stantio → mitigato dalla risoluzione dell'anchor del padre a runtime in `finalize`.

## Esclusioni tecniche

- Nessuna modifica a flow-run (invocazione di `finalize` → downstream).
- Nessun cascading bubble-up multi-livello.

---
Generato: 2026-06-02 | Versione: 1
