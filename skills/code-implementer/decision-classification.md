# Decision classification

Criteri operativi per distinguere decisioni **cross-task** (chiedere prima), **locali meritevoli di trace** (annotare dopo), e **rumore** (nessuna traccia).

## Principio guida

L'obiettivo è la **tracciabilità utile**, non la verbosità. Una decisione viene annotata solo se serve a qualcosa nel futuro. Test mentale per ogni decisione:

> "Se tra 3 mesi io o un altro sviluppatore leggessimo questo T-NNN.md per capire come è stato fatto questo task, questa decisione sarebbe utile saperla?"

Se sì → annotare (o chiedere, se cross-task).
Se no → silenzio.

## Categoria 1: Decisioni CROSS-TASK (chiedi PRIMA di scrivere)

Rientrano qui scelte che hanno effetti **oltre il task corrente**. Per ognuna, la skill blocca il flusso, propone 2-3 alternative con trade-off, e attende risposta.

### 1.1 Nuova libreria/pacchetto

Trigger: il task richiede una funzionalità per cui serve una dipendenza non già in `technical-context.md` § "Librerie e versioni".

Esempio:
```
Per gestire la mappatura DTO ↔ Entity nel task T-008 non c'è una libreria
ancora in technical-context.md. Propongo:

a) AutoMapper 13.0.1 — convenzionale, molto usato, configurazione esterna
b) Mapster 7.4.0 — più veloce, configurazione fluent
c) Mapping manuale (no lib) — zero dipendenze, più codice ripetitivo

Mio default: (b) per progetti nuovi, (a) se hai familiarità più alta.

Quale uso?
```

### 1.2 Nuovo pattern architetturale

Trigger: il task richiede un pattern che non è già adottato (non presente in `technical-context.md` § "Pattern architetturali").

Esempio: primo uso di MediatR, primo Command/Query split, primo Outbox pattern, prima introduzione di Specification, ecc.

### 1.3 Nuovo Value Object o tipo di dominio

Trigger: il task introduce un VO che non è già in `technical-context.md` § "Value Objects".

La skill non lo introduce silenziosamente — chiede:
```
Il task richiede di rappresentare [concetto X]. Propongo di introdurlo come VO:

  public sealed record [Name]
  {
      // shape proposta
  }

Questo VO entrerà in technical-context.md e sarà usato da [stima task futuri
che lo userebbero, basato su brief o intuizione].

Confermo l'introduzione? Oppure preferisci tenerlo locale (solo primitivo
o classe interna al task)?
```

### 1.4 Nuova convenzione

Trigger: il task richiede una scelta di naming/struttura che andrebbe estesa al resto del codebase.

Esempio: convenzione di error response, convenzione di naming dei file di test, convenzione di organizzazione cartelle.

### 1.5 Decisione che contraddice/estende planning

Trigger: la skill identifica che il modo "naturale" di scrivere il codice richiederebbe di violare o estendere qualcosa già scritto in `02-abstract.md` o `technical-context.md`.

In questo caso, **non basta chiedere**: serve indirizzare a `revise` se il vincolo strategico va modificato.

```
⛔ Conflitto strategico durante implementazione

Per implementare T-NNN nel modo che il brief suggerisce, dovrei [X], ma:
- 02-abstract.md esclude esplicitamente [X] (vedi sezione "Esclusioni tecniche")

Opzioni:
a) Rivedere 02-abstract.md con `planner revise` — strategico
b) Rivedere il brief T-NNN.md con task-implementer — tattico
c) Riformulare l'implementazione per evitare [X] (la skill propone alternativa)

Non procedo finché non scegli.
```

## Categoria 2: Decisioni LOCALI MERITEVOLI DI TRACE (annota DOPO)

Scelte interne al task ma con valore documentale. La skill scrive il codice, poi mostra la decisione all'utente per conferma e annota nelle Deviazioni.

### 2.1 Adattamento della shape del brief

Trigger: lo shape code del brief è stato adattato per ragioni emerse in implementazione.

Esempio:
- Brief prevedeva `User.Create(string email)`, implementazione richiede `User.Create(Email email, UserId? id = null)` perché il sample usa sempre questa convenzione
- Brief prevedeva costruttore con 2 dipendenze, ne è servita una terza

### 2.2 Scelta non banale di edge case

