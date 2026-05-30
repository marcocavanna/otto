# Elicitation

The elicitation phase is the most important part of the skill. A weak elicitation produces a plan full of filler. A good elicitation forces the user to confront gaps in their thinking *before* they commit to a direction.

## Rules

1. **One question at a time.** Never batch questions. Wait for the answer, then move on.
2. **Acknowledge briefly, then ask.** Don't reformulate the user's answer back at length. A 1-line confirmation is enough.
3. **Probe vague answers.** If the user says "una web app per gestire X", ask "web app per chi specificamente — quanti utenti, che device, che frequenza d'uso". Vague answers produce vague plans.
4. **Mark gaps as assumptions, don't invent.** If after 2 probes the user genuinely doesn't know, log the gap as a tracked assumption and move on. Do not synthesize an answer.

## Question sequence

Ask in this order. Skip a question only if the user has already answered it spontaneously.

### Block A — Problem and motivation (mandatory)

A1. **In una frase, qual è il problema concreto che il progetto risolve?**
*Probe se vago:* "Per chi specificamente? Quando si manifesta questo problema?"

A2. **Per chi è? Descrivi un utente tipo realistico — non personas astratte.**
*Probe se vago:* "Sei tu l'utente? Conosci personalmente persone con questo problema? Quante?"

A3. **Perché *adesso*? Cosa è cambiato che rende questo progetto sensato oggi e non 2 anni fa?**
*Probe se vago:* "Se la risposta è 'niente', il progetto può comunque andare avanti ma è un segnale. Procediamo o vuoi rifletterci?"

A4. **Cosa esiste già che risolve un problema simile? Perché non basta?**
*Probe se "niente":* "Davvero niente? Cerchiamo insieme 2-3 alternative prima di procedere — un progetto senza concorrenza è quasi sempre un progetto mal definito."

### Block B — Forma del prodotto e scope (mandatory)

B1. **Che forma ha il prodotto? Web app, mobile, CLI, libreria, estensione browser, desktop, altro?**
*Se l'utente non sa:* proponi 2-3 alternative con trade-off basati su A1-A2. Marca come assunzione.

B2. **Qual è il *minimo* per cui il progetto è utile? Descrivi in 2 righe la versione più piccola che useresti tu stesso.**
*Probe se troppo ampio:* "Questo non è minimo. Se ti togliessi metà delle feature, cosa resterebbe di indispensabile?"

B3. **Cosa è esplicitamente *fuori scope*? Cosa decidi di non fare anche se sembra ovvio farlo?**
*Se "niente è fuori scope":* "Questo è un red flag. Senza esclusioni esplicite il progetto cresce fino a non finire mai. Forza almeno 2 esclusioni."

### Block C — Vincoli di execution (mandatory)

C1. **Quanto tempo puoi dedicarci realisticamente a settimana?** (ore concrete, non "il tempo libero")

C2. **Entro quando vuoi/devi avere qualcosa di utile? Hai una deadline reale o auto-imposta?**

C3. **Budget per servizi/infrastruttura? Anche zero è una risposta valida.**

### Block D — Stack e competenze (mandatory)

D1. **Hai già in mente lo stack tecnico? Se sì, quale e perché.**
*Se sì:* validare se è coerente con B1 e C. Se incoerente, sollevare il problema.
*Se no:* proporre 2-3 alternative basate su contesto, marcare come assunzione.

D2. **Ci sono tecnologie/pattern dello stack proposto che non hai mai usato in produzione?**
*Se sì:* segnalare come area di rischio per l'abstract tecnico.

### Block E — Definizione di successo (mandatory)

E1. **Come saprai che il progetto è "riuscito"? Metrica concreta, non "se la gente lo usa".**
*Esempi di metriche concrete:* "10 utenti che lo usano almeno 1 volta a settimana", "io stesso lo uso quotidianamente per 1 mese", "supera N richieste al giorno", "lo pubblico su GitHub e ottiene 50 stars".
*Se la risposta è "se piace":* spingere per qualcosa di misurabile.

E2. **Cosa fai se dopo 3 mesi non hai raggiunto il successo definito in E1?** (questa domanda non serve per il piano, serve a forzare onestà sulle aspettative)

### Block F — Distribuzione (opzionale, chiedere solo se rilevante)

F1. **Come arrivano gli utenti al prodotto?** Solo se il prodotto è user-facing e non è solo per te.

F2. **C'è un modello di business o è puramente personal/open-source?**

## End of elicitation

Quando tutti i blocchi mandatory sono coperti, riassumi al volo (max 10 righe) e chiedi:

> "Ho questo quadro. Prima di generare i documenti, voglio segnalarti [N] punti che vedo come potenzialmente problematici: [...]. Vuoi rivedere qualcosa o procedo?"

Vedi `critical-review.md` per i punti da sollevare.

## Tracked assumptions

Per ogni risposta "non lo so" + scelta proposta dalla skill, registra come:

```
ASSUMPTION-001: [descrizione]
  Scelta: [opzione scelta]
  Alternative valutate: [altre opzioni con trade-off]
  Impatta: [lista artefatti che dipendono — es. 02-abstract.md, 03-milestones.md]
  Status: active | superseded
  Data: [YYYY-MM-DD]
```

Queste assunzioni vanno in `00-context.md` sezione "Tracked assumptions".
