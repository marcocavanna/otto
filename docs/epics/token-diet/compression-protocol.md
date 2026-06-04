# Compression protocol — Epic: Token diet (`token-diet`)

> **Single-source.** Questo documento definisce il protocollo obbligatorio di compressione, il metodo
> di estrazione della checklist edge-case e i criteri del gate di accettazione per tutte le feature
> dell'epic `token-diet`. Ogni feature consuma queste regole senza ridefinirle.
>
> Linkato da: `docs/epics/token-diet/technical-context.md` · `docs/features/token-diet-foundation/technical-context.md`

---

## 1. Protocollo di compressione (5 step obbligatori)

### Step 1 — Estrai la checklist edge-case

Prima di toccare il testo, estrai dal file **originale** la lista completa delle regole, eccezioni,
degradi conservativi e casi limite. Questa checklist è il riferimento del gate (step 4) e **non**
viene modificata dopo l'estrazione.

Ogni voce della checklist deve essere:
- atomica (un comportamento o una regola per riga),
- descrittiva in modo da essere ritrovabile nel testo compresso senza match lessicale esatto,
- etichettata con un identificativo progressivo (`EC-001`, `EC-002`, ...) per citabilità nel gate report.

Vedi §2 per il metodo di estrazione dettagliato.

### Step 2 — Riscrivi: potatura + prosa EN + struttura a liste

Applica in un'unica passata le tre trasformazioni:

**Potatura** — elimina:
- filler e ridondanze ("è importante notare che", "come indicato sopra", "assicurarsi di");
- paragrafi che ripetono quanto già espresso altrove nello stesso file;
- esempi narrativi sostituibili da un pattern (un esempio strutturale vale più di due esempi narrativi);
- intestazioni di sezione vuote o decorative.

**Prosa EN** — riscrivi la prosa esplicativa in inglese:
- usa English tecnico diretto (forma imperativa o dichiarativa, niente subordinate inutili);
- target: frasi ≤ 20 parole per il 90% delle istruzioni operative;
- non tradurre le trigger-phrase (vedi step 3).

**Struttura a liste** — converti in bullet/lista ogni sequenza di passi o condizioni:
- procedure → lista numerata;
- condizioni / vincoli → lista puntata;
- tabelle per mapping multi-attributo (es. segnale → azione).

### Step 3 — Preserva le trigger-phrase verbatim

Le trigger-phrase contenute nella `description` (e le occorrenze funzionali nel body) **non si
traducono e non si comprimono**. Definizione operativa:

> Una trigger-phrase è qualunque stringa che Claude Code usa per il match di attivazione della
> skill/agent: frasi riportate come esempi di invocazione utente, parole chiave citate nell'elenco
> "Triggers on phrases like …", o sequenze token citate come input attesi.

Regola pratica: se rimuovere o modificare la stringa può cambiare *quali* prompt utente attivano la
skill, la stringa è una trigger-phrase — lasciala invariata.

### Step 4 — Gate di accettazione

Dopo la riscrittura, esegui il gate in quest'ordine. Il gate è **bloccante**: se una voce fallisce,
il task non è `done`.

1. **Checklist coverage** — per ogni voce `EC-NNN`: il comportamento/regola è ritrovabile nel testo
   riscritto? La ricerca è semantica, non lessicale: parafrasi e struttura a lista valgono come match.
   Esito ammesso: `OK` / `MANCANTE` / `DEGRADATO` (presente ma meno preciso).
   Soglia: zero voci `MANCANTE`; le voci `DEGRADATO` richiedono giustificazione esplicita.

2. **Diff semantico** — confronta le sezioni ad alto rischio (escalation, biforcazioni, degradi
   conservativi, contratti machine-readable) tra originale e riscritto. Documenta le differenze
   rilevate. Esito ammesso: `INVARIATO` / `EQUIVALENTE` (forma diversa, comportamento identico) /
   `DIVERGENTE`.
   Soglia: zero sezioni `DIVERGENTE`.

3. **Delta token** — esegui `python3 scripts/measure-tokens.py --delta` dopo aver salvato la baseline
   pre-riscrittura con `--save`. Registra i valori:
   - `delta_desc`: variazione token `description` (negativo = riduzione).
   - `delta_body`: variazione token body.
   - `delta_%`: percentuale di riduzione su totale artefatto.
   Soglia minima attesa: riduzione ≥ 20% sul totale dell'artefatto (description + body).
   Soglia bloccante: delta **positivo** (aumento di token) → task non accettabile senza giustificazione.

### Step 5 — Annota, non correggere

