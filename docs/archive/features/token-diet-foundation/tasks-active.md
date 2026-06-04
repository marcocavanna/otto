# Task attivi — Feature: Baseline, protocollo, glossario e gate (`token-diet-foundation`)

**Feature**: token-diet-foundation
**Effort totale stimato**: 5-8 ore
**Definition of done feature**: script di misura funzionante con baseline committata + documento
protocollo/checklist/gate + glossario IT→EN disponibili come single-source per i fronti di riscrittura.

## Task

### token-diet-foundation-001 — 🏗️ [setup] Scrivere `scripts/measure-tokens.py` con misura e delta

- **Effort**: 2-3h
- **Definition of done**: `python3 scripts/measure-tokens.py` emette una tabella per-artefatto
  (`skills/*/SKILL.md` description + body; `agents/*.md` body) con stima token (ratio it/en), i totali
  **always-on** (somma description) e **hot-path** (body), gestendo frontmatter sia single-line sia folded
  (`>`/`>-`); con un baseline salvato presente, stampa anche il **delta** per artefatto e aggregato.
  Baseline iniziale generata e committata (es. `scripts/token-baseline.json`).
- **Dipende da**: —
- **Complessità (ipotesi)**: standard
- **Status**: ✅ done

### token-diet-foundation-002 — 📚 [docs] Documentare protocollo di compressione, checklist edge-case e gate

- **Effort**: 2-3h
- **Definition of done**: documento single-source (es. `docs/epics/token-diet/compression-protocol.md`)
  che definisce: i 5 step del protocollo (estrai checklist → riscrivi potatura+EN+liste → trigger
  verbatim → gate → annota-non-correggere), il **metodo di estrazione della checklist edge-case** da un
  file originale, e i **criteri del gate di accettazione** (ogni voce checklist ritrovabile nel nuovo
  testo + diff semantico + delta token misurato). Linkato dal `technical-context.md` dell'epic.
- **Dipende da**: —
- **Complessità (ipotesi)**: standard
- **Status**: ✅ done

### token-diet-foundation-003 — 📚 [docs] Redigere il glossario IT→EN dei termini di dominio otto

- **Effort**: 1-2h
- **Definition of done**: glossario (nel documento di protocollo o file dedicato) con la traduzione
  canonica dei termini ricorrenti (task, brief, flow-run, escalation, dry-run, finalize, ramo solo/team,
  tasks-file, contratto, scope-check, verify-gate, ecc.), così che i fronti di riscrittura usino
  terminologia EN coerente. Almeno i termini presenti in flow-run e negli agent coperti.
- **Dipende da**: —
- **Complessità (ipotesi)**: trivial
- **Status**: ✅ done

## Note operative

- I tre task sono **indipendenti** (nessuna dipendenza reciproca) → eseguibili in parallelo.
- 001 è il prerequisito *funzionale* per misurare i delta nelle feature successive; 002/003 sono il
  prerequisito *metodologico*. L'intera feature `foundation` resta bloccante per gli altri fronti dell'epic.
- Composizione: setup+docs (atteso per una foundation di tipo tooling/metodologia, non di prodotto).

## Out of scope per questa feature

- Qualsiasi riscrittura di skill/agent (feature `token-diet-flow-run`, `-agents`, `-hot-skills`, `-cold-skills`).
- Integrazione CI dello script (verifica manuale/dogfooding).

---
Generato: 2026-06-03 | Versione: 2 | Feature: token-diet-foundation
