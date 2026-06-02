# Abstract tecnico — Feature: Contratto v2 + anchor model (`planner-unification-contract`)

<!-- Anchor --> **Tier**: feature · **Parent**: planner-unification · **Bubble-up target**: docs/epics/planner-unification/technical-context.md

## Approccio

Riusa le decisioni condivise dell'epic: vedi `docs/epics/planner-unification/02-abstract.md`. Questa feature produce SOLO documenti-contratto (schema anchor, contratto v2, spec tier task), nessuna logica di skill. Nessun codice eseguibile, nessun comportamento runtime: deliverable interamente in markdown sotto `skills/planner/` e nelle spec di questa feature.

## Moduli impattati

- `skills/planner/` [nuovo]: destinazione del Planning source contract v2 relocato.
- `skills/feature-planner/feature-artifacts.md`: location attuale del contratto, da considerare origine; non viene rimossa né modificata in questa feature.
- `docs/tasks/<slug>/`: home documentata del tier task (spec, non materializzazione).

## Contratti da preservare

- Risoluzione context-root via scan per directory (ID opachi, lookup per scansione e non per path hardcoded).
- Esclusione di `docs/archive/**` dalla risoluzione.
- Brief co-locato sotto la context-root (`<context-root>/tasks/<id>.md`).
- ID opachi e unici, non parlanti.

## Trade-off

- Definire prima il contratto e ripuntare i downstream dopo introduce una finestra di incoerenza, ma isola il tronco comune e mantiene le feature piccole e sequenziabili (preferito a un big-bang skill+contratto).

## Rischi tecnici

- Drift tra contratto v2 e semantica realmente implementata nella feature core se la spec non è abbastanza precisa → mitigato dalla densità della spec e dagli esempi per tier.

## Esclusioni tecniche

- Nessuna implementazione della skill `planner`.
- Nessuna modifica ai consumer downstream (ripuntamento delegato alle feature successive).

---
Generato: 2026-06-02 | Versione: 1
