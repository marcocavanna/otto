# Abstract — Feature: Ritiro vecchie skill + migrazione + 2.0.0 (`planner-unification-release`)

<!-- Anchor --> **Tier**: feature · **Parent**: planner-unification · **Bubble-up target**: docs/epics/planner-unification/technical-context.md

## Approccio

Vedi `docs/epics/planner-unification/02-abstract.md`. Tre interventi sequenziali: rimozione netta delle 3 skill planner, estensione di `migrate` con il retrofit degli anchor sugli artefatti esistenti, release 2.0.0.

## Moduli impattati

- `skills/{project,feature,epic}-planner/` — rimossi
- `skills/migrate/` — esteso (retrofit anchor)
- `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` — 2.0.0
- `README.md` — riscrittura sezione planner + breaking notice

## Contratti da preservare

- `migrate`: idempotenza, reversibilità (backup), preview, post-verify — invarianti del comportamento esistente, estese al retrofit anchor.
- SemVer: la rimozione delle skill è breaking → major bump 2.0.0.

## Trade-off

Rimozione netta vs alias di retrocompatibilità: si sceglie la rimozione netta. I trigger sono già assorbiti dalla `description` di `planner`, gli alias aggiungerebbero superficie morta da mantenere senza valore. Costo: chi invocava i nomi vecchi deve adattarsi (mitigato dalla breaking notice).

## Rischi tecnici

- Auto-modifica massima: si rimuovono strumenti di pianificazione durante la pianificazione (RISK-...-001).
- Retrofit distruttivo su artefatti vivi (RISK-...-002).

## Esclusioni tecniche

- Logica del planner unificato (anchor schema, 4 tier, bubble-up via finalize) già implementata nelle feature a monte dell'epic.

---
Generato 2026-06-02 v1
