# token-diet-foundation-003 — Redigere il glossario IT→EN dei termini di dominio otto

**Status**: ✅ finalized
**Origin**: flow-run attended
**Context-root**: docs/features/token-diet-foundation/
**Feature**: token-diet-foundation

---

## Vincoli risolti

### Stack e runtime
- Nessun tooling aggiuntivo. Documento Markdown puro.
- Path scelto: `docs/features/token-diet-foundation/glossary.md` (file dedicato, indipendente dal protocollo).

### Librerie e versioni
- N/A (documento operativo, nessuna dipendenza).

### VO/pattern/interfacce consumati
- Terminologia tecnica di otto (task, brief, flow-run, escalation, ecc.) — completamente coperta dal glossario.
- Struttura: tabella IT | EN | Contesto (coerente con convention markdown).
- Scope: solo termini di dominio otto (workflow, artefatti, gate, skill); termini tecnici generici inclusi solo con precisazione otto-specifica.
- Regole di utilizzo: coerenza terminologica, append-only per estensioni, cross-reference a documenti quando necessario.

### Naming convention
- Sezioni alfabetiche (A, B, C, ...) per agevolare ricerca.
- Abbreviazioni/acronimi in tabella separata (CLI, EC-NNN, EN, IT, L1/L2/L3, PM, DEV, VO, YAML).
- Colonne: IT | EN | Contesto / Note.

---

## File impattati

- `docs/features/token-diet-foundation/glossary.md` [new]

---

## Shape reale

```markdown
# Glossario IT→EN — Termini di dominio otto

| IT | EN | Contesto / Note |
|:---|:---|:---|
| brief | brief | Documento di analisi tecnica di un task (prodotto da task-implementer). |
| flow-run | flow-run | Orchestratore di spawn atomici (PM) e fork sequenziali (DEV). |
| escalation | escalation | Segnalazione di blocco decisionale (L1, L2, L3) a orchestratore/utente. |
| ...

## Abbreviazioni e acronimi

| Acronimo | Espanso | Contesto |
|:---|:---|:---|
| L1, L2, L3 | escalation level 1, 2, 3 | Gravità escalation. |
| PM | project manager | Orchestratore (flow-run, attended mode). |
| DEV | developer | Implementatore (code-implementer, attended mode). |
| ...

## Regole di utilizzo

1. **Coerenza**: ogni occorrenza IT → EN, niente varianti ad hoc.
2. **Scope**: solo termini di dominio otto.
3. **Estensione**: append-only, ordine alfabetico.
4. **Cross-reference**: link a documenti quando rilevante.
```
(shape, non implementazione finale — il documento completo è in `docs/features/token-diet-foundation/glossary.md`)

---

## Deviazioni

- Nessuna deviazione da piano. Il glossario copre i termini di dominio otto (vedi 00-context.md § "Cosa fa la feature") e include anche abbreviazioni/acronimi per completezza operativa.

---

*Generato: 2026-06-03 | Implementato da: flow-run attended (solo)*
