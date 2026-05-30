# Preflight checks

Controlli da eseguire **prima** di iniziare qualsiasi operazione di implementazione. Se un check fallisce, la skill si ferma con messaggio chiaro all'utente.

## Check 1 — Esistenza file di planning

File richiesti:
- `docs/planning/00-context.md`
- `docs/planning/02-abstract.md`
- `docs/planning/technical-context.md`
- `docs/tasks/T-NNN.md` (per il task richiesto)

Se mancano:
```
⛔ Setup incompleto

Mancano file di planning richiesti:
- [lista file mancanti]

La skill richiede che project-planner e task-implementer siano stati eseguiti
prima. Non posso procedere senza il contesto strategico/tattico.

Suggerimento: esegui prima:
- project-planner init (se nessun planning esiste)
- task-implementer brief T-NNN (se manca il brief)
```

## Check 2 — Stato del brief

Il brief `docs/tasks/T-NNN.md` deve essere in stato `active`. Status accettati:
- 🔵 `active` → procedi
- ⏸ `paused` → chiedi conferma esplicita all'utente prima di procedere
- ✅ `finalized` → blocca

Per finalized:
```
⛔ Task già finalized

Il brief T-NNN risulta finalizzato il [data]. Implementare codice per un task
finalizzato è probabilmente un errore.

Opzioni:
a) Verificare se ti sbagli di task (controlla 05-tasks-active.md)
b) Se serve modificare codice di un task finalizzato, è probabile che serva
   un nuovo task (project-planner: expand o nuovo brief)
```

## Check 3 — Build command dichiarato

Cercare in `technical-context.md` sezione "Convenzioni di progetto" → voce `build_command`.

Se assente:
```
⚠ Build command non dichiarato

In technical-context.md non è dichiarato come buildare il progetto. La verifica
build dopo implementazione sarà saltata.

Suggerimento (non bloccante):
Aggiungi in technical-context.md sezione "Convenzioni di progetto":

  build_command: [comando reale del tuo progetto, es: `dotnet build`]

Procedo senza verifica build? (sì/no)
```

Non bloccante, ma chiede conferma.

## Check 4 — Working directory è un repo

Verificare che la working directory contenga indicatori di repository:
- `.git/` directory
- OPPURE un file di progetto (`*.csproj`, `*.sln`, `package.json`, `Cargo.toml`, ecc.)

Se nessuno presente:
```
⛔ Directory non riconosciuta come progetto

La directory corrente non sembra essere la root di un repository di codice.
Verifica di essere nella directory corretta prima di procedere.
```

## Check 5 — File impattati non già modificati

Per ogni file dichiarato in "File impattati" del brief con flag `[new]`:
- Verificare che NON esista già nel filesystem
- Se esiste: sollevare conflitto

```
⚠ File marcato [new] esiste già

Il brief dichiara `path/to/File.cs` come `[new]` ma il file esiste già.

Opzioni:
a) Il file esistente è di un task precedente non finalizzato — verifica
b) Brief obsoleto — rigenera con task-implementer
c) Procedi sovrascrivendo (richiede conferma esplicita)
```

Per file con flag `[edit]`:
- Verificare che ESISTA
- Se non esiste: warning ma procedi (lo crei)

## Check 6 — Sample availability (informativo, non bloccante)

Identificare la categoria di costrutto dal brief (vedi `context-loading.md` per come). Cercare un sample esistente.

Se non trovato:
```
ℹ Nessun sample disponibile

Categoria task: [X]. Non ho trovato un costrutto simile già esistente nel
codebase da usare come riferimento stilistico.

Procederò applicando direttamente i template di technical-context.md. Questo
significa che lo stile di questo costrutto sarà la baseline per i task futuri
della stessa categoria.
```

Solo informativo — non chiede conferma, procede comunque.

## Ordine di esecuzione

I check vanno eseguiti in ordine. Al primo fallimento bloccante, si ferma e riporta. I check non-bloccanti (warning) accumulano messaggi che vanno mostrati prima di iniziare il flusso.

Output preflight ben formato:
```
Pre-flight checks per T-NNN:

✅ File di planning presenti
✅ Brief in stato active
⚠ Build command non dichiarato (procedo senza verifica build)
✅ Directory riconosciuta come progetto
✅ File impattati: 3 [new], 2 [edit], nessun conflitto
ℹ Sample disponibile: src/Controllers/UsersController.cs

Procedo con context loading. Confermi?
```

L'utente conferma o annulla. Niente conferme intermedie ridondanti dopo questa.
