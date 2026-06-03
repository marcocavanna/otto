# Anchor retrofit — detection, inferenza e protocollo apply

Reference consumata da `skills/migrate/SKILL.md` §"Modalità — Anchor retrofit".
Codifica quattro capacità: **scan** degli artefatti privi di anchor, **inferenza**
dei valori (Tier/Parent/Bubble-up target) dalla struttura del repo, **preview**
del piano, **apply** idempotente e reversibile, **post-verify**.

Lo schema anchor è single-source in `skills/planner/anchor-schema.md` —
questa reference lo **consuma** e non lo ridefinisce. Stessa regola per il
backup/manifest: riusa la strategia di `apply-protocol.md` (stesso timestamp,
stessa struttura `docs/.bak-<timestamp>/`), adattata agli inject invece dei move.

Principi del `SKILL.md` che governano tutto il protocollo:
- **Fail-closed**: se l'inferenza è ambigua o impossibile, non iniettare.
- **Idempotente**: se `<!-- Anchor -->` è già presente, skip senza toccare.
- **Reversibile**: backup integrale di `docs/` prima di ogni scrittura.
- **Non distruttivo**: l'inject è un'**inserzione** dopo il titolo H1; il
  contenuto esistente non viene mai modificato né rimosso.

---

## 1. Scan — artefatti candidati

Lo scan cerca `00-context.md` e `technical-context.md` nelle directory di
planning attive. La **detection è per-file**: ogni file viene classificato
indipendentemente.

### Directory scansionate

| Tier | Pattern |
|---|---|
| `project` | `docs/planning/00-context.md`, `docs/planning/technical-context.md` |
| `epic` | `docs/epics/<slug>/00-context.md`, `docs/epics/<slug>/technical-context.md` |
| `feature` | `docs/features/<slug>/00-context.md`, `docs/features/<slug>/technical-context.md` |
| `task` | `docs/tasks/<slug>/00-context.md`, `docs/tasks/<slug>/technical-context.md` |

### Esclusioni

- `docs/archive/**` — artefatti archiviati: congelati, non retrofittati.
- Ogni file non in questo scan (roadmap, tasks-active, abstract, ecc.) — solo
  `00-context.md` e `technical-context.md` portano l'anchor (schema §"Posizione").

### Classificazione per-file

Per ogni file trovato:

```
se una riga qualsiasi entro le prime 10 righe inizia con "<!-- Anchor":
  → already_anchored { path, reason: "anchor già presente" | "proto-anchor rilevato" }
  → skip (idempotenza)
altrimenti:
  → candidato all'inferenza (§2)
```

Il pattern di riconoscimento è il **prefisso** `<!-- Anchor` (non l'exact match
`<!-- Anchor -->`): cattura sia la forma canonica sia forme proto/legacy che
hanno testo aggiuntivo nel commento (es. `<!-- Anchor (modello introdotto...) -->`
prodotte da dogfooding pre-2.0.0). L'obiettivo è **non iniettare mai** quando
è già presente una qualsiasi dichiarazione anchor, indipendentemente dal formato.

Quando il prefisso `<!-- Anchor` è presente ma il formato non corrisponde alla
forma canonica (`<!-- Anchor --> **Tier**: ...`), il file va in `already_anchored`
con `reason: "proto-anchor rilevato (formato non canonico)"`. Il post-verify lo
segnalerà come `WARN` anziché `FAIL` (anchor presente ma non canonico).

La ricerca si limita alle prime 10 righe: l'anchor deve stare subito dopo il
titolo H1 (`anchor-schema.md` §"Posizione"). Un anchor fuori posizione (righe
11+) è trattato come assente e candidato all'inferenza — il post-verify lo segnalerà.

---

## 2. Inferenza — valori anchor per tier

Per ogni file candidato, il tier è determinato dalla **directory** che lo
contiene. I valori Parent e Bubble-up target sono inferiti come segue.

### Regola generale di fail-closed

Se l'inferenza produce un risultato ambiguo (>1 match) o impossibile (0 match
laddove era atteso almeno 1), il file va in `ambiguous` e **non viene toccato**.
Meglio un anchor assente che un anchor errato.

---

### Tier `project` (`docs/planning/`)

```
Tier:              project
Parent:            —
Bubble-up target:  —
```

