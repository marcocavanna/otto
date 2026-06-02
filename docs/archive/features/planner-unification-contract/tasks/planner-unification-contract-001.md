# Brief tecnico — planner-unification-contract-001

**Origin**: feature-planner
**Context-root**: docs/features/planner-unification-contract/
**Feature**: planner-unification-contract
**Status**: finalized

---

## Obiettivo

Produrre il documento-contratto che specifica formalmente lo schema dell'header anchor: i 3 campi (`Tier`, `Parent`, `Bubble-up target`), l'enum `Tier`, la semantica del valore vuoto `—`, la posizione dell'header negli artefatti e un esempio completo per ogni tier.

Questo documento diventa la **single source** consumata da:
- Planning source contract v2 (task -002) per la risoluzione context-root
- Feature `core` per l'emissione dell'anchor da `planner plan`/`expand`
- Feature `finalize` per la logica di bubble-up single-hop

## Definition of done

Documento `skills/planner/anchor-schema.md` che specifica:
1. I 3 campi con nome, tipo e semantica (incluso valore vuoto `—`)
2. Enum `Tier` completo: `{project, epic, feature, task}`
3. Dove l'header va posizionato: `00-context.md` e `technical-context.md`, in testa dopo il titolo H1
4. Semantica "anchor assente" = source standalone (back-compat)
5. Esempio per ogni tier (project, epic, feature, task) — formato markdown commentato

## File impattati

- `skills/planner/anchor-schema.md` [new]

## Vincoli risolti

**Stack**: Markdown puro. Nessun runtime, nessuna compilazione. Il documento è letto da skill Claude Code (bash + CLAUDE.md reader).

**Librerie + versioni**: nessuna.

**VO/pattern/interfacce consumati**:
- Anchor schema (definito QUI, consumato da -002/-003 e dalle feature successive) — schema:
  ```
  <!-- Anchor --> **Tier**: <tier> · **Parent**: <slug|—> · **Bubble-up target**: <path|—>
  ```
  Questo task lo **definisce**, non lo consuma da altrove.
- Taxonomy 4 tier (project ⊃ epic ⊃ feature ⊃ task) — già fissata in `docs/epics/planner-unification/technical-context.md`.
- Semantica back-compat (anchor assente = standalone) — già fissata in `docs/epics/planner-unification/02-abstract.md`.

**Naming convention**:
- File: `anchor-schema.md` (kebab-case, posizionato in `skills/planner/`)
- Campi dell'anchor: `Tier`, `Parent`, `Bubble-up target` (title-case, esattamente come appaiono negli artefatti)
- Valore vuoto: `—` (em-dash, non trattino corto)

## Approccio implementativo

Il task è interamente documentale: nessun codice eseguibile.

### Struttura del documento

```
# Anchor schema — Planning source contract v2

## Campi

| Campo | Tipo | Obbligatorio | Semantica |
|---|---|---|---|
| Tier | enum | sì | Tier nella gerarchia |
| Parent | string | sì | Slug del padre o — |
| Bubble-up target | path | sì | Path del technical-context.md del padre o — |

## Enum Tier

{project, epic, feature, task}

## Posizione

Header in testa a `00-context.md` e `technical-context.md`, riga singola
dopo il titolo H1, prima di qualsiasi altra sezione.

Formato canonico:
  <!-- Anchor --> **Tier**: <tier> · **Parent**: <slug|—> · **Bubble-up target**: <path|—>

## Semantica del valore vuoto (—)

[...]

## Semantica "anchor assente"

[...]

## Esempi per tier

### Tier: project
### Tier: epic
### Tier: feature
### Tier: task
```

### Decisioni da prendere nel documento

1. **Separatore tra campi**: il punto mediano `·` (U+00B7) è già usato negli artefatti esistenti della feature — da mantenere.
2. **Commento HTML `<!-- Anchor -->`**: necessario per permettere parsing bash (`grep '<!-- Anchor -->'`) senza ambiguità con altre righe bold in testa ai file.
3. **Valore `—` per `Bubble-up target`**: applicabile quando il tier è `project` (nessun padre) o quando la source è standalone (back-compat). Non è un errore; è semantica esplicita.
4. **`00-context.md` vs solo `technical-context.md`**: entrambi devono portare l'anchor — `00-context.md` per la risoluzione human-readable, `technical-context.md` per il bubble-up machine-parsato da `finalize`.

### Esempi minimi (shape per il documento)

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

## Out of scope per questo task

- Logica di risoluzione della context-root (→ task -002)
- Spec del bundle leggero del tier task (→ task -003)
- Implementazione della skill `planner` che emette l'anchor (→ feature core)
- Logica di bubble-up in `finalize` (→ feature finalize)
- Modifica di artefatti esistenti per aggiungere l'anchor (→ feature downstream/migrate)

## Subtask

Nessuno necessario, esecuzione lineare.

## Verifica (DoD check)

Il DEV verifica manualmente che `skills/planner/anchor-schema.md`:
- [ ] Esiste e ha il path corretto
- [ ] Specifica i 3 campi con nome, tipo, semantica
- [ ] Include l'enum `Tier` completo
- [ ] Indica la posizione esatta (header dopo H1 in `00-context.md` + `technical-context.md`)
- [ ] Specifica la semantica di `—` per ogni campo
- [ ] Specifica la semantica "anchor assente = standalone"
- [ ] Contiene un esempio per ognuno dei 4 tier nel formato canonico

---
Generato: 2026-06-02 | Task: planner-unification-contract-001
