# Task attivi — Feature: expand + finalize (`planner-unification-finalize`)

**Feature**: planner-unification-finalize
**Effort totale stimato**: 6-10 ore
**Definition of done feature**: `planner` supporta `expand` e `finalize`; `finalize` esegue bubble-up single-hop selettivo e idempotente seguendo l'anchor; documentata la catena task→feature→epic→project.

## Task

### planner-unification-finalize-001 — 💻 [impl] Modo expand unificato
- Effort: 1-2h
- Definition of done: risoluzione slug per tutti i tier; conflitto (più candidati) → CHIEDE; rigenera `tasks-active` preservando gli ID stabili; backup `.bak` prima di sovrascrivere.
- Dipende da: planner-unification-core-007
- Status: ✅ done

### planner-unification-finalize-002 — 💻 [impl] Modo finalize: gate + risoluzione anchor del padre
- Effort: 1-2h
- Definition of done: gate attended (`verify == pass`, nessuna escalation aperta); legge `Bubble-up target` dall'anchor; source standalone (`Parent —`) → no-op di risalita.
- Dipende da: planner-unification-finalize-001
- Status: ✅ done

### planner-unification-finalize-003 — 💻 [impl] Bubble-up single-hop selettivo
- Effort: 2-3h
- Definition of done: valuta il sottoinsieme coerente da risalire al padre; append-only datato (`## Consolidato da <slug> (YYYY-MM-DD)`); guardia di idempotenza; UN solo hop; documenta che supersede il bubble-up 1.1.0.
- Dipende da: planner-unification-finalize-002
- Status: ✅ done

### planner-unification-finalize-004 — 🧪 [test] Casi limite del finalize
- Effort: 1-2h
- Definition of done: dogfooding manuale su standalone, conflitto, re-run idempotente, catena task→feature→epic.
- Dipende da: planner-unification-finalize-003
- Status: ✅ done

### planner-unification-finalize-005 — 📚 [docs] Documentare la catena finalize multi-livello
- Effort: 1h
- Definition of done: esempi della catena single-hop task→feature→epic→project + promozione manuale via `revise`.
- Dipende da: planner-unification-finalize-003
- Status: ✅ done

## Note operative

- Il bubble-up è di proprietà di `finalize` (single-hop selettivo); supersede la copia integrale lato flow-run di otto 1.1.0.
- Append-only datato + guardia di idempotenza: mai cancellare contenuto del padre, skip se il blocco datato per lo slug esiste già.
- `expand` deve preservare gli ID stabili e fare backup `.bak` prima di sovrascrivere `tasks-active`.

## Out of scope per questa feature

- flow-run invoca `finalize` → downstream (feature successiva dell'epic).
- Retrofit dell'anchor sulle source esistenti → release.

---
Generato: 2026-06-02 | Versione: 1 | Feature: planner-unification-finalize