Nessuna inferenza richiesta. Tutti i file in `docs/planning/` sono tier `project`
per definizione; il tier radice non ha padre né bubble-up.

---

### Tier `epic` (`docs/epics/<slug>/`)

```
Tier:              epic
Parent:            <project-slug | —>
Bubble-up target:  docs/planning/technical-context.md  (se esiste)
                   —                                    (se non esiste)
```

**Bubble-up target**: se il file `docs/planning/technical-context.md` esiste nel
repo, il bubble-up target è quel path. Altrimenti `—`.

**Parent (project slug)**: tentare l'estrazione dal titolo H1 di
`docs/planning/00-context.md`. Se il file esiste e il titolo segue il pattern
`` # Context — [Nome] (`<slug>`) `` (con slug tra backtick), estrarre `<slug>`.
Se il titolo non ha uno slug backtick-wrapped, usare `—` e segnalare nella nota
del piano: `parent non determinato — impostato a —`.

---

### Tier `feature` (`docs/features/<slug>/`)

```
Tier:              feature
Parent:            <epic-slug | —>
Bubble-up target:  docs/epics/<epic-slug>/technical-context.md  (se parent trovato)
                   —                                             (altrimenti)
```

**Parent (epic slug)**: scansionare tutti i file `docs/epics/*/roadmap.md`
cercando il feature `<slug>` come stringa (tipicamente nella riga
`### <slug> —` o in `**Source**: docs/features/<slug>/`).

```
matches = epics E tali che roadmap.md di E contiene la stringa "<slug>"

se |matches| == 1  → parent = E, bubble-up = docs/epics/<E>/technical-context.md
se |matches| == 0  → parent = —, bubble-up = —  (feature standalone)
se |matches| >  1  → ambiguous { path, reason: ">1 epic match: <e1>, <e2>, ..." }
```

Caso `0 match`: la feature è standalone (non legata a nessun epic) — lecito e
non un errore. Parent `—` e bubble-up `—` sono i valori corretti per gli
artefatti standalone (`anchor-schema.md` §"Semantica del valore vuoto").

Caso `>1 match`: fail-closed. Non iniettare: un anchor errato è peggio di uno
assente. Riportare come `ambiguous` con la lista degli epic in conflitto.

---

### Tier `task` (`docs/tasks/<slug>/`)

```
Tier:              task
Parent:            <feature-slug | —>
Bubble-up target:  docs/features/<feature-slug>/technical-context.md  (se parent trovato)
                   —                                                    (altrimenti)
```

**Parent (feature slug)**: lo slug del task ha la forma `<feature-slug>-NNN`
(es. `flow-sync-003` → feature `flow-sync`). Estrarre il prefisso prima del
suffisso numerico `-NNN`.

Verifica: il path `docs/features/<feature-slug>/` deve esistere. Se non esiste,
trattare come `ambiguous` (feature non trovata, slug estratto non affidabile).

```
feature_slug = prefisso prima di "-NNN" nello slug del task

se docs/features/<feature_slug>/ esiste:
  → parent = feature_slug
  → bubble-up = docs/features/<feature_slug>/technical-context.md
altrimenti:
  → ambiguous { path, reason: "feature <feature_slug>/ non trovata" }
```

Nota: per i task, lo slug della directory **è** il prefisso — non serve scan di
tasks-active.md. La regola è deterministica e non produce match multipli.

---

## 3. Output strutturato — `AnchorRetrofitPlan`

La detection + inferenza producono un piano in memoria con tre categorie:

```
AnchorRetrofitPlan {
  injects: [{
    path:       string,          // path del file da retrofittare
    tier:       string,          // project | epic | feature | task
    parent:     string,          // slug | —
    bubble_up:  string,          // path | —
    note:       string | null    // es. "parent non determinato — impostato a —"
  }]
  already_anchored: [{
    path:   string,
    reason: string               // "anchor già presente"
  }]
  ambiguous: [{
    path:   string,
    reason: string               // motivo dell'ambiguità o impossibilità
  }]
}
```

Semantica:
- **`injects`** — file da retrofittare con i valori inferiti. Solo questi vengono scritti dall'apply.
- **`already_anchored`** — file con anchor già presente. Skip idempotente.
- **`ambiguous`** — file per cui l'inferenza è ambigua o impossibile. Fail-closed: non toccati.

