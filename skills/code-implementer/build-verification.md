# Build verification

Strategia di verifica build dopo scrittura del codice. Obiettivo: catch immediato di errori triviali, senza degenerare in loop di auto-fix.

## Pre-requisito

Build command deve essere dichiarato in `technical-context.md` § "Convenzioni di progetto":

```markdown
### Build & test
- build_command: `dotnet build`
- test_command: `dotnet test` (opzionale, non usato da code-implementer)
```

Se assente: skip verifica con warning (vedi `preflight.md` check 3).

## Flusso

```
1. Codice scritto
   ↓
2. Esegui build_command
   ↓
3. Exit code 0?
   Sì → ✅ Build OK
   No → vai a 4
   ↓
4. Parse output errori
   ↓
5. Errori sono "triviali" e fixabili?
   (typo, using mancante, namespace, signature mismatch ovvio)
   Sì → tenta fix
   No → ferma e riporta all'utente
   ↓
6. Re-run build_command
   ↓
7. Exit code 0?
   Sì → ✅ Build OK dopo retry
   No → ferma e riporta TUTTI gli errori
```

**Limite duro: 1 retry.** Mai più di un tentativo di auto-fix.

## Cosa conta come "errore triviale fixabile"

Auto-fix consentito solo per:

1. **Using/import mancanti**: la skill conosce i namespace standard del progetto (da sample e technical-context) e può aggiungere using mancanti.

2. **Typo evidenti in identificatori**: solo se l'errore segnala chiaramente "did you mean X?" con un solo candidato vicino.

3. **Signature mismatch ovvio**: es. metodo che ritorna `Task<T>` ma chiamato senza `await`. Solo se la correzione è univoca.

4. **Missing semicolons / parentesi sbilanciate**: errori di sintassi causati da edit incompleto.

5. **Namespace errato**: file in cartella X con `namespace Y` quando convenzione vuole `namespace X`.

## Cosa NON è auto-fixabile

Fermare e riportare all'utente per:

1. **Errori semantici**: il tipo X non implementa l'interfaccia Y, l'override non è compatibile
2. **Ambiguità**: più candidati per la stessa correzione
3. **Errori in file non scritti dalla skill**: se la build fallisce in un file che la skill non ha toccato, è regressione di altro codice — non fixare
4. **Errori di dipendenza**: pacchetto non installato, riferimento NuGet mancante
5. **Errori di configurazione**: csproj/json/yaml mal formati
6. **Più di 5 errori di compilazione**: alta probabilità che il problema sia strutturale, non triviale

## Reporting degli errori

Quando si ferma (errori non auto-fixabili o post-retry):

```
🔴 Build fallita dopo retry

Errori rimanenti:

[file:line] [codice errore]
> [messaggio errore]
> [contesto codice intorno alla riga, 3 righe sopra e 3 sotto]

[ripeti per ogni errore, max 10 mostrati. Se >10, "...e altri N errori"]

Cosa fare:
- Se l'errore è in codice che ho scritto: dimmi cosa correggere
- Se è in codice esistente del progetto: probabilmente regressione, verifica
- Se vuoi che riproponga una shape diversa: dimmi quale errore ti preoccupa
  e propongo alternativa

Lo stato attuale è:
- File scritti: [lista]
- Decisioni annotate: [se già fatte]
- T-NNN.md aggiornato: [sì/no]
- technical-context.md aggiornato: [sì/no]
```

## Reporting del successo

Build OK al primo tentativo:
```
✅ Build OK
[build_command] exited 0 in [Xs]
```

Build OK dopo retry:
```
✅ Build OK dopo 1 fix automatico
[build_command] exited 0 in [Xs]
Fix applicato: [descrizione concisa, es: "Aggiunto using Microsoft.Extensions.Logging in OrderService.cs"]

Il fix automatico viene annotato come decisione locale rumore (non in Deviazioni).
```

## Output di build verbose

Se il build_command produce output molto verboso, la skill estrae solo:
- Exit code
- Linee con `error CS`, `error TS`, `Error:` (case-insensitive)
- Linee con `warning` di alta severità (CS8xxx in C#, ts strict mode in TS)

Non mostrare warning di basso livello nella response — solo se rilevanti.

## Edge case: build_command non eseguibile

Se il comando fallisce non per errore di compilazione ma per errore di esecuzione (toolchain non installata, path sbagliato, permission denied):

```
⚠ Impossibile eseguire build_command

Comando: `[build_command]`
Errore: [stderr]

Possibili cause:
- Toolchain non installata
- Comando obsoleto in technical-context.md
- Working directory sbagliata

Procedo segnando build come "skipped" — verifica tu manualmente.
```

Non considerare questo un fallimento del task. Procedere con il reporting normale, segnando build come `skipped`.

## Cosa fare con i file scritti se la build fallisce

**Non fare rollback automatico.** I file restano scritti come sono. Motivazione:
- Il rollback è invasivo e può cancellare lavoro utile
- L'utente potrebbe voler manualmente sistemare il piccolo errore residuo
- Il vcs (git) è il sistema di rollback corretto, non la skill

La skill **dichiara esplicitamente** lo stato:
```
Stato dopo build fallita:
- File scritti rimangono sul filesystem
- Decisioni cross-task confermate: aggiornate in technical-context.md
- Decisioni locali: NON annotate (in attesa di build OK)
- T-NNN.md: NON aggiornato

Quando la build sarà OK (manuale o successiva implement), puoi rieseguire
implement T-NNN per finalizzare l'annotazione.
```

Questo lascia il sistema in uno stato consistente e recuperabile.
