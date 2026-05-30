# 🧰 Planning & Flow Toolkit — Guida per umani

Benvenuto. Questo plugin ti dà **una piccola squadra di sviluppo in miniatura** che vive dentro Claude Code.
Non sono persone vere (niente ferie, niente caffè), ma si comportano come una troupe ben organizzata: c'è chi pianifica, chi scrive le specifiche, chi scrive il codice e un capo-officina che li coordina senza farti impazzire.

L'idea di fondo è semplice:

> Tu dici **cosa** vuoi. La squadra si occupa del **come**, e ti disturba **solo** quando serve davvero una tua decisione.

Questa guida si legge dall'alto verso il basso. Se sei di fretta, salta dritto a **"Ricette pronte"**.

---

## 1. Chi c'è nella squadra

Immagina un piccolo studio di sviluppo. Otto ruoli, ognuno con un compito preciso:

| Ruolo (skill/agente) | Metafora | Cosa fa | Quando lo chiami |
|---|---|---|---|
| **project-planner** | L'architetto che progetta una casa da zero | Trasforma un'idea grezza in un piano completo: pitch, milestone, fasi, task | Stai partendo con un **progetto nuovo** |
| **feature-planner** | Il geometra che progetta **una stanza in più** in una casa già costruita | Pianifica **una singola feature** su un progetto **esistente** → uno o più task, niente milestone | Vuoi aggiungere **una cosa specifica** a qualcosa che c'è già |
| **task-implementer** (agente **PM**) | Il tech lead che scrive la scheda di lavoro | Prende un task e produce un **brief tecnico**: cosa toccare, come, con quali vincoli | Quasi sempre lo chiama il capo-officina per te |
| **code-implementer** (agente **DEV**) | Lo sviluppatore con le mani sulla tastiera | Legge il brief e **scrive il codice**, poi controlla che compili | Idem: di solito lo chiama il capo-officina |
| **flow-run** | Il **capo-officina / direttore d'orchestra** | Fa lavorare PM e DEV in sequenza, da solo, fermandosi solo quando serve te | Quando vuoi **andare in automatico** su un piano di task |
| **critical-flow-analysis** | L'**ispettore** che entra nel codice esistente con la torcia | Analizza a fondo un flusso già scritto, stila un referto di bug/debolezze e — se glielo chiedi — trasforma il piano di riparazione in task | Vuoi **scovare bug** in qualcosa che già esiste (e poi sistemarli col flow) |
| **whats-next** | Il **caposquadra** che guarda la lavagna e ti dice da dove ripartire | Legge tutti i piani attivi (progetto + feature), riconcilia lo stato reale e ti dice **cosa fare adesso** e perché — senza toccare niente | Hai tanti task aperti e non sai **qual è il prossimo passo** |
| **flow-sync** | Il **tecnico riparatore** che rimette in pari lavagna e schede | Riconcilia lo stato reale (`PROGRESS.json`) con i marker dei tasks-file: ripara i casi sicuri, importa i `done` mancanti, segnala gli ambigui — senza decidere al posto tuo | Lo stato "non torna" (tipico dopo un **expand**) e vuoi **riallinearlo** |

Due cose da sapere subito:

- **PM e DEV non si parlano a voce.** Si lasciano bigliettini su disco (dei file). È una scelta voluta: così non ci sono fraintendimenti "ah ma io pensavo che…". Tutto è scritto.
- **Nessuno chiama altri collaboratori di nascosto.** Il capo-officina coordina PM e DEV, e basta. Niente catene infinite di assistenti che spawnano altri assistenti come gremlins bagnati.

---

## 2. I due modi di lavorare

### Modo manuale (guidi tu, passo per passo)
Come cucinare seguendo la ricetta a mano: fai un passo, guardi il risultato, fai il prossimo.
Utile quando stai imparando o vuoi controllo totale.

### Modo flow (pilota automatico "sorvegliato")
Il capo-officina (`flow-run`) fa girare tutto da solo. Tu vai a prenderti il caffè.
Ti richiama **solo** se c'è una vera decisione da prendere (vedi §5).

