# Brief elicitation

Elicitation per generare un brief tecnico di un singolo task. **Più breve** dell'elicitation di project-planner — sono già disponibili contesto strategico e tattico nei file di planning.

## Pre-requisiti di lettura

Prima di chiedere qualsiasi cosa all'utente, leggere:
1. `docs/planning/00-context.md` — assunzioni e rischi del progetto
2. `docs/planning/02-abstract.md` — stack, pattern strategici, esclusioni
3. `docs/planning/technical-context.md` — decisioni tattiche già prese (se esiste)
4. `docs/planning/05-tasks-active.md` — il task in oggetto + task vicini

Dopo la lettura, fare una sintesi mentale di:
- Cosa è già deciso (non da rimettere in discussione)
- Cosa è genuinamente aperto per questo task
- Quali decisioni di altri task vicini sono rilevanti come dipendenze

## Quando NON chiedere

Non chiedere all'utente cose che sono **già nei file letti**. Esempio:
- ❌ "Quale ORM uso?" → se è in `technical-context.md` o `02-abstract.md`, è già deciso
- ❌ "Quale convenzione di naming?" → se è già stabilita, applicala
- ❌ "Dove metto i file?" → se la struttura cartelle è già definita, seguila

Se una decisione esiste già, riprenderla nel brief con un riferimento esplicito (`vedi technical-context.md sezione X`).

## Quando chiedere

Chiedere solo per ciò che è genuinamente non risolto dal contesto disponibile. Esempi tipici:

1. **Libreria specifica non ancora scelta**. Es. lo stack dichiara ".NET 9 + EF Core" ma non si è mai parlato di password hashing. Proporre 2-3 alternative con trade-off corti.

2. **Pattern non ancora applicato in nessun task precedente**. Es. primo task che richiede error handling — proporre approccio (Result<T>, eccezioni, ecc.) e marcarlo come decisione che entrerà in `technical-context.md`.

3. **Assunzione operativa locale**. Es. "L'email è case-sensitive o normalizziamo a lowercase?" — domanda piccola ma con impatto su validation/query.

4. **Trade-off di scope locale**. Es. "Implementiamo paginazione ora o lasciamo a un task futuro?" — quando il task ha confini sfumati con i vicini.

## Regole

1. **Una domanda alla volta**. Mai batch.
2. **Massimo 3-4 domande per brief**. Se ne servono di più, è segno che il task è troppo grande o il contesto strategico è incompleto. Suggerire revise di project-planner.
3. **Proporre sempre opzioni**, non chiedere domande aperte. "Quale libreria di hashing usiamo?" è sbagliato. "Per password hashing propongo: a) BCrypt.Net-Next, b) ASP.NET Core Identity PasswordHasher, c) Argon2. Mio default: (b) perché già parte del runtime. Confermi o preferisci alternativa?" è giusto.
4. **Probe le risposte vaghe**. Se l'utente dice "boh, scegli tu", la skill può scegliere ma deve dichiararlo esplicitamente nel brief come assunzione locale, non come decisione condivisa.

## Conflitto rilevato durante elicitation

Se durante l'analisi emerge che una decisione di `02-abstract.md` è inadeguata per questo task (es. l'abstract dice "no real-time" ma il task lo richiede), **fermare il flusso**:

```
⛔ Conflitto strategico rilevato.

T-NNN richiede [X], ma 02-abstract.md ha esplicitamente escluso [X]
(vedi sezione "Esclusioni tecniche").

Due opzioni:
a) Rivedere 02-abstract.md con project-planner (revise) prima di procedere
b) Riformulare il task per evitare [X]

Non procedo finché non hai deciso.
```

Non aggirare mai un'esclusione strategica con una decisione tattica.

## End of elicitation

Quando le domande sono coperte, **non** chiedere "vuoi che generi?". Generare direttamente il brief. L'utente lo legge e dice se va bene; se serve revisione, lo chiede esplicitamente.

L'unica eccezione: se l'analisi ha portato a una decisione che va in `technical-context.md` e l'utente non ha confermato esplicitamente. In quel caso una conferma secca prima di scrivere: "Confermo che [decisione] entra in technical-context.md? (sì/no)".
