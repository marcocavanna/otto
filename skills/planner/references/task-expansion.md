# Task expansion

> Reference condiviso della skill `planner`. **Tier-agnostico**: "milestone" diventa "scope" — l'unità che
> si espande in task atomici è la milestone per il tier `project`, la feature per il tier `feature`, ecc.
> Lo **schema task-entry è canonico** in `../planning-source-contract.md` § "Schema task-entry": questo file
> NON lo ridefinisce, descrive le **regole operative** di espansione e l'**euristica di assegnazione** del
> campo `Complessità (ipotesi)`.

Regole per generare task atomici quando l'utente espande uno scope (`plan` di tier `project`/`feature`, oppure `expand` in feature `finalize`).

## Granularità

Ogni task atomico deve rispettare TUTTE queste regole:

1. **Effort tra 1 e 4 ore**. Più piccolo è frammentazione inutile; più grande tende a procrastinazione.
2. **Definition of done concreta e binaria**. "Implementata l'autenticazione" è vago. "Endpoint POST /login restituisce JWT valido per credenziali corrette e 401 altrimenti, verificato con test" è concreto.
3. **Indipendente quanto possibile**. Se task A blocca task B, esplicitare la dipendenza.
4. **Verbo all'infinito + oggetto specifico**. "Configurare", "Implementare", "Scrivere", "Testare", "Documentare".

## Anti-pattern da evitare

- ❌ "Setup progetto" → troppo vago. Scomporre.
- ❌ "Fix bug" → non è un task pianificabile, è una scoperta.
- ❌ "Refactor" senza target specifico → scope indefinito.
- ❌ "Migliorare performance" → quanto? Su cosa?
- ❌ "Studiare X" → non è un task del piano. Se serve studiare X, è uno spike (vedi sotto).

## Categorie di task

Etichettare ogni task con una categoria per dare visibilità sulla composizione del lavoro:

- 🏗️ **setup** — infrastruttura, tooling, configurazione iniziale
- 💻 **impl** — implementazione logica/UI
- 🧪 **test** — test automatici, validazione
- 📚 **docs** — documentazione (README, API docs, ADR)
- 🔬 **spike** — esplorazione tecnica time-boxed, output = decisione
- 🚀 **deploy** — release, CI/CD, deploy
- 🔧 **fix** — solo se il task arriva da un bug noto, non placeholder generico

## Assegnazione `Complessità (ipotesi)`

Per ogni task generato emettere il campo `Complessità (ipotesi)` ∈ {`trivial`, `standard`, `critical`}. È una **stima a priori** del planner: serve a orientare il downstream (`task-implementer` la raffina nel `meta.json`).

> **Lo schema dell'enum è canonico** in `../planning-source-contract.md` § "Campo `Complessità (ipotesi)`" — stesso enum di `skills/task-implementer/references/complexity-criteria.md`. Qui se ne definisce solo l'**euristica di assegnazione**, non lo schema.

Euristica operativa:

- **`trivial`**: 1 file, nessun contratto nuovo, nessuna dipendenza upstream critica; tipo setup/config/dto.
- **`standard`**: 2-3 file, consuma contratti esistenti senza introdurne di nuovi, dipendenze lineari; tipo impl/repository/query-handler.
- **`critical`**: introduce contratti nuovi consumati da altri task, >3 file impattati, oppure tipo domain-entity/value-object/cross-cutting.

Regola di fail-safe: **in dubbio tra due tier adiacenti, scegliere il più alto** (coerente con la filosofia di `complexity-criteria.md`). Sottostimare la complessità è più costoso che sovrastimarla.

> Questa è una stima a priori del planner; il PM (`task-implementer`) la raffina nel `meta.json` al momento del brief. Lo schema canonico dell'enum vive in `../planning-source-contract.md`.

## Composizione attesa per scope

Per uno scope di tipo "Foundation" (la prima milestone tipica):
- ~30% setup, ~50% impl, ~10% test, ~10% docs.

Per uno scope "Vertical slice":
- ~10% setup, ~70% impl, ~15% test, ~5% docs.

Per uno scope "Release":
- ~10% impl, ~20% test, ~30% docs, ~40% deploy.

Se la composizione si discosta molto, segnalarlo all'utente prima di salvare.

## Spike

Se durante l'espansione emergono incognite tecniche significative, prima dei task impl mettere uno o più spike:

```
### <id> — 🔬 [spike] Verificare se [tecnologia] supporta [requisito]
- **Effort**: 2-3h
- **Definition of done**: documento aggiornato (es. 02-abstract.md § "Trade-off") + scelta giustificata
- **Dipende da**: —
- **Complessità (ipotesi)**: standard
- **Status**: ⚪ todo
```

Gli spike sono time-boxed. Se uno spike supera il budget, va chiuso comunque con la migliore informazione disponibile, non esteso silenziosamente.

## Formato del tasks-file (post-expand)

Il tasks-file di una source (`05-tasks-active.md` per `project`, `tasks-active.md` per `epic`/`feature`/`task`) contiene le entry di task. Schema **canonico** in `../planning-source-contract.md` § "Schema task-entry":

```markdown
### <id> — <emoji> [<tipo>] <titolo>
- **Effort**: X-Yh
- **Definition of done**: [concreta, binaria, verificabile]
- **Dipende da**: <id> | —
- **Complessità (ipotesi)**: trivial | standard | critical
- **Status**: ⚪ todo | 🔵 in progress | ✅ done | ⏸ blocked
```

L'intestazione del tasks-file dichiara lo **scope attivo** secondo il tier:
- `project` → `**Milestone attiva**: M[N] — [nome]`
- `epic` → (l'epic non ha un proprio tasks-file: espande le feature figlie)
- `feature` → `**Feature**: <slug>`
- `task` → `**Tier**: task` (esattamente 1 task-entry — vedi `../task-bundle-spec.md`)

Gli altri campi di intestazione (effort totale, definition of done dello scope) e le sezioni "Note operative" / "Out of scope" sono in `artifact-contract.md` § per tier.

## Numero di task per scope

- Scope foundation (M1 di un project): 15-25 task tipicamente.
- Scope intermedi (slice/beta): 10-20 task.
- Scope leggeri (release, polish): 5-10 task.
- Una **feature**: 1-8 task (se >~10 → valuta split o promozione a milestone/epic).
- Un **task** (tier `task`): esattamente 1 task-entry — è una proprietà definitoria, vedi `../task-bundle-spec.md`.

Se uno scope supera i 30 task atomici → è troppo grande, va spezzato. Sollevare il punto con l'utente prima di salvare.

## Espansione di uno scope diverso dall'attivo

Solo per i tier che hanno più scope sequenziali (`project`: milestone). Quando l'utente chiede di espandere uno scope diverso da quello attivo:

1. Confermare: "M1 è attualmente attiva. Vuoi davvero saltare a M[N]? I task atomici di M1 saranno persi (resta solo lo scope macro)."
2. Se confermato, sovrascrivere il tasks-file.
3. Aggiornare lo status degli scope nel file roadmap/milestones:
   - Scope precedente: chiedere se è done o paused.
   - Nuovo scope: status diventa 🔵 active.
4. Aggiornare il README/indice se presente.

## Re-expand dello stesso scope

Se l'utente chiede di rifare l'expand dello scope già attivo (perché il contesto è cambiato o vuole task diversi):

1. Backup del tasks-file in `<tasks-file>.bak` (overwrite il backup precedente se esiste).
2. Generare nuova versione.
3. Segnalare all'utente che il backup esiste.
