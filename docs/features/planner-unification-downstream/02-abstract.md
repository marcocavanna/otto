# Abstract tecnico — Feature: Re-anchoring downstream + scan tier task (`planner-unification-downstream`)

<!-- Anchor --> **Tier**: feature · **Parent**: planner-unification · **Bubble-up target**: docs/epics/planner-unification/technical-context.md

## Approccio

Vedi `docs/epics/planner-unification/02-abstract.md` per la strategia complessiva. Qui: **nessun cambio di sostanza** ai downstream. Si interviene esclusivamente su path dei link, superficie di scan e punto di invocazione del bubble-up. La logica di risoluzione, il modello di stato e i contratti dati restano invariati.

## Moduli impattati

- `skills/task-implementer/` — la risoluzione context-root estesa a `docs/tasks/<slug>/`; brief co-locati sotto `docs/tasks/<slug>/tasks/`.
- `skills/code-implementer/` — stessa estensione di scan; risolve ID di task-tier.
- `skills/whats-next/` — il board include le source tier-task; rollup padre-figlio guidato dagli anchor.
- `skills/flow-sync/` — riconosce le source tier-task; riconciliazione coerente con gli anchor.
- `skills/flow-run/` — a fine source chiama `planner finalize <slug>`; rimosso l'append grezzo 1.1.0.
- `agents/pm.md` — reference ripuntati a `skills/planner/`.

## Contratti da preservare

- semantica di risoluzione context-root **invariata** (scan per directory di ID opachi);
- schema `.flow/` (PROGRESS.json, index.json, sources) **invariato**;
- mirror non-canonici nei tasks-file: comportamento di scrittura invariato.

## Trade-off

- ripuntamento manuale dei link (grep) vs. astrazione di un registry: si sceglie il grep — il costo una-tantum è basso e l'astrazione sarebbe over-engineering per un plugin markdown.

## Rischi tecnici

- auto-modifica di flow-run durante l'esecuzione (vedi RISK-downstream-001);
- link orfano residuo che rompe la risoluzione del contratto (RISK-downstream-002);
- scan esteso che intercetta directory non-task sotto `docs/tasks/` → vincolare alla presenza dell'anchor.

## Esclusioni tecniche

- niente rimozione delle vecchie skill;
- niente retrofit di `migrate` per il nuovo layout;
- niente bump 2.0.0 → release.

---
Generato 2026-06-02 · v1 · Feature: planner-unification-downstream
