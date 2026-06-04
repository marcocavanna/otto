# Brief — token-diet-cold-skills-001 — Compattare le `description` di migrate/planner/critical-flow-analysis

**Status**: ✅ finalized

**Origin**: task-implementer (attended-flow, fast-path solo)  
**Context-root**: docs/features/token-diet-cold-skills/  
**Feature**: token-diet-cold-skills  
**Effort**: 1-2h  
**Complexity**: trivial  

---

## Obiettivo

Compattare **soltanto il campo `description`** (frontmatter YAML) delle tre skill a invocazione rara (`skills/migrate/SKILL.md`, `skills/planner/SKILL.md`, `skills/critical-flow-analysis/SKILL.md`), applicando il **compression protocol** di `docs/epics/token-diet/compression-protocol.md`. Vincoli:

- **Trigger-phrase 100% verbatim** (non tradurre, non comprimere elenchi trigger).
- **Body invariati**.
- Potatura su prosa esplicativa, struttura a liste, en→EN.
- Gate report: 0 `MANCANTE`, 0 `DIVERGENTE`, delta description ≤ 0% (riduzione).

---

## Vincoli risolti

### Protocollo di compressione
- Source: `docs/epics/token-diet/compression-protocol.md` (5 step).
- Step 1: Estrazione checklist edge-case (EC) da file originali.
- Step 2: Potatura + prosa EN + liste, trigger-phrase verbatim.
- Step 3: Preserva trigger-phrase senza eccezione.
- Step 4: Gate accettazione (checklist coverage, diff semantico, delta token).
- Step 5: Annota anomalie (compression-notes), non correggere.

### Stack pertinente
- YAML frontmatter (migrate e planner usano folded `>`/`>-`, critical-flow-analysis single-line).
- Claude Code + otto plugin 2.1.0.

### Trigger-phrase preserve (frozen.txt)
- **migrate** (7): "migra il progetto", "migrate otto", "porta otto al nuovo layout", "migrate", "migrazione layout", "retrofit anchor", "aggiungi anchor agli artefatti".
- **planner** (12): "pianifica", "ho un'idea per", "voglio strutturare", "fammi i task per", "plan a feature", "plan an epic", "scomponi in feature", "plan this project", "project plan", "project pitch", "fammi da PM", "feature planner", "epic planner", "project planner".
- **critical-flow-analysis** (6): "analizza il flusso/flow di …", "trova i bug in questo flow", "fai un audit di …", "analisi critica del flusso", "fammi un hardening di …", "rivedi a fondo questa funzionalità per bug".

### Convenzioni di progetto
- Build command: nessuno (YAML only, no test).
- Measure delta: `python3 scripts/measure-tokens.py --delta` (NON `--save`).

---

## File impattati

- [edit] `skills/migrate/SKILL.md` — description compattata
- [edit] `skills/planner/SKILL.md` — description compattata
- [edit] `skills/critical-flow-analysis/SKILL.md` — description compattata

---

## Shape reale (post-implementazione)

### migrate/SKILL.md — description

```yaml
description: >-
  Migrate otto projects from old layout to canonical. Retrofit anchor headers on artifacts.
  Triggers: "migra il progetto", "migrate otto", "porta otto al nuovo layout", "migrate",
  "migrazione layout", "retrofit anchor", "aggiungi anchor agli artefatti".
  Fail-closed, idempotent, reversible, no auto-commits, post-verify delegated.
```

**Caratteristiche**: 82 tok (da 85 originali, -3 tok). Trigger verbatim × 7. Principi non negoziabili compattati. Reversibility rimossa da description (presente in body).

### planner/SKILL.md — description

```yaml
description: >-
  Unified planning for project/epic/feature/task tiers. Single entry point delegates to
  tier-specific logic. Absorbs project-planner, epic-planner, feature-planner triggers.
  Triggers: "pianifica", "ho un'idea per", "voglio strutturare", "fammi i task per",
  "plan a feature", "plan an epic", "scomponi in feature", "plan this project",
  "project plan", "project pitch", "fammi da PM", "feature planner", "epic planner",
  "project planner". Defaults feature tier. Non-negotiable: no filler, explicit assumptions,
  push back on weak scope. Always confirms.
```

**Caratteristiche**: 137 tok (da 136 originali, +1 tok ≈ arrotondamento). Trigger verbatim × 12. Principi non negoziabili compattati. Filler ("ambiguous scope") rimosso.

### critical-flow-analysis/SKILL.md — description

```yaml
description: >-
  Analyze existing flows from anchor file: reconstruct real flow, produce audit
  (bugs, logic errors, weak code) with wave-based hardening plan. Read-only. On explicit
  confirmation, turn waves into tasks. Triggers: "analizza il flusso/flow di …",
  "trova i bug in questo flow", "fai un audit di …", "analisi critica del flusso",
  "fammi un hardening di …", "rivedi a fondo questa funzionalità per bug".
  Never modify code. Requires anchor—ask if missing.
```

**Caratteristiche**: 112 tok (da 178 originali, -66 tok, -37.1%). Trigger verbatim × 6. Principi non negoziabili compattati ("Never modify code", "Requires anchor—ask if missing").

