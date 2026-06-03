# Abstract tecnico — Epic: Fast Path — esecuzione `solo` (`fast-path`)

## Approccio d'insieme
Estendere l'asse **`complexity → policy`** già esistente in `skills/flow-run/references/model-tiering.md`. Oggi quella single-source mappa `complexity` su tre policy (modello DEV, dry-run sì/no, modello finalize). Si aggiunge una **quarta** policy — la **topologia di esecuzione** (`execution-mode`) — e si insegna a `flow-run` a leggere la `Complessità (ipotesi)` **dal tasks-file, a monte**, prima di qualunque spawn, per selezionarla. Nessun nuovo modello mentale: una colonna in più su una tabella che già governa il comportamento per complessità.

Il percorso `team` resta **bit-per-bit** il flusso 2.0.0 (PM brief → [dry-run] → DEV implement → finalize inline/PM). Il percorso `solo` è un **subagent unico** (`agents/solo.md`) che, con gli **stessi hook** di `dev`, fa pre-analisi + implementazione + verifica + produzione degli artefatti versionati. La rete di sicurezza di otto (scope-gate su ogni scrittura, verify-gate alla chiusura) è **riusata**, non reinventata: `solo` è un subagent, quindi i suoi hook di frontmatter valgono.

## Decisioni tecniche condivise
- **Single-source della mappa**: la mappa `complexity → execution-mode` vive **solo** in `model-tiering.md` (candidato a rinomina `execution-tiering.md` se il nome "model" diventa fuorviante con 4 policy — vedi sotto). `flow-run` la consuma, non la ridefinisce. Stesso pattern delle 3 mappe esistenti.
- **Lettura a monte della complessità**: `flow-run` legge la `Complessità (ipotesi)` dal **tasks-file** (`<context-root>/tasks-active.md`, schema task-entry del contratto v2) al passo di selezione del task, **prima** dello spawn. È distinta dal `meta.json` che il PM emette al brief: quel dato arriva troppo tardi per decidere *se* spawnare il PM (chicken-and-egg già notato in ASSUMPTION-planner-unification-007). Nel percorso `team` il `meta.json` del PM resta l'autorità che **raffina** modello/dry-run/finalize (invariato).
- **Selezione modalità, fail-safe**: `trivial`/`standard` → `solo`; `critical` → `team`; complessità assente/fuori-enum → `team` (degrado conservativo, ASSUMPTION-fast-path-005). Override utente esplicito possibile (vedi sotto), effimero come gli altri override di `flow-run`.
- **Agente `solo`**: nuovo `agents/solo.md`, tool `Read, Write, Edit, Bash, Grep, Glob`, hook identici a `dev` (`scope-check` PreToolUse su Write|Edit|Bash, `verify-gate` Stop→SubagentStop). Legge le regole-ambiente del repo + le istruzioni di **entrambe** le skill (`task-implementer` per la produzione di brief/technical-context, `code-implementer` per l'implementazione/verifica), a lettura lazy. Modello derivato dalla complessità (haiku/sonnet), come la mappa esistente.
- **Artefatti identici, ordine invertito**: ASSUMPTION-fast-path-003. `solo` produce `<context-root>/tasks/<id>.md` completo (Vincoli risolti · File impattati · Shape · Deviazioni · `Status: finalized`) + append `technical-context.md` quando ci sono decisioni cumulative — **post-implementazione**, riflettendo la realtà. L'orchestratore applica il **gate del finalize** (`RESULT.verify=="pass"`, nessuna escalation) prima di accettare la chiusura, come per il finalize-inline esistente.
- **Promozione pre-write monodirezionale**: `solo → team` (mai `inline → solo`, perché `inline` è fuori scope). La promozione avviene **prima** di toccare il codice (working tree pulito → re-run sicuro a tier superiore). I fail **post-write** (build/verify falliti, deviazione di scope rilevata a scrittura avvenuta) restano sull'**escalation esistente** e **non** promuovono mai (eviterebbero un re-run su working tree sporco).

## Contratti da preservare
- **`<context-root>/tasks/<id>.md`**: struttura e sezioni obbligatorie invariate (contratto in `skills/task-implementer/references/brief-template.md` + `planning-source-contract.md` § "Vincoli risolti"). Diventa `frozen.txt` lato flow per le feature che lo toccano.
- **Schema task-entry v2** (`planning-source-contract.md` § "Schema task-entry"): il campo `Complessità (ipotesi)` è **consumato** così com'è, non modificato. Nessun nuovo campo nel tasks-file.
- **Rete hook** (`hooks/scope-check.sh`, `hooks/verify-gate.sh`, `hooks/flow-lib.sh`): **consumata invariata**. `flow_resolve_task` risolve il task dalla source sotto lock indipendentemente dal ruolo del subagent (dev o solo): l'agente `solo` ne eredita la protezione senza modifiche all'hook.
- **`PROGRESS.json` per-source + protocollo lock/heartbeat/index**: invariati. La modalità non entra in alcun contratto su disco: è una derivazione **effimera** dell'orchestratore (come modello/dry-run).
- **`team`**: il flusso 2.0.0 resta il default per i `critical` e il bersaglio di ogni promozione. Nessuna regressione ammessa.

## Trade-off
- **1 spawn vs presidio doppio**: `solo` rinuncia alla separazione PM↔DEV (due contesti, due gate naturali) per risparmiare uno spawn. Compensato dalla pre-analisi read-only (promozione) e dal verify-gate invariato. Accettato per `trivial`/`standard`, mai per `critical`.
- **Più contesto in un solo agente**: `solo` carica le istruzioni di due skill (task-implementer + code-implementer) a lettura lazy. È il prezzo del single-spawn; mitigato dalla natura leggera dei task a cui `solo` si applica (lazy reading: niente `build-verification.md`/`decision-classification.md` upfront su trivial/standard, come già fa `dev`).
- **Seed copiato, non risolto**: la mappa è single-source, ma `flow-run` la consuma via lettura del reference (come oggi). Nessun trade-off nuovo rispetto a 2.0.0.

## Rischi tecnici cross-feature
Vedi `00-context.md` § "Known risks": RISK-fast-path-001 (auto-modifica a runtime), -002 (`solo` debole sul modello derivato), -003 (pre-analisi che promuove male). Mitigazioni lì.

## Esclusioni tecniche
- **`inline`** (ASSUMPTION-fast-path-002): non si tocca il main-thread come scrittore di codice.
- **Modifica della struttura degli artefatti**: vietata (vincolo non-negoziabile).
- **Nuovi campi nel tasks-file o nuovi file di contratto su disco**: la modalità è effimera, non persistente.
- **Parallelismo flow / multi-source per run**: invariato, fuori scope.
- **Rinomina `model-tiering.md → execution-tiering.md`**: **opzionale**, da valutare in `fast-path-solo` solo se la rinomina **non** rompe i ~N link entranti (single-source linkata da più file); se rischiosa, si tiene il nome attuale e si aggiorna solo il titolo/scopo interno. Non è un obiettivo, è un'igiene eventuale.

---
Generato: 2026-06-03 | Versione: 1
