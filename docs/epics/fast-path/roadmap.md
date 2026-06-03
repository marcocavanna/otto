# Roadmap — Epic: Fast Path — esecuzione `solo` (`fast-path`)

**Outcome epic**: `flow-run` legge la `Complessità (ipotesi)` del planner a monte e chiude i task `trivial`/`standard` in **1 spawn** (`solo`) anziché 2, riservando il flusso PM+DEV (`team`) ai `critical`, con artefatti versionati **identici** e una rete di sicurezza pre-write (`solo → team`) sulle sottostime.
**Definition of done epic**: la mappa `complexity → execution-mode` è single-source in `model-tiering.md`; `flow-run` seleziona `solo`/`team` a monte (degrado conservativo → `team`); l'agente `solo` produce gli stessi artefatti di `team` con gli stessi hook di sicurezza; la pre-analisi read-only promuove `solo → team` su trigger misurabili senza toccare il codice; i fail post-write restano sull'escalation esistente; otto 2.1.0 rilasciata. Verifica end-to-end (dogfooding): eseguire un task `trivial`, uno `standard` (entrambi `solo`, artefatti completi) e uno deliberatamente sottostimato (promozione `solo → team`).
**Sizing complessivo**: M (~2 feature) — indicativo.

## Feature (ordine sequenziale)

> Sizing **indicativo** (t-shirt: `S ≈ 1-3 task · M ≈ 4-6 · L ≈ 7+`), **non vincolante**. Numero task ed effort reali NON sono fissati qui: li determina `planner expand <feature>` (ASSUMPTION-008).

### fast-path-solo — 🏗️ Modalità `solo`: selezione a monte + agente single-spawn + artefatti identici
- **Goal**: estendere `model-tiering.md` con la mappa `complexity → execution-mode`; insegnare a `flow-run` a leggere la `Complessità (ipotesi)` dal tasks-file **prima** di ogni spawn e a scegliere `solo`/`team` (degrado conservativo → `team`); introdurre l'agente `agents/solo.md` (hook identici a `dev`) che fa pre-analisi + implement + verify + produce `<context-root>/tasks/<id>.md` completo + append `technical-context.md`, post-implementazione. Già auto-sufficiente e sicura: le sottostime degradano sull'escalation **post-write** esistente.
- **Dipende da feature**: —
- **Sizing (indicativo)**: M
- **Status feature**: 🔵 active
- **Source**: docs/features/fast-path-solo/

### fast-path-promotion — 🔒 Rete di sicurezza pre-write: promozione `solo → team`
- **Goal**: aggiungere alla modalità `solo` una **pre-analisi read-only** che valuta una lista **chiusa e misurabile** di trigger (scope più ampio della complessità ipotizzata, contratto cross-task non dichiarato, contraddizione con `technical-context.md`/`02-abstract.md`, ambiguità che richiede una decisione di contratto). Allo scatto emette `RESULT.promote=true` (+ motivo) **senza toccare il codice** e termina; `flow-run` ri-esegue il task in `team`. I fail **post-write** restano sull'escalation esistente e non promuovono mai (eviterebbero un re-run su working tree sporco).
- **Dipende da feature**: fast-path-solo
- **Sizing (indicativo)**: S
- **Status feature**: ⚪ planned
- **Source**: docs/features/fast-path-promotion/

## Fronti paralleli
Nessuno. Catena strettamente lineare 1→2: `fast-path-promotion` consuma e indurisce il percorso `solo` introdotto da `fast-path-solo` (il segnale `RESULT.promote`, l'agente, il loop dell'orchestratore esistono solo dopo la prima feature).

## Note di sequencing
- **`fast-path-solo` prima**: introduce il tronco comune (mappa `execution-mode` + lettura complessità a monte + agente `solo` + ramo `solo` nell'orchestratore). È rilasciabile da sola: senza la rete pre-write, una sottostima del planner viene comunque intercettata dall'**escalation post-write** già esistente (degrado grazioso, non rottura).
- **`fast-path-promotion` dopo**: pura addizione di sicurezza pre-write sul percorso esistente. Non ha senso prima che `solo` esista.
- **Cautela esecuzione (RISK-fast-path-001)**: `fast-path-solo` modifica `flow-run` e introduce un agente. Valutare l'esecuzione **manuale** (non via `flow-run`) o con commit per task, perché tocca l'orchestratore mentre gira. Branch dedicato `epic/fast-path-solo-mode` già attivo.

---
Generato: 2026-06-03 | Versione: 1 | Epic: fast-path
