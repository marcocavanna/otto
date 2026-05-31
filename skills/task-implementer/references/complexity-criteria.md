# Complexity criteria — autovalutazione del PM (attended)

> Reference consumata dal **PM** in modalità attended per assegnare a un task un valore `complexity ∈ {trivial, standard, critical}`.
> Output deterministico e difendibile: dato lo stesso task, applicando questi criteri si ottiene la stessa classificazione.
> NON contiene la mappa `complexity → modello`: quella è single-source in [`../../flow-run/references/model-tiering.md`](../../flow-run/references/model-tiering.md) (consumata da `flow-run` allo spawn del DEV). Qui ci si ferma a `complexity`.

## Scopo

Il PM, nello stesso step in cui materializza `scope.txt` / `frozen.txt`, emette anche `.flow/briefs/<task>/meta.json` con la complessità del task. Questa reference è la base decisionale per quel valore. Non definisce il meccanismo di emissione (è del task che integra `attended-flow.md`/`agents/pm.md`) né la mappa verso i modelli (è di `flow-run`).

## Input decisionali

La classificazione si basa su quattro segnali, in **ordine di peso** decrescente:

1. **Decisioni cross-cutting / contratti nuovi** — il task introduce o modifica qualcosa che **altri task consumano**: un Value Object, un'interfaccia, un formato di file/contratto (es. un nuovo artefatto in `.flow/briefs/<task>/`), una convenzione estesa al resto del codebase. Spinge con forza verso `critical`.
2. **Superficie di rischio** — cosa si rompe se l'implementazione è sbagliata: la build, un contratto PM↔DEV, il protocollo del loop, un boundary di sicurezza/multi-tenant, una migrazione dati. Più ampio e irreversibile è il danno, più alto il tier.
3. **Numero di file impattati** — `1` = basso, `2-3` = medio, `>3` = alto. Indicatore di estensione, non di criticità intrinseca: modula, non determina.
4. **Categoria primaria del task** — il default di partenza (vedi tabella). È il segnale di **minor** peso: viene modulato dai tre precedenti.

> Le categorie sono l'insieme autorevole definito in [`../../code-implementer/context-loading.md`](../../code-implementer/context-loading.md) (§ "Identificazione categoria"). Qui si **referenzia** quel set, non lo si ridefinisce.

## Output

Un singolo valore: `trivial`, `standard` oppure `critical`.

- `trivial` — modifica locale, isolata, a basso rischio: nessun contratto nuovo, rischio limitato a sé stessa, pochi file. Candidata al modello più economico.
- `standard` — task di lavoro ordinario: consuma contratti esistenti senza introdurne di nuovi, rischio circoscritto, estensione media.
- `critical` — il task introduce contratti consumati da altri, ha superficie di rischio ampia (build/protocollo/sicurezza), o coinvolge decisioni cross-cutting.

## Regola di tie-break

**Fail-safe verso l'alto**: in dubbio tra due tier adiacenti (`trivial`↔`standard` o `standard`↔`critical`), scegliere sempre il **più alto**. Mai degradare un task incerto a `trivial`.

Motivo: una sottostima fa girare il DEV su un modello troppo debole, la build/verifica fallisce e i retry del gate consumano più token del risparmio (vedi RISK-model-tiering-001). Sovrastimare costa al massimo un task in più su un modello potente; sottostimare costa il task **più** i retry.

## Tabella categoria → complessità di default

> Punto di partenza, **modulato** dai segnali 1-3. Categorie: set autorevole in [`../../code-implementer/context-loading.md`](../../code-implementer/context-loading.md) — non ridefinire qui.

| Categoria (default) | Complessità di partenza |
|---|---|
| `config`, `dto`, `validator`, `migration` (banale) | `trivial` |
| `controller`, `repository`, `ui-component`, `query-handler`, `react-hook`, `application-service`, `middleware` | `standard` |
| `domain-entity`, `command-handler`, `value-object`, decisioni cross-cutting | `critical` |

Il default è solo il segnale di partenza (peso minore). I segnali 1-3 lo modulano in entrambe le direzioni:

- Un task `config` che introduce un **contratto nuovo** (segnale 1) o tocca un boundary di sicurezza (segnale 2) **sale** sopra `trivial`.
- Un `command-handler` puramente meccanico, senza contratti nuovi e a basso rischio, **può** restare `standard` — ma in dubbio, per il tie-break, → `critical`.
- Un task con `>3` file (segnale 3) raramente resta `trivial`.

## Scenari di riferimento

Esempi d'applicazione (per il PM, non test di codice):

- Task `config`, 1 file, nessun contratto, rischio basso → **`trivial`**.
- Task `repository` standard, 2-3 file, consuma VO esistenti, nessun contratto nuovo → **`standard`**.
- Task `domain-entity`, oppure qualunque task che introduce un contratto nuovo consumato da altri task → **`critical`**.
- Edge: categoria di default `trivial` (es. `config`) ma il task **introduce un VO/contratto nuovo** → il segnale 1 prevale e il fail-safe spinge verso l'alto → **`standard`/`critical`** (mai `trivial`).

## Procedura sintetica per il PM

1. Identifica la **categoria primaria** del task (insieme: `code-implementer/context-loading.md`) → leggi il default in tabella.
2. Verifica il **segnale 1** (contratti/decisioni cross-cutting): se presente, alza ad almeno `standard`, tipicamente `critical`.
3. Verifica il **segnale 2** (superficie di rischio): build/protocollo/sicurezza ampi → alza.
4. Pesa il **segnale 3** (#file): `>3` raramente compatibile con `trivial`.
5. In caso di dubbio tra due tier adiacenti → **tier più alto** (fail-safe).
6. Emetti il valore risultante come `complexity` in `meta.json`.
