---
name: migrate
description: >-
  Migrate otto projects from old layout to canonical. Retrofit anchor headers on artifacts.
  Triggers: "migra il progetto", "migrate otto", "porta otto al nuovo layout", "migrate",
  "migrazione layout", "retrofit anchor", "aggiungi anchor agli artefatti".
  Fail-closed, idempotent, reversible, no auto-commits, post-verify delegated.
---

# Migrate — migrazione old→new layout + retrofit anchor

Skill con due operazioni distinte:

1. **Layout migration** (modalità `preview` / `apply` / `post-verify`): porta un progetto otto dal **vecchio layout** (`docs/tasks/` flat, nessun archivio, `.flow/PROGRESS.json` unico) al **layout canonico** definito da `topology-canonical`.
2. **Anchor retrofit** (modalità `anchor-retrofit preview` / `anchor-retrofit apply` / `anchor-retrofit post-verify`): inietta l'header anchor (`<!-- Anchor --> **Tier** · **Parent** · **Bubble-up target**`) negli artefatti esistenti che ne sono privi, derivando i valori dalla struttura del repo e dalle roadmap.

Entrambe le operazioni condividono gli stessi principi fondamentali. Opera sempre con cognizione: preview obbligatoria prima dell'apply, idempotente, reversibile, con post-verify.

## Principi non negoziabili

Questi principi non si possono derogare in nessuna modalità (layout migration **e** anchor retrofit):

1. **Fail-closed**: nel dubbio non si tocca nulla — si segnala come caso ambiguo nel report.
2. **Idempotente**: rieseguire apply su un repo già migrato/già retrofittato è un no-op. Nessun errore, nessun danno.
3. **Reversibile**: backup pre-apply dell'albero `docs/` in `docs/.bak-<timestamp>/` (copia integrale, timestamp distinto per ogni apply). La procedura di restore dal backup è documentata nel report di apply.
4. **Niente commit automatici**: la skill non esegue mai `git commit`. Per i move usa `git mv` quando il repo è git. Fallback: operazione normale + nota esplicita se il repo non è git.
5. **Post-verify obbligatorio**: dopo ogni apply, verificare l'esito per ogni artefatto/ID coinvolto. Report esplicito pass/fail. Apply senza post-verify è incompleto.

## Modalità — Layout migration

### preview (default)

Legge lo stato del repo, classifica ogni brief trovato in `docs/tasks/` e determina la destinazione. Non scrive nulla.

Output del preview:

```text
Move pianificati:
  docs/tasks/flow-sync-001.md  →  docs/features/flow-sync/tasks/flow-sync-001.md
  docs/tasks/flow-sync-002.md  →  docs/features/flow-sync/tasks/flow-sync-002.md
  ...

Source concluse da archiviare:
  docs/features/flow-sync/  →  docs/archive/features/flow-sync/

Casi ambigui (non verranno mossi):
  docs/tasks/T-099.md  — ID non risolve a nessuna source nota

Riepilogo: N move pianificati, M ambigui (non toccati).
Per procedere: "apply"
```

La preview termina sempre con un riepilogo actionable. Senza preview, l'apply si rifiuta di partire.

Gate dell'apply: la preview deve essere stata prodotta nella stessa sessione. Il controllo è sulla presenza del piano in memoria di sessione (non su un file disco — il manifest disco è prodotto dal protocollo di apply).

Dettaglio del rendering del piano e regola formale del gate: `references/preview.md`.

### apply

Esegue la migrazione secondo il piano prodotto dalla preview. Rifiuta di partire se nessuna preview è stata prodotta nella sessione corrente.

Sequenza operativa:

1. Verifica che la preview sia in sessione — abort se assente.
2. Backup: copia integrale di `docs/` in `docs/.bak-<timestamp>/` (operazione pre-condizione, non saltabile).
3. Per ogni move pianificato: `git mv` (o `mv` se non-git) idempotente. Se il file di destinazione esiste già, skip + log "già migrato".
4. Sposta le source concluse in `docs/archive/features/<slug>/`.
5. Scrive il manifest `docs/.bak-<timestamp>/apply-manifest.json` + report terminale con istruzioni di restore.
6. Post-verify: **delegato** al task dedicato (`references/post-verify.md`, topology-migration-005). L'apply non lo esegue inline: si conclude dopo il manifest/report e rimanda l'utente al post-verify.

Dettagli operativi (gate, backup con timestamp, idempotenza, manifest, reversibilità): `references/apply-protocol.md`.

## Detection

Logica di riconoscimento dello stato del repo (vecchio vs nuovo layout, mapping ID→source, classificazione dei casi ambigui):

Vedere `references/detection.md`.

## Post-verify

Dopo ogni apply, per ogni ID che era nel piano di migrazione:

- Il resolver canonico deve trovare esattamente un brief al path `<context-root>/tasks/<id>.md`.
- Nessun brief orfano deve restare in `docs/tasks/` per gli ID migrati.

