# Roadmap — Epic: Token diet del plugin otto (`token-diet`)

**Outcome epic**: stesso comportamento del plugin con footprint token ridotto (always-on + hot-path),
zero regole/edge-case persi.
**Definition of done epic**: tutte le feature `done` con gate verde (checklist edge-case + diff semantico
+ delta token misurato); script di baseline mostra riduzione su `description` aggregate e sui body di
flow-run + dev/pm/solo + 4 skill calde; nessuna regressione comportamentale al dogfooding.
**Effort totale stimato**: da determinare a expand (sizing t-shirt indicativo — ASSUMPTION-token-diet-002).

## Feature (ordine sequenziale)

### token-diet-foundation — 🏗️ Baseline, protocollo, glossario e gate
- **Goal**: strumenti e regole anti-regressione che tutte le altre feature consumano — script di misura
  token riproducibile (baseline before/after), protocollo di compressione, glossario IT→EN, checklist/gate
  di accettazione.
- **Dipende da feature**: —
- **Size**: S  (indicativo — effort reale determinato a expand)
- **Status feature**: ✅ done
- **Source**: docs/features/token-diet-foundation/

### token-diet-flow-run — 💻 Riscrittura di flow-run (body + description)
- **Goal**: `skills/flow-run/SKILL.md` riscritto (potatura + EN), target ~17-19 KB da ~29 KB, tutti gli
  edge-case preservati (escalation, biforcazione solo/team, dry-run policy, model-tiering, degradi). Leva #1.
- **Dipende da feature**: token-diet-foundation
- **Size**: M  (indicativo — effort reale determinato a expand)
- **Status feature**: ✅ done
- **Source**: docs/features/token-diet-flow-run/

### token-diet-agents — 💻 Riscrittura agent dev/pm/solo (body + description)
- **Goal**: `agents/{dev,pm,solo}.md` riscritti (potatura + EN). Caricati a ogni spawn → impatto composto
  sui full-run.
- **Dipende da feature**: token-diet-foundation
- **Size**: S  (indicativo — effort reale determinato a expand)
- **Status feature**: ⚪ planned
- **Source**: docs/features/token-diet-agents/

### token-diet-hot-skills — 💻 Riscrittura skill calde (body + description)
- **Goal**: body+desc di `task-implementer`, `flow-sync`, `whats-next`, `code-implementer` riscritti
  (potatura + EN), edge-case preservati.
- **Dipende da feature**: token-diet-foundation
- **Size**: L  (indicativo — effort reale determinato a expand)
- **Status feature**: ⚪ planned
- **Source**: docs/features/token-diet-hot-skills/

### token-diet-cold-skills — 💻 Compattazione description skill rare
- **Goal**: **solo** le `description` di `migrate`, `planner`, `critical-flow-analysis` compattate +
  EN (guadagno always-on). Body **fuori scope** (skill rare, ROI basso). Trigger verbatim.
- **Dipende da feature**: token-diet-foundation
- **Size**: M  (indicativo — effort reale determinato a expand)
- **Status feature**: ⚪ planned
- **Source**: docs/features/token-diet-cold-skills/

## Fronti paralleli

`{token-diet-flow-run, token-diet-agents, token-diet-hot-skills, token-diet-cold-skills}` dopo
`token-diet-foundation`. File disgiunti per feature → nessuna dipendenza reciproca, nessun conflitto.

## Note di sequencing

- La `foundation` è bloccante per tutte: definisce gate e glossario senza i quali la riscrittura non è
  verificabile in modo coerente.
- Priorità di valore (per l'utente, non vincolo tecnico): `flow-run` (leva #1) → `agents` / `hot-skills`
  → `cold-skills`.
- Consigliato eseguire un **dogfooding** (un flow reale) dopo `flow-run` + `agents` per intercettare
  regressioni comportamentali prima di chiudere l'epic (RISK-token-diet-003).

---
Generato: 2026-06-03 | Versione: 1 | Epic: token-diet
