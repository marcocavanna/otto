# Lazy reading — razionale e mappa step→reference

> Reference documentale. Non contiene logica operativa: quella è in `agents/dev.md` (mappa step→reference) e nei file di skill (`preflight.md`, `context-loading.md`).

## Problema originale

Il DEV caricava upfront l'intero bundle di reference prima di iniziare il task: `preflight.md`, `context-loading.md`, `decision-classification.md`, `build-verification.md`. Su task trivial/standard senza decisioni cross-task e senza build command, 2-3 letture erano inutili (le reference non venivano mai usate nel task).

Contemporaneamente, preflight Check 6 e context-loading step 2-3 rifacevano gli stessi calcoli (identificazione categoria + sample-search).

## Soluzione

**B — lazy reference reading** (topology-lean-exec-001): ogni reference viene aperta solo allo step che la usa. La mappa operativa è in `agents/dev.md`.

**C — dedup preflight⟷context-loading** (topology-lean-exec-002): preflight Check 6 è single-source di `{categoria, sample-path, file impattati}`; context-loading step 2-3 consuma questi artefatti invece di ricalcolarli.

## Mappa step→reference (DEV — canonica in `agents/dev.md`)

- **step1 preflight** → `preflight.md`
- **step2 context-loading** → `context-loading.md`, `writing-rules.md`
- **step3 decisioni** → `decision-classification.md` **solo se** emergono decisioni cross-task
- **step4 code generation** → nessuna reference aggiuntiva
- **step5 build** → `build-verification.md` **solo se** build command dichiarato nel brief

Fonte operativa: `agents/dev.md`. Qui è solo a scopo consultivo.

## Artefatti preflight→context-loading

Preflight Check 6 emette `{categoria, sample-path, file impattati}` come artefatti strutturati. Context-loading step 2-3 li consuma direttamente invece di ricalcolarli. Vedi `preflight.md` Check 6 e `context-loading.md` step 2-3 per i dettagli di Come implementare il raccordo.

## Invarianza degli artefatti

Questa ottimizzazione non cambia cosa decide o produce il DEV/PM: stessi artefatti (brief/scope/frozen/meta/output), meno letture sui task trivial/standard.