Output: report pass/fail per ogni ID. Se anche un solo ID è fail, il report lo segnala in evidenza e suggerisce il recovery.

Dettaglio dell'algoritmo, edge case e forma canonica del report: `references/post-verify.md`.

---

## Modalità — Anchor retrofit

Retrofit dell'header anchor sugli artefatti di planning esistenti che ne sono privi. Logica completa (detection, inferenza tier/parent/bubble-up, preview plan, apply idempotente, post-verify): `references/anchor-retrofit.md`.

### anchor-retrofit preview (default per questa operazione)

Scansiona `docs/planning/`, `docs/epics/*/`, `docs/features/*/`, `docs/tasks/*/` (esclude `docs/archive/`) cercando i file `00-context.md` e `technical-context.md` privi della riga `<!-- Anchor -->`. Per ognuno inferisce i valori anchor (Tier, Parent, Bubble-up target) dalla struttura del repo e dalle roadmap. Non scrive nulla.

Output: `AnchorRetrofitPlan` con sezioni `injects` (da iniettare), `already_anchored` (skip), `ambiguous` (non toccati — inferenza multipla o impossibile). Termina con riepilogo + CTA `"anchor-retrofit apply"` se ci sono inject pianificati.

Gate dell'apply: la preview deve essere prodotta nella stessa sessione.

### anchor-retrofit apply

Esegue il retrofit secondo il piano prodotto dalla preview. Rifiuta di partire se nessuna preview è stata prodotta nella sessione corrente.

Sequenza operativa:

1. Verifica che la preview (anchor-retrofit) sia in sessione — abort se assente.
2. Backup: copia integrale di `docs/` in `docs/.bak-<timestamp>/` (bloccante, non skippabile).
3. Per ogni `injects[]`: inserisce la riga anchor dopo il titolo H1, con riga vuota prima e dopo. Idempotente: se l'anchor è già presente, skip.
4. Scrive il manifest `docs/.bak-<timestamp>/anchor-retrofit-manifest.json` + report terminale.
5. Post-verify: **delegato** (`anchor-retrofit post-verify`). L'apply non lo esegue inline.

### anchor-retrofit post-verify

Dopo l'apply, per ogni artefatto che era in `injects`:
- Verifica che la riga `<!-- Anchor -->` sia presente nel file, nella posizione corretta (dopo H1, prima della prima sezione H2/contenuto).
- Verifica che i campi Tier/Parent/Bubble-up target corrispondano ai valori pianificati.

Report pass/fail per ogni file. Se anche un solo file è fail, segnala in evidenza con suggerimento di recovery.

---

## Scope di scrittura

La skill scrive **solo** durante apply (layout migration o anchor retrofit), mai durante preview.

**Layout migration — scrive:**
- `<context-root>/tasks/<id>.md` — destinazione dei brief migrati
- `docs/archive/features/<slug>/tasks/<id>.md` — destinazione dei brief di source concluse
- `docs/.bak-<timestamp>/` — backup pre-apply + manifest `apply-manifest.json`

**Anchor retrofit — scrive:**
- `docs/planning/00-context.md`, `docs/planning/technical-context.md` — inietta riga anchor (tier `project`)
- `docs/epics/<slug>/00-context.md`, `docs/epics/<slug>/technical-context.md` — inietta riga anchor (tier `epic`)
- `docs/features/<slug>/00-context.md`, `docs/features/<slug>/technical-context.md` — inietta riga anchor (tier `feature`)
- `docs/tasks/<slug>/00-context.md`, `docs/tasks/<slug>/technical-context.md` — inietta riga anchor (tier `task`)
- `docs/.bak-<timestamp>/` — backup pre-apply + manifest `anchor-retrofit-manifest.json`

**Non tocca mai (entrambe le modalità):**
- `.flow/` — effimero, rigenerato da `flow-run`
- `docs/features/*/tasks-active.md` e altri file piano — source of truth del planning, non alterata
- `docs/archive/**` — gli artefatti archiviati non vengono retrofittati
- Skill (`skills/*/`), agent file (`agents/*.md`), epics roadmap (`docs/epics/*/roadmap.md`) — read-only

## Cosa NON fa questa skill

- Non ridefinisce il layout canonico (è `topology-canonical`).
- Non gestisce la concorrenza multi-agente (`topology-concurrency-core`).
- Non migra `.flow/` (è effimero, viene rigenerato da `flow-run`).
- Non committa nel repo git.
- Non rimuove il back-compat fallback da `feature-artifacts.md` (task 006).
- Non opera su repo con layout già canonico senza un piano di migrazione valido.
- Non retrofitta artefatti in `docs/archive/`.
- Non modifica i valori anchor già presenti (idempotenza pura: se `<!-- Anchor -->` c'è, skip senza toccare).
