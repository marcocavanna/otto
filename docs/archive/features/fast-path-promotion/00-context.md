# Context — Feature: Promozione pre-write `solo → team` (`fast-path-promotion`)

**Progetto**: otto (plugin Claude Code per planning → brief → code)
**Epic**: fast-path
**Dipende da feature**: fast-path-solo

<!-- Anchor -->
**Tier**: feature
**Parent**: fast-path
**Bubble-up target**: docs/epics/fast-path/technical-context.md

## Cosa realizza la feature
Aggiunge alla modalità `solo` una **rete di sicurezza pre-write**: prima di toccare il codice, l'agente `solo` esegue una **pre-analisi read-only** che valuta una lista **chiusa e misurabile** di trigger. Se uno scatta, l'agente emette `RESULT.promote=true` (+ motivo) **senza aver scritto nulla** e termina; `flow-run` ri-esegue il task in modalità `team` (working tree pulito → re-run sicuro). Intercetta le **sottostime del planner** *prima* del codice, anziché lasciarle cadere — più costosamente — sull'escalation post-write. Contributo alla DoD epic: la rete pre-write che indurisce il percorso `solo`.

## Derivato dal codebase
- **Aree/moduli toccati**: `agents/solo.md` (step di pre-analisi read-only + emissione `RESULT.promote`), `skills/flow-run/SKILL.md` (lettura di `RESULT.promote` → re-run in `team`; semantica monodirezionale), il contratto `RESULT.json` (nuovo campo `promote`), un reference con la **lista trigger** (probabilmente sotto `skills/flow-run/references/` o `skills/code-implementer/`, da decidere a expand).
- **Stack pertinente**: skill/agenti Markdown; nessun runtime. Riusa il contratto `RESULT.json`/`ESCALATION.json` esistente.
- **Convenzioni rilevate**: pre-write vs post-write (escalation esistente = post-write); trigger misurabili come quelli dei segnali di `complexity-criteria.md`; derivazione effimera dell'orchestratore.
- **Build/test command**: nessuno. Verifica = dogfooding (task deliberatamente sottostimato → promozione osservabile).

## Boundary e scope (feature)
- **In scope**: lista **chiusa e misurabile** di trigger read-only; step di pre-analisi nell'agente `solo`; campo `promote` in `RESULT.json`; gestione di `RESULT.promote` in `flow-run` (re-run del task in `team`, monodirezionale `solo → team`); annotazione nel summary; idempotenza del re-run (la promozione non lascia residui su disco perché è pre-write).
- **Fuori scope**: promozione `inline → solo` (inline è fuori scope dell'epic); modificare la semantica dei fail **post-write** (restano sull'escalation esistente, non promuovono mai); auto-tuning dei trigger; promozione **discendente** (`team → solo`, mai).
- **Integrazione con l'esistente**: l'escalation post-write (step 7 di `flow-run`, `ESCALATION.json`) resta il canale per i fail a scrittura avvenuta ed è **invariata**. La promozione è un canale **distinto e pre-write** (`RESULT.promote`). Se la pre-analisi non scatta, il comportamento è esattamente quello di `fast-path-solo`.

## Tracked assumptions (specifiche)
> Assunzioni condivise dell'epic vincolanti: vedi `docs/epics/fast-path/00-context.md`.

### ASSUMPTION-fast-path-promotion-001
- **Descrizione**: lista trigger **chiusa e misurabile** (non "quelli dell'escalation").
- **Scelta**: solo trigger **rilevabili read-only, pre-write** e **misurabili**:
  - **T1 — scope più ampio della complessità ipotizzata**: il task richiederebbe di toccare un numero di file incoerente con la complessità (segnale 3 di `complexity-criteria.md`: `>3` file su un task `trivial`; area di file fuori da quella ovvia del task).
  - **T2 — contratto cross-task non dichiarato**: il task introdurrebbe/modificherebbe un VO/interfaccia/formato-file consumato da **altri** task (segnale 1 di `complexity-criteria.md`, il più forte verso `critical`), non previsto dalla complessità `trivial`/`standard`.
  - **T3 — contraddizione con `technical-context.md`/`02-abstract.md`**: il task come compreso confligge con una decisione **vincolante** ereditata → richiede il giudizio di coerenza che è proprietà del PM (`task-implementer` regola 1).
  - **T4 — ambiguità che richiede una decisione di contratto** che l'agente `solo` non può prendere in sicurezza da solo.
- **Razionale**: sono esattamente i segnali che, se veri, qualificano il task come `critical` → la complessità a priori era una sottostima → serve `team`. Tutti valutabili **senza** scrivere codice.
- **Alternative valutate**: usare l'intero set di trigger d'escalation (scartato: include fail intrinsecamente **post-write** come il verify fallito, non promuovibili).
- **Impatta**: `agents/solo.md`, reference lista trigger. **Status**: active. **Data**: 2026-06-03

### ASSUMPTION-fast-path-promotion-002
- **Descrizione**: cosa NON promuove (confine pre/post-write).
- **Scelta**: i fail **post-write** — build/verify falliti, deviazione di scope rilevata a scrittura **avvenuta**, cambio di contratto emerso durante l'implementazione — **non** promuovono mai: restano sull'escalation esistente (`ESCALATION.json` → step 7). Promuovere dopo una scrittura significherebbe un re-run su **working tree sporco**.
- **Impatta**: `agents/solo.md` (la pre-analisi precede ogni Write/Edit di codice), `flow-run` (distinzione `RESULT.promote` pre-write vs `ESCALATION.json` post-write). **Status**: active. **Data**: 2026-06-03

### ASSUMPTION-fast-path-promotion-003
- **Descrizione**: direzione e idempotenza della promozione.
- **Scelta**: promozione **monodirezionale** `solo → team` (mai `team → solo`, mai `inline → *`). Poiché è **pre-write**, il re-run in `team` parte da working tree pulito e non richiede cleanup; eventuali `scope.txt`/`frozen.txt` materializzati dall'agente solo in `.flow/briefs/<task>/` sono sovrascritti dal PM al brief. Bias: la promozione è **rara** perché il planner sovrastima in dubbio (fail-safe verso l'alto, `task-expansion.md`).
- **Impatta**: `flow-run` (gestione re-run), `agents/solo.md`. **Status**: active. **Data**: 2026-06-03

## Known risks (feature)
### RISK-fast-path-promotion-001 — Trigger mal calibrati
- **Severità**: 🟡
- **Descrizione**: trigger troppo larghi → promozione quasi sistematica, guadagno di `solo` annullato; troppo stretti → sottostime sfuggono al pre-write.
- **Mitigazione**: lista chiusa e misurabile (ASSUMPTION-001); dogfooding su un task sottostimato per tarare; i fail post-write restano comunque coperti dall'escalation (la rete pre-write è un'ottimizzazione, non l'unica difesa).

---
Generato: 2026-06-03 | Versione: 1