> "Sorvegliato" (in inglese *attended*) vuol dire: automatico **ma con un adulto responsabile in casa**. Non è "parti e prega".

---

## 3. Dove finiscono le cose (gli schedari)

Ogni cosa ha il suo cassetto. Non devi toccarli a mano, ma sapere dove stanno aiuta.

```
docs/
  planning/              ← il piano di un PROGETTO INTERO (lo crea project-planner)
    00-context.md           contesto, assunzioni, rischi
    02-abstract.md          scelte tecniche di fondo
    05-tasks-active.md      i task, chiamati T-001, T-002, …
    (+ pitch, milestone, fasi)

  features/              ← una cartella per ogni FEATURE (la crea feature-planner)
    <nome-feature>/
      00-context.md         contesto della feature
      02-abstract.md        approccio tecnico della feature
      technical-context.md  build, pattern, convenzioni da seguire
      tasks-active.md       i task, chiamati <nome-feature>-001, -002, …

  tasks/                 ← i "brief" tecnici, uno per task (li scrive il PM)
    <id-task>.md

.flow/                   ← la lavagna del capo-officina (stato del lavoro)
  PROGRESS.json             a che punto siamo
  briefs/<task>/            i bigliettini che PM e DEV si scambiano
```

Metafora: `docs/` è **l'archivio ufficiale** (la verità a lungo termine), `.flow/` è **la lavagna in officina** (lo stato del lavoro di oggi, cancellabile).

---

## 4. Una regola d'oro: i nomi dei task

- Task di un **progetto** → si chiamano `T-001`, `T-002`, …
- Task di una **feature** → si chiamano `nomefeature-001` (es. `export-csv-001`)

Perché due stili? Perché i nomi devono essere **unici come un codice fiscale**: è così che il sistema capisce, dato un task, **a quale piano appartiene** e dove andare a leggere il contesto. Niente nomi gemelli, niente confusione.

---

## 5. Quando (e perché) la squadra ti interrompe

Il bello del modo flow è che **non ti chiama per ogni sciocchezza**. È come un bravo collaboratore: risolve da solo il 90% delle cose e ti scrive solo per le 3 situazioni che richiedono te:

1. **"Devo uscire dal seminato"** — il task richiede di toccare un file che non era previsto, o di cambiare qualcosa di delicato (sicurezza, multi-tenant). → *Ti chiedo prima di farlo.*
2. **"Non compila e ci ho già riprovato"** — ha tentato di sistemare da solo un paio di volte, niente. → *Ti chiamo invece di accanirmi.*
3. **"Qui cambia un contratto"** — servirebbe una nuova libreria, un nuovo pattern, o si scontra con una scelta strategica già presa. → *Decidi tu, non improvviso.*

In tutti gli altri casi: silenzio operoso. 🤫

Quando ti interrompe, ti compare una **domanda con opzioni**: scegli, e il flow riprende da lì. Finché non rispondi, **non va avanti** (niente decisioni prese alle tue spalle).

---

## 6. I due "buttafuori" che proteggono il codice

Mentre il DEV lavora, due controlli automatici vegliano (si chiamano *hook*, ma pensali come due addetti alla sicurezza):

- 🚪 **Il buttafuori dello scope** (`scope-check`): controlla la lista degli invitati. Se il DEV prova a scrivere su un file **non previsto dal brief**, lo ferma e chiede il tuo permesso. Nessuno modifica file a caso.
- ✅ **Il controllo qualità all'uscita** (`verify-gate`): prima di considerare un task "finito", verifica che il lavoro sia davvero a posto (build verde). Se non lo è, **rimanda il DEV al banco** un paio di volte; se proprio non se ne esce, scala a te.

Regola di sicurezza di entrambi: **nel dubbio, chiedono.** Meglio una domanda in più che un disastro silenzioso. (Il principio in gergo si chiama *fail-closed*; tu chiamalo pure "prudenza".)