Se durante la riscrittura emergono ambiguità, inconsistenze o probabili bug nell'originale:
- **non correggerli** (fuori scope dell'epic);
- aggiungi una nota a fine file riscritto nella sezione `## Compression notes`:
  ```
  ## Compression notes
  - [NOTA] <descrizione dell'anomalia rilevata nel file originale>
  ```
- segnalala nel task brief sotto "Deviazioni".

---

## 2. Metodo di estrazione della checklist edge-case

### Quando estrarre

Prima di qualunque modifica al file (step 1 del protocollo). L'estrazione avviene sull'**originale**,
non su copie intermedie.

### Cosa catturare

Scansiona il file originale cercando esplicitamente:

| Segnale testuale | Tipo di voce |
|---|---|
| "NON fare", "mai", "vietato", "evitare" | Vincolo negativo |
| "se … allora … altrimenti" / "se non" | Branch / condizionale |
| "solo se", "tranne se", "eccetto" | Eccezione a regola generale |
| "in caso di errore / fallimento / retry" | Degrado conservativo |
| "L2 / L3", "escalation", "promote" | Canale di uscita dal happy path |
| Sezioni "Override", "Eccezioni", "Quando NON" | Edge-case espliciti |
| Valori soglia numerici (es. "> 6 file", "≤ 2 retry") | Invariante quantitativa |
| Schema JSON / contratti (campi obbligatori, enum validi) | Contratto machine-readable |

### Formato voce

```
EC-NNN | <file>:<sezione> | <descrizione comportamento/regola in ≤ 20 parole>
```

Esempio:
```
EC-001 | flow-run/SKILL.md:§dry-run | NON eseguire scritture in dry-run; tutte le operazioni sono simulate
EC-002 | flow-run/SKILL.md:§retry   | Massimo 2 retry interni prima di escalation L2
```

### Output dell'estrazione

Salva la checklist in un file temporaneo o sezione di lavoro (non committato) durante la riscrittura;
include il conteggio totale voci nel gate report.

---

## 3. Criteri del gate di accettazione

### Gate report obbligatorio

Per ogni task di riscrittura (feature successive alla foundation), il brief `docs/tasks/<id>.md` deve
includere una sezione `## Gate report` con:

```
### Gate report — <artefatto>

Baseline pre-riscrittura: <data/commit>
Checklist edge-case: <N> voci estratte

| EC | Esito | Note |
|----|-------|------|
| EC-001 | OK | |
| EC-002 | EQUIVALENTE | Lista puntata sostituisce il paragrafo narrativo |
| ... | | |

Diff semantico sezioni ad alto rischio:
- §escalation: INVARIATO
- §retry: EQUIVALENTE
- ...

Delta token:
- description: <prima> → <dopo> (<delta> tok, <delta%>)
- body:        <prima> → <dopo> (<delta> tok, <delta%>)
- totale:      <prima> → <dopo> (<delta> tok, <delta%>)

Esito gate: PASS | FAIL
Motivo (se FAIL): ...
```

### Soglie vincolanti

| Metrica | Soglia minima | Soglia bloccante |
|---|---|---|
| Checklist coverage | 0 voci MANCANTE | 1+ voci MANCANTE → FAIL |
| Diff semantico | 0 sezioni DIVERGENTE | 1+ sezioni DIVERGENTE → FAIL |
| Delta token totale | ≥ −20% | Delta positivo senza giustificazione → FAIL |

### Deroghe ammesse

Una voce `DEGRADATO` o un delta < 20% sono accettabili **solo se** accompagnati da una
giustificazione esplicita nel gate report e approvati (non bloccano automaticamente, ma
richiedono annotazione).

Un delta positivo è accettabile **solo se** la riscrittura ha aggiunto una sezione mancante
nell'originale per colmare un'ambiguità critica — annotare con `[COMPRESSION-NOTE-ADDED]`.

---

## 4. Invarianti cross-feature (never compress)

I seguenti elementi **non si toccano mai**, indipendentemente dal delta token:

- Contratti machine-readable: schema `RESULT.json`, `ESCALATION.json`, `meta.json`, `scope.txt`,
  `frozen.txt`, `PROGRESS.json`, `index.json`.
- Trigger-phrase (vedi step 3).
- Valori soglia e enum che condizionano il comportamento runtime (es. `"trivial|standard|critical"`,
  livelli L2/L3, soglie retry).
- Design file-based di `flow-run` (PM/DEV comunicano via `.flow/`; prompt di spawn sottili).
- Hook `scope-check` / `verify-gate` (contratti del plugin).

---

*Generato: 2026-06-03 | Versione: 1 | Feature: token-diet-foundation-002*
