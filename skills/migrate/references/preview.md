# Preview — rendering del piano e gate dell'apply

Reference consumata da `skills/migrate/SKILL.md` §"preview (default)". Codifica due
capacità: il **rendering** umano-leggibile del `DetectionPlan` e il **gate** che
impedisce all'apply di partire senza una preview prodotta nella sessione corrente.

L'input è il `DetectionPlan` prodotto dalla detection (`references/detection.md`,
shape `{ moves, ambiguous, orphan, already_migrated }`). Questa reference lo
**consuma**, non lo ridefinisce: la struttura del piano è contratto downstream
(`detection.md` §3).

La preview **non scrive nulla su disco**. Stampa il report all'utente e imposta il
gate di sessione. Ogni scrittura/spostamento è in `apply-protocol.md` (task 004).

Due principi del `SKILL.md` valgono qui:
- **Fail-closed**: se la detection non completa senza errori fatali, il gate resta
  chiuso — l'apply non parte.
- **Idempotente**: un repo già migrato produce comunque una preview valida (piano
  con soli `already_migrated`), il gate si sblocca, l'apply sarebbe un no-op.

---

## 1. Rendering del piano

Dato un `DetectionPlan` in memoria, la preview produce un report testuale
strutturato. Forma canonica (caso con almeno un move):

```text
=== Preview migrazione ===

Move pianificati (N):
  docs/tasks/<id>.md  →  docs/features/<slug>/tasks/<id>.md
  ...
  docs/tasks/<id>.md  →  docs/archive/features/<slug>/tasks/<id>.md   [source conclusa]

Già migrati — skip (M):
  <id>  →  <canonical_path>

Casi ambigui — NON verranno mossi (A):
  <id>: <reason>

Orfani — NON verranno mossi (O):
  <id>: <reason>

Riepilogo: N move pianificati, M già migrati, A ambigui, O orfani.
Nessuna modifica su disco effettuata.
Per procedere con la migrazione: "apply"
```

### Mapping campi `DetectionPlan` → sezioni del report

| Campo del piano | Sezione | Formato riga |
|---|---|---|
| `moves` (archive=false) | Move pianificati | `from  →  to` |
| `moves` (archive=true) | Move pianificati | `from  →  to   [source conclusa]` |
| `already_migrated` | Già migrati — skip | `id  →  canonical_path` |
| `ambiguous` | Casi ambigui | `id: reason` |
| `orphan` | Orfani | `id: reason` |

`N`/`M`/`A`/`O` sono le cardinalità rispettive di `moves` / `already_migrated` /
`ambiguous` / `orphan`. Una sezione con cardinalità 0 viene **omessa** dal corpo
del report (non si stampa "Casi ambigui (0)"), ma il conteggio resta nel riepilogo.

### Regole di rendering

- I `moves` con `archive: true` sono evidenziati con il suffisso
  `[source conclusa]` (destinazione `docs/archive/features/<slug>/tasks/`).
- Le voci di `already_migrated` sono **sempre** mostrate quando presenti: rendono
  esplicita l'idempotenza (conferma che quei brief non verranno toccati).
- `ambiguous` e `orphan` sono informativi e fail-closed: il report chiarisce che
  **non verranno mossi**, riportando `reason` da `detection.md` (es. `>1 match`,
  `0 match`, `tasks-active.md` assente).
- Il report termina **sempre** con `Nessuna modifica su disco effettuata.` —
  invariante della modalità preview.
- La riga `Per procedere con la migrazione: "apply"` compare **solo** quando esiste
  almeno un move pianificabile (vedi §2 per le eccezioni).

---

## 2. Messaggi terminali per stato del piano

A seconda della composizione del `DetectionPlan`, il riepilogo e la call-to-action
cambiano:

| Stato del piano | Messaggio terminale | `"apply"` proposto |
|---|---|---|
| `moves` non vuoto | riepilogo standard + `Per procedere... "apply"` | sì |
| `moves` vuoto, `already_migrated` non vuoto, `ambiguous`+`orphan` vuoti | `Repo già migrato. Nessun'azione necessaria.` | no |
| `moves` vuoto, `ambiguous`+`orphan` non vuoti | `Nessun move sicuro. Risolvere i casi ambigui/orfani prima di procedere.` | no |
| piano completamente vuoto | `Nessun brief da migrare in docs/tasks/. Apply è no-op.` | no |

