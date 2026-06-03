# Elicitation

> Reference condiviso della skill `planner`. **Tier-agnostico**: i blocchi di domande sono gli stessi
> per tutti i tier; cambia solo la **profondità** (quali blocchi sono obbligatori) — vedi § "Livello di
> elicitation per tier". Consumato dai reference tier-specifici `references/tier-{project,epic,feature,task}.md`.

L'elicitation è la parte più importante della skill. Un'elicitation debole produce un piano pieno di filler. Una buona elicitation costringe l'utente a confrontarsi con i buchi nel proprio ragionamento *prima* di impegnarsi su una direzione.

## Regole

1. **Una domanda alla volta.** Mai raggruppare domande. Attendi la risposta, poi prosegui.
2. **Acknowledge breve, poi chiedi.** Non riformulare la risposta dell'utente per esteso. Una conferma di 1 riga basta.
3. **Sonda le risposte vaghe.** Se l'utente dice "una web app per gestire X", chiedi "web app per chi specificamente — quanti utenti, che device, che frequenza d'uso". Risposte vaghe producono piani vaghi.
4. **Marca i gap come assunzioni, non inventare.** Se dopo 2 probe l'utente genuinamente non sa, registra il gap come tracked assumption e prosegui. Non sintetizzare una risposta.

## Question sequence

Chiedi in quest'ordine. Salta una domanda solo se l'utente l'ha già coperta spontaneamente. Il **set obbligatorio dipende dal tier** (vedi tabella in fondo): ai tier inferiori alcuni blocchi si riducono o saltano.

### Block A — Problema e motivazione (obbligatorio per tutti i tier tranne `task`)

A1. **In una frase, qual è il problema concreto che lo scope risolve?**
*Probe se vago:* "Per chi specificamente? Quando si manifesta questo problema?"

A2. **Per chi è? Descrivi un utente tipo realistico — non personas astratte.**
*Probe se vago:* "Sei tu l'utente? Conosci personalmente persone con questo problema? Quante?"

A3. **Perché *adesso*? Cosa è cambiato che lo rende sensato oggi e non 2 anni fa?**
*Probe se vago:* "Se la risposta è 'niente', si può comunque andare avanti ma è un segnale. Procediamo o vuoi rifletterci?"

A4. **Cosa esiste già che risolve un problema simile? Perché non basta?** *(rilevante per `project`/`epic`; advisory per `feature`)*
*Probe se "niente":* "Davvero niente? Cerchiamo insieme 2-3 alternative prima di procedere — uno scope senza riferimenti è quasi sempre mal definito."

### Block B — Forma e scope (obbligatorio per `project`/`epic`/`feature`)

