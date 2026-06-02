# Brief tecnico — planner-unification-finalize-002

**Origin**: feature-planner
**Context-root**: docs/features/planner-unification-finalize/
**Feature**: planner-unification-finalize
**Status**: ✅ finalized

---

## Obiettivo

Implementare il modo `finalize <scope>` nella skill `planner`, limitato ai passi:

1. **Gate attended** — verifica precondizione obbligatoria (RESULT.json + assenza ESCALATION.json) prima di procedere.
2. **Risoluzione anchor del padre** — legge `Bubble-up target` dall'anchor del `technical-context.md` della source; se `Parent —` o anchor assente → no-op di risalita (solo finalizzazione locale).
3. **Finalizzazione locale** — marca il task come finalized, aggiorna `technical-context.md` della source se il task ha introdotto decisioni (append-only).

Il bubble-up single-hop selettivo (la risalita vera e propria) è scope di `planner-unification-finalize-003`. Questo task costruisce solo il gate e la risoluzione del percorso di risalita (l'infrastruttura su cui 003 opera).

---

## Analisi tecnica

### Flusso del modo `finalize`

```
finalize <scope>
  1. [GATE] Risolvi la source (come expand: scan 4 tier, esclude docs/archive/**)
     - 0 match → errore "source sconosciuta: <scope>"
     - >1 match → chiede selezione esplicita
     - 1 match → context-root confermata

  2. [GATE attended] Verifica precondizioni:
     a. Leggi .flow/briefs/<id>/ per il task corrente:
        - RESULT.json deve esistere e contenere "verify": "pass"
        - ESCALATION.json NON deve esistere (o deve essere risolto)
     b. Se gate non passa → BLOCCA, output:
        "BLOCKED: finalize negato — verify=<valore|mancante> / escalation aperta"
        Non procedere oltre.

  3. [RISOLUZIONE ANCHOR] Leggi <context-root>/technical-context.md:
     a. Cerca riga `<!-- Anchor -->` (grep deterministico)
     b. Estrai campo `Bubble-up target`
     c. Valutazione:
        - `Bubble-up target: —` → no-op di risalita; log "source standalone, nessuna risalita"
        - Anchor assente → no-op di risalita (back-compat implicita)
        - Path valorizzato → memorizza come target per il bubble-up (eseguito in 003)

  4. [LETTURA DECISIONI] Leggi <context-root>/tasks/<id>.md (brief):
     a. Sezione "Decisioni tecniche" e "Vincoli risolti"
     b. Sezione "Deviazioni durante l'implementazione" (se presente)
     c. Presenta all'utente il delta: decisioni del brief + deviazioni registrate

  5. [AGGIORNAMENTO technical-context.md — locale]
     a. Domanda obbligatoria:
        "Qualcosa in technical-context.md è cambiato per effetto di questo task?
         (es. libreria diversa, pattern modificato, naming convention introdotta)"
     b. Se sì → append-only in <context-root>/technical-context.md:
        sezione `## Decisioni introdotte da <id> (<titolo>)`
     c. Se no → nessuna modifica a technical-context.md

  6. [FINALIZZAZIONE brief]
     a. Aggiorna header del brief <context-root>/tasks/<id>.md:
        `Status: ✅ finalized`
     b. tasks-active.md NON viene toccato da questa skill

  7. [AGGIORNAMENTO SKILL.md]
     a. Sostituisce lo stub `### finalize <scope> > Rimandato...` con flusso reale
        + link a `references/finalize.md`

  8. [SUMMARY]
     - task finalizzato
     - technical-context.md aggiornato? (sì/no)
     - bubble-up target: <path|"nessuno (standalone)">
     - nota: "bubble-up effettivo → planner-unification-finalize-003"
```

### Parsing dell'anchor

Pattern deterministico bash-compatible:

```bash
# grep della riga anchor in technical-context.md
ANCHOR_LINE=$(grep '<!-- Anchor -->' <context-root>/technical-context.md | head -1)

# Estrazione Bubble-up target con sed (field dopo "Bubble-up target**: ")
BUBBLE_TARGET=$(echo "$ANCHOR_LINE" | sed 's/.*\*\*Bubble-up target\*\*: //' | sed 's/ *$//')
# Valori attesi: "—" | "<path>"
```

Il parsing deve essere robusto ai separatori `·` (U+00B7); si estrae il campo leggendo tutto ciò che segue `**Bubble-up target**: ` fino a fine riga.

### Reference `references/finalize.md`

Nuovo file. Il SKILL.md lo referenzia con un link singolo (pattern "SKILL.md sottile + reference lazy"). Struttura shape:

```markdown
# Finalize — Planner

> Letto da SKILL.md § "finalize <scope>" allo step di chiusura task.
> Dipendenze: ../planning-source-contract.md (risoluzione), ../anchor-schema.md (parsing).

## Step 1 — Risoluzione slug / source
[identico all'algoritmo di expand, Step 1]

## Step 2 — Gate attended
[verifica RESULT.json + ESCALATION.json]

## Step 3 — Risoluzione anchor del padre
[parsing <!-- Anchor --> in technical-context.md, estrazione Bubble-up target]

## Step 4 — Lettura decisioni del brief
[sezione Decisioni tecniche + Deviazioni]

## Step 5 — Aggiornamento technical-context.md (locale)
[domanda obbligatoria, append-only]

## Step 6 — Finalizzazione brief
[Status: ✅ finalized in header]

## Step 7 — Aggiornamento SKILL.md
[sostituisce stub, aggiunge link]

## Step 8 — Summary
[formato canonico]
```

### Aggiornamento SKILL.md

La sezione `### finalize <scope>` in `skills/planner/SKILL.md` attualmente è:

```markdown
### finalize <scope>

> Rimandato — feature `planner-unification-finalize`.
```

Va sostituita con:

```markdown
### finalize <scope>

Chiude un task: verifica il gate attended (RESULT.json + assenza ESCALATION.json),
risolve l'anchor del padre, aggiorna technical-context.md locale (append-only),
e prepara il bubble-up single-hop selettivo.
Logica completa: `references/finalize.md`.
```

### Gate attended — contratto di lettura

```
.flow/briefs/<id>/
  RESULT.json     → { "verify": "pass" | "fail", ... }  (obbligatorio)
  ESCALATION.json → se esiste → gate bloccato             (opzionale, assenza = OK)
```

Il task corrente (`<id>`) è ricavato dall'ID del task nella source risolta al Step 1 (il task che si sta finalizzando, non lo scope della source). In modalità attended il PM passerà l'ID direttamente; in modalità standalone l'utente specifica l'ID task.

### Logica no-op di risalita

```
Anchor assente         → no-op (back-compat)
Parent: —              → no-op (standalone esplicito)
Bubble-up target: —    → no-op (esplicito, nessun padre)
Bubble-up target: <path> → memorizza per 003 (questo task non esegue la risalita)
```

Il no-op deve essere comunicato all'utente in modo esplicito nel summary, non silenzioso.

---

## File impattati

| File | Stato | Note |
|---|---|---|
| `skills/planner/references/finalize.md` | [new] | Reference del modo finalize — gate + risoluzione anchor + finalizzazione locale |
| `skills/planner/SKILL.md` | [edit] | Sostituire stub `### finalize <scope>` con flusso reale + link a `finalize.md` |

---

## Vincoli risolti

- **Stack**: Markdown + bash (skill Claude Code; nessun build/compilazione)
- **Librerie + versioni**: nessuna
- **VO/pattern/interfacce consumati** (da NON modificare):
  - Anchor schema (`skills/planner/anchor-schema.md`) — formato canonico `<!-- Anchor -->`, campo `Bubble-up target`, semantica `—` vs path, back-compat "anchor assente"
  - Planning source contract v2 (`skills/planner/planning-source-contract.md`) — algoritmo scan 4 tier, esclusione `docs/archive/**`, ID opachi, path brief co-locato `<context-root>/tasks/<id>.md`
  - Pattern "SKILL.md sottile + reference lazy" — SKILL.md delega al reference
  - Pattern "append-only datato con guardia di idempotenza" — sezione `## Consolidato da <slug> (YYYY-MM-DD)` (usato in 003; questo task prepara solo la struttura)
  - Contratto gate attended (`.flow/briefs/<id>/RESULT.json` + `ESCALATION.json`) — già consumato da `task-implementer` (attended-flow.md); identico contratto
- **Naming convention**:
  - Reference: `skills/planner/references/<modo>.md` (kebab-case, lowercase) — coerente con `expand.md`
  - Heading sezione SKILL.md: `### finalize <scope>` (invariato)
  - Status brief: `✅ finalized` (coerente con task-implementer)

---

## Decisioni tecniche

- **Gate prima di tutto**: il gate attended è la prima operazione dopo la risoluzione della source. Se non passa, nulla viene modificato. Il principio è "fail early, fail loud".
- **Risoluzione anchor separata dal bubble-up**: questo task risolve solo l'anchor e determina se c'è un target di risalita; il bubble-up effettivo è in 003. Separazione netta delle responsabilità: 002 = infrastruttura, 003 = risalita.
- **No-op esplicito per source standalone**: se `Bubble-up target: —` o anchor assente, il finalize completa la finalizzazione locale senza errori. Il no-op è segnalato nel summary (non silenzioso), così l'utente sa che non avverrà risalita.
- **Gate: ID task vs scope della source**: la source è identificata dallo slug (`expand planner-unification-finalize`); il gate attended usa l'ID del task specifico che si finalizza (`planner-unification-finalize-002`). Sono cose distinte; il brief documenta la disambiguazione.
- **tasks-active.md non toccato**: coerente con task-implementer — la skill di planning non gestisce lo stato nei tasks-file; quello è responsabilità dell'utente o di project-planner.
- **SKILL.md aggiornato in questo task**: lo stub `### finalize <scope>` è aggiornato qui (non in 003), perché la struttura del flusso è definita da questo task. Il 003 aggiungerà solo la logica di bubble-up nel reference `finalize.md`.

---

## Out of scope per questo task

- Bubble-up single-hop selettivo (selezione sottoinsieme coerente, append datato idempotente) → planner-unification-finalize-003
- Invocazione di `finalize` da flow-run → feature downstream dell'epic
- Retrofit dell'anchor sulle source esistenti → feature release
- Gestione dei casi limite (re-run idempotente, conflitto, catena multi-livello) → planner-unification-finalize-004

---

## Dipendenze

- **Upstream**: planner-unification-finalize-001 ✅ finalized — `expand.md` e pattern di risoluzione slug in `references/expand.md` sono il template operativo per la risoluzione slug in `finalize`
- **Downstream**: planner-unification-finalize-003 — consuma il `Bubble-up target` risolto da questo task

---

## Verifica

Dogfooding manuale:

1. Invocare `finalize planner-unification-finalize-002` senza `RESULT.json` → gate bloccato, messaggio `"BLOCKED: finalize negato — verify=mancante"`.
2. Creare `RESULT.json` con `"verify": "fail"` → gate bloccato, messaggio `"BLOCKED: finalize negato — verify=fail"`.
3. Creare `ESCALATION.json` con `RESULT.json` a `"pass"` → gate bloccato, messaggio `"BLOCKED: finalize negato — escalation aperta"`.
4. Gate ok (`RESULT.json verify=pass`, no escalation): invocare su source con `Bubble-up target: —` → no-op risalita, summary lo esplicita.
5. Gate ok su source con anchor valorizzato → summary riporta il `Bubble-up target` risolto.
6. Verificare che SKILL.md non contenga più lo stub "Rimandato" per `finalize`; link `references/finalize.md` risolve (file esiste).
7. Verifica `0 link orfani`: grep di `finalize.md` in SKILL.md + file esiste.

Subtask: nessuno necessario, esecuzione lineare.

---

Generato: 2026-06-02 | Task: planner-unification-finalize-002
