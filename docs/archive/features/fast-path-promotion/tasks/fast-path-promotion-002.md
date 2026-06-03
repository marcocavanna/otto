---
Task: fast-path-promotion-002
Feature: fast-path-promotion
Context-root: docs/features/fast-path-promotion/
Origin: flow-run (attended, fast-path)
Status: ✅ finalized
---

# fast-path-promotion-002 — Pre-analisi read-only + emissione `RESULT.promote` in `agents/solo.md`

**Effort stimato**: 2-3h
**Dipendenze**: fast-path-promotion-001 (done)
**Generato**: 2026-06-03
**Versione**: 1

## Obiettivo

Inserire in `agents/solo.md`, prima di qualunque Write/Edit di codice, uno step di pre-analisi read-only che valuta i trigger T1–T4 di `promotion-triggers.md`; se almeno uno scatta: scrivere `RESULT.json` con `promote=true` + `promote_reason` e terminare senza aver scritto codice. Estendere lo schema `RESULT.json` con i campi `promote`/`promote_reason` in modo additivo e retro-compatibile.

## Vincoli risolti

### Stack & tooling
- **Markdown puro** — `agents/solo.md` è un file di istruzioni Markdown, consumato da Claude Code come system prompt dell'agente `solo`. Nessun runtime, nessuna compilazione.
- **Build/test**: `build_command: —`, `test_command: —` (technical-context.md). Verifica = lint reference + coerenza strutturale. Nessuna libreria di terze parti; tooling indiretto `bash`/`jq`/`git` (già usato nella sequenza (g)).

### Contratti consumati (non modificati)
- **`promotion-triggers.md`** (`skills/flow-run/references/`) — single-source dei trigger T1–T4. `agents/solo.md` la **linka e legge**, non la duplica (DECISION-fast-path-promotion-001).
- **Schema `RESULT.json` base** (`verify`, `deviations`, `escalate`) — preesistente, **non modificato**: i nuovi campi sono aggiunti in modo additivo (frozen.txt).
- **`scope-check.sh`** — bootstrap consente `.flow/briefs/<TASK>/**` anche prima di `scope.txt`, abilitando l'emissione di `RESULT.json` nel path di promozione senza materializzare scope/frozen.

### Contratto introdotto (additivo, retro-compatibile)
- **`RESULT.promote`** (bool, opzionale) e **`RESULT.promote_reason`** (stringa libera, formato convenzionale `"<Tx>: <misura>"`). Assenza ≡ `false`. Letti da `flow-run` S3 con truthy check (attivazione del ramo = compito di fast-path-promotion-003, qui solo il punto di emissione). Allineato al VO condiviso del seed epic (technical-context.md § Value Objects).

### Naming & convenzioni
- Sezioni di `agents/solo.md` numerate `(a)…(g)`; il nuovo step è `(b2)` — collocato tra `(b)` (analisi read-only) e `(c)` (materializzazione scope/frozen) per esprimere l'ordinamento "dopo aver letto il contesto, prima di toccare il codice".
- `promote_reason`: stringa libera, non enum (ASSUMPTION-fast-path-promotion-002-003).

## File impattati

```
agents/solo.md                                                     [edit]
docs/features/fast-path-promotion/tasks/fast-path-promotion-002.md [new]
```

Nota: lo schema `RESULT.json` non è un file su disco con struttura separata — è definito inline nelle istruzioni. La modifica fisica del punto di emissione coinvolge solo `agents/solo.md`. La rimozione della nota "predisposto ma inerte" e l'attivazione del ramo `promote==true` in `flow-run/SKILL.md` S3 sono out-of-scope (fast-path-promotion-003).

## Shape reale

> Shape post-implementazione, non implementazione finale.

### `agents/solo.md` — nuovo step `(b2)` (tra `(b)` e `(c)`)

```markdown
### (b2) Pre-analisi promozione (read-only, prima di qualunque Write/Edit su codice)

Prima di materializzare scope/frozen e prima di qualunque Write/Edit su file di codice
o configurazione fuori da `.flow/briefs/<TASK>/`, valuta i trigger di promozione.

Leggi `.../flow-run/references/promotion-triggers.md`. Valuta T1, T2, T3, T4.
Usa solo Read / Grep / Glob — nessuna scrittura su codice.

Se almeno un trigger scatta:
1. Determina `promote_reason` formato `"<Tx>: <misura>"`.
2. Scrivi `.flow/briefs/<TASK>/RESULT.json`: { "promote": true, "promote_reason": "..." }
3. Termina con summary `PROMOTED: <promote_reason>`. Non proseguire con (c)…(g).

Se nessun trigger scatta: pre-analisi silenziosa, prosegui con (c).

[Confine pre/post-write: post-write un trigger NON promuove → ESCALATION.json.]
```

### `agents/solo.md` — sezione `(g)` arricchita

```markdown
**Path di implementazione normale** (schema base):
{ "verify": "pass | fail", "deviations": ["..."], "escalate": false }

**Path di promozione** (emesso in (b2), prima di (c)):
{ "promote": true, "promote_reason": "<Tx>: <misura>" }

[promote/promote_reason opzionali e additivi; assenza ≡ promote:false; retro-compatibile.]
```

## Deviazioni

- **preflight**: l'artefatto versionato `tasks/fast-path-promotion-002.md` (marcato `[new]`) esisteva già come copia untracked del brief (Status active), residuo della dry-run precedente. In implement è stato sovrascritto con l'artefatto finalizzato. Nessun conflitto reale.
- **build**: `build skipped: markdown puro, build_command "—" nel technical-context (verifica = coerenza strutturale + lint reference)`.

Nessuna decisione cross-task: lo schema `RESULT.json` arricchito è additivo/retro-compatibile (già previsto dal seed epic, technical-context.md § Value Objects); l'attivazione del ramo in `flow-run` è esplicitamente delegata a fast-path-promotion-003. Nessuna escalation.

## Riferimenti

- Reference trigger (single-source criteri T1–T4): `skills/flow-run/references/promotion-triggers.md`
- Agente modificato: `agents/solo.md`
- Flusso di consumo: `skills/flow-run/SKILL.md` § "Ramo `solo`" / S3 (attivazione → fast-path-promotion-003)
- Assunzioni: ASSUMPTION-fast-path-promotion-001/002/003
- Decisioni: DECISION-fast-path-promotion-001 (collocazione reference), DECISION-fast-path-promotion-002 (soglie T1)
</content>