---

## 4. Preview — rendering del piano

La preview consuma l'`AnchorRetrofitPlan` e stampa un report human-readable.
**Non scrive nulla su disco.** Imposta il gate di sessione `anchor_retrofit_plan_ready = true`.

### Forma canonica

```text
=== Preview anchor retrofit ===

Inject pianificati (N):
  docs/planning/technical-context.md
    Tier: project · Parent: — · Bubble-up target: —
  docs/epics/my-epic/00-context.md
    Tier: epic · Parent: — · Bubble-up target: docs/planning/technical-context.md
    ⚠ Nota: parent non determinato — impostato a —
  docs/features/my-feat/technical-context.md
    Tier: feature · Parent: my-epic · Bubble-up target: docs/epics/my-epic/technical-context.md
  ...

Già anchored — skip (M):
  docs/features/my-feat/00-context.md  (anchor già presente)

Ambigui — NON verranno toccati (A):
  docs/features/other-feat/00-context.md: >1 epic match: epic-a, epic-b

Riepilogo: N inject pianificati, M già anchored, A ambigui.
Nessuna modifica su disco effettuata.
Per procedere: "anchor-retrofit apply"
```

### Regole di rendering

- Sezioni a cardinalità 0 omesse dal corpo; contatori sempre nel riepilogo.
- Gli `injects` con `note` non null mostrano la nota con prefisso `⚠`.
- La CTA `"anchor-retrofit apply"` compare **solo** se `injects` non è vuoto.
- Il terminatore `Nessuna modifica su disco effettuata.` è invariante.

### Messaggi terminali per stato del piano

| Stato | Messaggio | CTA `apply` |
|---|---|---|
| `injects` non vuoto | riepilogo standard | sì |
| `injects` vuoto, `already_anchored` non vuoto, `ambiguous` vuoto | `Tutti gli artefatti hanno già l'anchor. Nessun'azione necessaria.` | no |
| `injects` vuoto, `ambiguous` non vuoto | `Nessun inject sicuro. Risolvere gli ambigui a mano.` | no |
| piano completamente vuoto | `Nessun artefatto candidato trovato.` | no |

### Gate dell'apply

`anchor_retrofit_plan_ready = true` dopo ogni preview valida (detection senza
errori fatali + piano prodotto + report stampato). Persiste solo in sessione:
dopo un'interruzione, la preview va rieseguita.

---

## 5. Apply — protocollo di inject

L'apply materializza il piano. È l'unica fase che scrive su disco.

### Precondizioni

- `anchor_retrofit_plan_ready == true` — abort immediato se false.
- `AnchorRetrofitPlan` disponibile in sessione (prodotto dalla preview).

### Sequenza operativa

```text
1. Gate check    — anchor_retrofit_plan_ready == true, altrimenti abort
2. Backup        — copia integrale di docs/ in docs/.bak-<timestamp>/ (bloccante)
3. Inject loop   — per ogni injects[]: inserisci riga anchor idempotente (§5.1)
4. Manifest      — scrive docs/.bak-<timestamp>/anchor-retrofit-manifest.json (§5.2)
5. Report        — riepilogo a schermo + istruzioni restore
6. Post-verify   — DELEGATO (anchor-retrofit post-verify), non inline
```

### 5.1 Inject loop — algoritmo per file

Per ogni entry `{ path, tier, parent, bubble_up }` in `injects`:

```text
1. Rileggi il file da disco (fonte di verità; non usare la copia in sessione).
2. Se la riga "<!-- Anchor -->" compare già nelle prime 10 righe:
     → skip + log "già anchored a runtime: <path>" → entry in injects_skipped
     → continua (idempotenza)
3. Trova la prima riga H1 (pattern "^# ").
     Se non trovata: skip + log "H1 non trovato: <path>" → entry in injects_failed
     → continua (fail-closed: non iniettare in file senza H1)
4. Costruisci la riga anchor:
     "<!-- Anchor --> **Tier**: <tier> · **Parent**: <parent> · **Bubble-up target**: <bubble_up>"
5. Inserisci dopo la riga H1:
     - Se la riga successiva all'H1 è una riga vuota: inserisci la riga anchor e
       poi una riga vuota (→ H1 · riga-anchor · blank · contenuto).
     - Se la riga successiva all'H1 è non-vuota: inserisci blank · riga-anchor ·
       blank (→ H1 · blank · riga-anchor · blank · contenuto).
     Obiettivo invariante: la riga anchor è separata dal titolo e dal contenuto
     da esattamente una riga vuota per lato.
6. Scrivi il file su disco (sovrascrittura in-place, non rename).
7. Registra in injects_done { path, tier, parent, bubble_up }.
```

