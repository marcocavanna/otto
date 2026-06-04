# Context — Feature: Baseline, protocollo, glossario e gate (`token-diet-foundation`)

<!-- Anchor --> **Tier**: feature · **Parent**: token-diet · **Bubble-up target**: docs/epics/token-diet/technical-context.md

**Progetto**: otto
**Epic**: token-diet
**Dipende da feature**: —
**Tipo**: feature su progetto esistente

## Cosa fa la feature

Materializza il guardrail anti-regressione che tutte le altre feature dell'epic consumano: uno **script di
misura token** riproducibile (baseline before/after), il **protocollo di compressione**, il **glossario
IT→EN** dei termini di dominio otto, e la **checklist/gate di accettazione**.

## Derivato dal codebase

- **Moduli/aree toccate**: nuovo script in `scripts/` (o equivalente); doc operative di supporto. Non
  modifica alcun `SKILL.md`/agent.
- **Stack pertinente**: shell/Python per la misura (coerente con l'assenza di runtime applicativo).
- **Convenzioni rilevate**: nessun tooling preesistente → introdurre il minimo indispensabile.
- **Build/test command**: lo script stesso è il "test" (misura e confronta).

## Boundary e scope

- **In scope**: script di misura (description + body per skill/agent, totali e delta); documento di
  protocollo+glossario+checklist; baseline iniziale committata.
- **Fuori scope**: qualsiasi riscrittura di skill/agent (è delle feature successive).
- **Integrazione con l'esistente**: lo script legge i frontmatter/body sotto `skills/` e `agents/`; non
  altera i contratti `.flow/`.

## Tracked assumptions

### ASSUMPTION-token-diet-foundation-001
- **Descrizione**: linguaggio dello script di misura.
- **Scelta**: Python 3 (disponibile, parsing frontmatter semplice, già usato nelle misure d'analisi).
- **Alternative valutate**: shell puro (parsing YAML fragile); Node (dipendenze).
- **Impatta**: tasks-active.md
- **Status**: active
- **Data**: 2026-06-03

## Known risks

### RISK-token-diet-foundation-001 — Metrica token solo stimata
- **Severità**: 🟢 bassa
- **Descrizione**: senza il tokenizer reale di Claude, il conteggio è una stima (char/token). I delta
  relativi restano validi anche se l'assoluto è approssimato.
- **Mitigazione**: usare un metodo coerente (stesso ratio) per before/after; dichiarare che la metrica è
  un proxy comparativo.

---
Generato: 2026-06-03 | Versione: 1
