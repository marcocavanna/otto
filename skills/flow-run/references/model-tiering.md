# Model tiering — mappa complessità→modello (single source)

> **Single-source.** Questa è l'**unica** definizione della mappa `complexity → modello`.
> Consumata da `flow-run` allo spawn del subagent DEV (vedi `skills/flow-run/SKILL.md`).
> Gli altri file (`docs/features/model-tiering/02-abstract.md`,
> `skills/task-implementer/references/complexity-criteria.md`, la SKILL `flow-run`)
> **linkano qui** e NON ridoppiano la tabella né le regole sottostanti.

## Mappa

| `complexity` | modello DEV (alias) |
|---|---|
| `trivial`  | `haiku`  |
| `standard` | `sonnet` |
| `critical` | `opus`   |

`complexity` è l'enum stabile `{trivial, standard, critical}` (definito in
`technical-context.md` § "Value Objects / contratti"): da consumare, non ridefinire.

I valori della colonna modello sono **alias**, non ID pinned (es. non
`claude-haiku-4-5-...`), per resilienza ai version-bump — ASSUMPTION-model-tiering-002.

## Precedenza

In ordine, dal più forte al più debole:

```
override utente > mapping dinamico (DEV) > frontmatter agente > modello di sessione
```

- **override utente**: forzatura manuale per il run (es. `--model opus`); vince su tutto.
- **mapping dinamico (DEV)**: questa mappa, applicata da `flow-run` allo spawn del DEV.
- **frontmatter agente**: `model:` di default in `agents/dev.md` / `agents/pm.md`.
- **modello di sessione**: fallback ultimo se nessuno dei precedenti si applica.

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
modello DEV = sonnet   (default; MAI degrado a haiku)
```

`flow-run` aggiunge una **nota nel summary** quando applica questo default, così la
misclassificazione/illeggibilità resta visibile.