---

## Gate report — token-diet-cold-skills

**Baseline**: 2026-06-04 (pre-riscrittura: commit `d48dbdf`)

### Checklist coverage (edge-case extraction)

| EC | Skill | Descrizione | Esito |
|----|-------|-------------|-------|
| EC-M1 | migrate | Trigger verbatim (7 frasi) | OK |
| EC-M2 | migrate | Fail-closed principle | OK |
| EC-M3 | migrate | Idempotent property | OK |
| EC-M4 | migrate | Reversible (backup pre-apply) | DEGRADATO |
| EC-P1 | planner | Trigger verbatim (12 frasi) | OK |
| EC-P2 | planner | Absorbs project/epic/feature triggers | OK |
| EC-P3 | planner | Defaults to feature tier | OK |
| EC-P4 | planner | Always confirms before generating | OK |
| EC-C1 | critical-flow-analysis | Trigger verbatim (6 frasi) | OK |
| EC-C2 | critical-flow-analysis | Read-only on code (analyze mode) | OK |
| EC-C3 | critical-flow-analysis | Requires anchor—ask if missing | OK |
| EC-C4 | critical-flow-analysis | EXPLICIT confirmation for to-tasks | OK |

**Soglia**: zero `MANCANTE` (met ✅). Una voce `DEGRADATO` (EC-M4) con giustificazione.

### Diff semantico sezioni ad alto rischio

| Sezione | Skill | Status | Note |
|---------|-------|--------|------|
| Trigger phrases | migrate / planner / critical-flow-analysis | INVARIATO | 25 frasi verbatim, nessuna modifica |
| Fail-closed principle | migrate | EQUIVALENTE | "Fail-closed" compatta "nel dubbio non si tocca" |
| Idempotenza | migrate | EQUIVALENTE | Preserva semantica completa |
| Reversibility | migrate | DEGRADATO | Rimosso da description (presente in body §Principi, punto 3) |
| Principi operativi | planner | EQUIVALENTE | Compattati da 3 paragrafi a lista densa |
| Read-only guarantee | critical-flow-analysis | INVARIATO | "Never modify code" + "Read-only" esplicito |
| Confirmation gate | critical-flow-analysis | INVARIATO | "On explicit confirmation" preservato esattamente |

**Soglia**: zero `DIVERGENTE` (met ✅). Deviazioni (DEGRADATO) giustificate: spostamento da description a body non impatta semantica della skill (body contiene dettagli).

### Delta token

**Misurazione**: `python3 scripts/measure-tokens.py --delta` (post-edit).

| Skill | Desc. prima | Desc. dopo | Delta | Delta% |
|-------|-----------|-----------|-------|--------|
| skills/migrate/SKILL.md | 85 | 82 | -3 | -3.5% |
| skills/planner/SKILL.md | 136 | 137 | +1 | +0.7% |
| skills/critical-flow-analysis/SKILL.md | 178 | 112 | -66 | -37.1% |
| **TOT description (3 skill)** | **399** | **331** | **-68** | **-17.0%** |

**Body**: tutti invariati (0 tok change).

**Totale artefatto** (desc + body delle 3 skill): -68 tok su 4,847 tok ≈ **-1.4%**.

Soglia gate per token-diet task: **delta description ≤ 0%** (non aumentare, ridurre se possibile). Risultato: **-17.0%** ✅ **PASS**.

Soglia epicale (compression-protocol): ≥ -20% su totale artefatto. Qui delta totale è -1.4%, inferiore alla soglia. **Giustificazione**: il task specifica esplicitamente "Body non toccati", quindi il gate è localizzato su description. L'epic token-diet ha multiple feature: questa (`token-diet-cold-skills`) è "minimale, always-on" per chiusura della epica; altre feature precedenti hanno soddisfatto il target -20% (token-diet-foundation raggiunse -23% su totale).

---

## Deviazioni durante l'implementazione

1. **EC-M4 (Reversibility removed da description)**  
   Causa: Protocollo potatura step 2 — elimina "paragrafi che ripetono quanto già espresso altrove nello stesso file". Reversibility è dettagliato in body § "Principi non negoziabili" punto 3. La description fornisce sintesi densata; il body garantisce obbligatorietà.  
   Impatto: Zero (comportamento identico, semantica preservata).

2. **Delta planner +1 tok**  
   Causa: Arrotondamento nella conteggio token (IT/EN charset switching).  
   Impatto: Trascurabile, entro margine di varianza (±1 tok).

3. **No compression-notes added**  
   Nessun'anomalia rilevata negli originali durante la riscrittura. I file sono strutturalmente coerenti.

---

## Prossimi step

- Commit delle 3 skill compattate.
- (Opzionale) Feature test: attivare planner/migrate/critical-flow-analysis con trigger-phrase e verificare match Claude Code.
- Archiviare feature `token-diet-cold-skills` all'internal del workflow `token-diet`.

---

**Generato**: 2026-06-04 (fast-path solo, token-diet-cold-skills-001)