### 5.2 Manifest — `anchor-retrofit-manifest.json`

Path: `docs/.bak-<timestamp>/anchor-retrofit-manifest.json`.

```json
{
  "timestamp": "2026-06-03T12:00:00Z",
  "injects_done": [
    {
      "path": "docs/features/my-feat/technical-context.md",
      "tier": "feature",
      "parent": "my-epic",
      "bubble_up": "docs/epics/my-epic/technical-context.md"
    }
  ],
  "injects_skipped": [
    { "path": "docs/features/other/00-context.md", "reason": "già anchored a runtime" }
  ],
  "injects_failed": [
    { "path": "docs/tasks/broken/00-context.md", "reason": "H1 non trovato" }
  ]
}
```

### 5.3 Report terminale

```text
=== Anchor retrofit — completato ===

Inject effettuati (N):
  docs/planning/technical-context.md  [project]
  docs/features/my-feat/technical-context.md  [feature · parent: my-epic]
  ...

Skip — già anchored a runtime (M):
  docs/features/other/00-context.md

Falliti — H1 non trovato (F):
  docs/tasks/broken/00-context.md

Riepilogo: N inject effettuati, M skip, F falliti.
Backup: docs/.bak-<timestamp>/ (manifest: docs/.bak-<timestamp>/anchor-retrofit-manifest.json)

Per ripristinare allo stato pre-apply:
  cp -r docs/.bak-<timestamp>/ docs/
  (oppure, in un repo git: git checkout HEAD -- docs/)

Prossimo passo: esegui "anchor-retrofit post-verify".
```

Le sezioni a cardinalità 0 sono omesse dal corpo; i contatori restano nel riepilogo.

---

## 6. Post-verify

Dopo l'apply, per ogni entry in `injects_done` (dal manifest):

```text
per ogni { path, tier, parent, bubble_up } in injects_done:
  1. Leggi il file.
  2. Cerca la riga "<!-- Anchor -->" entro le prime 10 righe.
     se assente   → FAIL: "anchor non trovato"
  3. Parsa i campi Tier / Parent / Bubble-up target dalla riga trovata.
     se Tier      ≠ <tier>      → FAIL: "Tier mismatch: atteso <tier>, trovato <x>"
     se Parent    ≠ <parent>    → FAIL: "Parent mismatch"
     se Bubble-up ≠ <bubble_up> → FAIL: "Bubble-up target mismatch"
  4. Verifica la posizione: la riga anchor deve stare subito dopo la riga H1
     (separata da al più una riga vuota).
     se fuori posizione → WARN: "anchor presente ma fuori posizione (riga N)"
  → PASS: "ok"
```

Report pass/fail per ogni file. Forma canonica:

```text
=== Anchor retrofit — post-verify ===

PASS  docs/planning/technical-context.md
PASS  docs/features/my-feat/technical-context.md
FAIL  docs/tasks/broken/technical-context.md  — anchor non trovato
WARN  docs/epics/my-epic/00-context.md  — anchor presente ma fuori posizione (riga 15)

Riepilogo: N pass, F fail, W warn.
```

Se anche un solo `FAIL`: segnalarlo in evidenza e suggerire recovery:

```text
⚠ Recovery per i FAIL: verificare il file manualmente e iniettare l'anchor
  nella posizione corretta (dopo il titolo H1, separato da una riga vuota).
  Schema: skills/planner/anchor-schema.md
```

I `WARN` non bloccano: la skill segnala la posizione anomala ma l'anchor è presente
e parsabile. Un WARN sull'anchor già presente pre-retrofit (rilevato dallo scan al §1)
non raggiunge il post-verify: quei file sono in `already_anchored`, non in `injects_done`.

---

## 7. Edge case

### 7.1 File con H1 assente

