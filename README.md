# 🧰 Planning & Flow Toolkit — Guida per umani

Benvenuto. Questo plugin ti dà **una piccola squadra di sviluppo in miniatura** che vive dentro Claude Code.
Non sono persone vere (niente ferie, niente caffè), ma si comportano come una troupe ben organizzata: c'è chi pianifica, chi scrive le specifiche, chi scrive il codice e un capo-officina che li coordina senza farti impazzire.

L'idea di fondo è semplice:

> Tu dici **cosa** vuoi. La squadra si occupa del **come**, e ti disturba **solo** quando serve davvero una tua decisione.

Questa guida si legge dall'alto verso il basso. Se sei di fretta, salta dritto a **"Ricette pronte"**.

---

## 🆕 Novità 2.0.0

- **`planner` unificato a 4 tier**: le tre skill separate `project-planner`, `feature-planner` ed `epic-planner` sono state ritirate e sostituite da un unico entry-point `planner`. Scegli (o conferma) il tier — `project`, `epic`, `feature`, `task` — e lui si comporta di conseguenza.
- **Anchor system**: ogni artefatto di planning porta ora una riga `<!-- Anchor -->` con Tier, Parent e Bubble-up target — rende la gerarchia esplicita e machine-parsabile.
- **Bubble-up single-hop selettivo**: a task/feature conclusa, `planner finalize` promuove le decisioni tattiche durevoli al livello padre (feature → epic, epic → project), un solo salto alla volta, idempotente. Le feature successive le ereditano senza ri-elicitare.
- **`migrate anchor-retrofit`**: retrofitta gli anchor sugli artefatti esistenti (pre-2.0.0) in modalità preview → apply → post-verify, non distruttivo e idempotente.

---

## ⚠️ Aggiornare a 2.0.0 — breaking changes & migrazione

La **2.0.0** ritira le tre skill di planning separate. Se hai chiamato direttamente `project-planner`, `feature-planner` o `epic-planner` nei tuoi flussi o script, **sostituiscili con `planner`**.

**Cosa cambia:**
- `project-planner`, `feature-planner`, `epic-planner` **non esistono più**. Il loro trigger è assorbito da `planner` (anche le vecchie frasi di attivazione come *"feature-planner"* o *"epic-planner"* triggerano ancora `planner`).
- Il campo `Origin` nei brief ora è semplicemente `planner` (era `project-planner | feature-planner`).
- Il campo `Complessità (ipotesi)` nei task è **obbligatorio** nel tasks-file (era opzionale).

**Cosa NON cambia (back-compat):**
- I progetti pre-2.0.0 **continuano a funzionare**: anchor assente = artefatto standalone, nessun bubble-up. Nessuna rottura silenziosa.
- Il layout dei file (`docs/planning/`, `docs/features/`, `docs/epics/`) è invariato.
- I downstream (`task-implementer`, `code-implementer`, `flow-run`, `whats-next`) leggono gli stessi path di prima.

**Migrazione opt-in (anchor retrofit):**
Se vuoi aggiungere gli anchor ai tuoi artefatti pre-2.0.0:
1. *"anchor-retrofit preview"* → mostra cosa verrebbe iniettato, senza scrivere.
2. Confermi → *"anchor-retrofit apply"*: backup automatico, inject non distruttivo.
3. *"anchor-retrofit post-verify"*: verifica che ogni file abbia l'anchor corretto.

**Aggiornare da < 1.0.0** — prima fai la migrazione layout (vedi Ricetta I), poi l'anchor retrofit.

---

## 1. Chi c'è nella squadra

Immagina un piccolo studio di sviluppo. Otto ruoli, ognuno con un compito preciso:

