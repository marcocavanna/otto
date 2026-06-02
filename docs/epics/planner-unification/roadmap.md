# Roadmap — Epic: Unificazione dei planner (`planner-unification`)

**Outcome epic**: una sola skill `planner` (tier project/epic/feature/task) rimpiazza i tre planner, con anchor espliciti e bubble-up single-hop selettivo via `finalize`; otto a 2.0.0.
**Definition of done epic**: `planner` copre i 4 tier in `plan`/`expand`/`finalize`; i downstream risolvono anchor + tier `task` senza rotture; le 3 vecchie skill non esistono più; `migrate` retrofitta gli anchor; versione 2.0.0 rilasciata. Verifica end-to-end (dogfooding): pianificare ed eseguire un task, una feature e un'epic via `planner` con bubble-up corretto.
**Sizing complessivo**: L (~5 feature) — indicativo.

## Feature (ordine sequenziale)

> Sizing **indicativo** (t-shirt: `S ≈ 1-3 task · M ≈ 4-6 · L ≈ 7+`), **non vincolante**. Numero task ed effort reali NON sono fissati qui: li determina `feature-planner` in `expand` (ASSUMPTION-008).

### planner-unification-contract — 🏗️ Contratto v2 + anchor model + home tier `task`
- **Goal**: definire (non implementare la skill) il Planning source contract v2 relocato sotto `planner/`, lo schema anchor e la home `docs/tasks/<slug>/` del tier task. Tronco comune.
- **Dipende da feature**: —
- **Sizing (indicativo)**: S
- **Status feature**: ✅ done
- **Source**: docs/archive/features/planner-unification-contract/

### planner-unification-core — 💻 Skill `planner` + plan mode (4 tier)
- **Goal**: `skills/planner/SKILL.md` (router + scelta/conferma tier) + reference tier-{project,epic,feature,task} + consolidamento dei reference condivisi sotto `planner/`. Solo modo `plan`.
- **Dipende da feature**: planner-unification-contract
- **Sizing (indicativo)**: L
- **Status feature**: ✅ done
- **Source**: docs/archive/features/planner-unification-core/

### planner-unification-finalize — 💻 Modi `expand` + `finalize` con bubble-up single-hop
- **Goal**: modo `expand` unificato; modo `finalize` che possiede il bubble-up single-hop selettivo (legge l'anchor, valuta cosa risale, append datato idempotente). Supersede il bubble-up grezzo della 1.1.0.
- **Dipende da feature**: planner-unification-core
- **Sizing (indicativo)**: M
- **Status feature**: ✅ done
- **Source**: docs/archive/features/planner-unification-finalize/

### planner-unification-downstream — 🔧 Re-anchoring + scan tier `task` + flow-run→finalize
- **Goal**: ripuntare i ~15-20 link a `planner/`; insegnare agli scanner `docs/tasks/<slug>/` e la lettura degli anchor; `flow-run` invoca `planner finalize <slug>` invece dell'append diretto; `whats-next`/`flow-sync` gestiscono tier task + anchor.
- **Dipende da feature**: planner-unification-finalize
- **Sizing (indicativo)**: L
- **Status feature**: ⚪ planned
- **Source**: docs/features/planner-unification-downstream/

### planner-unification-release — 🚀 Ritiro vecchie skill + migrazione + 2.0.0
- **Goal**: rimozione netta di `project/feature/epic-planner` (trigger assorbiti da `planner`); estensione di `migrate` per il retrofit degli anchor negli artefatti esistenti; bump 2.0.0 + README/changelog + breaking notice.
- **Dipende da feature**: planner-unification-downstream
- **Sizing (indicativo)**: M
- **Status feature**: ⚪ planned
- **Source**: docs/features/planner-unification-release/

## Fronti paralleli
Nessuno. Catena strettamente lineare 1→2→3→4→5, imposta dalle dipendenze tecniche reali e dal vincolo di **auto-modifica a runtime** (RISK-001): i tool che eseguono il flow (`flow-run`, `task-implementer`) si toccano solo nelle ultime due feature.

## Note di sequencing
- **`contract` prima di tutto**: è il tronco comune; ogni feature successiva ne consuma lo schema anchor + il contratto v2.
- **`core` prima di `finalize`**: serve la skill `planner` esistente prima di aggiungerle i modi `expand`/`finalize`.
- **`finalize` prima di `downstream`**: `flow-run` può invocare `planner finalize` solo dopo che esiste.
- **`downstream` prima di `release`**: non si rimuovono le vecchie skill finché i link non sono tutti ripuntati e i downstream non risolvono il nuovo contratto.
- **Cautela esecuzione**: valutare di eseguire `downstream` e `release` **a mano** (non via `flow-run`), o con commit/branch per feature, perché modificano l'orchestratore stesso mentre gira.

---
Generato: 2026-06-02 | Versione: 1 | Epic: planner-unification