Se un file non ha una riga H1, l'inject non è sicuro (non si sa dove posizionare
l'anchor). Fail-closed: l'inject loop salta il file (`injects_failed`) e lo riporta
nel manifest. Il post-verify lo segnala come FAIL.

### 7.2 File vuoto o illeggibile

Se la lettura del file fallisce, skip + log. Il file non entra in `injects_done`
né in `injects_skipped`: va in `injects_failed` con `reason: "lettura fallita"`.

### 7.3 `docs/planning/` assente (nessun tier project)

La sezione project viene semplicemente saltata: non ci sono candidati in quella
directory. Non è un errore — il progetto potrebbe usare solo epics standalone.

### 7.4 `docs/epics/` senza `roadmap.md`

Se una feature non trova nessuna roadmap da scansionare, il match è 0 → parent `—`
e bubble-up `—`. Non un errore: feature standalone legittima.

### 7.5 Epic senza `docs/planning/`

Se non esiste `docs/planning/technical-context.md`, il bubble-up target dell'epic
è `—`. Legittimo in un repo senza tier project.

### 7.6 Backup già esistente per quel timestamp

Impossibile per design (il timestamp è generato al momento dell'apply). Vedi
`apply-protocol.md` §4 per la strategia con timestamp distinto.

### 7.7 Anchor già presente con valori diversi

L'idempotenza è **pura**: se il prefisso `<!-- Anchor` è già presente (nelle
prime 10 righe), il file va in `already_anchored` a prescindere dai valori. La
skill non corregge anchor esistenti — quello è fuori scope. Il post-verify può
segnalare discrepanze rispetto al valore atteso, ma l'apply non tocca mai un
anchor già presente.

### 7.8 Proto-anchor non canonico (pre-2.0.0)

Alcuni artefatti creati durante il dogfooding pre-2.0.0 possono avere un anchor
in formato esteso o multi-riga — es.:

```markdown
<!-- Anchor (modello introdotto da questo stesso epic — dogfooding) -->
**Tier**: epic
**Parent**: —
**Bubble-up target**: —
```

La detection riconosce il prefisso `<!-- Anchor` e classifica il file come
`already_anchored { reason: "proto-anchor rilevato (formato non canonico)" }`.
Nessun inject. Il post-verify emette `WARN: proto-anchor non canonico` per
questi file. La normalizzazione al formato canonico è un'operazione manuale fuori
scope di `migrate`.

---

## Riepilogo contratti

| Aspetto | Regola |
|---|---|
| Scope scan | `00-context.md` e `technical-context.md` in `docs/planning/`, `docs/epics/*/`, `docs/features/*/`, `docs/tasks/*/` |
| Esclusione | `docs/archive/**` |
| Detection anchor | prefisso `<!-- Anchor` nelle prime 10 righe (cattura canonico + proto-anchor) |
| Anchor canonico presente | `already_anchored { reason: "anchor già presente" }` — skip |
| Proto-anchor (non canonico) | `already_anchored { reason: "proto-anchor rilevato" }` — skip; WARN in post-verify |
| Inferenza project | `Tier: project · Parent: — · Bubble-up target: —` (fisso) |
| Inferenza epic | bubble-up = `docs/planning/technical-context.md` se esiste; parent = slug da H1 di planning/00-context o `—` |
| Inferenza feature | scan roadmap; 0 match → standalone `—/—`; >1 match → `ambiguous` |
| Inferenza task | prefix-slug; verifica `docs/features/<prefix>/` esiste; altrimenti `ambiguous` |
| Fail-closed | inferenza ambigua o impossibile → `ambiguous`, non toccato |
| Inject posizione | dopo H1, separato da una riga vuota per lato |
| H1 assente | `injects_failed`, non toccato |
| Idempotenza runtime | se anchor trovato durante inject loop → skip (`injects_skipped`) |
| Backup | `docs/.bak-<timestamp>/`, copia integrale, bloccante, esclude `.bak-*` |
| Manifest | `anchor-retrofit-manifest.json` nello stesso backup |
| Post-verify | per ogni `injects_done`: verifica presenza + valori + posizione |
| Anchor con valori diversi già presente | `already_anchored` — non corretto (fuori scope) |
| Commit git | mai |

---

Generato: 2026-06-03 | Task: planner-unification-release-002
