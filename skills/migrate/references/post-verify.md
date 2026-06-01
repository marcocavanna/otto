# Post-verify — verifica post-apply della migrazione

Reference consumata da `skills/migrate/SKILL.md` §"Post-verify". Codifica l'unica
fonte di verità della logica di verifica post-apply: input, algoritmo di verifica,
produzione del report pass/fail e istruzioni di recovery.

Due contratti consumati (non ridefiniti qui):
- **`apply-manifest.json`** (`apply-protocol.md` §5) — shape
  `{ timestamp, moves_done, moves_skipped, sources_archived }`. Contratto già
  fissato da topology-migration-004.
- **Resolver canonico** (`topology-canonical`, `feature-artifacts.md`) — definisce
  il path canonico atteso per ogni ID. Il post-verify usa il campo `to` del manifest
  come verità primaria del path; il resolver serve come fallback di derivazione.

Il post-verify **non scrive** alcun file di progetto. Legge manifest + fs, emette
solo il report a schermo.

---

## 1. Input

### §1.1 — `apply-manifest.json` (path, shape atteso, fallback manifest assente)

Il manifest si trova in `docs/.bak-<timestamp>/apply-manifest.json`, dentro il
backup prodotto dalla stessa apply. Se sono presenti più backup `docs/.bak-*/`:

- **Default**: usa il manifest del backup con il **timestamp più recente** (ordine
  lessicografico del nome directory, efficace per il formato ISO8601 file-safe).
- **Esplicito**: se l'utente passa un path diretto al manifest, usa quello.

**Manifest assente**: se nessun `docs/.bak-*/apply-manifest.json` è trovato, il
post-verify **abort** con avviso:

```text
Nessun apply-manifest.json trovato in docs/.bak-*/
L'apply non è stata eseguita oppure il backup è stato cancellato.
Il post-verify richiede il manifest per determinare gli ID processati.
```

Non viene avviata alcuna verifica best-effort: senza la lista degli ID processati
la verifica sarebbe incompleta e potenzialmente fuorviante.

### §1.2 — Resolver canonico e `slug_da_id`

Per ogni ID, il **path canonico atteso** è determinato così:

```
entry = moves_done.find(e => e.to include <id>)
        || moves_skipped.find(e => e.id == <id>)

se entry ha campo `to` → path_canonico = entry.to
altrimenti (entry in moves_skipped senza `to`):
  slug = slug_da_id(<id>)
  se source conclusa (archive: true) → docs/archive/features/<slug>/tasks/<id>.md
  altrimenti                         → docs/features/<slug>/tasks/<id>.md
```

**Preferenza al campo `to` del manifest**: è la verità di dove l'apply ha
effettivamente puntato. La derivazione da slug è un fallback per gli skip
idempotenti che non riportano `to`.

`slug_da_id(<id>)`: prefisso prima del suffisso numerico `-NNN`
(es. `flow-sync-001` → `flow-sync`, `model-tiering-003` → `model-tiering`).

---

## 2. Algoritmo di verifica

### §2.1 — Verifica per ID (`moves_done` + `moves_skipped`)

```
id_verificati = { id da moves_done } ∪ { id da moves_skipped }

per ogni id in id_verificati:
  path_canonico = path_canonico_atteso(id)   // §1.2
  se file esiste a path_canonico:
    → PASS { id, path: path_canonico }
  altrimenti:
    → FAIL { id, expected: path_canonico }
```

**`moves_skipped` partecipano alla verifica**: uno skip idempotente implica che il
brief sia già al path canonico prima dell'apply. Se non lo è, è un **FAIL** —
non silenzio. L'assenza del brief al path canonico è un'anomalia indipendentemente
dal fatto che il move sia stato eseguito o saltato.

### §2.2 — Verifica residui orfani in `docs/tasks/`

Separata dalla verifica per ID; esegue dopo §2.1:

```
per ogni file docs/tasks/<stem>.md:
  se <stem> ∈ moves_done.id:
    → RESIDUO_ORFANO { id: <stem>, path: docs/tasks/<stem>.md }
```

Un ID in `moves_skipped` **non genera RESIDUO_ORFANO** se il file source era già
assente (skip idempotente = nessuna origine da rimuovere). Se il file source è
ancora presente per un ID in `moves_done`, è invece un'anomalia: il move è stato
registrato come fatto, ma la source non è stata rimossa.

