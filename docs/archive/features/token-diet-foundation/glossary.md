# Glossario IT→EN — Termini di dominio otto

<!-- Anchor --> **Tier**: feature deliverable · **Project**: otto · **Scope**: termine di dominio ricorrente in flow-run, skill, agent, planning.

Traduzione canonica per coerenza terminologica tra file. Utilizzato dalle feature di riscrittura di flow-run, skill e agent per garantire consistenza di naming EN nei redesign.

---

## Glossario operativo

### A

| IT | EN | Contesto / Note |
|:---|:---|:---|
| analisi | analysis | Riferito a fase di task (task-implementer, step 3). |
| artefatto | artifact | Prompt caricato a runtime (SKILL.md, agent .md). |
| atteso/attese | expected | Nel contesto di assunzioni operative o risultati attesi. |

### B

| IT | EN | Contesto / Note |
|:---|:---|:---|
| baseline | baseline | Snapshot di metriche token salvato nello script di misura. |
| brief | brief | Documento di analisi tecnica di un task (prodotto da task-implementer). |

### C

| IT | EN | Contesto / Note |
|:---|:---|:---|
| checklist | checklist | Voce di verifica nel gate di accettazione (formato EC-NNN). |
| contratto | contract | Interfaccia/VO/schema scambio dati tra componenti (es. RESULT.json, ESCALATION.json). |
| coverte | covered | Riferito a voce checklist verificata (esito `OK`, `EQUIVALENTE`). |

### D

| IT | EN | Contesto / Note |
|:---|:---|:---|
| delta | delta | Differenza quantitativa (token, char) tra misura before/after. |
| deviazione | deviation | Scostamento da piano task durante implementazione. |
| decisione | decision | Scelta tecnica (locale, cross-task, strategica). |
| dipendenza | dependency | Requisito su task/feature precedente o risorsa esterna. |
| dominio | domain | Contesto semantico (es. "termini di dominio otto" = vocabolario otto). |

### E

| IT | EN | Contesto / Note |
|:---|:---|:---|
| epic | epic | Raggruppamento multi-feature ad alto livello (es. token-diet). |
| escalation | escalation | Segnalazione di blocco decisionale (L1, L2, L3) a orchestratore/utente. |
| esito | outcome | Risultato di verifica (pass, fail, skipped). |

### F

| IT | EN | Contesto / Note |
|:---|:---|:---|
| feature | feature | Raggruppamento di task atomici con planning autonomo e context-root dedicata. |
| finalize | finalize | Chiusura task (mode 3 di task-implementer): marca brief come ✅ finalized, aggiorna technical-context.md. |
| finestra / window | window | Intervallo temporale (es. "window di misurazione"). |
| flow-run | flow-run | Orchestratore di spawn atomici (PM) e fork sequenziali (DEV); gestisce `.flow/` e gate. |

### G

| IT | EN | Contesto / Notes |
|:---|:---|:---|
| gate | gate | Checkpoint di validazione (scope-check, verify-gate, finalize-gate). |
| glossario | glossary | Documento di traduzione canonica (questo file). |
| glossario IT→EN | glossary IT→EN | Titolo esteso per disambiguazione. |

### I

| IT | EN | Contesto / Note |
|:---|:---|:---|
| implementazione | implementation | Traduzione di brief in codice (mode 1 di code-implementer). |
| invariante | invariant | Contratto da non violare mai (es. struttura `.flow/`, schema RESULT.json). |

### L

| IT | EN | Contesto / Note |
|:---|:---|:---|
| libreria | library | Dipendenza di runtime o build (npm, NuGet, pip, ecc.). |

### M

| IT | EN | Contesto / Note |
|:---|:---|:---|
| materiale | material | File/artefatto di input (brief, contesto, schema). |
| materializzazione | materialization | Creazione di artefatto (scope.txt, frozen.txt, RESULT.json). |
| metodo | method | Procedura codificata (es. metodo di estrazione checklist in compression-protocol.md). |
| metrica | metric | Misura quantitativa (token, char, complexity score). |
| milestone | milestone | Insieme di task con data/obiettivo comune (project-planner M1, M2, ...). |
| misura | measurement | Conteggio quantitativo (token count). |

### O

| IT | EN | Contesto / Note |
|:---|:---|:---|
| orchestratore | orchestrator | Sistema che coordina spawn/fork (flow-run). |
| outcome | outcome | Vedi "esito". |

### P