---

## 7. Ricette pronte 🍳

Esempi lineari. Le frasi tra virgolette sono **esattamente quello che scrivi** a Claude Code.

### Ricetta A — Parto con un progetto nuovo da zero
1. *"Ho un'idea per un progetto, aiutami a strutturarlo"* → parte **project-planner**, ti fa qualche domanda, crea `docs/planning/`.
2. *"Espandi la milestone M1 in task"* → genera i task `T-001`, `T-002`, …
3. Ora hai un piano. Vai alla Ricetta C per eseguirlo.

### Ricetta B — Aggiungo UNA feature a un progetto che esiste già ⭐ (il caso più comune)
1. *"Pianifica la feature: esportazione utenti in CSV"*
   → parte **feature-planner**. Sbircia il codice esistente per capire stack e convenzioni, ti fa **poche** domande mirate, e crea `docs/features/export-csv/` con 1–N task (`export-csv-001`, …).
2. Controlli al volo i task generati (sono in `docs/features/export-csv/tasks-active.md`).
3. Esegui con la Ricetta C o D.

> Differenza con la Ricetta A in una frase: project-planner **fonda una città**, feature-planner **apre un negozio in una via che c'è già**.

### Ricetta C — Eseguo tutto il piano in automatico
1. *"Avvia il flow"*
2. Vai a prenderti il caffè. ☕
3. Il capo-officina fa girare PM→DEV su ogni task, uno dopo l'altro.
4. Se ti compare una domanda (vedi §5), rispondi e riprende. Altrimenti, a fine giro ti dà il riepilogo.

### Ricetta D — Eseguo UN SOLO task
1. *"Esegui solo export-csv-001"*
2. Fa girare PM→DEV su quel singolo task e si ferma. Utile per andarci coi piedi di piombo o testare.

### Ricetta E — Voglio guidare io, passo per passo (modo manuale)
1. *"Fai il brief tecnico di export-csv-001"* → il PM scrive il brief.
2. *"Fai un dry-run di export-csv-001"* → il DEV ti mostra cosa **farebbe**, senza scrivere nulla.
3. *"Implementa export-csv-001"* → il DEV scrive il codice e verifica la build.
4. *"Finalizza export-csv-001"* → si chiude il task come si deve.

### Ricetta F — Ho un flusso esistente che fa le bizze: trova i bug e sistemali 🔦
1. *"Analizza il flusso di login partendo da `AuthService.cs`"*
   → parte **critical-flow-analysis**. Legge il codice (senza toccarlo!), ricostruisce il flow vero e ti dà un **referto**: bug critici, bug logici, flussi incoerenti, codice debole + un piano di riparazione a "ondate" (wave).
2. L'ispettore ti chiede: *"Trasformo il piano in task operativi?"* — se dici **sì**, scrive un bundle in `docs/features/harden-login/` con i task (`harden-login-001`, …), uno per riparazione, già nel formato giusto.
3. Da qui è come una feature qualsiasi: *"avvia il flow"* (Ricetta C) o *"esegui solo harden-login-001"* (Ricetta D) e la squadra mette in sicurezza il codice.

> In una frase: l'ispettore **fa la diagnosi**, e su tuo ok **scrive le ricette mediche** che poi il flow esegue. Lui non opera mai di testa sua. 🩺

### Ricetta G — Ho tanti task aperti e non so da dove ripartire 🧭
1. *"whats-next"* (oppure *"cosa devo fare adesso?"*)
   → parte **whats-next**. Guarda **tutti** i piani attivi (il progetto + le feature in parallelo), controlla cosa è davvero fatto e cosa no, e ti dà una **lavagna**: a che punto sei, cosa è sbloccato, cosa è quasi finito.
