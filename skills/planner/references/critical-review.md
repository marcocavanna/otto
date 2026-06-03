# Critical review

> Reference condiviso della skill `planner`. **Tier-agnostico**: i 9 pattern di rischio valgono per tutti i
> tier; cambia solo *quali* sono rilevanti per ciascuno — vedi § "Applicabilità per tier". Consumato dai
> reference tier-specifici `references/tier-{project,epic,feature,task}.md`.

Prima di generare gli artefatti, fai un passo critico sul contesto elicitato. Lo scopo è far emergere problemi *prima* che diventino piani sbagliati.

## Pattern di rischio da rilevare

Per ognuno, se rilevato, sollevarlo esplicitamente prima della generazione. Non addolcire. L'utente può comunque scegliere di procedere, ma la skill non passa avanti in silenzio.

### 1. Scope/effort mismatch

Calcola un effort grezzo dalla descrizione di B1+B2 e confrontalo con C1+C2.

- Se B2 (versione minima) sembra richiedere >40h di lavoro e C1 dichiara <5h/settimana e C2 deadline <2 mesi → **rosso**: deadline irrealistica.
- Se lo scope è una "piattaforma" / "ecosistema" / "marketplace" e l'esecutore è solo → **rosso**: scope strutturalmente incompatibile con executor singolo.

### 2. "Why now" debole

Se A3 ha risposta "niente di particolare" o "ci pensavo da tempo" → **giallo**: niente di pregiudiziale, ma segnala che non c'è urgenza esterna a spingere lo scope. Su scope personali questo è il principale predittore di abbandono.

### 3. Nessuna concorrenza dichiarata

Se A4 dice "niente esiste" e dopo probe l'utente conferma → **rosso**: nel 95% dei casi significa che non ha cercato. Suggerire 30min di research prima di procedere. Se persiste, marcare come assunzione esplicita rivedibile.

### 4. Nessuna esclusione di scope

Se B3 non ha prodotto almeno 2 esclusioni concrete → **rosso**: lo scope non ha confini e finirà per espandersi all'infinito. Non procedere senza esclusioni.

### 5. Stack-scope mismatch

Se D1 propone uno stack che non corrisponde a B1:
- Frontend pesante per CLI → mismatch
- Microservizi / Kubernetes per side project → over-engineering
- Stack che l'utente non conosce + deadline corta (C2) → rischio execution

### 6. Metrica di successo molle

Se E1 resta vaga dopo i probe ("se piace", "se funziona", "se lo finisco") → **giallo**: il piano si può comunque generare ma la milestone/feature finale non avrà un acceptance criterion misurabile. Segnalare.

### 7. Lock-in tecnologico su area ignota

Se D2 segnala >2 tecnologie nuove insieme → **giallo**: rischio di plateau di apprendimento concentrato. Suggerire di marcare le aree ignote per spike preliminari nei task del primo scope.

### 8. Mismatch budget/ambizione

Se C3 è zero o quasi e lo scope richiede infrastruttura significativa (DB managed, storage, CDN, ML inference) → **rosso**: rivedere stack o ridurre scope. Non procedere finché non risolto.

### 9. Scope già fallito una volta

Domanda implicita: se l'utente menziona spontaneamente "questa volta lo finisco" o "ci ho già provato" → **giallo**: chiedere cosa è andato storto prima e cosa è diverso ora. Inserire la risposta come constraint esplicito.

## Applicabilità per tier

Non tutti i pattern hanno senso a ogni tier: alcuni presuppongono blocchi di elicitation che ai tier inferiori non vengono raccolti (vedi `elicitation.md` § "Livello per tier"). Tabella di rilevanza:

| #  | Pattern                          | `project` | `epic` | `feature` | `task` |
|----|----------------------------------|:---------:|:------:|:---------:|:------:|
| 1  | Scope/effort mismatch            |     ✅    |   ✅   |     ✅    |   ✅   |
| 2  | "Why now" debole                 |     ✅    |   ✅   |     —     |   —    |
| 3  | Nessuna concorrenza dichiarata   |     ✅    |   ✅   |     —     |   —    |
| 4  | Nessuna esclusione di scope      |     ✅    |   ✅   |     ✅    |   ✅   |
| 5  | Stack-scope mismatch             |     ✅    |   ✅   |     ✅    |   —    |
| 6  | Metrica di successo molle        |     ✅    |   ✅   |     —     |   —    |
| 7  | Lock-in tecnologico su area ignota|    ✅    |   ✅   |     ✅    |   —    |
| 8  | Mismatch budget/ambizione        |     ✅    |   —    |     —     |   —    |
| 9  | Scope già fallito una volta      |     ✅    |   ✅   |     ✅    |   —    |

Sintesi operativa:
- **`project` / `epic`**: tutti i pattern rilevanti (l'epic eredita il budget dal progetto, quindi il #8 è in genere già risolto a monte).
- **`feature`**: pattern 1, 4, 5, 7, 9 — i pattern legati a pitch/market/success-metric (2, 3, 6) non si applicano perché quei blocchi non vengono elicitati.
- **`task`**: solo pattern 1 e 4 — l'unico rischio rilevante è che il singolo deliverable sia sovradimensionato (effort) o senza confini (scope).

## Formato dell'output critico

Presentare i problemi rilevati così:

```
Prima di generare, segnalo [N] punti:

🔴 [N problemi rossi] — bloccanti o quasi
1. [Problema concreto] — [una riga sul perché è un problema]

🟡 [N problemi gialli] — non bloccanti ma da considerare
1. [...]

Vuoi affrontare uno di questi prima di procedere, oppure procedo registrandoli come rischi noti nel piano?
```

L'utente decide se mitigare o procedere. Se procede, i problemi rossi/gialli vanno inseriti in `00-context.md` sezione "Known risks" e referenziati dove pertinente negli altri artefatti.
