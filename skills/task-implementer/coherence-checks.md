# Coherence checks

Verifiche di coerenza che la skill deve eseguire — sia durante la generazione di ogni brief, sia su richiesta esplicita via `check-coherence`.

## Tipi di check

### Check 1: brief vs 02-abstract.md (non-contraddizione strategica)

Durante `brief T-NNN`, verificare che nessuna decisione proposta contraddica `02-abstract.md`.

Punti da controllare:
- Lo **stack** scelto nel brief corrisponde a quello dichiarato nell'abstract?
- I **pattern** proposti non rientrano nelle "Esclusioni tecniche" dell'abstract?
- I **trade-off** del brief sono coerenti con quelli dichiarati nell'abstract?
- Eventuali assunzioni tracciate in `00-context.md` rilevanti per il task sono rispettate?

Se conflitto rilevato:
```
⛔ Conflitto strategico

[Descrizione precisa del conflitto, con riferimenti ai documenti.]

Non posso procedere finché non risolvi:
a) Rivedi 02-abstract.md (usa `planner revise`)
b) Riformula la decisione tattica per rispettare l'abstract
c) Marca questo come deviazione esplicita autorizzata (richiede revise dell'abstract dopo)
```

### Check 2: brief vs technical-context.md (non-contraddizione tattica)

Durante `brief T-NNN`, verificare che nessuna decisione proposta contraddica decisioni già accumulate.

Punti da controllare:
- Librerie referenziate nel brief: la versione/nome corrisponde a quella in `technical-context.md`?
- Pattern referenziati: sono coerenti con quelli già adottati?
- Naming conventions: il brief segue le convenzioni già fissate?
- VO referenziati: esistono già in `technical-context.md` o vengono introdotti adesso?

Se conflitto:
```
⚠ Conflitto tattico

[Voce in technical-context.md] vs [decisione proposta nel brief].

Opzioni:
a) Aggiorno il brief per essere coerente con technical-context.md
b) Aggiorno technical-context.md (con superseded della voce vecchia) e procedo
c) Mostrami le motivazioni e decido manualmente
```

### Check 3: brief vs altri brief della stessa milestone

Durante `brief T-NNN`, leggere brevemente i brief già esistenti co-locati sotto la context-root (`<context-root>/tasks/`, solo della milestone/feature attiva) e verificare:

- VO definiti in un task precedente sono **referenziati** correttamente, non **ri-definiti**?
- File impattati: ci sono **conflitti di file** (es. T-007 dice "modifica X.cs in modo A", T-008 dice "modifica X.cs in modo B incompatibile")?
- Dipendenze implicite: il brief assume qualcosa di un task precedente che non è ancora finalized?

Se conflitto:
```
⚠ Conflitto inter-task

[Descrizione]

Suggerimento: [...]
```

### Check 4: technical-context.md vs realtà cumulata

Durante `finalize T-NNN`, verificare:
- Tutti i VO/pattern/librerie introdotti dal task sono stati registrati in `technical-context.md`?
- Eventuali deviazioni richiedono aggiornamento del contesto tecnico?
- Voci in `technical-context.md` che riferiscono questo task sono ancora accurate?

### Check 5 (modo `check-coherence`): audit completo

Su richiesta esplicita, audit completo:

1. **Brief attivi (non archiviati)**:
   - Ogni brief referenzia librerie/pattern presenti in `technical-context.md`?
   - Ci sono brief che modificano gli stessi file senza coordinarsi?
   - Ci sono brief con effort sommato che supera il budget della milestone?

2. **technical-context.md**:
   - Ogni voce ha un "Deciso in: T-NNN" valido (il task esiste)?
   - I VO referenziati nelle voci hanno tutte le loro shape definite?
   - Ci sono voci superseded che non hanno una sostituzione documentata?

3. **Allineamento con planning**:
   - Tutti i task in `05-tasks-active.md` hanno un brief? (warning se mancano)
   - Tutti i brief co-locati in `<context-root>/tasks/` hanno un task corrispondente nel tasks-file? (warning se orfani)

Output del check-coherence: report markdown con sezione per ogni problema. Niente modifiche automatiche.

## Output dei check

I check sono **bloccanti** quando rilevano conflitti reali (check 1 e 2 in generazione brief).

I check sono **avvertimenti** quando rilevano potenziali problemi (check 3 inter-task, check 5 audit).

Distinguere chiaramente nei messaggi:
- ⛔ = bloccante, la skill ferma il flusso
- ⚠ = warning, la skill procede ma segnala
- ℹ = info, segnalazione per consapevolezza

## Falsi positivi

I check possono produrre falsi positivi (es. due brief sembrano modificare lo stesso file ma in realtà toccano sezioni diverse). In quel caso:
- Il messaggio deve essere preciso e localizzato
- L'utente deve poter dire "ignora questo warning"
- La skill **non** mantiene una whitelist di warning ignorati — è responsabilità dell'utente decidere di volta in volta

Questo è intenzionale: una whitelist diventa rapidamente un meccanismo per ignorare problemi reali.
