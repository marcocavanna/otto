# Task expansion

Regole per generare task atomici quando l'utente esegue `expand M[N]`.

## Granularità

Ogni task atomico deve rispettare TUTTE queste regole:

1. **Effort tra 1 e 4 ore**. Più piccolo è frammentazione inutile; più grande tende a procrastinazione.
2. **Definition of done concreta e binaria**. "Implementata l'autenticazione" è vago. "Endpoint POST /login restituisce JWT valido per credenziali corrette e 401 altrimenti, verificato con test" è concreto.
3. **Indipendente quanto possibile**. Se task A blocca task B, esplicitare la dipendenza.
4. **Verbo all'infinito + oggetto specifico**. "Configurare", "Implementare", "Scrivere", "Testare", "Documentare".

## Anti-pattern da evitare

- ❌ "Setup progetto" → troppo vago. Scomporre.
- ❌ "Fix bug" → non è un task pianificabile, è una scoperta.
- ❌ "Refactor" senza target specifico → scope indefinito.
- ❌ "Migliorare performance" → quanto? Su cosa?
- ❌ "Studiare X" → non è un task del piano. Se serve studiare X, è uno spike (vedi sotto).

## Categorie di task

Etichettare ogni task con una categoria per dare visibilità sulla composizione del lavoro:

- 🏗️ **setup** — infrastruttura, tooling, configurazione iniziale
- 💻 **impl** — implementazione logica/UI
- 🧪 **test** — test automatici, validazione
- 📚 **docs** — documentazione (README, API docs, ADR)
- 🔬 **spike** — esplorazione tecnica time-boxed, output = decisione
- 🚀 **deploy** — release, CI/CD, deploy
- 🔧 **fix** — solo se task arriva da un bug noto, non placeholder generico

## Composizione attesa di una milestone

Per una milestone di tipo "Foundation" (M1 tipica):
- ~30% setup, ~50% impl, ~10% test, ~10% docs.

Per una milestone "Vertical slice":
- ~10% setup, ~70% impl, ~15% test, ~5% docs.

Per una milestone "Release":
- ~10% impl, ~20% test, ~30% docs, ~40% deploy.

Se la composizione si discosta molto, segnalarlo all'utente prima di salvare.

## Spike

Se durante l'expand emergono incognite tecniche significative, prima dei task impl mettere uno o più spike:

```
### T-001 — 🔬 [SPIKE] Verificare se [tecnologia] supporta [requisito]
- **Effort**: 2-3h
- **Output**: decisione documentata in 02-abstract.md sezione "Trade-off"
- **Definition of done**: documento aggiornato + scelta giustificata
```

Gli spike sono time-boxed. Se uno spike supera il budget, va chiuso comunque con la migliore informazione disponibile, non esteso silenziosamente.

## Formato file 05-tasks-active.md (post-expand)

```markdown
# Task attivi — [Nome progetto]

**Milestone attiva**: M[N] — [nome]
**Effort totale stimato**: [X-Y ore]
**Definition of done milestone**: [da 03-milestones.md]

## Task

### T-001 — 🏗️ [setup] Configurare repo con [stack]
- **Effort**: 1-2h
- **Definition of done**: repo inizializzato, primo commit con README, .gitignore appropriato, struttura cartelle base
- **Dipende da**: —
- **Status**: ⚪ todo | 🔵 in progress | ✅ done | ⏸ blocked

### T-002 — 💻 [impl] Implementare modello dati [entità]
- **Effort**: 2-3h
- **Definition of done**: schema definito in [file], migration scritta e applicata, modello mappato in codice
- **Dipende da**: T-001
- **Status**: ⚪ todo

[...]

## Note operative
[Se ci sono ordini suggeriti, blocchi paralleli possibili, o riferimenti a spike → metterli qui.]

## Out of scope per questa milestone
[Cose che potrebbero sembrare logiche da fare ma sono esplicitamente rimandate. Riferimento a milestone futura.]

---
Generato: YYYY-MM-DD | Versione: 1 | Milestone: M[N]
```

## Numero di task per milestone

- M1 (foundation): 15-25 task tipicamente
- M2-M3 (slice/beta): 10-20 task
- Milestone "leggere" (release, polish): 5-10 task

Se una milestone supera i 30 task atomici → è troppo grande, va spezzata. Sollevare il punto con l'utente prima di salvare.

## Quando l'utente chiede `expand` su una milestone diversa dall'attiva

1. Confermare: "M1 è attualmente attiva. Vuoi davvero saltare a M[N]? I task atomici di M1 saranno persi (resta solo la milestone macro)."
2. Se confermato, sovrascrivere `05-tasks-active.md`.
3. Aggiornare lo status delle milestone in `03-milestones.md`:
   - Milestone precedente: chiedere se è done o paused.
   - Nuova milestone: status diventa 🔵 active.
4. Aggiornare `README.md`.

## Re-expand della stessa milestone

Se l'utente chiede di rifare l'expand della milestone già attiva (perché il contesto è cambiato o vuole task diversi):

1. Backup di `05-tasks-active.md` in `05-tasks-active.md.bak` (overwrite il backup precedente se esiste).
2. Generare nuova versione.
3. Segnalare all'utente che il backup esiste.
