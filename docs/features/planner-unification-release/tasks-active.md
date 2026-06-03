# Task attivi — Feature: Ritiro vecchie skill + migrazione + 2.0.0 (`planner-unification-release`)

**Feature**: planner-unification-release
**Effort totale stimato**: 4-9 ore
**Definition of done feature**: le 3 vecchie skill non esistono più; `migrate` retrofitta gli anchor (preview/apply/post-verify idempotenti); versione 2.0.0 in plugin.json + marketplace.json; README/changelog/breaking-notice aggiornati; smoke end-to-end via `planner` su task/feature/epic ok.

## Task

### planner-unification-release-001 — 🔧 [chore] Rimozione netta di project/feature/epic-planner
- Effort: 1-2h
- Definition of done: le 3 dir skill rimosse; description di `planner` assorbe i trigger ("pianifica la feature/epic/progetto"); nessun link orfano residuo nei runtime
- Dipende da: planner-unification-downstream-006
- Status: ✅ done
> Untangle reale (core aveva portato i planner per LINK non per copia): migrati decomposition.md + epic-artifacts.md in planner/references/ con fix dei loro link interni; ripuntati ~17 hard-link in entrata; rimosse le 3 dir; 0 link orfani verificati. Follow-up: ~80 menzioni in PROSA dei vecchi nomi skill (non-breaking) da ripulire contestualmente.

### planner-unification-release-002 — 💻 [impl] Estendere migrate per il retrofit degli anchor
- Effort: 2-3h
- Definition of done: migrate inietta gli header anchor (Tier/Parent/Bubble-up target) negli artefatti esistenti, ricavando Parent/target dalla roadmap Source e dalla struttura; append non distruttivo; idempotente
- Dipende da: planner-unification-release-001
- Status: ✅ done
> Estesi SKILL.md (nuova sezione "Modalità — Anchor retrofit" con modalità anchor-retrofit preview/apply/post-verify) e creato references/anchor-retrofit.md con la logica completa: scan artefatti candidati, inferenza tier/parent/bubble-up per tutti e 4 i tier, AnchorRetrofitPlan, preview con gate di sessione, apply idempotente+reversibile (backup+manifest), post-verify pass/fail, 7 edge case coperti.

### planner-unification-release-003 — 🧪 [test] migrate anchor: preview/apply/post-verify
- Effort: 1-2h
- Definition of done: preview mostra gli inserimenti senza scrivere; apply idempotente e reversibile (backup); post-verify "ogni artefatto ha anchor coerente"; testato su un progetto esistente (es. fixture o copia dell'epic tenancy)
- Dipende da: planner-unification-release-002
- Status: ⚪ todo

### planner-unification-release-004 — 🚀 [release] Bump 2.0.0 + README/changelog + breaking notice
- Effort: 1-2h
- Definition of done: plugin.json e marketplace.json a 2.0.0; README aggiornato (planner unico, 4 tier, anchor, bubble-up via finalize); nota breaking esplicita sul ritiro delle 3 skill e sul retrofit migrate
- Dipende da: planner-unification-release-003
- Status: ⚪ todo

## Note operative

- ATTENZIONE: ultima feature dell'epic, auto-modifica massima — eseguire con cautela, su branch dedicato e con commit incrementali; non affidarsi alle skill in corso di rimozione.

## Out of scope per questa feature

- —

---
Generato 2026-06-02 v1 | Feature: planner-unification-release
