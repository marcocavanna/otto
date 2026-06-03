# Task attivi — Feature: Promozione pre-write `solo → team` (`fast-path-promotion`)

**Feature**: fast-path-promotion
**Effort totale stimato**: 5-8h (~3 task)
**Definition of done feature**: l'agente `solo` esegue una pre-analisi read-only su una lista chiusa di trigger misurabili (T1 scope · T2 contratto cross-task · T3 contraddizione contesto · T4 ambiguità contratto) **prima** di scrivere codice; allo scatto emette `RESULT.promote=true` + motivo senza toccare il working tree; `flow-run` ri-esegue il task in `team` (monodirezionale, working tree pulito); i fail post-write restano sull'escalation esistente e non promuovono mai; un task deliberatamente sottostimato dimostra la promozione `solo → team`. Contributo alla DoD epic: rete di sicurezza pre-write.

## Task

### fast-path-promotion-001 — 💻 [impl] Lista trigger di promozione (reference single-source)

- **Effort**: 1-2h
- **Definition of done**: esiste un reference single-source (collocazione da decidere a implementazione: `skills/flow-run/references/promotion-triggers.md` candidato) che definisce la **lista chiusa e misurabile** dei trigger di promozione read-only: **T1** scope più ampio della complessità ipotizzata (es. `>3` file su `trivial`; area fuori da quella ovvia), **T2** contratto cross-task non dichiarato (VO/interfaccia/formato consumato da altri task — segnale 1 di `complexity-criteria.md`), **T3** contraddizione con `technical-context.md`/`02-abstract.md` vincolanti, **T4** ambiguità che richiede una decisione di contratto. Ogni trigger ha un criterio **misurabile e valutabile read-only**. Il reference dichiara esplicitamente che i fail **post-write** (build/verify) NON sono trigger di promozione. Linka (non duplica) i segnali di `complexity-criteria.md`. Nessuna logica attiva (è la fonte consumata da 002).
- **Dipende da**: —
- **Complessità (ipotesi)**: standard
- **Status**: ⚪ todo

### fast-path-promotion-002 — 💻 [impl] Pre-analisi read-only + emissione `RESULT.promote` in `agents/solo.md`

- **Effort**: 2-3h
- **Definition of done**: `agents/solo.md` esegue, **prima di qualunque Write/Edit di codice**, uno step di pre-analisi read-only (solo Read/Grep/Glob) che valuta i trigger del reference di 001; allo scatto di un trigger scrive `RESULT.json` con **`promote=true`** + **`promote_reason`** (trigger + misura, es. "T1: 5 file su task trivial") e **termina senza scrivere codice né brief**; se nessun trigger scatta prosegue la sequenza solo esistente (`promote` assente/false). Lo schema `RESULT.json` è esteso coerentemente col contratto letto da `flow-run` (campi `promote`/`promote_reason` additivi, retro-compatibili). La pre-analisi precede la materializzazione di `scope.txt`/`frozen.txt` di codice (resta consentito scrivere in `.flow/briefs/<task>/`). Confine pre/post-write esplicito: i fail post-write restano su `ESCALATION.json`.
- **Dipende da**: fast-path-promotion-001
- **Complessità (ipotesi)**: critical
- **Status**: ⚪ todo

### fast-path-promotion-003 — 💻 [impl] Gestione `RESULT.promote` in `flow-run` (re-run `solo → team`)

- **Effort**: 2-3h
- **Definition of done**: nel ramo `solo` di `skills/flow-run/SKILL.md` (passo S3, già predisposto in `fast-path-solo-003`) la logica `promote==true` diventa **attiva** (rimossa la nota "predisposto ma inerte"): l'orchestratore, letto `RESULT.promote=true`, **ri-esegue lo stesso task dal passo 3 in `team`** (working tree pulito, nessun cleanup), annotando la promozione + motivo nel summary; monodirezionale (`solo → team`, mai `team → solo`); `promote` valutato **prima** di `escalate`/`verify` (caso pre-write). I fail post-write (`escalate`/`verify!=pass`/`ESCALATION.json`) restano allo step 7, mai promozione. Nessuna regressione del ramo `team` né del ramo `solo` senza promote.
- **Dipende da**: fast-path-promotion-002
- **Complessità (ipotesi)**: critical
- **Status**: ⚪ todo

## Note operative
- **RISK-fast-path-001 (auto-modifica a runtime)**: 003 tocca l'orchestratore. Valutare esecuzione **manuale** o commit per task, come per `fast-path-solo-003`.
- **Dipendenza dalla feature precedente**: tutta la feature consuma `fast-path-solo` (agente `solo`, ramo `solo`, punto d'innesto `promote` in S3) — già finalized.
- **Calibrazione trigger (RISK-fast-path-promotion-001)**: la lista 001 va tarata col dogfooding (un task deliberatamente sottostimato). Bias verso la rarità: il planner sovrastima in dubbio.

## Out of scope per questa feature
- Promozione `inline → solo` / `team → solo`, auto-tuning trigger.
- Modifica della semantica dei fail post-write (restano sull'escalation esistente).
- Modalità `inline`, modifica struttura artefatti versionati.

---
Generato: 2026-06-03 | Versione: 2
