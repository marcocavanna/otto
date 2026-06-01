# Topology Harness — Fixture

Materiale di input statico e versionato per l'harness di topologia del loop attended.
NON è un progetto reale: è un repo fittizio (`Acme Notes`) con golden-task sintetici
ma realistici, usato per esercitare resolver / PM / contratti su input controllato.

Prodotto da `topology-harness-001`. Consumato da:
- `topology-harness-002` (runner) — esegue il loop sui golden-task in un `.flow/` temporaneo.
- `topology-harness-003` (asseritore) — confronta l'output contro gli `snapshot.json`.

## Layout

```
tests/harness/fixture/
  README.md                                  # questo file
  docs/
    planning/                                # project source (context-root: docs/planning)
      00-context.md  02-abstract.md  technical-context.md  05-tasks-active.md
    features/
      sample-feature/                        # feature source (context-root: docs/features/sample-feature)
        00-context.md  02-abstract.md  technical-context.md  tasks-active.md
  golden-tasks/
    <golden-id>/snapshot.json                # invarianti attese per ciascun golden-task
```

> Il fixture NON committa `.flow/`. Il runner crea un `.flow/` temporaneo a runtime.
> Topologia usata: **corrente** (flat `docs/tasks/`), non la canonical target
> (vedi assunzione locale 1 di `topology-harness-001`).

## Golden-task

7 task; naming: `fixture-proj-NNN` (project source), `fixture-feat-NNN` (feature source).

| Golden-id          | Source  | Category        | Expected complexity | Context-root atteso                |
|--------------------|---------|-----------------|---------------------|------------------------------------|
| fixture-proj-001   | project | config          | trivial             | docs/planning                      |
| fixture-proj-002   | project | command-handler | critical            | docs/planning                      |
| fixture-feat-001   | feature | dto             | trivial             | docs/features/sample-feature       |
| fixture-feat-002   | feature | repository      | standard            | docs/features/sample-feature       |
| fixture-feat-003   | feature | ui-component    | standard            | docs/features/sample-feature       |
| fixture-feat-004   | feature | value-object    | critical            | docs/features/sample-feature       |
| fixture-feat-005   | feature | config          | standard            | docs/features/sample-feature       |

Distribuzione complexity: trivial=2, standard=3, critical=2 (rispetta ≥1 trivial, ≥2 standard, ≥2 critical).
Le `expected_complexity` derivano dai criteri deterministici in
`skills/task-implementer/references/complexity-criteria.md` (fail-safe verso l'alto):
- `fixture-proj-001` e `fixture-feat-001` restano `trivial` (locali, nessun contratto).
- `fixture-proj-002` e `fixture-feat-004` salgono a `critical` (contratto nuovo cross-cutting: command / VO).
- `fixture-feat-005` è `config` ma il segnale 1 (contratto di opzioni consumato da altri) lo alza a `standard`.

## Schema snapshot

Ogni `snapshot.json` (`$schema: "versione 1"`) dichiara le invarianti raggruppate per dimensione.
Tutti i path sono **relativi alla root del fixture**, non del repo otto.

```json
{
  "$schema": "versione 1",
  "task_id": "<id>",
  "source": "project|feature",
  "context_root": "<path>",
  "invariants": {
    "resolver": { "resolves_to_one": true, "expected_context_root": "<path>" },
    "brief":    { "required_sections": ["Obiettivo", "Vincoli risolti", "File impattati", "Out of scope"],
                  "must_not_be_empty": ["Obiettivo", "File impattati"] },
    "scope":    { "must_contain": ["<path>", "..."],
                  "must_contain_service_glob": ".flow/briefs/<id>/**" },
    "frozen":   { "must_contain": ["<contratto>", "..."] },
    "meta":     { "complexity_in_enum": true, "expected_complexity": "trivial|standard|critical" }
  }
}
```

Le asserzioni sono **a insiemi/presenza** (`contains`, `⊇`, `matches-enum`, `resolves-to-one`),
mai uguaglianza byte-a-byte di output LLM (vedi `frozen.txt` del task e `attended-flow.md`).

## Invarianza

**Invariante** = proprietà che deve valere indipendentemente da variazioni dell'LLM:
- l'ID risolve a **una** sola context-root (`resolver.resolves_to_one`);
- il brief contiene le **sezioni canoniche** richieste e non lascia vuote quelle obbligatorie;
- `scope.txt` **contiene** i path dei file impattati + il glob di servizio `.flow/briefs/<id>/**`;
- `frozen.txt` **contiene** i contratti/VO che il task non deve toccare;
- `meta.json.complexity` è nell'**enum** ed è il **tier atteso** secondo i criteri deterministici.

**Non-invariante** = contenuto su cui l'LLM può legittimamente variare e che NON va asserito:
- testo verbale del brief (frasi, ordine dei bullet, wording);
- nomi di variabili / commenti generati nel codice;
- formattazione, righe vuote, ordine non significativo degli elementi.

## Procedura di aggiornamento snapshot

Quando un contratto cambia **intenzionalmente** (es. nuovo campo obbligatorio nel brief,
nuovo path in scope, cambio di tier di un golden-task):

1. Rieseguire il loop sul golden-task interessato (via runner, in `.flow/` temporaneo).
2. Verificare **manualmente** che la variazione rilevata sia voluta, non una regressione.
3. Aggiornare lo `snapshot.json` corrispondente.
4. Committare con messaggio esplicito che motiva la variazione dell'invariante.

Mai aggiornare uno snapshot "per far passare il test" senza il passo 2: lo snapshot è la
fonte-di-verità, non un sottoprodotto dell'esecuzione corrente.

## Limiti

- Materiale sintetico: piccolo per design, mantenibilità sopra realismo esaustivo.
- Nessun golden-task per **epic source** (non esiste `tasks-active.md` sotto `docs/epics/`).
- Nessuna esecuzione reale del loop in questo spike (solo input + invarianti attese).