**Distinzione FAIL / RESIDUO_ORFANO** (non si escludono, possono coesistere):
- **FAIL** = il brief non si trova al path canonico atteso.
- **RESIDUO_ORFANO** = `docs/tasks/<id>.md` è ancora presente per un ID in
  `moves_done` (spostamento incompleto o parziale).

---

## 3. Output — report pass/fail

Forma canonica stampata a schermo:

```text
=== Post-verify migrazione ===

ID verificati: N
  PASS  flow-sync-001        docs/features/flow-sync/tasks/flow-sync-001.md
  PASS  model-tiering-003    docs/archive/features/model-tiering/tasks/model-tiering-003.md
  FAIL  topology-foo-001     atteso: docs/features/topology-foo/tasks/topology-foo-001.md  — non trovato

Residui orfani in docs/tasks/ (non rimossi dall'apply):
  docs/tasks/topology-foo-001.md

Riepilogo: N verificati, P pass, F fail, R residui orfani.

Esito: PASS
```

Regole di rendering:
- **Sezioni a cardinalità 0 omesse** dal corpo (coerente con preview/apply): se
  nessun FAIL, la riga di FAIL non appare; se nessun RESIDUO_ORFANO, quella sezione
  è omessa.
- `PASS` / `FAIL` in maiuscolo per leggibilità immediata.
- Esito finale in evidenza nell'ultima riga: `Esito: PASS` o `Esito: FAIL`.
- `Esito: PASS` solo se F == 0 **e** R == 0.
- `Esito: FAIL` se F > 0 o R > 0.

---

## 4. Recovery

Quando l'esito è FAIL, il report appende le istruzioni di ripristino:

```text
Per ripristinare allo stato pre-apply:
  cp -r docs/.bak-<timestamp>/ docs/
  (oppure, in un repo git: git checkout HEAD -- docs/)

Manifest dell'apply: docs/.bak-<timestamp>/apply-manifest.json
```

Il `<timestamp>` è quello del backup consultato. In caso di apply multiple, ogni
backup ha timestamp distinto: l'utente sceglie lo stato a cui tornare.

- `cp -r` è il metodo **universale**: copre anche i file non ancora tracciati da git
  al momento dell'apply.
- `git checkout HEAD -- docs/` ripristina solo i file tracciati: utile in repo git
  con working tree pulito, ma non copre file non in index.

---

## 5. Edge case

### §5.1 — Manifest assente / backup cancellato

Vedi §1.1. Il post-verify abort con avviso. Nessuna verifica parziale.

### §5.2 — ID in `moves_skipped` senza brief al path canonico

Il brief avrebbe dovuto essere già al path canonico (ragione dello skip). Se non lo
è: **FAIL**, come per qualsiasi altro ID in `id_verificati`. Lo skip non è una
giustificazione per assenza del brief.

### §5.3 — RESIDUO_ORFANO senza FAIL corrispondente

Il brief esiste al path canonico (`PASS`), ma `docs/tasks/<id>.md` è ancora
presente (`RESIDUO_ORFANO`). Scenario: il move è stato eseguito (`moves_done`) ma
il file source non è stato rimosso (anomalia di apply parziale). Il RESIDUO_ORFANO
va comunque segnalato e fa scattare `Esito: FAIL`: l'apply è incompleta finché
esiste il doppione nella directory flat.

---

## Riepilogo contratti

| Aspetto | Regola |
|---|---|
| Input primario | `apply-manifest.json` — path `docs/.bak-<timestamp>/apply-manifest.json` |
| Backup più recente | ordine lessicografico del nome directory (ISO8601 file-safe) |
| Manifest assente | abort con avviso; nessuna verifica best-effort |
| ID verificati | `moves_done` ∪ `moves_skipped` |
| Path canonico atteso | campo `to` del manifest (priorità); fallback derivazione da slug |
| FAIL | brief assente al path canonico atteso |
| RESIDUO_ORFANO | `docs/tasks/<id>.md` presente per ID in `moves_done` |
| `moves_skipped` | contribuiscono alla verifica; assenza al canonico → FAIL |
| FAIL e RESIDUO_ORFANO | non si escludono, possono coesistere per lo stesso ID |
| Esito PASS | F == 0 e R == 0 |
| Esito FAIL | F > 0 o R > 0; appende istruzioni di recovery |
| Sezioni a 0 | omesse dal corpo del report |
| Scritture | nessuna |
