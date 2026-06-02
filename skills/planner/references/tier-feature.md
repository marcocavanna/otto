# Tier-feature — modo `plan`

> Reference tier-specifico della skill `planner`. Implementa il modo `plan` per il tier `feature`.
> Parte da una context-root **già selezionata** dal router (`SKILL.md`): la scelta del tier e la conferma
> dell'utente sono già avvenute. Questo file descrive l'esecuzione da quel punto in poi.
>
> Reference condivisi consumati (non duplicati qui):
> - Elicitation: `elicitation.md`
> - Critica: `critical-review.md`
> - Espansione task: `task-expansion.md`
> - Template artefatti: `artifact-contract.md` § "Tier `feature`"
> - Schema anchor: `../anchor-schema.md`
> - Contratto planning source: `../planning-source-contract.md`

---

## Flusso `plan <feature>`

Il flusso si compone di 6 passi in sequenza. La derivazione dal codebase **precede** l'elicitation: il
contesto non si elicita da zero, si deriva prima e si chiede solo sui gap.

### Passo 1 — Verifica prerequisiti

1. Verifica che la cwd sia un repo di progetto. Se ambiguo, chiedi conferma del path.
2. Deriva lo **slug** kebab-case dal nome feature (es. "Export utenti CSV" → `user-export`). Conferma con
   l'utente se il mapping non è ovvio o se il nome è lungo/ambiguo.
3. **Guardia anti-overwrite**: se `docs/features/<slug>/` esiste già → **rifiuta immediatamente**,
   indirizza a `expand <feature>` (per ri-generare i task) o `revise <feature>` (per aggiornare
   un'assunzione). Non procedere oltre.

### Passo 2 — Derivazione dal codebase

Prima di chiedere all'utente, ispeziona il repo per inferire stack, convenzioni e build:

1. `CLAUDE.md` di root e dei sub-progetti (routing, stack, vincoli).
2. `.claude/assistant/{project,codebase,code}/00-summary.md` e i file linkati **pertinenti alla feature**
   (non ricaricare l'intero knowledge base — leggere solo ciò che è rilevante al dominio della feature).
3. **1-2 file sample** della stessa categoria della feature (es. un controller se la feature è un
   endpoint, un componente React se è UI) per inferire stile e pattern.
4. Build/test command: da `package.json`, `*.csproj`/`*.sln`, Makefile, script noti, o
   `.claude/assistant/code/*.md`.

Da questa ispezione pre-compila:
- Bozza di `technical-context.md` (build_command, pattern, convenzioni).
- Bozza di `02-abstract.md` (moduli toccati, approccio).

Se l'ispezione è insufficiente (repo opaco, assenza di knowledge), dichiararlo esplicitamente e passare a
un'elicitation più estesa — non inventare convenzioni.

### Passo 3 — Elicitation

Delega a `elicitation.md` con profondità tier **`feature`**: blocchi **A** (A1-A3) e **B** (scope)
obbligatori; blocco **D** come stack-check advisory (solo per verificare coerenza con ciò che il codebase
già ha — non per scegliere lo stack da zero).

Regola chiave: **chiedi solo ciò che il codebase non ha rivelato**. Se la derivazione al Passo 2 ha già
coperto un punto (es. lo stack, le convenzioni di naming, il build command), non ri-elicitarlo.

### Passo 4 — Critica

Delega a `critical-review.md`. Per il tier `feature` sono applicabili i pattern: **1** (scope/effort
mismatch), **4** (nessuna esclusione di scope), **5** (stack-scope mismatch), **7** (lock-in
tecnologico su area ignota), **9** (scope già fallito una volta). I pattern 2, 3, 6, 8 non si applicano
al tier `feature` (vedi `critical-review.md` § "Applicabilità per tier").

Sollevare i problemi rilevati **prima** di generare i 4 file. L'utente decide se mitigare o procedere.
Se procede, i problemi rossi/gialli vanno in `00-context.md` § "Known risks".

### Passo 5 — Generazione dei 4 file

Genera in `docs/features/<slug>/` i **4 file**. Template completi: `artifact-contract.md` § "Tier
`feature`". Regole di espansione task: `task-expansion.md`.

#### 1. `00-context.md`

Contesto feature + tracked assumptions + rischi noti. Porta l'**anchor obbligatorio** subito dopo
il titolo H1 (vedi `../anchor-schema.md` § "Formato canonico"):

```
<!-- Anchor --> **Tier**: feature · **Parent**: <epic-slug|—> · **Bubble-up target**: <docs/epics/<epic>/technical-context.md|—>
```

**Risoluzione `Parent` / `Bubble-up target`**: scan di `docs/epics/*/roadmap.md`.
- **0 match** → feature standalone: `Parent: —` e `Bubble-up target: —`.
- **1 match** (riga `Source: docs/features/<slug>/` trovata nel roadmap) → popolare `Parent` con
  `<epic-slug>` e `Bubble-up target` con `docs/epics/<epic-slug>/technical-context.md`.
- **>1 match** → ambiguità: chiedere disambiguazione esplicita all'utente prima di procedere.

#### 2. `02-abstract.md`

Abstract tecnico della feature: moduli toccati, approccio, integrazione, esclusioni.
**Non porta l'anchor** (vedi `../anchor-schema.md` § "Posizione": solo `00-context.md` e
`technical-context.md`).

#### 3. `technical-context.md`

Seed tattico: build_command, pattern e convenzioni da seguire, VO/contratti consumati. `task-implementer`
lo estende in append-only. Porta l'**anchor obbligatorio** con la stessa valorizzazione di
`00-context.md`.

#### 4. `tasks-active.md`

Task atomici con ID `<slug>-NNN`. **Nessuna milestone** — campo `Feature: <slug>`. Schema
task-entry canonico in `../planning-source-contract.md` § "Schema task-entry". Il campo
`Complessità (ipotesi)` è **obbligatorio** per ogni task; euristica di assegnazione in
`task-expansion.md` § "Assegnazione `Complessità (ipotesi)`".

Numero tipico: 1-8 task. Se supera ~10 → sollevare il punto con l'utente (split feature o promozione
a epic/milestone).

### Passo 6 — Estensione `technical-context.md` (append-only)

Se il `plan` introduce decisioni cumulative che non erano già nel seed (nuovo VO, pattern adottato,
libreria con versione specifica), aggiungere al `technical-context.md` della feature in modalità
**append-only**. Regola: non riscrivere ciò che è già presente; aggiungere solo le voci nuove.

Questa regola vale qui al momento del `plan`; vale a fortiori per `task-implementer` che estende il
file durante il brief dei singoli task.

### Passo 7 — Summary

Dopo aver scritto i 4 file:

1. Lista dei task creati (ID + titolo + effort stimato).
2. Assunzioni più fragili (quelle con `Status: active` in `00-context.md` che dipendono da informazioni
   non confermate o non desumibili dal codebase).
3. Prossimo passo: `flow-run <slug>` (se l'utente vuole eseguire via flow) oppure
   `task-implementer brief <slug>-001` (se vuole un brief manuale per il primo task).

---

## Vincoli di scope

- Scrive **solo** sotto `docs/features/<slug>/`.
- Non tocca `docs/planning/`, `docs/epics/`, né il codice sorgente.
- Non tocca le skill `*-planner` esistenti: `feature-planner` resta attiva in parallelo.
- I 4 file hanno nome fisso: `00-context.md`, `02-abstract.md`, `technical-context.md`,
  `tasks-active.md`.

---
Generato: 2026-06-02 | Task: planner-unification-core-003 | Feature: planner-unification-core