Trigger: il task ha un edge case non coperto dal brief e la scelta tra approcci alternativi è significativa.

Esempio:
- Cosa fare se il parametro è null vs vuoto vs whitespace
- Cosa restituire se l'entità non esiste (eccezione vs Result.NotFound vs null)
- Come gestire timeout su chiamate esterne

### 2.3 Scelta di struttura interna significativa

Trigger: una scelta strutturale interna al file che influenza la leggibilità o estensibilità futura.

Esempio:
- Estrarre un helper privato in una classe statica vs metodo locale
- Usare pattern matching vs switch tradizionale per logica complessa
- Inlining vs estrazione di metodo

### 2.4 Deviazione dal sample

Trigger: il sample esistente usa uno stile/pattern che è stato consapevolmente NON replicato.

Esempio:
```
Decisione locale annotata:
Il sample UsersController.cs usa attributi di routing su ogni action.
Per il nuovo OrdersController ho usato attributi sulla classe + override
sui method specifici, perché [motivo].

Andrà nelle Deviazioni di T-NNN.md? (sì/no)
```

Questo tipo richiede sempre validazione utente — è una deliberata divergenza stilistica.

## Categoria 3: RUMORE (nessuna traccia)

Decisioni che NON vanno annotate:

### 3.1 Sintassi pura
- Ordine degli `using`/`import`
- Formattazione (allineamenti, spazi)
- Trailing newlines
- Quote singole vs doppie

### 3.2 Decisioni dettate banalmente dal contesto
- `async/await` invece di `.Result` (è ovvio)
- `IEnumerable<T>` vs `IReadOnlyList<T>` come return type (scelta convenzionale)
- Uso di nameof() invece di stringhe per nomi di proprietà
- `var` vs tipo esplicito

### 3.3 Già dichiarato nel brief
- Tutto ciò che il brief già specifica non è una deviazione, è esecuzione del brief

### 3.4 Fix banali durante scrittura
- Typo corretti mentre scrivi
- Off-by-one fix
- Missing using/import aggiunti

### 3.5 Scelte di test interne
A meno che la convenzione di test sia esplicitamente parte di una decisione cross-task (categoria 1.4), le scelte di:
- Organizzazione assert
- Nomi dei test method
- Setup vs costruttore vs IClassFixture
sono rumore.

## Flusso decisionale durante implementazione

Per ogni decisione che emerge mentre la skill ragiona sul codice da scrivere:

```
Decisione emerge
  ↓
È in Categoria 1 (cross-task)?
  Sì → STOP scrittura, chiedi all'utente con alternative + trade-off
       Risposta → procedi + annota in T-NNN.md (Deviazioni) + technical-context.md
  No → continua
  ↓
È in Categoria 2 (locale meritevole)?
  Sì → scrivi il codice, poi al termine mostra all'utente per conferma
       Se conferma → annota in T-NNN.md (Deviazioni)
       Se non vale la pena → silenzio
  No → silenzio (Categoria 3)
```

## Soglia di sensibilità

Per Categoria 2, applicare il test mentale:
> "Se cambio idea tra 3 mesi e voglio fare diversamente, mi serve sapere che ho fatto questa scelta consapevolmente?"

Se la risposta è "ovvio, lo rifarei uguale": silenzio.
Se la risposta è "mh, potrei rifare diversamente": annota.

Nel dubbio → preferire silenzio. È più facile aggiungere una nota mancante che ripulire un T-NNN.md gonfio di micro-decisioni.

## Limite duro

Massimo decisioni cross-task chieste per task: **3**. Se ne emergono più, è un segno che:
- Il brief è inadeguato → suggerire all'utente di rivederlo con `task-implementer`
- Il task è troppo grande → suggerire di splittare con `planner`
- Il planning generale è incompleto → suggerire revise

In quel caso:
```
⚠ Troppe decisioni cross-task emerse

Ho identificato 4 decisioni cross-task per questo task. Tipicamente significa:
- Il brief T-NNN è incompleto (mancano scelte tattiche)
- Il task copre troppo scope

Suggerimento: ferma l'implementazione, torna a task-implementer brief T-NNN
per esplicitare queste scelte nel brief, poi riprendi implementazione.

Decisioni emerse:
1. [...]
2. [...]
3. [...]
4. [...]

Procedo comunque o fermo?
```
