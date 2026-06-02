# Attended flow — override additivi per orchestrazione `.flow/`

> **Additivo, non sostitutivo.** Si applica SOLO quando la skill è invocata dall'orchestratore `flow-run` (subagent `pm`). In uso standalone questa reference è inerte: il flusso `brief`/`finalize` resta identico a SKILL.md. Qui si aggiungono SOLO artefatti machine-readable e un gate. Niente cambia nella generazione del brief markdown.

## Perché

PM e DEV non si parlano: comunicano via file su disco in `.flow/briefs/<TASK>/`. Lo YAML/markdown del brief è fragile da parsare in bash, quindi gli artefatti contro cui l'hook valida le scritture del DEV sono **file separati e machine-readable**, non sezioni dentro il brief.

## Override su `brief T-NNN`

Dopo aver generato il brief co-locato `<context-root>/tasks/<id>.md` come da flusso standard, materializza in `.flow/briefs/<TASK>/`:

1. **`brief.md`** — copia del brief generato. È l'**unica** fonte che il DEV leggerà (isolamento file-based; il DEV non legge il brief canonico). **Produrlo con `cp` dal canonico appena scritto, NON ri-emetterlo via Write**: il contenuto è per definizione identico, quindi copia byte-a-byte invece di rigenerare il markdown nel tuo output (risparmia output-token pari alla dimensione del brief, per ogni task):

   ```bash
   cp "<PATH_BRIEF_CANONICO>" ".flow/briefs/<TASK>/brief.md"
   ```

   `<PATH_BRIEF_CANONICO>` è il file appena generato dal flusso standard, co-locato sotto la context-root (`docs/planning/tasks/<TASK>.md` per i progetti; `docs/features/<slug>/tasks/<TASK>.md` per le feature). Usa Write su `brief.md` SOLO come fallback se il `cp` fallisce (es. canonico non ancora su disco).

2. **`scope.txt`** — whitelist dei path scrivibili dal DEV, **un glob per riga**, derivata dalla sezione **"File impattati"** del brief:
   - una riga per ogni file `[new]`/`[edit]` (path esatto relativo alla root del repo, senza l'annotazione `[new]`/`[edit]`);
   - più la riga di servizio `.flow/briefs/<TASK>/**` (il DEV deve poter scrivere `RESULT.json`/`ESCALATION.json`/`retries`).
   - Formato: solo path, niente commenti, niente YAML, niente righe vuote superflue. Pattern matchato via `case` di bash 5 (`*` attraversa `/`): per scope per-cartella usare `dir/**`.

3. **`frozen.txt`** — interfacce/VO/contratti da NON toccare, **uno per riga**:
   - VO/interfacce/contratti citati in `technical-context.md` che questo task **consuma** ma non deve modificare;
   - voci della sezione "Out of scope per questo task" del brief.

4. **`meta.json`** — complessità del task per il tiering dinamico del DEV, emessa nello
   **stesso step** di `scope.txt`/`frozen.txt` (dopo aver generato il brief markdown):
   `{ "complexity": "trivial|standard|critical", "category": "<categoria primaria>" }`.
   - `complexity` assegnata applicando i criteri di [`references/complexity-criteria.md`](references/complexity-criteria.md) (fail-safe verso l'alto: in dubbio tra due tier, quello più alto).
   - `category` = categoria primaria del task (set autorevole [`../code-implementer/context-loading.md`](../code-implementer/context-loading.md)).
   - Consumato da `flow-run` prima dello spawn DEV; la mappa complessità→modello vive single-source in [`../flow-run/references/model-tiering.md`](../flow-run/references/model-tiering.md). Qui ci si ferma a `complexity`/`category`, non si replica il mapping al modello.

   **Best-effort, NON bloccante** (a differenza di `scope.txt`/`frozen.txt`): se non producibile
   o la classificazione è incerta al punto da non poter scegliere, NON scrivere `ESCALATION.json` e
   NON bloccare il brief — ometterlo e annotarlo nel summary; `flow-run` degrada al default (Sonnet).

### Validazione di output (obbligatoria)

`scope.txt` e `frozen.txt` devono esistere; `scope.txt` non deve essere vuoto. Se non producibili (planning assente, "File impattati" vuoto/non derivabile), NON inventare contenuto: scrivere `.flow/briefs/<TASK>/ESCALATION.json` = `{ "level":"L3", "reason":"brief non producibile: <motivo>" }` e fermarsi.

`meta.json`, se prodotto, dev'essere JSON valido con `complexity` nell'enum `{trivial, standard, critical}`. La sua **assenza non blocca** il brief (degrado lato `flow-run` a Sonnet); il gate bloccante resta solo su `scope.txt`/`frozen.txt`.

## Override su `finalize T-NNN`

Prima di eseguire il flusso `finalize` standard, applicare il **gate attended** (precondizione):

1. Leggere `.flow/briefs/<TASK>/RESULT.json`. Richiesto `verify == "pass"`.
2. Verificare che NON esista `.flow/briefs/<TASK>/ESCALATION.json` aperto.

Se una delle due condizioni non è soddisfatta → **non finalizzare**. La chiusura è bloccata finché l'escalation non è risolta dall'utente / il verify non passa.

## Cosa NON cambia

- Generazione, struttura e densità del brief markdown.
- `technical-context.md`: gestito come da SKILL.md (append-only su brief, update puntuale su finalize). Il DEV non lo tocca mai.
- Modalità `deviation`, `archive-milestone`, `check-coherence`: invariate.
