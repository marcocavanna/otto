# Writing rules

Regole operative per la scrittura effettiva del codice. Cosa scrivere, come, dove fermarsi.

## Principio base: mimic > template

Quando esiste un sample dell'area, **lo stile del sample vince sui template** di `technical-context.md`, eccetto per decisioni esplicitamente vincolanti (naming, pattern strategici).

Ordine di precedenza:
1. **Vincoli strategici** (02-abstract.md) — assoluti, non negoziabili
2. **Vincoli tattici espliciti** (technical-context.md, voci dichiarate) — non negoziabili
3. **Stile del sample** — vince su tutto il resto
4. **Template generici** — solo se nessun sample disponibile
5. **Best practice del linguaggio/framework** — fallback ultimo

Se in conflitto: vince il livello più alto. Se sample contraddice technical-context: technical-context vince (sample obsoleto, andrà segnalato).

## Scope di scrittura

La skill scrive **solo** i file dichiarati in "File impattati" del brief, eccetto due eccezioni esplicitamente consentite:

### Eccezione 1: Registrazione DI/routing

Se il task crea un nuovo costrutto che richiede registrazione (es. nuovo `IRepository` da registrare in `IServiceCollection`, nuova route, nuovo handler), la skill **può** modificare il file di registrazione anche se non è in "File impattati".

Vincoli:
- Solo file standard di registrazione (Program.cs, Startup.cs, AppModule.ts, ecc.)
- Modifica minima: solo l'aggiunta necessaria, niente refactoring
- Esplicitato nella sezione Deviazioni come "Modifica DI/routing fuori da File impattati"

### Eccezione 2: File di configurazione strettamente necessari

Se il task richiede una configurazione (es. connection string, setting in appsettings.json, env var), la skill **può** aggiungerla.

Vincoli:
- Mai sovrascrivere valori esistenti
- Mai inserire valori sensibili (passwords, API keys reali) — usa placeholder
- Esplicitato in Deviazioni

### Tutto il resto: non si tocca

In particolare:
- NON modificare altri costrutti per "uniformità" (refactoring fuori scope)
- NON aggiornare README/CHANGELOG (non è scope di questa skill)
- NON modificare file di test esistenti (a meno che il brief lo richieda)
- NON modificare file di altri task non finalizzati

## Stile del codice

### Mimicare il sample (se presente)

Estrarre dal sample:
- **Struttura file**: ordine delle dichiarazioni (using → namespace → class → fields → ctor → methods)
- **Pattern di DI**: costruttore esplicito vs property injection
- **Async/await**: ovunque async vs solo dove serve
- **Naming locali**: convenzioni di parametri (`_dbContext` vs `dbContext`, `cancellationToken` vs `ct`)
- **Error handling**: Result<T> vs eccezioni vs return null
- **Documentazione**: XML doc / JSDoc / nessuno
- **Test naming**: `Method_Scenario_Expected` vs `Should_X_When_Y` vs altro

### Quando il sample è inadeguato

Se il sample ha pratiche che la skill ritiene **palesemente errate** (es. campi public mutabili in domain entity, eccezioni come flow control quando convenzione è Result<T>), NON replicarle.

Trattare come decisione locale meritevole di trace (categoria 2.4): scrivere diversamente, annotare la divergenza.

## Commenti nel codice

Default: **commenti scarsi**. Il codice deve spiegarsi da sé.

Commentare solo:
- Algoritmi non ovvi
- Workaround che sembrerebbero strani senza spiegazione
- Decisioni controintuitive con rimando a contesto:
  ```csharp
  // Usiamo UTC esplicito qui (non DateTime.Now) per coerenza con
  // ASSUMPTION-014 in 00-context.md
  ```

NON commentare:
- "Costruttore" sopra il costruttore
- "Getter per X" sopra le proprietà
- Codice ovvio per chi conosce il framework
- TODO/FIXME (vanno tracciati nelle Deviazioni o subtask futuri, non lasciati nel codice)

## Test

La skill scrive test **solo se** il brief li dichiara esplicitamente in "File impattati" o "Test minimo".

Default: niente test prodotti dalla skill. Motivo: test scritti da skill rischiano di essere superficiali ("testa che la classe esiste") o sbagliati. Meglio nessun test che test falsi-positivi.

Se il brief richiede test:
- Stile mimicato da test esistenti (se presenti)
- Coperti gli scenari del "Test minimo" del brief
- Niente test extra "per completezza"
- Test fallible (assert sostanziali, no `Assert.True(true)`)

## Limiti di scrittura

### Limite di righe per file

Soft limit: 300 righe per file. Hard limit: 500.

Se il task richiede di scrivere più di 300 righe in un singolo file:
```
⚠ File generato grande

Sto per scrivere [N] righe in [filename]. Soft limit: 300.

Tipicamente significa:
- Il task è troppo grande (rivedi splitting in project-planner)
- Il costrutto andrebbe spezzato in più file (es. classe parziale, helper)

Procedo comunque o suggerisci diverso?
```

Solo informativo, non bloccante. L'utente decide.

### Limite di file scritti

Soft limit: 6 file per esecuzione di `implement T-NNN`. Hard limit: 10.

Se brief dichiara più di 6 file:
```
ℹ Task con molti file ([N])

Il brief dichiara [N] file impattati. Tipicamente significa task di setup
iniziale o task large. Procedo come previsto.
```

Solo informativo.

## Cosa fare se durante scrittura emerge un blocco

Se durante la generazione del codice la skill rileva che **non può procedere** (es. mancano informazioni non emerse al context loading, sample troppo divergente, brief contraddittorio):

```
⛔ Blocco durante scrittura

[Descrizione precisa]

Sto fermando l'esecuzione. File scritti finora: [N] su [M previsti].

Opzioni:
a) [opzione concreta 1]
b) [opzione concreta 2]
```

NON tentare di "indovinare" per sbloccare. Fermarsi è meno costoso di scrivere codice sbagliato che poi devi rifare.

## File appena scritti vs file esistenti

Per i file `[new]`:
- Sono nuovi, la skill ha pieno controllo
- Devono compilare in isolamento (dipendenze coerenti)

Per i file `[edit]`:
- La skill ha letto il file in context loading
- Modifica solo le sezioni necessarie (usa str_replace per precisione)
- NON riscrive l'intero file per "uniformità"
- Mantiene formatting esistente del file (anche se diverge dal sample)

In particolare, **non riformattare** un file durante un `[edit]` — la modifica deve essere la minima richiesta dal task. Refactoring è scope diverso.
