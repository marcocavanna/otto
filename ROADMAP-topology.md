# Epic `topology` — roadmap (anchor versionato)

> I bundle di pianificazione completi vivono in `docs/epics/topology/` e `docs/features/topology-*/`,
> **gitignored by-design** (il repo del plugin tratta `docs/` come dogfood/test residue). `flow-run` li
> legge dal working tree. Questo file è l'unico artefatto **versionato** dell'epic: tienilo aggiornato.

## Obiettivo
Ristrutturare topologia artefatti + concorrenza source-level + migrazione progetti esistenti + execution-path snello. Vedi commit `6a93080`, `071aa6f` e la cronologia conversazionale per il razionale completo.

## Layout canonico target
```
docs/  planning/{...,tasks/T-NNN.md}  features/<slug>/{...,tasks-active.md,tasks/<id>.md}
       epics/<epic>/{...,roadmap.md}  archive/{features,epics}/<...>   # archive fuori dallo scan
.flow/ sources/<slug>/{PROGRESS.json,briefs/<id>/...}  locks/<slug>/{heartbeat.ts}  index.json
```
Contratto canonico: `skills/feature-planner/feature-artifacts.md` § "Planning source contract".

## Decisioni chiave (non rinegoziare senza motivo)
- **Concorrenza a grana SOURCE**: un flow possiede una feature; task seriali dentro. Lock atomico `mkdir .flow/locks/<slug>` + heartbeat + reclaim. `planning` è un lock unico (niente parallelismo intra-progetto).
- **Auto-archivio** a fine source sotto lock: `git mv → docs/archive/`, niente commit automatici.
- **Brief self-sufficient (A)**: sezione "Vincoli risolti" nel brief; il DEV non legge più i 3 file di planning. Rete di sicurezza più sottile → garantita dall'harness.
- **Tiering modello** (già in prod): trivial→haiku/skip-dryrun/finalize-haiku, standard→sonnet/skip/haiku, critical→opus/run/sonnet. Fail-safe verso l'alto.

## Feature e stato

| # | feature | task | stato | note |
|---|---|---|---|---|
| 1 | `topology-harness` | 4 | ✅ **done** (commit 071aa6f) | eval-harness + fixture. Affinare per build isolata (vedi Validazione) |
| 2 | `topology-canonical` | 6 | 🟡 **5/6** (commit 6a93080) | 001-004,006 done; **005 deferred** (validazione fuori-flow) |
| 3 | `topology-concurrency-core` | 5 | ⚪ pending | lock/PROGRESS-per-source/index/auto-archivio. Dipende da 2 |
| 4 | `topology-reconcile` | 4 | ⚪ pending | whats-next/flow-sync per-source + gitignore. Dipende da 3 |
| 5 | `topology-migration` | 7 | ⚪ pending | skill shippable old→new (dry-run/idempotente/reversibile/verify). Dipende da 2. **Sblocca il reinstall globale** |
| 6 | `topology-lean-exec` | 4 | ⚪ pending | B+C: lazy refs + dedup preflight⟷context-loading. Dipende da 1; dopo 2 (stessi file) |

Ordine flow-run: `harness → canonical → lean-exec → concurrency-core → reconcile → migration`.

## Strategia di validazione (vincolo: NO reinstall globale a metà)
1. Costruisci le feature rimanenti **in-flow**: girano sul plugin **cached invariato** → zero impatto sui run in corso. Committa ciascuna.
2. Valida su **build isolata** del plugin (working tree), mai sulla cache globale condivisa.
3. **Reinstall globale solo alla fine**, dopo `topology-migration` (è lei che rende sicuro il passaggio per i progetti esistenti).
- `topology-canonical-005` resta `deferred` fino a questa validazione coordinata.

### Meccanismo di isolamento — CONFERMATO (claude 2.1.158, auth login/keychain)
- **`claude --print --plugin-dir <repo-root>`**: carica la otto del working tree (stesso nome `otto`) che **scavalca** quella installata per quella sessione. Auth intatta, globale invariata → run concorrenti su altri progetti **non toccati**. (`run.sh` aggiornato, commit `701bacb`.)
- **NON** usare `--bare` (salta le keychain reads → perde l'auth OAuth).
- **NON** usare `--settings '{"enabledPlugins":{"otto@otto":false}}'`: disabilita anche la copia `--plugin-dir` (stesso nome). Il solo `--plugin-dir` basta.
- ⚠ **Aperto (da validare alla 1ª esecuzione di `run.sh`)**: l'invocazione produce gli artefatti **attended** (`.flow/briefs/<id>/` scope/frozen/meta) che gli snapshot asseriscono? Il PM li materializza solo come subagent di flow-run; `run.sh` lo emula con prompt attended esplicito. Se `.flow/briefs/<id>/` resta vuoto → rivedere l'invocazione (far girare l'orchestratore flow-run sul golden-task). Richiede terminale autenticato.

## Residui / findings aperti
- **`canonical-002`**: `task-implementer/SKILL.md` mode `deviation`/`finalize` (righe ~83/93) hanno ancora il path legacy hardcoded `docs/tasks/<id>.md` — da rifinire.
- **Tier haiku, disciplina lasca**: subagent haiku hanno scritto `.flow/PROGRESS.json` fuori scope (×2). → stringere `scope-check` in `concurrency-core` e/o finalize a sonnet anche su standard.
- **Brief in transizione**: `001` in `docs/tasks/` legacy, resto co-locato → uniformati da `migration`.
- **Fixture harness su layout vecchio**: aggiornare al co-locato durante la validazione di canonical.

## Git
- Branch corrente porta perf + harness + canonical (commit sopra). Separabile in branch dedicati se serve.
- `docs/` e `.flow/` gitignored; eccezione per `tests/harness/fixture/docs/`.

---
Aggiornato: 2026-06-01 | dopo topology-canonical (5/6)