| IT | EN | Contesto / Note |
|:---|:---|:---|
| pattern | pattern | Design pattern ricorrente (es. VO, CQRS). |
| piano | plan | Documento di struttura/sequenza (es. piano implementazione). |
| precondizione | precondition | Requisito che deve essere vero prima di un step (pre-flight check, gate). |
| processo | process | Sequenza ordinata di step (es. attended flow). |
| progetto | project | Codebase principale (es. "progetto otto"). |
| promise | promise | Promessa di consegna (non usare nei brief tecnici; preferire "commitment" o "versione"). |
| protocollo | protocol | Sequenza standardizzata di step (es. protocollo di compressione). |

### R

| IT | EN | Contesto / Note |
|:---|:---|:---|
| ramo | branch | Percorso decisionale (es. "ramo solo" vs "ramo team"). |
| rischio | risk | Minaccia nota a realizzazione/efficacia. |

### S

| IT | EN | Contesto / Note |
|:---|:---|:---|
| scenario | scenario | Caso d'uso o situazione specifica. |
| scope | scope | Insieme di path/entità scrivibili da DEV (scope.txt). |
| scope-check | scope-check | Hook bash che valida Write/Edit entro scope.txt + frozen.txt. |
| sezione | section | Parte di documento (es. "Sezione Vincoli risolti"). |
| shape | shape | Struttura scheletrica del codice (20-30 righe, non implementazione finale). |
| skill | skill | Plugin modulare che implementa un'operazione (task-implementer, code-implementer, flow-run, ecc.). |
| soddisfare / satisfy | satisfy | Adempiere a vincolo/requisito. |
| solo | solo | Modalità fast-path DEV senza interventi PM. |
| sorgente | source | Origine dati (planning source: project-planner, feature-planner). |
| source | source | Vedi "sorgente". |
| spawn | spawn | Invocazione discreta di task/process (orchestrator → agent). |
| step | step | Fase/gradino di procedura. |

### T

| IT | EN | Contesto / Note |
|:---|:---|:---|
| task | task | Unità di lavoro atomica (pianificata in project-planner o feature-planner). |
| task file | tasks file | Documento di piano task per feature/progetto (tasks-active.md). |
| team | team | Modalità di handoff tra PM e DEV (opposto di "solo"). |
| technical-context | technical-context | Documento di decisioni tattiche cumulative (tattico vs strategico di 02-abstract.md). |
| terminologia | terminology | Scelta di naming (es. "terminologia EN"). |
| token | token | Unità di compressione prompt (ChatGPT encoding, ~3.4 char it / ~4.0 char en). |
| trigger-phrase | trigger-phrase | Frase chiave che attiva un'operazione di skill/agent (es. "implementa il task T-NNN"). |

### U

| IT | EN | Contesto / Note |
|:---|:---|:---|
| utente | user | Sviluppatore/architetto che interagisce con otto. |

### V

| IT | EN | Contesto / Note |
|:---|:---|:---|
| validazione | validation | Controllo di correttezza/coerenza. |
| valore | value | Dato/risultato (es. "valore atteso"). |
| verify | verify | Esecuzione di test/build per validare implementazione (step 5 di code-implementer). |
| verify-gate | verify-gate | Hook che verifica che build/test passino prima di chiusura task. |
| versione | version | Release/incremento (plugin, documento, schema). |
| vincolo | constraint | Limitazione/requisito vincolante. |
| VO | value object | Oggetto valore (contratto dati immodificabile). |

---

## Abbreviazioni e acronimi

| Acronimo | Espanso | Contesto |
|:---|:---|:---|
| CLI | command-line interface | Interfaccia linea di comando. |
| EC-NNN | edge-case NNN | Identificatore progressivo voce checklist. |
| EN | English | Lingua inglese. |
| IT | Italian | Lingua italiana. |
| L1, L2, L3 | escalation level 1, 2, 3 | Gravità escalation. |
| PM | project manager | Orchestratore (flow-run, attended mode). |
| DEV | developer | Implementatore (code-implementer, attended mode). |
| VO | value object | Vedi "VO" sopra. |
| YAML | YAML Ain't Markup Language | Formato dati (frontmatter dei prompt). |

---

## Regole di utilizzo

1. **Coerenza**: ogni occorrenza di termine IT nel glossario deve essere tradotta in colonna EN nei brief EN. Niente varianti ad hoc.
2. **Scope**: il glossario copre solo termini di **dominio otto** (workflow, artefatti, gate, skill). Non include termini tecnici generici (algoritmo, libreria, ecc.) se non con precisazione otto-specifica.
3. **Estensione**: il glossario è append-only. Se una feature introduce un termine nuovo e significativo, aggiungere una riga in ordine alfabetico.
4. **Cross-reference**: se un termine nel glossario rimanda a un documento (es. "Vedi compression-protocol.md"), aggiungere il link nel contesto.

---

*Generato: 2026-06-03 | Versione: 1 | Delivery task: token-diet-foundation-003*
