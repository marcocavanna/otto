---
name: migrate
description: >
  Porta un progetto otto dal vecchio layout (docs/tasks/ flat, nessun archivio)
  al layout canonico. Trigger: "migra il progetto", "migrate otto",
  "porta otto al nuovo layout", "migrate", "migrazione layout".
---

# Migrate — migrazione old→new layout

Skill che porta un progetto otto qualsiasi dal **vecchio layout** (`docs/tasks/` flat, nessun archivio, `.flow/PROGRESS.json` unico) al **layout canonico** definito da `topology-canonical`. Opera sempre con cognizione: preview obbligatoria prima dell'apply, idempotente, reversibile, con post-verify.

## Principi non negoziabili

Questi principi non si possono derogare in nessuna modalità:

1. **Fail-closed**: se l'ID di un brief non risolve a nessuna source nota, non muovere quel brief — segnalarlo come caso ambiguo nel report. Nel dubbio: niente move.
2. **Idempotente**: rieseguire apply su un repo già migrato è un no-op. Nessun errore, nessun danno, nessun file duplicato.
3. **Reversibile**: backup pre-apply dell'albero `docs/` in `docs/.bak-<timestamp>/` (copia integrale, timestamp distinto per ogni apply). La procedura di restore dal backup è documentata nel report di apply.
4. **Niente commit automatici**: la skill non esegue mai `git commit`. Usa `git mv` per ogni spostamento quando il repo è git (preserva la history). Fallback: `mv` normale + nota esplicita se il repo non è git.
5. **Post-verify obbligatorio**: dopo ogni apply, verificare che ogni ID risolva ancora al path canonico atteso. Report esplicito pass/fail per ogni ID. Apply senza post-verify è incompleto.

## Modalità

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

## Scope di scrittura

La skill scrive **solo** durante apply, mai durante preview.

**Scrive:**
- `<context-root>/tasks/<id>.md` — destinazione dei brief migrati
- `docs/archive/features/<slug>/tasks/<id>.md` — destinazione dei brief di source concluse
- `docs/.bak-<timestamp>/` — backup pre-apply (copia dell'albero `docs/` originale; timestamp distinto per ogni apply) + manifest `apply-manifest.json`

**Non tocca mai:**
- `.flow/` — effimero, rigenerato da `flow-run`
- `docs/features/*/tasks-active.md` — source of truth del planning, non alterata
- `feature-artifacts.md` — rimozione del back-compat fallback è scope del task dedicato (topology-migration-006)
- Agent file (`agents/*.md`) e altre skill (`skills/*/`)

## Cosa NON fa questa skill

- Non ridefinisce il layout canonico (è `topology-canonical`).
- Non gestisce la concorrenza multi-agente (`topology-concurrency-core`).
- Non migra `.flow/` (è effimero, viene rigenerato da `flow-run`).
- Non committa nel repo git.
- Non rimuove il back-compat fallback da `feature-artifacts.md` (task 006).
- Non opera su repo con layout già canonico senza un piano di migrazione valido.
