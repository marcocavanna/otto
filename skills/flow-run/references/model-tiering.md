# Model tiering — policy complessità-driven (single source)

> **Single-source.** Questa è l'**unica** definizione delle policy guidate da `complexity`:
> il **modello** dei subagent (DEV e finalize PM), il **processo** (eseguire o saltare il dry-run)
> e l'**execution-mode** (`solo`/`team`).
> Consumate da `flow-run` (vedi `skills/flow-run/SKILL.md`).
> Gli altri file (`docs/features/model-tiering/02-abstract.md`,
> `skills/task-implementer/references/complexity-criteria.md`, la SKILL `flow-run`)
> **linkano qui** e NON ridoppiano le tabelle né le regole sottostanti.

## Mappa

| `complexity` | modello DEV (alias) | execution-mode |
|---|---|---|
| `trivial`  | `haiku`  | `solo` |
| `standard` | `sonnet` | `solo` |
| `critical` | `opus`   | `team` |

`complexity` è l'enum stabile `{trivial, standard, critical}` (definito in
`technical-context.md` § "Value Objects / contratti"): da consumare, non ridefinire.

I valori della colonna modello sono **alias**, non ID pinned (es. non
`claude-haiku-4-5-...`), per resilienza ai version-bump — ASSUMPTION-model-tiering-002.

La colonna `execution-mode` seleziona il **processo di esecuzione del task** in `flow-run`:
`solo` = singolo agente fast-path (vedi `agents/solo.md`); `team` = loop attended PM↔DEV.

## Enum execution-mode (2.1.0)

`{solo, team}` — enum chiuso.

- `solo`: fast-path mono-agente, senza loop attended PM↔DEV. Per task a basso rischio cross-task.
- `team`: percorso attended completo (PM brief → DEV → gate). Per task `critical`.
- `inline` **non** è presente: riservato a una release futura (ASSUMPTION-fast-path-002) — non inserirlo.
- `promote` **non** è gestito qui: appartiene alla feature `fast-path-promotion`.

## Precedenza

In ordine, dal più forte al più debole:

```
override utente > mapping dinamico (DEV) > frontmatter agente > modello di sessione
```

- **override utente**: forzatura manuale per il run (es. `--model opus`); vince su tutto.
- **mapping dinamico (DEV)**: questa mappa, applicata da `flow-run` allo spawn del DEV.
- **frontmatter agente**: `model:` di default in `agents/dev.md` / `agents/pm.md`.
- **modello di sessione**: fallback ultimo se nessuno dei precedenti si applica.

### Precedenza — execution-mode

```
override utente > mappa `model-tiering.md` > default `team`
```

- **override utente** (effimero): es. *"esegui in team"* / *"forza solo"*; vince su tutto,
  **non** persistito, annotato nel summary del run. Stessa meccanica degli override modello/dry-run.
- **mappa**: risoluzione a runtime da `complexity` via la tabella `## Mappa` sopra.
- **default `team`**: se `meta.json` assente / `complexity` fuori-enum / illeggibile → `team` (fail-safe,
  vedi `## Degrado graceful`). MAI `solo` per degrado.

## Fail-safe verso l'alto

In dubbio tra due tier **adiacenti**, vince il più alto (`trivial`→`standard`,
`standard`→`critical`). La classificazione a monte avviene nel PM (vedi
`skills/task-implementer/references/complexity-criteria.md`); qui il principio è
ribadito per il caso limite di mapping. Sovrastimare costa al massimo un task su un
modello più potente; sottostimare costa il task **più** i retry del gate.

## Degrado graceful (RISK-model-tiering-001)

`meta.json` assente, illeggibile, oppure `complexity` fuori dall'enum
`{trivial, standard, critical}` (incluse varianti non normalizzate come `"trivial "`
con spazio, o valori ignoti come `"low"`):

```
modello DEV    = sonnet   (default; MAI degrado a haiku)
execution-mode = team     (default; MAI degrado a solo)
```

`flow-run` aggiunge una **nota nel summary** quando applica questi default, così la
misclassificazione/illeggibilità resta visibile. Il degrado di `execution-mode` è
**conservativo** (ASSUMPTION-fast-path-005 epic): in dubbio si esegue il percorso `team`,
mai il fast-path `solo`.

## Dry-run: eseguire o saltare (complessità-driven)

Il dry-run del DEV è il primo checkpoint di escalation **pre-scrittura**: ha valore solo
dove l'escalation pre-codice è probabile. Dato che dry-run e implement sono subagent
distinti senza memoria condivisa, su un task leggero il dry-run paga un **secondo**
context-loading + planning per restituire quasi sempre "pass" → costo 2x senza informazione.

| `complexity` | dry-run |
|---|---|
| `trivial`  | **skip** (vai diretto a implement) |
| `standard` | **skip** |
| `critical` | **run**  |

- `meta.json` assente / illeggibile / fuori enum → **run** (fail-safe: in dubbio, controlla prima di scrivere).
- Saltando il dry-run, il **primo** checkpoint di escalation diventa l'`implement`
  (`RESULT.json` / `ESCALATION.json`): il DEV può comunque escalare e lo `scope-check` hook
  continua a gate-are ogni scrittura fuori scope. Il working tree può risultare toccato prima
  dell'escalation — accettabile su trivial/standard (per definizione privi di insidie cross-task),
  non su critical (che mantiene il dry-run).
- Override utente: *"salta il dry-run"* / `--no-dry-run` → skip; *"forza il dry-run"* / `--dry-run` → run.
  L'override vince sulla policy.

## Finalize: modello del PM (complessità-driven)

Il `finalize` del PM è per la gran parte meccanico (gate + confronto col brief + edit della riga
`Status`); l'unico punto di giudizio è l'eventuale append a `technical-context.md` (memoria
persistente cross-task), che però è **già presidiato a monte dal `brief`** (su Sonnet). Quindi il
finalize può scendere di tier, salvo sui task dove le decisioni cumulative sono probabili.

| `complexity` | modello finalize (PM) |
|---|---|
| `trivial`  | `haiku`  |
| `standard` | `haiku`  |
| `critical` | `sonnet` |

- Cap a `sonnet`: il finalize non richiede `opus` nemmeno sui `critical`.
- `meta.json` assente / illeggibile / fuori enum → `sonnet` (fail-safe verso l'alto: tocca memoria persistente).
- Override utente esteso al PM (es. *"tutto in opus"*, *"PM compreso"*): vince anche sul modello del finalize.
- Il `brief` del PM **non** è tierizzato: resta al default del frontmatter (`sonnet`), perché gira
  prima che `meta.json` esista (boundary di feature — il PM non è tierizzabile dinamicamente).