2. Ti propone 1–3 mosse **motivate** (es. *"chiudi la feature X che è all'88% e ferma"*, *"poi T-012 che ne sblocca altri 3"*), ognuna con il comando pronto.
3. Scegli tu: la scelta "spingo il progetto o chiudo una feature?" resta tua. Copi il comando suggerito (es. *"esegui solo T-012"*) e parte la Ricetta D.
4. Puoi anche restringere: *"whats-next nella feature export-csv"* oppure *"whats-next nella milestone M1"*.

> In una frase: il caposquadra **non tocca niente e non decide al posto tuo** — ti dice solo dove sei e qual è la mossa più sensata adesso. 🧭

### Ricetta H — Lo stato "non torna" più: riallineo lavagna e schede 🔧
1. *"flow-sync"* (oppure *"riallinea lo stato"*, *"ripara il drift"*)
   → parte **flow-sync** in **preview**: ti mostra, task per task, cosa è in-sync, cosa riparerebbe (i casi sicuri), cosa importerebbe (`done` manuali mancanti) e cosa è ambiguo (lo segnala soltanto).
2. Se il piano ti convince: *"applica"* (apply). Scrive **solo** le righe Status sicure e gli import conservativi; gli **ambigui** non li tocca mai.
3. Caso tipico: dopo un *expand* (che riscrive i tasks-file e azzera i marker) lo stato del flow e le schede divergono → flow-sync li rimette in pari.

> In una frase: **whats-next** ti dice *che* lo stato è sfasato (e non tocca niente); **flow-sync** lo **rimette in sincrono** — i casi sicuri da solo, gli ambigui solo segnalandoli. 🔧

---

## 8. Il giro completo, in un disegno

```
        TU
        │  "pianifica la feature X"
        ▼
  ┌─────────────┐         crea i task in
  │ feature-    │ ──────► docs/features/X/
  │  planner    │         (o project-planner → docs/planning/)
  └─────────────┘
        │  "avvia il flow"
        ▼
  ┌──────────────────────── flow-run (capo-officina) ──────────────────────────┐
  │                                                                            │
  │   per ogni task:                                                           │
  │                                                                            │
  │     ┌────┐  scrive brief + regole   ┌─────────────────┐                    │
  │     │ PM │ ───────────────────────► │  file su disco  │                    │
  │     └────┘                          │   (.flow/…)     │                    │
  │                                     └─────────────────┘                    │
  │                                              │ legge                       │
  │                                              ▼                             │
  │                                          ┌─────┐  scrive codice            │
  │                                          │ DEV │ ──► (solo file permessi)  │
  │                                          └─────┘                           │
  │                                              │                             │
  │                            tutto ok? ───────► sì → prossimo task           │
  │                                  │                                         │
  │                                  └─ no (3 casi del §5) ─► CHIEDE A TE      │
  └────────────────────────────────────────────────────────────────────────────┘
```

---

## 9. Mini-dizionario (senza paroloni)

| Parola che sentirai | Traduzione in umano |
|---|---|
| **Skill** | Una "competenza" che Claude può attivare (project-planner, ecc.) |
| **Subagent / agente** | Un collaboratore con **un solo compito** (il PM, il DEV) |
| **Brief** | La scheda di lavoro di un task: cosa fare e con quali paletti |
| **Scope** | La lista dei file che il DEV **ha il permesso** di toccare |
| **Hook** | Un controllo automatico che scatta da solo (i "buttafuori" del §6) |
| **Escalation** | Quando la squadra **ferma tutto e chiede a te** |
| **Context-root** | La cartella da cui si legge il contesto di un task (planning o feature) |
| **PROGRESS.json** | La lavagna che dice "a che punto siamo" |
| **Attended / sorvegliato** | Automatico, ma pronto a chiamarti per le decisioni vere |

---

## 10. Domande frequenti (e inciampi tipici)

**"Ho lanciato il flow e si è fermato subito dicendo che manca qualcosa in `docs/planning/`."**
Probabile: stai eseguendo task di progetto ma non hai ancora il piano. Usa prima project-planner (Ricetta A) o, se è una feature, feature-planner (Ricetta B).

