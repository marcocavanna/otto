# Anchor schema — Planning source contract v2

> Single source dello schema dell'**anchor**: l'header machine-parsabile che ogni artefatto di planning porta in testa per dichiarare il proprio tier, il padre e il target di risalita delle decisioni (bubble-up). Definito qui; consumato da Planning source contract v2 (risoluzione context-root), dalla feature `core` (emissione in `plan`/`expand`) e dalla feature `finalize` (bubble-up single-hop).

Contratti correlati (single-source, non duplicare):
- Taxonomy dei 4 tier: `docs/epics/planner-unification/technical-context.md` § Taxonomy.
- Semantica back-compat: `docs/epics/planner-unification/02-abstract.md` § Back-compat.

## Formato canonico

L'anchor è una **riga singola** in formato Markdown bold, prefissata da un commento HTML marcatore:

```
<!-- Anchor --> **Tier**: <tier> · **Parent**: <slug|—> · **Bubble-up target**: <path|—>
```

- Marcatore: `<!-- Anchor -->` in testa alla riga. Serve al parsing bash deterministico (`grep '<!-- Anchor -->'`) senza ambiguità con altre righe bold che possono comparire in testa ai file.
- Separatore tra campi: punto mediano `·` (U+00B7), con uno spazio per lato. Allineato agli artefatti esistenti della feature.
- Valore vuoto: em-dash `—` (U+2014), **non** il trattino corto `-`.

## Campi

| Campo | Tipo | Obbligatorio | Semantica |
|---|---|---|---|
| `Tier` | enum `{project, epic, feature, task}` | sì | Tier dell'artefatto nella gerarchia di planning. |
| `Parent` | string (slug) \| `—` | sì | Slug del padre diretto, oppure `—` se l'artefatto non ha padre (tier `project`) o è standalone. |
| `Bubble-up target` | path (verso un `technical-context.md`) \| `—` | sì | Path del `technical-context.md` del padre, destinazione del bubble-up di `finalize`; `—` se non c'è risalita. |

Tutti e tre i campi sono **sempre presenti**, anche quando valorizzati a `—`. L'assenza di un campo non è ammessa; l'assenza dell'**intera riga** anchor ha una semantica dedicata (vedi § Semantica "anchor assente").

### `Tier` (enum)

Enum **chiuso**, da non estendere:

```
{ project, epic, feature, task }
```

Relazione di contenimento: `project` ⊃ `epic` ⊃ `feature` ⊃ `task`. Ogni tier produce gli stessi tipi di artefatto; cambia il set e la profondità dell'elicitation (definito nella taxonomy condivisa, vedi link in testa).

### `Parent` (slug \| —)

- Slug **opaco** del padre diretto (i downstream non lo interpretano semanticamente: risolvono la context-root per scan di directory).
- `—` quando:
  - il tier è `project` (radice della gerarchia, nessun padre), oppure
  - l'artefatto è **standalone** (creato senza inserimento in una gerarchia: back-compat).

### `Bubble-up target` (path \| —)

- Path relativo (dalla root del repo) verso il `technical-context.md` del **padre diretto**. È la destinazione che `finalize` legge per la risalita single-hop delle decisioni consolidate.
- `—` quando:
  - il tier è `project` (nessun padre verso cui risalire), oppure
  - l'artefatto è standalone (nessun bubble-up).

Il bubble-up è **a un solo salto** (task→feature, feature→epic, epic→project): ogni `finalize` risale al padre diretto, non in cascata.

## Posizione

L'anchor va in **testa** ai file:
- `00-context.md` — per la risoluzione human-readable della gerarchia.
- `technical-context.md` — per il bubble-up machine-parsato da `finalize`.

Collocazione esatta: **riga singola subito dopo il titolo H1**, prima di qualsiasi altra sezione (separata dal titolo e dal contenuto seguente da una riga vuota). Esempio:

```markdown
# Technical context — Feature: <nome>

<!-- Anchor --> **Tier**: feature · **Parent**: my-epic · **Bubble-up target**: docs/epics/my-epic/technical-context.md

## Prima sezione
...
```

Gli altri artefatti (`02-abstract.md`, `roadmap.md`, `milestones.md`, `tasks-active.md`, brief dei task) **non** portano l'anchor: la coppia `00-context.md` + `technical-context.md` è sufficiente per risoluzione e bubble-up.

## Semantica del valore vuoto (`—`)

`—` non è un errore né un placeholder "da compilare": è un valore **esplicito e valido** che significa "non applicabile / assente".

- `Parent: —` → l'artefatto non ha un padre nella gerarchia (radice `project` o standalone).
- `Bubble-up target: —` → non esiste un target di risalita: `finalize` non esegue alcun bubble-up per questo artefatto.

Combinazioni valide:
- Tier `project`: `Parent: —` e `Bubble-up target: —` (radice).
- Tier `epic`/`feature`/`task` inseriti in gerarchia: `Parent` e `Bubble-up target` valorizzati.
- Qualsiasi tier creato standalone: `Parent: —` e `Bubble-up target: —` (back-compat esplicita).

## Semantica "anchor assente"

Se la riga `<!-- Anchor -->` **non è presente** nel file, l'artefatto è trattato come **standalone**:
- equivale a `Parent: —` e `Bubble-up target: —`;
- nessun bubble-up viene eseguito da `finalize`.

Questa è la regola di **back-compat**: i progetti creati prima dell'introduzione dell'anchor (pre-2.0.0) non si rompono e continuano a funzionare come planning standalone. Il retrofit dell'anchor sugli artefatti esistenti è **opt-in** (via `migrate`), non automatico.

Distinzione netta:
- **Anchor assente** = back-compat, artefatto pre-anchor o esplicitamente standalone → comportamento standalone.
- **Anchor presente con `—`** = dichiarazione esplicita e moderna che l'artefatto non ha padre/target → stesso comportamento standalone, ma intenzionale e tracciato.

## Esempi per tier

Tutti nel formato canonico. Il commento `<!-- Tier: ... -->` qui sotto è solo didattico per questo documento e **non** fa parte dell'anchor emesso.

```markdown
<!-- Tier: project -->
<!-- Anchor --> **Tier**: project · **Parent**: — · **Bubble-up target**: —

<!-- Tier: epic -->
<!-- Anchor --> **Tier**: epic · **Parent**: my-project · **Bubble-up target**: docs/planning/technical-context.md

<!-- Tier: feature -->
<!-- Anchor --> **Tier**: feature · **Parent**: my-epic · **Bubble-up target**: docs/epics/my-epic/technical-context.md

<!-- Tier: task -->
<!-- Anchor --> **Tier**: task · **Parent**: my-feature · **Bubble-up target**: docs/features/my-feature/technical-context.md
```

Note sui target di esempio:
- `project` risale a nulla (`—`): è la radice.
- `epic` risale al `technical-context.md` del project, che vive in `docs/planning/`.
- `feature` risale al `technical-context.md` dell'epic padre (`docs/epics/<slug>/`).
- `task` risale al `technical-context.md` della feature padre (`docs/features/<slug>/`).

---
Generato: 2026-06-02 | Task: planner-unification-contract-001