B1. **Che forma ha il prodotto/deliverable? Web app, mobile, CLI, libreria, estensione, desktop, modulo, altro?** *(per `epic`/`feature` su progetto esistente: che forma ha l'incremento — endpoint, modulo, flusso UI, ecc.)*
*Se l'utente non sa:* proponi 2-3 alternative con trade-off basati su A1-A2. Marca come assunzione.

B2. **Qual è il *minimo* per cui lo scope è utile? Descrivi in 2 righe la versione più piccola che useresti tu stesso.**
*Probe se troppo ampio:* "Questo non è minimo. Se ti togliessi metà, cosa resterebbe di indispensabile?"

B3. **Cosa è esplicitamente *fuori scope*? Cosa decidi di non fare anche se sembra ovvio farlo?**
*Se "niente è fuori scope":* "Questo è un red flag. Senza esclusioni esplicite lo scope cresce fino a non finire mai. Forza almeno 2 esclusioni."

### Block C — Vincoli di execution (obbligatorio per `project`/`epic`)

C1. **Quanto tempo puoi dedicarci realisticamente a settimana?** (ore concrete, non "il tempo libero")

C2. **Entro quando vuoi/devi avere qualcosa di utile? Hai una deadline reale o auto-imposta?**

C3. **Budget per servizi/infrastruttura? Anche zero è una risposta valida.**

### Block D — Stack e competenze (obbligatorio per `project`; advisory per `epic`/`feature`)

D1. **Hai già in mente lo stack tecnico? Se sì, quale e perché.** *(per `epic`/`feature`: lo stack è in genere già fissato dal progetto — qui basta validare la coerenza con lo scope.)*
*Se sì:* validare se è coerente con B1 e C. Se incoerente, sollevare il problema.
*Se no:* proporre 2-3 alternative basate su contesto, marcare come assunzione.

D2. **Ci sono tecnologie/pattern dello stack proposto che non hai mai usato in produzione?**
*Se sì:* segnalare come area di rischio per l'abstract tecnico.

### Block E — Definizione di successo (obbligatorio per `project`; opzionale per `epic`)

E1. **Come saprai che lo scope è "riuscito"? Metrica concreta, non "se la gente lo usa".**
*Esempi di metriche concrete:* "10 utenti che lo usano almeno 1 volta a settimana", "io stesso lo uso quotidianamente per 1 mese", "supera N richieste al giorno", "lo pubblico e ottiene 50 stars".
*Se la risposta è "se piace":* spingere per qualcosa di misurabile.

E2. **Cosa fai se dopo 3 mesi non hai raggiunto il successo definito in E1?** (questa domanda non serve per il piano, serve a forzare onestà sulle aspettative)

### Block F — Distribuzione (opzionale, solo `project`)

F1. **Come arrivano gli utenti al prodotto?** Solo se il prodotto è user-facing e non è solo per te.

F2. **C'è un modello di business o è puramente personal/open-source?**

## Livello di elicitation per tier

La sequenza di domande è unica; il tier seleziona la profondità. Più si scende nella gerarchia (`project` ⊃ `epic` ⊃ `feature` ⊃ `task`), più l'elicitation si riduce — perché il contesto strategico è già fissato dal padre.

| Tier      | Blocchi obbligatori        | Blocchi opzionali / advisory | Note                                                                                  |
|-----------|----------------------------|------------------------------|---------------------------------------------------------------------------------------|
| `project` | A, B, C, D, E              | F                            | Elicitation completa: pitch, mercato, stack, metrica di successo.                     |
| `epic`    | A, B (focus decomposizione)| C, D, E                      | A4/E ridotti; focus sul confine tra le feature figlie e sul tronco comune.            |
| `feature` | A (A1-A3), B (scope)        | D (solo stack-check)         | No pitch/market/success-metric elaborati: lo stack è ereditato dal progetto.          |
| `task`    | scope + output atteso      | dipendenze                   | Elicitation minima: cosa fa, da cosa dipende, output atteso. Vedi `../task-bundle-spec.md`. |

> Tier `task`: non si passa per i blocchi A-F. Si raccolgono solo scope, dipendenze e output atteso del singolo deliverable — il resto è ereditato dal parent (vincolo strutturale del bundle leggero, `../task-bundle-spec.md`).

## End of elicitation

Quando tutti i blocchi obbligatori **per il tier** sono coperti, riassumi al volo (max 10 righe) e chiedi:

> "Ho questo quadro. Prima di generare i documenti, voglio segnalarti [N] punti che vedo come potenzialmente problematici: [...]. Vuoi rivedere qualcosa o procedo?"

Vedi `critical-review.md` per i punti da sollevare (con l'applicabilità per tier).

## Tracked assumptions

Per ogni risposta "non lo so" + scelta proposta dalla skill, registra come:

```
ASSUMPTION-<slug>-NNN: [descrizione]
  Scelta: [opzione scelta]
  Alternative valutate: [altre opzioni con trade-off]
  Impatta: [lista artefatti che dipendono — es. 02-abstract.md, tasks-active.md]
  Status: active | superseded
  Data: [YYYY-MM-DD]
```

Queste assunzioni vanno in `00-context.md` sezione "Tracked assumptions" della source del tier corrente.
