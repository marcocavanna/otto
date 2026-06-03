# Context — Epic: Fast Path — esecuzione `solo` (`fast-path`)

**Progetto**: otto (plugin Claude Code per planning → brief → code)
**Tipo**: epic (più feature sequenziali) su progetto esistente

<!-- Anchor -->
**Tier**: epic
**Parent**: —
**Bubble-up target**: —

## Cosa realizza l'epic
Fa sì che `flow-run` **consumi** la `Complessità (ipotesi)` già emessa dal `planner` (campo del task-entry, contratto v2) per scegliere la **topologia di esecuzione** di ogni task: un solo agente (`solo`) per i task leggeri (`trivial`/`standard`), il flusso PM+DEV (`team`) per i `critical`. È il **consumo a valle** esplicitamente previsto e rimandato da `planner-unification` (ASSUMPTION-planner-unification-007). Riduce il costo dei task leggeri da **2 spawn** (PM brief + DEV implement; il finalize è già inline in 2.0.0) a **1 spawn**, **senza** degradare gli artefatti versionati. Una rete di sicurezza **pre-write** (pre-analisi read-only che promuove `solo → team` su trigger misurabili) protegge dalle sottostime del planner prima di toccare il codice. Sblocca otto 2.1.0.

## Derivato dal codebase
- **Aree/moduli toccati (d'insieme)**: `skills/flow-run/SKILL.md` (selezione modalità + loop), `skills/flow-run/references/model-tiering.md` (nuova mappa `complexity → execution-mode`; candidata a rinomina in `execution-tiering.md`), `agents/` (nuovo agente `solo` o estensione), `skills/task-implementer/SKILL.md` + `skills/code-implementer/` (percorso artefatti in modalità solo), `hooks/scope-check.sh` + `hooks/verify-gate.sh` (riuso invariato della rete hook), `.claude-plugin/{plugin,marketplace}.json` + `README.md` (release).
- **Stack pertinente**: skill Markdown (SKILL.md sottile + `references/` a lettura lazy), agenti con hook nel frontmatter (`agents/*.md`), hook bash (`hooks/`), nessun runtime compilato.
- **Convenzioni rilevate**: single-source dei contratti (la mappa `complexity → policy` vive in un solo file, linkata non duplicata); reference funzione-specifici a lettura lazy; ID task opachi; mirror non-canonici (`PROGRESS.json` è la verità d'esecuzione); enforcement delle scritture via hook registrati **nel frontmatter dell'agente** (non globali).
- **Build/test command**: nessuno (plugin di markdown). "Test" = **dogfooding**: pianificare ed eseguire end-to-end via le skill stesse.

## Decomposizione in feature
- **Criterio di split**: per dipendenza tecnica reale e per **sicurezza incrementale**. Prima il percorso esecutivo `solo` completo e auto-sufficiente (`fast-path-solo`): già sicuro perché le sottostime degradano sull'**escalation post-write esistente**. Poi la rete di sicurezza **pre-write** (`fast-path-promotion`): la pre-analisi read-only che intercetta la sottostima *prima* di scrivere e promuove a `team`. La seconda feature consuma e indurisce la prima.
- **Tronco comune**: la mappa `complexity → execution-mode` in `model-tiering.md` (estende l'asse `complexity → {modello, dry-run, finalize}` già esistente) + la lettura **a monte** della `Complessità (ipotesi)` dal tasks-file da parte di `flow-run`, **prima** di qualunque spawn. Entrambi nascono in `fast-path-solo` e sono seed condiviso.

## Boundary e scope d'insieme
- **In scope (epic)**: consumo della complessità a priori per la scelta `solo`/`team`; nuovo percorso esecutivo single-spawn che produce artefatti **identici** a oggi; pre-analisi read-only con promozione `solo → team`; release 2.1.0.
- **Fuori scope (epic)**: la modalità **`inline`** (0 spawn, scrittura dal main-thread) — **deliberatamente rimandata** (ASSUMPTION-fast-path-002): bypasserebbe gli hook `scope-check.sh`/`verify-gate.sh` che vivono solo su `agents/dev.md`, rimuovendo la rete di sicurezza strutturale di otto; va progettata a parte. Fuori scope anche: cambiare la **struttura** degli artefatti versionati (resta identica), riscrivere gli hook, l'esecuzione automatica multi-source di `flow-run` (resta one-source-per-run), il parallelismo dei flow.
- **Integrazione con l'esistente**: gli artefatti versionati (`<context-root>/tasks/<id>.md` + append `technical-context.md`) restano **identici** in struttura; cambia solo l'**ordine di produzione** in modalità solo (prima l'implementazione, poi il brief che riflette la realtà — vedi ASSUMPTION-fast-path-003). La rete hook (`scope-check` + `verify-gate`) è **riusata invariata**: l'agente `solo` è un subagent con gli stessi hook nel frontmatter, quindi le scritture restano gate-ate e il verify resta imposto. `team` resta bit-per-bit il flusso 2.0.0.

## Tracked assumptions (condivise)
### ASSUMPTION-fast-path-001
- **Descrizione**: mappa `complexity → execution-mode` (con `inline` fuori scope).
- **Scelta**: `trivial → solo`, `standard → solo`, `critical → team`. Allinea il confine `solo`/`team` ai confini **già esistenti** in `model-tiering.md` (dry-run: skip su trivial/standard; finalize-inline: ammesso su trivial/standard; finalize PM: solo critical). Il cluster "trivial/standard" è già trattato come a-basso-cerimoniale; `solo` ne è l'estensione coerente.
- **Alternative valutate**: (a) solo `trivial → solo`, `standard → team` (più cauto, ma `standard` salta già dry-run e finalize-PM: trattarlo come `team` sarebbe incoerente); (b) includere `inline` (scartato, ASSUMPTION-002).
- **Fallback**: se il dogfooding mostra `solo` troppo debole su `standard`, ripiegare su `trivial → solo` / `standard → team` senza toccare il resto del meccanismo.
- **Impatta**: 02-abstract.md / technical-context.md / feature: `fast-path-solo`. **Status**: active. **Data**: 2026-06-03

### ASSUMPTION-fast-path-002
- **Descrizione**: `inline` (0 spawn) **fuori scope** in 2.1.0.
- **Scelta**: implementare solo `solo` e `team`. `inline` rimandata a una release dedicata.
- **Razionale**: gli hook che rendono sicure le scritture di otto — `scope-check.sh` (PreToolUse) e `verify-gate.sh` (SubagentStop) — sono registrati **nel frontmatter di `agents/dev.md`**, quindi valgono **solo per i subagent**. In `inline` scriverebbe il main-thread (l'orchestratore), che **non ha** quegli hook: niente scope-gate, niente verify-gate, oltre all'inquinamento del contesto dell'orchestratore (contro il principio "stato nei file, regge la compattazione"). Recuperare quelle garanzie come logica inline costerebbe la complessità che `inline` doveva risparmiare. `solo` cattura ~90% del valore a una frazione del rischio perché **riusa** la rete hook (è un subagent).
- **Alternative valutate**: implementare `inline` dietro flag + trigger durissimi (scartato per 2.1.0: superficie di rischio sproporzionata al guadagno marginale di 1 spawn).
- **Impatta**: scope d'insieme. **Status**: active. **Data**: 2026-06-03

### ASSUMPTION-fast-path-003
- **Descrizione**: ordine di produzione degli artefatti in modalità `solo`.
- **Scelta**: in `solo` l'agente **prima** analizza+implementa+verifica, **poi** scrive il brief co-locato `<context-root>/tasks/<id>.md` (Vincoli risolti · File impattati · Shape · Deviazioni · `Status: finalized`) riflettendo la **realtà** implementata, ed esegue l'eventuale append a `technical-context.md`. In `team` l'ordine resta invariato (brief forward → implement → finalize). **Struttura identica, ordine diverso.**
- **Razionale**: in `team` il brief è analisi *forward* perché serve a passare il lavoro al DEV (handoff via file). In `solo` non c'è handoff: l'agente è anche l'implementatore, quindi il brief è documentazione *post-hoc* — più aderente alla realtà (la sezione Shape riflette ciò che è stato davvero scritto). Il vincolo non-negoziabile (artefatti identici in struttura) è rispettato.
- **Impatta**: `fast-path-solo` (contratto dell'agente solo), technical-context.md. **Status**: active. **Data**: 2026-06-03

### ASSUMPTION-fast-path-004
- **Descrizione**: nuovo agente `solo` vs estensione di `dev`/`pm`.
- **Scelta**: **nuovo agente** `agents/solo.md` che compone le responsabilità d'artefatto del PM (brief + technical-context) e l'implementazione del DEV in un solo subagent, con gli **stessi hook** di `dev` (`scope-check` su Write|Edit|Bash, `verify-gate` su SubagentStop) e i tool `Read, Write, Edit, Bash, Grep, Glob`. Bootstrap dello `scope.txt`: l'agente materializza i propri contratti in `.flow/briefs/<task>/` (già consentito dal ramo bootstrap di `scope-check.sh`), poi le scritture di codice restano gate-ate dallo `scope.txt`. Modello: derivato dalla complessità (haiku per trivial, sonnet per standard), come la mappa esistente.
- **Alternative valutate**: estendere `dev` perché produca anche brief/technical-context (scartato: il reading-set del DEV è volutamente stretto — solo il brief — e il DEV non tocca `technical-context.md`; conflondere i ruoli sporca la separazione PM/DEV e l'enforcement di scope per ruolo).
- **Impatta**: `fast-path-solo` (agente + reading-set), `hooks/` (riuso, non modifica). **Status**: active. **Data**: 2026-06-03

### ASSUMPTION-fast-path-005
- **Descrizione**: degrado conservativo della selezione modalità.
- **Scelta**: `Complessità (ipotesi)` assente nel task-entry / fuori dall'enum `{trivial, standard, critical}` → modalità **`team`** (MAI `solo`), + nota nel summary. Stesso spirito fail-safe del degrado di `model-tiering.md` (default `sonnet`, mai `haiku`).
- **Razionale**: in dubbio sulla complessità si sceglie il flusso con più presidi (PM brief forward + gate del finalize), non il più veloce.
- **Impatta**: `fast-path-solo` (regola di selezione in flow-run). **Status**: active. **Data**: 2026-06-03

## Known risks (cross-feature)
### RISK-fast-path-001 — Auto-modifica a runtime (dogfooding)
- **Severità**: 🔴
- **Descrizione**: `fast-path-solo` riscrive `flow-run` (l'orchestratore) e introduce un nuovo agente: le feature potrebbero essere eseguite **con** l'orchestratore che stanno modificando. Identico a RISK-planner-unification-001.
- **Mitigazione**: branch dedicato già creato (`epic/fast-path-solo-mode`); commit per feature; valutare l'esecuzione **manuale** (non via `flow-run`) della feature che tocca `flow-run`/`agents`; le feature si toccano in ordine, l'orchestratore per primo ma su branch isolato.

### RISK-fast-path-002 — `solo` troppo debole sul modello derivato
- **Severità**: 🟡
- **Descrizione**: `solo` su `trivial` gira su `haiku` e deve fare analisi **+** implementazione **+** documentazione in un solo contesto. Su un task mal classificato può produrre artefatti scadenti o codice errato.
- **Mitigazione**: (a) la pre-analisi read-only di `fast-path-promotion` promuove a `team` prima di scrivere quando il task si rivela più grande; (b) il `verify-gate` (SubagentStop) impone comunque il verify; (c) i fail post-write restano sull'escalation esistente; (d) fallback di ASSUMPTION-001 (`standard → team`) se il dogfooding lo richiede.

### RISK-fast-path-003 — Pre-analisi che promuove troppo (o troppo poco)
- **Severità**: 🟡
- **Descrizione**: trigger di promozione troppo larghi → `solo` promuove quasi sempre a `team` e il guadagno svanisce; troppo stretti → sottostime sfuggono al pre-write e cadono (più costosamente) sull'escalation post-write.
- **Mitigazione**: lista di trigger **misurabili** e chiusa (vedi `fast-path-promotion`/02-abstract); bias verso la rarità della promozione perché il planner **sovrastima** in dubbio (fail-safe verso l'alto, già principio in `task-expansion.md`); i fail post-write restano comunque coperti dall'escalation.

---
Generato: 2026-06-03 | Versione: 1
