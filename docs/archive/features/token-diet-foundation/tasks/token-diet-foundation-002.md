# token-diet-foundation-002 — Documentare protocollo di compressione, checklist edge-case e gate

**Status**: ✅ finalized
**Origin**: flow-run attended
**Context-root**: docs/features/token-diet-foundation/
**Feature**: token-diet-foundation

---

## Vincoli risolti

### Stack e runtime
- Nessun tooling aggiuntivo. Documento Markdown puro.
- Path scelto: `docs/epics/token-diet/compression-protocol.md` (esempio citato nell'abstract, confermato come path definitivo).

### Librerie e versioni
- N/A (documento operativo, nessuna dipendenza).

### VO/pattern/interfacce consumati
- Schema gate report (§3 del documento) citato nelle feature successive come formato obbligatorio.
- Riferimento a `scripts/measure-tokens.py --delta` per la misura dei delta token (contratto CLI da token-diet-foundation-001).
- Schema voce checklist: `EC-NNN | <file>:<sezione> | <descrizione ≤ 20 parole>`.

### Naming convention
- Voci checklist edge-case: identificatore `EC-NNN` (progressivo per artefatto).
- Esiti gate: `OK` / `EQUIVALENTE` / `DEGRADATO` / `MANCANTE` per checklist; `INVARIATO` / `EQUIVALENTE` / `DIVERGENTE` per diff semantico; `PASS` / `FAIL` per esito gate.

---

## File impattati

- `docs/epics/token-diet/compression-protocol.md` [new]
- `docs/epics/token-diet/technical-context.md` [edit] — §protocollo di compressione aggiornato con link al documento; versione bumped a 2.

---

## Shape reale

```markdown
# compression-protocol.md — struttura del documento

## 1. Protocollo di compressione (5 step obbligatori)
  Step 1 — Estrai la checklist edge-case
  Step 2 — Riscrivi: potatura + prosa EN + struttura a liste
  Step 3 — Preserva le trigger-phrase verbatim
  Step 4 — Gate di accettazione (checklist coverage + diff semantico + delta token)
  Step 5 — Annota, non correggere

## 2. Metodo di estrazione della checklist edge-case
  Tabella segnali testuali → tipo di voce
  Formato voce: EC-NNN | <file>:<sezione> | <descrizione>

## 3. Criteri del gate di accettazione
  Formato gate report obbligatorio (template Markdown)
  Soglie vincolanti: tabella metrica/soglia minima/soglia bloccante
  Deroghe ammesse

## 4. Invarianti cross-feature (never compress)
  Lista contratti/trigger/enum non toccabili
```
(shape, non implementazione finale — il documento completo è in `docs/epics/token-diet/compression-protocol.md`)

**Soglie chiave del gate** (contratto consumato da tutte le feature successive):
- Checklist coverage: 0 voci `MANCANTE` → FAIL
- Diff semantico: 0 sezioni `DIVERGENTE` → FAIL
- Delta token: ≥ −20% su totale artefatto; delta positivo senza giustificazione → FAIL

---

## Deviazioni

- Il path `docs/epics/token-diet/compression-protocol.md` era indicato come "es." nell'abstract — confermato come path definitivo (il glossario IT→EN finirà nello stesso documento o in file separato per task-003).
- Il `technical-context.md` dell'epic è stato aggiornato al volo per rimpiazzare il seed inline del protocollo con un link al documento single-source. Aggiornamento in append coerente con la policy di task-implementer.

---

*Generato: 2026-06-03 | Implementato da: flow-run attended (solo)*
