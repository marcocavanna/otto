# Wave → Task — generazione del bundle eseguibile

Regole per la modalità `to-tasks`: convertire il piano di hardening (le wave dell'audit) in un **bundle-feature** che `task-implementer` / `code-implementer` / `flow-run` eseguono **senza modifiche**. Si scrive **solo** sotto `docs/features/<slug>/`. Mai codice.

## Slug

`slug = harden-<flow>` in kebab-case (es. flusso di login → `harden-login`). Confermalo con l'utente prima di scrivere. Se `docs/features/<slug>/` esiste già → non sovrascrivere: proponi un suffisso (`harden-login-2`) o `revise`.

## File da produrre (bundle conforme al contratto)

Stesso formato di `../planner/planning-source-contract.md` (§ "Planning source contract" è la fonte di verità della risoluzione downstream). Popolati **dall'audit**, non da elicitation:

1. **`audit.md`** — il report completo delle 5 sezioni (provenienza permanente: da qui sono nati i task).
2. **`00-context.md`** — Teoria del flusso (sez. 1) + sintesi delle issue + boundary del flusso analizzato. Le issue diventano `RISK-<slug>-NNN`.
3. **`02-abstract.md`** — approccio di hardening + **"Contratti da preservare"**: le interfacce/contratti del flusso esistente che NON vanno rotti (diventeranno il `frozen.txt` quando il flow genera il brief). Esclusioni tecniche.
4. **`technical-context.md`** — seed: `build_command` (dedotto dal codebase), pattern/convenzioni del flusso da rispettare, costrutti esistenti vincolanti.
5. **`tasks-active.md`** — i task delle wave (sotto).

## Mapping wave → task

- Ogni riga `Fix` delle tabelle di hardening → **almeno un task**.
- **Frammentazione** (regole di `../planner/references/task-expansion.md`): se un fix è >4h o tocca molti file/aree, spezzalo in più task atomici (1-4h ciascuno, DoD binaria). Meglio 3 task netti che 1 task-mostro.
- **Categoria**: 🔧 fix (bug) · 💻 impl (rework) · 🧪 test (copertura del fix). Un bug critico tipicamente genera una coppia 🔧 fix + 🧪 test.
- **Tracciabilità**: ogni task riporta `**Issue**: BC-01` (le issue che chiude). Niente task senza issue di origine.
- **Dipendenze / ordine**: Wave 1 → Wave 2 → Wave 3. I task della Wave 2 dipendono dal completamento dei critici della Wave 1; la Wave 3 (refactor/perf) viene per ultima. Esplicita le dipendenze nel campo `Dipende da`.
- **DoD**: concreta e verificabile — "issue BC-01 non più riproducibile + test che lo dimostra + build verde".

### Formato task (identico al tier feature di `planner`)

```markdown
### harden-login-001 — 🔧 [fix] Correggere null-deref in TokenValidator.Validate
- **Effort**: 1-2h
- **Issue**: BC-01, BL-03
- **Definition of done**: input null/empty gestito; test che riproduceva il crash ora verde; build OK
- **Dipende da**: —
- **Status**: ⚪ todo
```

## ID e unicità

ID = `<slug>-NNN`, **globalmente unici** (è la chiave con cui il downstream risolve la context-root via scan). Non riusare un ID per un task diverso.

## Provenienza / Origin

I task vivono in `docs/features/<slug>/`: `task-implementer` li tratterà come task **feature** (`Origin: planner`, niente milestone) — corretto e voluto, nessuna modifica ai downstream. La provenienza "da audit" resta tracciata in `audit.md` e nel campo `**Issue**:` di ogni task.

## Dopo la generazione

Stampa un summary (quanti task per wave, quali issue coperte) e indirizza all'esecuzione:
- tutto l'hardening → *"avvia il flow"*
- una wave/task alla volta → *"esegui solo `<slug>-001`"*

Quando il flow genera il brief, le "Contratti da preservare" del `02-abstract.md` alimentano il `frozen.txt` → il DEV non romperà le interfacce del flusso mentre lo mette in sicurezza. Cerchio chiuso.
