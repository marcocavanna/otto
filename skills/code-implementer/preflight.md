# Preflight checks

Controlli da eseguire **prima** di iniziare qualsiasi operazione di implementazione. Se un check fallisce, la skill si ferma con messaggio chiaro all'utente.

## Check 1 — Esistenza e integrità del brief

File richiesto:
- `<context-root>/tasks/<id>.md` (co-locato, unico path supportato)

Risoluzione context-root: header `Context-root:` del brief; default `docs/planning/`.
Contratto canonico: `../feature-planner/feature-artifacts.md` § "Planning source contract".

Se il brief non esiste al path co-locato:
```
⛔ Setup incompleto

Brief non trovato:
- <context-root>/tasks/<id>.md

La skill richiede che task-implementer abbia generato il brief prima.
(Progetto pre-canonical con brief flat in docs/tasks/? Esegui prima la skill `migrate`.)

Suggerimento: esegui prima:
- task-implementer brief <id> (se manca il brief)
```

Il brief è la **fonte unica** di contesto: la skill NON verifica più la presenza
di `00-context`, `02-abstract`, `technical-context` (il PM li ha già distillati nel
brief — vedi `context-loading.md`).

## Check 1-bis — Sezione "Vincoli risolti" nel brief

Se il brief esiste, verificare che contenga la sezione `## Vincoli risolti`.

- **Presente** → reading-set ridotto attivo: brief + 1 sample + file `[edit]`.
  NON leggere i 3 file di planning.
- **Assente** (brief legacy pre-topology-canonical) → warning non bloccante:
  procedere con lettura fallback dei 3 file di planning (modalità pre-topologia).

```
⚠ Brief senza "Vincoli risolti" (brief legacy)

Il brief <id> non contiene la sezione "Vincoli risolti".
Questo brief è stato generato prima di topology-canonical-002.
Procedo con lettura dei file di planning (modalità pre-topologia):
- <context-root>/00-context.md
- <context-root>/02-abstract.md
- <context-root>/technical-context.md
[warning non bloccante — continua]
```

## Check 2 — Stato del brief

Il brief (risolto al Check 1) deve essere in stato `active`. Status accettati:
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

Cercare il build command nella sezione "Vincoli risolti" del brief (stack/convenzioni). In fallback legacy: `technical-context.md` sezione "Convenzioni di progetto" → voce `build_command`.

Se assente:
```
⚠ Build command non dichiarato

Il brief non dichiara come buildare il progetto. La verifica build dopo
implementazione sarà saltata.

Suggerimento (non bloccante):
Dichiara il build command nella sezione "Vincoli risolti" del brief (stack),
es: `dotnet build`.

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

## Check 6 — Identificazione categoria + sample (informativo, non bloccante)

Identificare la categoria di costrutto dal brief (vedi tabella in `context-loading.md` § "Categoria del costrutto").
Cercare un sample esistente nel codebase (strategia: naming pattern per categoria, file più recente se più candidati).

Emettere gli artefatti di preflight (consumati da context-loading, **non ricalcolare lì**):
- **categoria**: categoria primaria identificata
- **sample-path**: path del sample trovato, oppure `nessuno`
- **file impattati**: lista già estratta dal brief (dai check 1/5)

Nel report preflight, aggiungere la riga:
```
ℹ Categoria: <categoria> | Sample: <path>    (se trovato)
ℹ Categoria: <categoria> | Sample: nessuno   (se non trovato)
```

Solo informativo — non chiede conferma, procede comunque.

## Ordine di esecuzione

I check vanno eseguiti in ordine. Al primo fallimento bloccante, si ferma e riporta. I check non-bloccanti (warning) accumulano messaggi che vanno mostrati prima di iniziare il flusso.

Output preflight ben formato:
```
Pre-flight checks per T-NNN:

✅ Brief trovato (context-root risolta)
✅ Sezione "Vincoli risolti" presente (reading-set ridotto)
✅ Brief in stato active
⚠ Build command non dichiarato (procedo senza verifica build)
✅ Directory riconosciuta come progetto
✅ File impattati: 3 [new], 2 [edit], nessun conflitto
ℹ Categoria: controller | Sample: src/Controllers/UsersController.cs

Procedo con context loading. Confermi?
```

L'utente conferma o annulla. Niente conferme intermedie ridondanti dopo questa.
