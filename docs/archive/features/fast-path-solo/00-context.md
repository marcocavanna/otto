# Context — Feature: Modalità `solo` (`fast-path-solo`)

**Progetto**: otto (plugin Claude Code per planning → brief → code)
**Epic**: fast-path
**Dipende da feature**: —

<!-- Anchor -->
**Tier**: feature
**Parent**: fast-path
**Bubble-up target**: docs/epics/fast-path/technical-context.md

## Cosa realizza la feature
Introduce la modalità di esecuzione **`solo`**: `flow-run` legge la `Complessità (ipotesi)` dal tasks-file **prima** di qualunque spawn, e per i task `trivial`/`standard` spawna **un solo agente** (`solo`) che fa pre-analisi + implementazione + verifica + produzione degli **stessi artefatti versionati** di oggi, invece dei 2 spawn PM+DEV. I `critical` (e i casi di complessità assente/ambigua) restano sul flusso `team` invariato. Contributo alla DoD epic: il tronco comune (mappa `execution-mode`, lettura complessità a monte, agente `solo`, ramo `solo` nell'orchestratore) su cui `fast-path-promotion` aggiungerà la rete pre-write.

## Derivato dal codebase
- **Aree/moduli toccati**: `skills/flow-run/references/model-tiering.md` (nuova colonna `execution-mode`), `skills/flow-run/SKILL.md` (lettura complessità a monte + selezione modalità + ramo `solo` nel protocollo per-task + spawn dell'agente solo), `agents/solo.md` (nuovo), `skills/task-implementer/SKILL.md` (contratto: artefatti prodotti durante/dopo l'implementazione in modalità solo), `skills/code-implementer/` (riferito dall'agente solo per l'implementazione/verifica). Possibile rinomina `model-tiering.md → execution-tiering.md` (opzionale, solo se i link entranti reggono).
- **Stack pertinente**: skill Markdown + agenti con hook di frontmatter; hook bash riusati invariati.
- **Convenzioni rilevate**: single-source delle mappe `complexity → policy`; derivazione effimera dell'orchestratore; enforcement scope/verify per-ruolo via hook di frontmatter (solo i subagent sono protetti).
- **Build/test command**: nessuno (Markdown). Verifica = dogfooding.

## Boundary e scope (feature)
- **In scope**: mappa `complexity → execution-mode` (`trivial`/`standard → solo`, `critical → team`, degrado → `team`); lettura `Complessità (ipotesi)` dal tasks-file a monte; agente `solo` con hook identici a `dev`; ramo `solo` nel protocollo per-task di `flow-run`; produzione artefatti identici post-implementazione (ASSUMPTION-fast-path-003); gate del finalize applicato dall'orchestratore al ritorno dell'agente solo.
- **Fuori scope**: la **pre-analisi read-only con promozione** `solo → team` (è `fast-path-promotion`); `inline`; modifica della struttura degli artefatti; nuovi campi su disco; rinomina del file mappa se rischiosa per i link.
- **Integrazione con l'esistente**: `team` resta bit-per-bit il flusso 2.0.0. La rete hook è riusata invariata. Senza la rete pre-write (feature successiva), una sottostima del planner viene intercettata dall'**escalation post-write** già esistente: la feature è sicura da sola.

## Tracked assumptions (specifiche)
> Le assunzioni condivise dell'epic (`ASSUMPTION-fast-path-001…005`) sono **vincolanti** e non ripetute qui: vedi `docs/epics/fast-path/00-context.md`. In particolare: mappa modalità (001), `inline` fuori scope (002), ordine artefatti (003), agente nuovo (004), degrado conservativo (005).

### ASSUMPTION-fast-path-solo-001
- **Descrizione**: chi marca `Status: finalized` e applica il gate in modalità `solo`.
- **Scelta**: l'**agente `solo`** scrive il brief co-locato con `Status: ✅ finalized` e l'eventuale append a `technical-context.md`; l'**orchestratore** applica comunque il **gate del finalize** al ritorno (`RESULT.verify=="pass"` E nessun `ESCALATION.json`) prima di marcare `done` nel `PROGRESS.json` e fare il mirror. Se il gate fallisce → escalation (step 7 invariato), e lo stato del brief resta non-finalized fino a risoluzione.
- **Alternative valutate**: far marcare `finalized` solo all'orchestratore (come nel finalize-inline) — scartato: l'agente solo ha già il contesto per scrivere il brief completo in un colpo; l'orchestratore si limita a gate-are, evitando una seconda passata.
- **Impatta**: `flow-run` (ramo solo del protocollo), `agents/solo.md`. **Status**: active. **Data**: 2026-06-03

### ASSUMPTION-fast-path-solo-002
- **Descrizione**: spawn dell'agente solo (numero di chiamate).
- **Scelta**: **una sola** chiamata `Agent` (`subagent_type: solo`, modalità `implement`), che internamente fa analisi → scope/frozen → implement → verify → artefatti. Nessun dry-run separato in `solo` (il dry-run è un secondo contesto: in `solo` l'analisi è già nello stesso contesto dell'implementazione, quindi il suo valore — escalation pre-codice — è assorbito dalla pre-analisi della feature `fast-path-promotion`).
- **Impatta**: `flow-run` (1 spawn in solo vs 1-2 in team), `model-tiering.md` (la policy dry-run resta definita per `team`). **Status**: active. **Data**: 2026-06-03

## Known risks (feature)
> I rischi cross-feature stanno nell'epic. Specifico di questa feature:

### RISK-fast-path-solo-001 — Modifica di `flow-run` mentre gira (dogfooding)
- **Severità**: 🔴
- **Descrizione**: questa feature riscrive l'orchestratore e aggiunge un agente; eseguirla via `flow-run` significa modificarlo mentre gira (eredita RISK-fast-path-001).
- **Mitigazione**: branch dedicato attivo; esecuzione **manuale** consigliata per i task che toccano `flow-run`/`agents`; commit per task.

---
Generato: 2026-06-03 | Versione: 1