**"Il DEV ha saltato la verifica della build."**
Manca il `build_command`. Vive nel `technical-context.md` del piano/feature. feature-planner prova a indovinarlo dal codice; se non ci riesce, scrivilo tu lì (es. `build_command: dotnet build`).

**"Mi ha chiesto conferma per scrivere un file che secondo me era ovvio."**
È il buttafuori dello scope che fa il suo lavoro: quel file non era nella lista del brief. O lo autorizzi al volo, o aggiorni il brief. Meglio così che ritrovarsi file modificati a sorpresa.

**"Posso usare project-planner e feature-planner sullo stesso progetto?"**
Sì. Stanno in cassetti diversi (`docs/planning/` vs `docs/features/<slug>/`) e non si pestano i piedi. Unico accorgimento: i nomi dei task restano unici (vedi §4).

**"Devo committare io o lo fa la squadra?"**
**Lo fai tu.** La squadra scrive codice e file, ma **non tocca git** di sua iniziativa. Il salvataggio definitivo resta una tua decisione.

**"C'è una cartella `.flow/` con dentro `T-SMOKE`. Che roba è?"**
È un task-giocattolo usato per i test interni. Innocuo. Se ti dà fastidio: cancella `.flow/` e via.

---

## 11. La regola che riassume tutto

> **Tu decidi il "cosa" e le scelte importanti. La squadra fa il "come" e ti chiama solo quando conta.**

Se ti ricordi solo questa frase e le quattro ricette del §7, sei operativo. Il resto è dettaglio che imparerai usandolo.

Buon lavoro — e se la squadra fa una domanda, non è perché è confusa: è perché ha trovato qualcosa che merita la tua testa. 🧠

---

## Appendice — Installare otto 🛩️

`otto` è un plugin Claude Code. Una volta che è in una repo (o in un marketplace interno):

```
/plugin marketplace add marcocavanna/otto    # registra la sorgente
/plugin install otto                         # installa il plugin
```

Da lì hai subito disponibili le 8 skill (`project-planner`, `feature-planner`, `task-implementer`, `code-implementer`, `flow-run`, `critical-flow-analysis`, `flow-sync`, `whats-next`), i 2 agenti (`pm`, `dev`) e i 2 controlli automatici. Per partire ti basta una frase: *"pianifica la feature …"* oppure *"ho un'idea per un progetto"*.

> Nota tecnica (per chi pubblica): gli hook usano `${CLAUDE_PLUGIN_ROOT}`, quindi funzionano da qualunque path di installazione. Gli artefatti di lavoro (`docs/…`, `.flow/…`) vengono invece creati nella cartella del **tuo** progetto, dove devono stare.

### Permessi consigliati (meno prompt durante il flow)

Durante il flow gli agenti leggono e scrivono parecchi file. Senza configurazione, Claude Code ti chiede conferma a ogni operazione — rumoroso. Puoi togliere i prompt **ridondanti** (non il controllo: le scritture fuori-scope e il verify restano gatati dagli hook) aggiungendo questo blocco al `.claude/settings.json` **del tuo progetto**:

```jsonc
{
  "permissions": {
    "allow": [
      "Read", "Glob", "Grep",                // le letture sono sempre innocue
      "Edit(docs/**)", "Write(docs/**)",     // planner e PM scrivono qui
      "Edit(.flow/**)", "Write(.flow/**)",   // stato del flow
      "Bash(<tuo-build-command>:*)"          // es. dotnet build, npm run build…
    ]
  }
}
```

Cosa resta a chiederti conferma (ed è giusto così): le scritture del DEV **fuori** dallo scope del brief e i fallimenti di build/verify — cioè le sole vere decisioni del modo *attended*. Adatta la riga `Bash(...)` al build command del tuo progetto, o omettila se preferisci confermare la build a mano.

> `.flow/` è stato effimero: aggiungilo al `.gitignore` del progetto. Versiona invece `docs/planning/` e `docs/features/`: lì vive il piano, ed è conoscenza che vuoi tenere.
