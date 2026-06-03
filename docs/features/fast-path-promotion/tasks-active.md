# Task attivi — Feature: Promozione pre-write `solo → team` (`fast-path-promotion`)

**Feature**: fast-path-promotion
**Effort totale stimato**: da determinare
**Definition of done feature**: l'agente `solo` esegue una pre-analisi read-only su una lista chiusa di trigger misurabili (T1 scope · T2 contratto cross-task · T3 contraddizione contesto · T4 ambiguità contratto) **prima** di scrivere codice; allo scatto emette `RESULT.promote=true` + motivo senza toccare il working tree; `flow-run` ri-esegue il task in `team` (monodirezionale, working tree pulito); i fail post-write restano sull'escalation esistente e non promuovono mai; un task deliberatamente sottostimato dimostra la promozione `solo → team`. Contributo alla DoD epic: rete di sicurezza pre-write.

## Task

> ⏳ Task da espandere. Eseguire `planner expand fast-path-promotion` per generare i task atomici.

## Out of scope per questa feature
- Task atomici — determinati a expand.
- Promozione `inline → solo` / `team → solo`, auto-tuning trigger.
- Modifica della semantica dei fail post-write (restano sull'escalation esistente).

---
Generato: 2026-06-03 | Versione: 1
