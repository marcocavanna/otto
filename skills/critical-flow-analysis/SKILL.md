---
name: critical-flow-analysis
description: Use this skill to deeply analyze an EXISTING software flow/feature starting from an anchor file, reconstruct the real flow, and produce a dense technical audit (bugs, logic errors, incoherent flows, weak code) with a wave-based hardening plan. Read-only on code. On EXPLICIT user confirmation it can turn the hardening waves into operational tasks (fragmenting long ones) as a feature bundle under docs/features/<slug>/, ready for flow-run. Triggers on phrases like "analizza il flusso/flow di …", "trova i bug in questo flow", "fai un audit di …", "analisi critica del flusso", "fammi un hardening di …", "rivedi a fondo questa funzionalità per bug". Requires an anchor/entry-point file; if missing, ask for it.
---

# Critical Flow Analysis

Sesta skill di **otto**. Serve ad analizzare in profondità un flusso/funzionalità **già esistente** partendo da un file *anchor* (entry-point), per scovare bug e debolezze reali — non per pianificare cose nuove (quello è `feature-planner`).

È l'unico ingresso "diagnostico" della pipeline: produce un audit, e — **solo se glielo chiedi esplicitamente** — converte il piano di hardening in task operativi nello stesso formato di `feature-planner`, così `flow-run` li esegue senza modifiche.

## Principio non negoziabile

**NON modifica codice. Mai.** In modalità `analyze` non scrive nulla; in modalità `to-tasks` scrive **solo** artefatti di planning sotto `docs/features/<slug>/`. I fix veri li applica il flow (DEV), dopo, su tua decisione.

Se manca il file anchor → **chiedilo**, non indovinare il punto d'ingresso.

---

## Mode 1: `analyze <anchor>` — audit (default, read-only)

Obiettivo, in quest'ordine:

1. Comprendi il **flow reale** nel codice (non quello che "dovrebbe" essere).
2. Ricostruisci dipendenze e lifecycle.
3. Estendi l'analisi ai file correlati **rilevanti** (segui il flow, non l'intero repo).
4. Identifica criticità **concrete e verificabili nel codice**.
5. Proponi un piano di hardening a wave.

### Regole operative

- Segui il flow reale; apri file correlati solo se rilevanti.
- Niente analisi dell'intero repository.
- Niente narrativa, niente consulenza, niente testo prolisso. Massima densità.
- Ogni issue deve essere **verificabile nel codice**: riferimento `file:linea` + funzione. Niente issue speculative o generiche.
- Massimo 3-6 righe per issue.
- Non implementare fix senza conferma.

### Output (5 sezioni, formato obbligatorio)

#### 1. Teoria del flusso
Max 80-120 parole. Bullet point + mini-diagrammi ASCII / flow schematici. NO narrativa.

#### 2. Catalogo issue
Ordine: (1) Bug critici → (2) Bug logici → (3) Flussi incoerenti → (4) Codice debole.
Categorie: **BC** = Bug Critico · **BL** = Bug Logico · **FI** = Flusso Incoerente · **CD** = Codice Debole.
Severity: 🔴 alto · 🟠 medio · 🟡 basso.

Formato per ogni issue:
```
### 🔴 BC-01 — Titolo issue
[file.cs:123 — Funzione]
Descrizione tecnica breve.
**Rischio**: breve.
**Fix**: breve.
```

#### 3. Piano di hardening
Diviso in wave operative, tabelle sintetiche.
- **Wave 1 — Stabilizzazione**: bug critici/alti.
- **Wave 2 — Robustezza**: coerenza flow, retry, error handling.
- **Wave 3 — Scalabilità**: refactoring, performance, coupling.

```
| # | Fix | Issue | File | Test |
|---|-----|-------|------|------|
```
(La colonna `Issue` lega ogni fix alle issue del catalogo: tracciabilità.)

#### 4. Backlog
Solo temi realmente fuori scope. Bullet list.

#### 5. Domande aperte
Solo dubbi architetturali realmente bloccanti. Max 10 punti.

### Chiusura della modalità analyze

Dopo l'audit, **proponi** (non eseguire): *"Vuoi che trasformi il piano di hardening in task operativi sotto `docs/features/<slug>/`, pronti per `flow-run`?"* — e fermati. Procedi a Mode 2 **solo** su conferma esplicita.

---

## Mode 2: `to-tasks` — materializza le wave in task (solo dopo conferma)

Trigger: l'utente conferma esplicitamente (es. *"sì, genera i task"*, *"trasforma le wave in task"*).

Produci un **bundle-feature** sotto `docs/features/<slug>/` identico nel formato a `feature-planner`, così il downstream lo consuma senza modifiche. Regole dettagliate, mapping wave→task e frammentazione: vedi `references/wave-to-tasks.md`.

In sintesi:
- `slug` = `harden-<flow>` (es. `harden-login`), confermato con l'utente.
- Scrivi `audit.md` (il report completo, per provenienza) + i 4 file di contratto (`00-context.md`, `02-abstract.md`, `technical-context.md`, `tasks-active.md`).
- Ogni fix delle wave → uno o più task `<slug>-NNN` (frammenta se >4h o multi-file), con `**Issue**:` di riferimento, categoria 🔧/💻/🧪, dipendenze Wave1→Wave2→Wave3.
- A fine generazione, indirizza a `flow-run` (*"avvia il flow"* o *"esegui solo <slug>-001"*).

---

## Quando NON usarla

- Per pianificare codice nuovo → `feature-planner` / `project-planner`.
- Per applicare i fix → è read-only; i fix li esegue il flow (DEV).
- Per una code review stilistica generica → questa cerca bug e debolezze **verificabili nel flow**, non opinioni.

## Tone

Senior, denso, zero didattica. Lingua dell'utente.