Razionale del "no": quando non esiste alcun move pianificabile, proporre `"apply"`
indurrebbe l'utente a un comando inutile (no-op) o prematuro (casi da risolvere a
mano). Il gate (§3) resta comunque sbloccato in tutti questi stati, perché la
preview è stata eseguita con successo — `apply` resta invocabile, semplicemente non
è suggerito.

---

## 3. Gate dell'apply — regola formale

L'apply **non può partire** se e solo se non è stato prodotto un `DetectionPlan`
nella sessione corrente mediante una preview eseguita nella stessa sessione.

Condizione di sblocco: la variabile di sessione `migration_plan_ready` è `true`.
È impostata al termine di **ogni** preview che produce un `DetectionPlan` valido —
anche un piano completamente vuoto — purché l'esecuzione non sia abortita per
errore.

### Preview valida (gate → sbloccato)

Tutte e tre le condizioni:

- Detection eseguita senza errori fatali.
- `DetectionPlan` prodotto (anche con tutti i campi vuoti: repo già migrato o
  nessun brief è un piano valido).
- Report di preview stampato all'utente.

### Preview NON valida (gate resta chiuso)

- Detection abortita per errore fatale (es. parsing failure su **tutti** i
  `tasks-active.md`, impossibile produrre un piano).
- Apply invocata direttamente senza preview nella sessione corrente.

In stato chiuso, l'apply si rifiuta di partire con un messaggio che rimanda l'utente
a eseguire prima `preview`.

### Edge case — reset di sessione

Il gate è **esclusivamente di sessione**: non esiste persistenza su disco. Se
l'utente riprende una conversazione dopo un'interruzione, `migration_plan_ready` è
di nuovo `false` e la preview va **rieseguita** prima dell'apply. Il manifest su
disco è prodotto dall'apply (`apply-protocol.md`), non dalla preview, e non
sostituisce il gate di sessione.

---

## 4. Edge case da coprire

### 4.1 Repo già migrato

`moves` vuoto, `already_migrated` non vuoto, `ambiguous`+`orphan` vuoti. La preview
è valida e il gate si sblocca; l'apply sarebbe un no-op (idempotenza). Report con la
sola sezione "Già migrati — skip" e messaggio `Repo già migrato. Nessun'azione
necessaria.`

### 4.2 Piano completamente vuoto

Nessun brief in `docs/tasks/`: tutti i campi del `DetectionPlan` sono vuoti. La
preview è valida, il gate si sblocca, ma non c'è nulla da fare. Messaggio:
`Nessun brief da migrare in docs/tasks/. Apply è no-op.`

### 4.3 Detection parziale

Un subset di `tasks-active.md` non è scansionabile per parsing failure (ma **non**
tutti — vedi `detection.md` §4: gli ID che matcherebbero un file corrotto diventano
`orphan` fail-closed). La preview viene eseguita ugualmente con i dati disponibili,
ma il report **segnala esplicitamente**:

- i file piano non scansionati (path),
- il conteggio degli ID potenzialmente mancanti dal mapping a causa di quei file.

Il warning è prominente, in testa al report:

```text
=== Preview migrazione ===

⚠ Detection parziale: K file piano non scansionati.
  docs/features/<slug>/tasks-active.md
  ...
  Gli ID che dipendevano da questi file sono trattati come orfani (fail-closed).
  Verificare manualmente prima dell'apply.

Move pianificati (N):
  ...
```

Il gate si sblocca comunque (preview eseguita con successo sui dati disponibili), ma
l'utente è avvisato che il piano potrebbe essere incompleto. Se invece **tutti** i
`tasks-active.md` falliscono il parsing, la detection è abortita: preview NON valida,
gate chiuso (§3).

---

## Riepilogo contratti

| Aspetto | Regola |
|---|---|
| Input | `DetectionPlan` da `detection.md` (consumato, non ridefinito) |
| Scritture su disco | nessuna (delegate ad `apply-protocol.md`) |
| Sezioni a cardinalità 0 | omesse dal corpo, contate nel riepilogo |
| `moves` con `archive: true` | suffisso `[source conclusa]` |
| Terminatore invariante | `Nessuna modifica su disco effettuata.` |
| CTA `"apply"` | solo se `moves` non vuoto |
| Gate sblocco | `migration_plan_ready = true` dopo preview valida |
| Preview valida | detection senza errori fatali + piano prodotto + report stampato |
| Piano vuoto / già migrato | preview valida, gate sbloccato, apply no-op |
| Detection parziale | preview valida con warning prominente; orfani fail-closed |
| Detection totalmente abortita | preview NON valida, gate chiuso |
| Persistenza gate | nessuna (solo sessione; reset → rieseguire preview) |
