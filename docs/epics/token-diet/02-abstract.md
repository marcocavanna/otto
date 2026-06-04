# Abstract tecnico — Epic: Token diet del plugin otto (`token-diet`)

## Approccio d'insieme

Compressione **lossless a livello di comportamento**: si riduce il numero di token degli artefatti
prompt (Markdown + frontmatter YAML) senza alterare regole, edge-case né trigger. Tre leve combinate:

1. **Potatura** — rimuovere filler, ripetizioni, rationale ridondante, prosa esplicativa; convertire
   procedure in elenchi puntati densi; tenere prosa breve solo per i distinguo/when-to-use.
2. **Traduzione IT→EN** — la prosa passa in inglese (tokenizzazione ~15% migliore + aderenza), con
   trigger-phrase preservate verbatim.
3. **Rappresentazione giusta** — relazioni/stato in forma strutturata dove già non lo sono; procedure in
   liste; motivazioni in prosa breve.

La `foundation` materializza il guardrail (script di misura + protocollo + glossario + gate) **prima**
dello sweep; i fronti di riscrittura sono indipendenti per file e procedono in parallelo.

## Decisioni tecniche condivise

- **Unità di lavoro = file** (un `SKILL.md` o un agent `.md`). Nessuna feature condivide un file con
  un'altra → niente conflitti, parallelismo pieno dopo la foundation.
- **Gate di accettazione obbligatorio** per ogni file riscritto: (a) checklist edge-case derivata
  dall'originale, tutte le voci ritrovabili nel nuovo testo; (b) diff semantico letto da umano/agente;
  (c) delta token misurato dallo script di baseline.
- **Trigger verbatim**: l'elenco di trigger-phrase nelle `description` non si traduce né si comprime.
- **Niente cambi di semantica**: se durante la riscrittura emerge un'ambiguità o un possibile bug nella
  regola originale, si **annota** (technical-context / decisione), non si "corregge" dentro questo epic.

## Contratti da preservare

- **Design file-based di flow-run**: PM/DEV comunicano solo via `.flow/`, prompt di spawn sottili
  (`"Modalità: implement. TASK: <task>."`), business logic sul disco. Diventa `frozen.txt` della feature
  `token-diet-flow-run`.
- **Hook**: `scope-check` / `verify-gate` e i loro contratti (`RESULT.json`, `ESCALATION.json`).
- **Schema/anchor/contratti planning**: schema task-entry, anchor, `.flow/` — invarianti.
- **Trigger di attivazione** di ogni skill/agent.

## Trade-off

- **Inglese vs manutenibilità per team IT**: gli artefatti sono infrastruttura/prompt, non output utente;
  l'inglese è accettato dalla convenzione otto. L'output verso l'utente resta italiano (non cambia).
- **Compressione vs sicurezza**: si privilegia la sicurezza (gate) sull'aggressività della potatura; un
  file che non supera il gate resta com'è piuttosto che rischiare una regola persa.

## Rischi tecnici cross-feature

- Edge-case densi persi nella potatura (RISK-token-diet-001) → gate.
- Triggering degradato (RISK-token-diet-002) → trigger verbatim.
- Assenza di test automatici (RISK-token-diet-003) → dogfooding post-sweep.

## Esclusioni tecniche

- Nessuna ristrutturazione del **design** di alcuna skill (solo forma del testo).
- Nessun intervento sulle **references on-demand**.
- Nessun nuovo tooling oltre lo script di misura token della foundation.

---
Generato: 2026-06-03 | Versione: 1
