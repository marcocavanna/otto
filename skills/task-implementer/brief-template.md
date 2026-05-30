# Brief template

Template del file `docs/tasks/T-NNN.md`. Markdown denso, niente filler.

## Template completo

```markdown
# <id> — [titolo del task dal tasks-file]

**Status**: 🔵 active | ✅ finalized | ⏸ paused  
**Origin**: project-planner | feature-planner  
**Context-root**: docs/planning/ | docs/features/<slug>/  
**Milestone**: M[N]  *(project-planner)* — oppure **Feature**: `<slug>`  *(feature-planner; niente milestone)*  
**Effort stimato**: [dal tasks-file]  
**Dipendenze**: [dal tasks-file]  
**Generato**: YYYY-MM-DD  
**Versione**: 1

> `Origin` + `Context-root` sono il contratto letto da `code-implementer` per caricare il contesto. Vedi `../feature-planner/feature-artifacts.md` § "Planning source contract". Header assente → default `docs/planning/`.

## Obiettivo

[Una/due frasi che riprendono la Definition of done dal task originale. Niente reinterpretazione.]

## Analisi funzionale

[Cosa fa il task in termini di comportamento osservabile. Input, output, side effects. Niente codice qui — pura analisi funzionale.]

[Se utile, una piccola lista di scenari concreti:
- Scenario 1: input X → output Y
- Scenario 2: input invalido Z → errore di tipo W
- Edge case: ...]

## Analisi tecnica

### Stack di implementazione
[Solo voci rilevanti per QUESTO task. Non ripetere lo stack globale.]

- Libreria/componente: nome + versione + breve perché
- [...]

### Pattern adottati
[Riferirsi a pattern già stabiliti in `technical-context.md` quando possibile. Nuovi pattern vanno proposti e poi propagati lì.]

- Pattern X — vedi `technical-context.md` § Y
- Nuovo: Pattern Z — motivato da [...], andrà in `technical-context.md`

### Assunzioni operative locali

[Assunzioni specifiche di questo task, non globali. Numerate con prefisso del task ID.]

- **ASSUMPTION-T-NNN-001**: [...]
- **ASSUMPTION-T-NNN-002**: [...]

[Se nessuna assunzione locale, scrivere esplicitamente "Nessuna assunzione locale — tutto deciso a livello strategico/tattico."]

## File impattati

```
[lista file da creare/modificare con annotazione [new] o [edit]]
- src/Domain/Entities/User.cs [new]
- src/Infrastructure/Persistence/AppDbContext.cs [edit]
- src/Infrastructure/Persistence/Configurations/UserConfiguration.cs [new]
- tests/Domain.UnitTests/UserTests.cs [new]
```

## Shape di implementazione

> ⚠ Le seguenti shape sono **direzione**, non implementazione finale. Adattare durante esecuzione.

[Stralci di codice ~20-30 righe per costrutto. Mostrano struttura, decisioni di design, firme. NON copia-incolla pronto all'uso.]

```[linguaggio]
// [path/al/file.ext]
// Shape — adattare in implementazione

[codice]
```

[Ripetere per ogni costrutto chiave del task. Limite duro: massimo 3-4 stralci per brief. Se ne servono di più, il task è troppo grande.]

## Test minimo

[Cosa testare per considerare il task done. Non implementazione dei test, solo cosa deve essere coperto.]

- Test 1: [comportamento]
- Test 2: [comportamento]
- Edge case: [comportamento]

## Subtask

[**Default: nessuno**. Sezione presente solo se subtask sono realmente necessari secondo `subtask-criteria.md`.]

[Se nessuno:]
**Nessun subtask necessario** — esecuzione lineare.

[Se presenti:]
- **T-NNN.1** — [titolo] — effort: [Xh] — output: [...]
- **T-NNN.2** — [titolo] — effort: [Xh] — output: [...]

## Riferimenti

- Task in plan: `docs/planning/05-tasks-active.md` § T-NNN
- Assunzioni di progetto rilevanti: [ASSUMPTION-XXX dal 00-context.md]
- Decisioni tecniche rilevanti: [voci di technical-context.md citate]

## Out of scope per questo task

[Cose che potrebbero sembrare logiche da fare in questo task ma sono esplicitamente rimandate. Linkare al task futuro se noto.]

- [...] → vedi T-NNN successivo / milestone M[N+1]

---

## Deviazioni durante l'implementazione

[Sezione opzionale, popolata via `deviation T-NNN`. Vuota inizialmente. NON eliminare la sezione anche se vuota.]

[Quando popolata:]

### DEV-001 — YYYY-MM-DD
- **Cosa è cambiato**: [...]
- **Perché**: [...]
- **Impatto su technical-context.md**: [da valutare a finalize]

---

## Finalize

[Popolato solo via `finalize T-NNN`. Vuoto inizialmente.]

[Quando popolato:]
- **Finalized**: YYYY-MM-DD
- **Aggiornamenti a technical-context.md**:
  - [lista puntuale di cosa è stato modificato/aggiunto]
- **Note di chiusura**: [eventuali, brevi]
```

## Regole sulla shape di implementazione

Lo "shape code" nei brief segue regole rigorose. È la parte più rischiosa della skill — può degenerare in "codice generato che non funziona ma sembra giusto".

### Cosa includere

- Firme di classi, metodi, interfacce
- Struttura di tipi (record, DTO, VO)
- Esempi di chiamate ad API esterne con parametri rilevanti
- Schema di tabelle, schema JSON, contratti
- Pseudocodice quando l'algoritmo ha logica non banale

### Cosa NON includere

- Implementazione completa di metodi non banali
- Boilerplate (using, namespace, ecc. — l'utente li mette da sé)
- Codice che dipende da context locale non visibile (es. servizi DI specifici del progetto non documentati altrove)
- Try/catch generici, logging, configurazione — distraggono dalla shape

### Formato

Ogni stralcio:
- Prefisso commento `// [path/al/file.ext]` o equivalente per il linguaggio
- Commento esplicito `// Shape — adattare in implementazione` in cima
- Commenti `// ...` per indicare parti omesse intenzionalmente
- Massimo 30 righe per stralcio. Se sfora, il costrutto è probabilmente troppo complesso per essere "shape" — è già implementazione, va omesso.

### Quando non includere alcuno stralcio

Per task molto semplici o di pura configurazione (es. "configurare ESLint", "creare migration vuota") può non servire nessuno stralcio. In quel caso:

```markdown
## Shape di implementazione

[Non applicabile — il task non richiede design di codice. Vedi sezione "File impattati" per cosa toccare.]
```

Mai forzare uno stralcio per "completezza visiva" del brief.