| Ruolo (skill/agente) | Metafora | Cosa fa | Quando lo chiami |
|---|---|---|---|
| **planner** | L'architetto/geometra/direttore lavori in un unico cappello | Pianifica a qualsiasi livello: progetto intero, epic multi-feature, singola feature, singolo task atomico. Sceglie (e conferma con te) il tier giusto | Vuoi **pianificare qualcosa** — a qualsiasi scala |
| **task-implementer** (agente **PM**) | Il tech lead che scrive la scheda di lavoro | Prende un task e produce un **brief tecnico**: cosa toccare, come, con quali vincoli | Quasi sempre lo chiama il capo-officina per te |
| **code-implementer** (agente **DEV**) | Lo sviluppatore con le mani sulla tastiera | Legge il brief e **scrive il codice**, poi controlla che compili | Idem: di solito lo chiama il capo-officina |
| **flow-run** | Il **capo-officina / direttore d'orchestra** | Fa lavorare PM e DEV in sequenza, da solo, fermandosi solo quando serve te | Quando vuoi **andare in automatico** su un piano di task |
| **critical-flow-analysis** | L'**ispettore** che entra nel codice esistente con la torcia | Analizza a fondo un flusso già scritto, stila un referto di bug/debolezze e — se glielo chiedi — trasforma il piano di riparazione in task | Vuoi **scovare bug** in qualcosa che già esiste (e poi sistemarli col flow) |
| **whats-next** | Il **caposquadra** che guarda la lavagna e ti dice da dove ripartire | Legge tutti i piani attivi (progetto + feature), riconcilia lo stato reale e ti dice **cosa fare adesso** e perché — senza toccare niente | Hai tanti task aperti e non sai **qual è il prossimo passo** |
| **flow-sync** | Il **tecnico riparatore** che rimette in pari lavagna e schede | Riconcilia lo stato reale (`PROGRESS.json`) con i marker dei tasks-file: ripara i casi sicuri, importa i `done` mancanti, segnala gli ambigui | Lo stato "non torna" (tipico dopo un **expand**) e vuoi **riallinearlo** |
| **migrate** | Il tecnico del trasloco (e dell'etichettatura) | Porta un progetto dal vecchio layout al nuovo; e — da 2.0.0 — retrofitta gli anchor sugli artefatti pre-anchor | Hai un progetto pre-canonico o pre-2.0.0 da aggiornare |

Due cose da sapere subito:

- **PM e DEV non si parlano a voce.** Si lasciano bigliettini su disco (dei file). Nessun fraintendimento "ah ma io pensavo che…". Tutto è scritto.
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
  planning/              ← il piano di un PROGETTO INTERO (tier project di planner)
    00-context.md           contesto, assunzioni, rischi
    02-abstract.md          scelte tecniche di fondo
    05-tasks-active.md      i task della milestone attiva, chiamati T-001, T-002, …
    tasks/                  brief tecnici dei task di progetto
      T-001.md
      T-002.md
    (+ pitch, milestone, fasi)

  features/              ← una cartella per ogni FEATURE (tier feature di planner;
    <nome-feature>/          le figlie di un epic stanno QUI, col prefisso <epic>-…)
      00-context.md         contesto della feature
      02-abstract.md        approccio tecnico della feature
      technical-context.md  build, pattern, convenzioni da seguire
      tasks-active.md       i task, chiamati <nome-feature>-001, -002, …
      tasks/                brief tecnici dei task della feature
        <nome-feature>-001.md
        <nome-feature>-002.md

  epics/                 ← una cartella per ogni EPIC (tier epic di planner)
    <nome-epic>/             SOLO coordinamento, NON contiene task
      00-context.md         contesto d'insieme + assunzioni condivise
      02-abstract.md        decisioni tecniche condivise
      technical-context.md  seed condiviso (giù alle figlie + su dalle feature concluse via finalize)
      roadmap.md            ordine + dipendenze; Status feature auto-aggiornato dal flow

  tasks/                 ← un bundle per ogni TASK ATOMICO STANDALONE (tier task di planner)
    <nome-task>/
      00-context.md
      technical-context.md
      tasks-active.md       un solo task-entry

  archive/               ← feature/epic concluse (non partecipano allo scan dei task)
    features/<slug>/
    epics/<slug>/

.flow/                   ← la lavagna del capo-officina (stato del lavoro)
  sources/<slug>/           stato per-source (PROGRESS.json per ogni source attiva)
  locks/<slug>/             lock atomici POSIX per le source in esecuzione
  index.json                roll-up cached (ricostruibile da scan)
  briefs/<task>/            i bigliettini che PM e DEV si scambiano (puliti all'archivio)
```

Metafora: `docs/` è **l'archivio ufficiale** (la verità a lungo termine), `.flow/` è **la lavagna in officina** (lo stato del lavoro di oggi, cancellabile).

**Nota per i contributor**: tutti i path sotto `.flow/` sono stato effimero d'orchestrazione — non vanno versionati. Il `.gitignore` del plugin copre le voci `.flow/**`.

Il brief in `tasks/` è **self-sufficient**: il PM ha già distillato lì stack, librerie e convenzioni — il DEV non deve cercare altrove. I dettagli del meccanismo di risoluzione stanno in [`skills/planner/planning-source-contract.md`](skills/planner/planning-source-contract.md) § "Planning source contract".

---

## 4. Una regola d'oro: i nomi dei task

- Task di un **progetto** → si chiamano `T-001`, `T-002`, …
- Task di una **feature** → si chiamano `nomefeature-001` (es. `export-csv-001`)
- Task di un **task bundle** (tier task) → si chiamano `<slug>-001` (un solo task-entry per bundle)

Perché questi stili? Perché i nomi devono essere **unici come un codice fiscale**: è così che il sistema capisce, dato un task, **a quale piano appartiene** e dove andare a leggere il contesto. Niente nomi gemelli, niente confusione.

---

## 5. Quando (e perché) la squadra ti interrompe

Il bello del modo flow è che **non ti chiama per ogni sciocchezza**. È come un bravo collaboratore: risolve da solo il 90% delle cose e ti scrive solo per le 3 situazioni che richiedono te:

1. **"Devo uscire dal seminato"** — il task richiede di toccare un file non previsto, o di cambiare qualcosa di delicato (sicurezza, multi-tenant). → *Ti chiedo prima di farlo.*
2. **"Non compila e ci ho già riprovato"** — ha tentato di sistemare da solo un paio di volte, niente. → *Ti chiamo invece di accanirmi.*
3. **"Qui cambia un contratto"** — servirebbe una nuova libreria, un nuovo pattern, o si scontra con una scelta strategica già presa. → *Decidi tu, non improvviso.*

In tutti gli altri casi: silenzio operoso. 🤫

Quando ti interrompe, ti compare una **domanda con opzioni**: scegli, e il flow riprende da lì. Finché non rispondi, **non va avanti** (niente decisioni prese alle tue spalle).

---

## 6. I due "buttafuori" che proteggono il codice

Mentre il DEV lavora, due controlli automatici vegliano (si chiamano *hook*, ma pensali come due addetti alla sicurezza):

- 🚪 **Il buttafuori dello scope** (`scope-check`): controlla la lista degli invitati. Se il DEV prova a scrivere su un file **non previsto dal brief**, lo ferma e chiede il tuo permesso. Nessuno modifica file a caso.
- ✅ **Il controllo qualità all'uscita** (`verify-gate`): prima di considerare un task "finito", verifica che il lavoro sia davvero a posto (build verde). Se non lo è, **rimanda il DEV al banco** un paio di volte; se proprio non se ne esce, scala a te.

Regola di sicurezza di entrambi: **nel dubbio, chiedono.** Meglio una domanda in più che un disastro silenzioso.

---

## 6-bis. Lo sviluppatore "cambia marcia" da solo 🚗

Non tutti i lavori meritano lo stesso impegno. Per questo il DEV **non gira sempre sullo stesso modello**.

Funziona così, senza che tu debba pensarci:

- Quando il PM scrive la scheda di un task, **valuta anche quanto è impegnativo** (banale, normale, delicato) e lo annota in un bigliettino.
- Il capo-officina legge quel bigliettino e, **prima di mettere al lavoro il DEV**, sceglie il modello adatto: più leggero e veloce per le cose banali, più potente per quelle delicate.
- Nel dubbio fra due marce, **ingrana sempre la più alta**. E se il bigliettino manca, parte su un modello **affidabile di default** — mai al risparmio.

Il PM, invece, gira sempre sul suo modello fisso: lavora **prima** che la complessità sia nota.

> Dettagli esatti (quale complessità → quale modello): [`skills/flow-run/references/model-tiering.md`](skills/flow-run/references/model-tiering.md).

**E se voglio decidere io?** Puoi **forzare il modello** per un singolo run. Vedi la FAQ nel §10.

---

## 7. Ricette pronte 🍳

Esempi lineari. Le frasi tra virgolette sono **esattamente quello che scrivi** a Claude Code.

### Ricetta A — Parto con un progetto nuovo da zero
1. *"Ho un'idea per un progetto, aiutami a strutturarlo"* → parte **planner** (tier `project`), ti fa qualche domanda, crea `docs/planning/`.
2. *"Espandi la milestone M1 in task"* → genera i task `T-001`, `T-002`, …
3. Ora hai un piano. Vai alla Ricetta C per eseguirlo.

### Ricetta B — Aggiungo UNA feature a un progetto che esiste già ⭐ (il caso più comune)
1. *"Pianifica la feature: esportazione utenti in CSV"*
   → parte **planner** (tier `feature`, default). Sbircia il codice esistente per capire stack e convenzioni, ti fa **poche** domande mirate, e crea `docs/features/export-csv/` con 1–N task (`export-csv-001`, …).
2. Controlli al volo i task generati (sono in `docs/features/export-csv/tasks-active.md`).
3. Esegui con la Ricetta C o D.

> In una frase: il tier `project` **fonda una città**, il tier `feature` **apre un negozio in una via che c'è già**.

### Ricetta B-bis — Ho un lavoro GROSSO da spezzare in più feature ordinate 🏗️
1. *"Pianifica l'epic: rifacimento dell'area pagamenti"*
   → parte **planner** (tier `epic`). Sbircia il codice, ti fa poche domande e soprattutto ti propone una **decomposizione**: 2–6 feature logiche, in ordine, con le dipendenze tra loro. Tu confermi.
2. Materializza ogni feature come un bundle standard in `docs/features/<epic>-…/` (es. `payments-revamp-foundation`, `payments-revamp-api`, …) **più** una `roadmap.md` di coordinamento in `docs/epics/payments-revamp/`.
3. Da qui le feature sono normalissime: chiedi *"whats-next"* per sapere da quale partire (rispetta l'ordine dell'epic), poi esegui con la Ricetta C/D.
4. Mentre esegui, l'epic resta vivo: lo `Status feature` nella `roadmap.md` si aggiorna da solo (`⚪ planned → 🔵 active → ✅ done`); e a feature conclusa le decisioni tattiche **risalgono** al `technical-context.md` condiviso dell'epic via `planner finalize`.

> In una frase: il tier `feature` apre **un** negozio; il tier `epic` **pianifica un quartiere** di negozi nell'ordine giusto — ma senza fondare una città nuova (quello è il tier `project`).

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
2. L'ispettore ti chiede: *"Trasformo il piano in task operativi?"* — se dici **sì**, scrive un bundle in `docs/features/harden-login/` con i task (`harden-login-001`, …), già nel formato giusto.
3. Da qui è come una feature qualsiasi: *"avvia il flow"* (Ricetta C) o *"esegui solo harden-login-001"* (Ricetta D).

> In una frase: l'ispettore **fa la diagnosi**, e su tuo ok **scrive le ricette mediche** che poi il flow esegue. Lui non opera mai di testa sua. 🩺

### Ricetta G — Ho tanti task aperti e non so da dove ripartire 🧭
1. *"whats-next"* (oppure *"cosa devo fare adesso?"*)
   → parte **whats-next**. Guarda **tutti** i piani attivi (il progetto + le feature in parallelo), controlla cosa è davvero fatto e cosa no, e ti dà una **lavagna**: a che punto sei, cosa è sbloccato, cosa è quasi finito.
2. Ti propone 1–3 mosse **motivate** (es. *"chiudi la feature X che è all'88% e ferma"*, *"poi T-012 che ne sblocca altri 3"*), ognuna con il comando pronto.
3. Scegli tu. Copi il comando suggerito (es. *"esegui solo T-012"*) e parte la Ricetta D.
4. Puoi anche restringere: *"whats-next nella feature export-csv"* oppure *"whats-next nella milestone M1"*.

> In una frase: il caposquadra **non tocca niente e non decide al posto tuo** — ti dice solo dove sei e qual è la mossa più sensata adesso. 🧭

### Ricetta H — Lo stato "non torna" più: riallineo lavagna e schede 🔧
1. *"flow-sync"* (oppure *"riallinea lo stato"*, *"ripara il drift"*)
   → parte **flow-sync** in **preview**: ti mostra, task per task, cosa è in-sync, cosa riparerebbe (i casi sicuri), cosa importerebbe (`done` manuali mancanti) e cosa è ambiguo (lo segnala soltanto).
2. Se il piano ti convince: *"applica"* (apply). Scrive **solo** le righe Status sicure e gli import conservativi; gli **ambigui** non li tocca mai.
3. Caso tipico: dopo un *expand* (che riscrive i tasks-file e azzera i marker) lo stato del flow e le schede divergono → flow-sync li rimette in pari.

> In una frase: **whats-next** ti dice *che* lo stato è sfasato (e non tocca niente); **flow-sync** lo **rimette in sincrono** — i casi sicuri da solo, gli ambigui solo segnalandoli. 🔧

### Ricetta I — Migro un progetto otto dal vecchio al nuovo layout 📦

Utile quando hai un progetto otto già esistente con brief in `docs/tasks/` flat e vuoi portarlo al layout canonico.

1. *"migra il progetto"* → parte **migrate** in modalità **preview** (default).
   Elenca ogni brief che verrebbe spostato, dove va, e i casi ambigui (non verranno toccati).
   Non scrive nulla: è solo un piano.

2. Controlla il piano. Se ti convince: *"apply"*
   → backup automatico in `docs/.bak-<timestamp>/`, poi sposta i brief ai path canonici.
   Le source concluse finiscono in `docs/archive/features/<slug>/`.
   Niente commit automatici.

3. Dopo l'apply, esegui il **post-verify**: *"verifica la migrazione"*
   → per ogni ID, il resolver deve trovare il brief al path canonico. Report pass/fail.

> In una frase: **migrate** ti fa vedere il piano prima di muovere un file, sposta tutto con backup automatico, e ti conferma che ogni brief è atterrato dove deve. 📦

### Ricetta J — Retrofitto gli anchor a un progetto pre-2.0.0 🏷️

Utile quando hai artefatti di planning pre-2.0.0 senza la riga `<!-- Anchor -->` e vuoi abilitare il bubble-up di `planner finalize`.

1. *"anchor-retrofit preview"* → parte **migrate** in modalità anchor-retrofit.
   Mostra ogni file a cui verrebbe iniettato l'anchor (Tier, Parent, Bubble-up target inferiti dalla struttura), i già-anchored (skip) e gli ambigui (non toccati). Non scrive nulla.

2. Controlla il piano. Se ti convince: *"anchor-retrofit apply"*
   → backup automatico in `docs/.bak-<timestamp>/`, inject non distruttivo in ogni file candidato.

3. *"anchor-retrofit post-verify"* → verifica che ogni file abbia l'anchor corretto. Report pass/fail.

> Operazione completamente opt-in: i progetti senza anchor continuano a funzionare come prima (back-compat). Il retrofit aggiunge il bubble-up, non lo impone.

---

## 8. Il giro completo, in un disegno

```
        TU
        │  "pianifica la feature X"
        ▼
  ┌─────────────┐         crea i task in
  │   planner   │ ──────► docs/features/X/
  │  (4 tier)   │         (o docs/planning/ se tier project)
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
| **Skill** | Una "competenza" che Claude può attivare (`planner`, `flow-run`, ecc.) |
| **Tier** | Il livello di planning: `project` (progetto intero), `epic` (più feature ordinate), `feature` (singola funzionalità), `task` (deliverable atomico standalone) |
| **Subagent / agente** | Un collaboratore con **un solo compito** (il PM, il DEV) |
| **Brief** | La scheda di lavoro di un task: cosa fare e con quali paletti |
| **Scope** | La lista dei file che il DEV **ha il permesso** di toccare |
| **Hook** | Un controllo automatico che scatta da solo (i "buttafuori" del §6) |
| **Escalation** | Quando la squadra **ferma tutto e chiede a te** |
| **Context-root** | La cartella da cui si legge il contesto di un task (planning o feature) |
| **Anchor** | La riga `<!-- Anchor -->` in ogni artefatto di planning: dichiara Tier, Parent e Bubble-up target. Rende la gerarchia leggibile al sistema. |
| **Bubble-up** | A task/feature conclusa, le decisioni durevoli "risalgono" al livello padre via `planner finalize` — così le feature successive le ereditano senza ri-elicitare. |
| **PROGRESS.json** | La lavagna che dice "a che punto siamo" |
| **Attended / sorvegliato** | Automatico, ma pronto a chiamarti per le decisioni vere |
| **Brief self-sufficient** | Il brief scritto dal PM embedda già stack, librerie, pattern e naming: il DEV non ri-legge i file di planning |
| **Layout canonico** | Il modo "giusto" di organizzare i brief: ognuno sotto la sua feature, quelli delle feature concluse in `docs/archive/`. |

---

## 10. Domande frequenti (e inciampi tipici)

**"Ho lanciato il flow e si è fermato subito dicendo che manca qualcosa in `docs/planning/` o `docs/features/`."**
Probabile: stai eseguendo task di un piano che non esiste ancora. Usa prima `planner` (Ricetta A per un progetto, Ricetta B per una feature).

**"Ho scritto 'feature-planner' o 'project-planner' e non succede niente / succede una cosa strana."**
Da 2.0.0 quelle skill non esistono più. Le frasi di attivazione (`"feature-planner"`, `"epic-planner"`, `"project-planner"`) triggerano ancora `planner` — ma se usi la sintassi vecchia in script o hook, sostituiscila.

**"Il DEV ha saltato la verifica della build."**
Manca il `build_command`. Vive nel `technical-context.md` del piano/feature. `planner` prova a indovinarlo dal codice; se non ci riesce, scrivilo tu lì (es. `build_command: dotnet build`).

**"Mi ha chiesto conferma per scrivere un file che secondo me era ovvio."**
È il buttafuori dello scope che fa il suo lavoro: quel file non era nella lista del brief. O lo autorizzi al volo, o aggiorni il brief. Meglio così che ritrovarsi file modificati a sorpresa.

**"Posso usare il tier project e il tier feature sullo stesso progetto?"**
Sì. Stanno in cassetti diversi (`docs/planning/` vs `docs/features/<slug>/`) e non si pestano i piedi. Unico accorgimento: i nomi dei task restano unici (vedi §4).

**"Devo committare io o lo fa la squadra?"**
**Lo fai tu.** La squadra scrive codice e file, ma **non tocca git** di sua iniziativa. Il salvataggio definitivo resta una tua decisione.

**"Perché il DEV a volte usa un modello diverso?"**
Perché il modello viene scelto **in base a quanto è impegnativo il task**: il PM stima la complessità, il capo-officina sceglie di conseguenza. Così non sprechi un modello costoso per cambiare una virgola, né lasci un lavoro critico a uno troppo leggero. Nel dubbio, ingrana la marcia più alta; se la stima manca, parte su un default affidabile. Vedi §6-bis e [`skills/flow-run/references/model-tiering.md`](skills/flow-run/references/model-tiering.md).

**"Come forzo il modello per un run?"**
Dillo nella frase con cui lanci il task: *"esegui solo T-003 con opus"*. La tua scelta **vince su tutto** per quel singolo run.

**"Perché a volte il DEV salta il dry-run e va dritto a scrivere?"**
Il dry-run ha senso solo dove c'è il rischio concreto di doversi fermare prima di toccare il codice. Il capo-officina lo **salta sui task leggeri** e lo **tiene sui task critici**. Puoi forzare la mano: *"salta il dry-run"* / *"forza il dry-run"*.

**"Ho aggiornato a 2.0.0 e i miei vecchi brief hanno ancora `Origin: project-planner`."**
Funzionano ancora (back-compat). Se vuoi allinearli: apri i brief e cambia manualmente il campo in `Origin: planner`. Non è una rottura funzionale, solo una nota stilistica.

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

Da lì hai subito disponibili le skill (`planner`, `task-implementer`, `code-implementer`, `flow-run`, `critical-flow-analysis`, `flow-sync`, `whats-next`, `migrate`), i 2 agenti (`pm`, `dev`) e i 2 controlli automatici. Per partire ti basta una frase: *"pianifica la feature …"* oppure *"ho un'idea per un progetto"*.

> Nota tecnica (per chi pubblica): gli hook usano `${CLAUDE_PLUGIN_ROOT}`, quindi funzionano da qualunque path di installazione. Gli artefatti di lavoro (`docs/…`, `.flow/…`) vengono invece creati nella cartella del **tuo** progetto, dove devono stare.

### Permessi consigliati (meno prompt durante il flow)

Durante il flow gli agenti leggono e scrivono parecchi file. Senza configurazione, Claude Code ti chiede conferma a ogni operazione — rumoroso. Puoi togliere i prompt **ridondanti** aggiungendo questo blocco al `.claude/settings.json` **del tuo progetto**:

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

Cosa resta a chiederti conferma (ed è giusto così): le scritture del DEV **fuori** dallo scope del brief e i fallimenti di build/verify. Adatta la riga `Bash(...)` al build command del tuo progetto, o omettila se preferisci confermare la build a mano.

> `.flow/` è stato effimero: aggiungilo al `.gitignore` del progetto. Versiona invece `docs/planning/` e `docs/features/`: lì vive il piano, ed è conoscenza che vuoi tenere.

### Nome sessione & stato live del flow 🏷️

Quando un flow è in esecuzione, otto **rinomina la sessione** di Claude Code con un nome canonico — `otto:flow · <slug-source> [· <task>]` — così, con più finestre aperte, riconosci al volo quale sta eseguendo cosa (e imposta anche il titolo della tab del terminale). È automatico, via hook del plugin: nessuna configurazione.

> Come funziona: l'hook setta il nome su `SessionStart` e a ogni tuo prompt (`UserPromptSubmit`). Quindi è perfetto al **resume** di una sessione e quando interagisci, mentre durante un full-run lungo e silenzioso (un solo prompt iniziale) il nome non cambia tra un task e l'altro. Per lo **stato live continuo** usa la statusLine qui sotto.

Per un footer sempre aggiornato (source · task · avanzamento), abilita la statusLine **opt-in** nel `.claude/settings.json` del progetto:

```jsonc
{
  "statusLine": {
    "type": "command",
    "command": "\"${CLAUDE_PLUGIN_ROOT}\"/hooks/flow-statusline.sh",
    "refreshInterval": 2
  }
}
```

Mostra `⚙ otto:flow · <slug> · <task> · N/M done` solo quando un flow è vivo; riga vuota altrimenti. È opt-in perché la statusLine è una preferenza globale tua, non qualcosa che un plugin debba importi.
