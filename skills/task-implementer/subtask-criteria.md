# Subtask criteria

Regole operative per decidere quando un task atomico va decomposto in subtask.

## Default

**Default: nessun subtask.**

Generare subtask è l'eccezione, non la regola. Il task atomico (1-4h) prodotto da `planner` è già al livello di granularità giusto per la pianificazione operativa. Subtask aggiuntivi sono rumore testuale tranne nei casi sotto.

## Quando generare subtask

Solo se rispetta **almeno uno** dei seguenti criteri:

### Criterio 1: Task ai limiti superiori (3.5-4h) con >3 unità logicamente separate

Il task è arrivato al massimo dell'effort accettabile (4h), e l'analisi mostra che internamente contiene più di 3 unità di lavoro che hanno senso compiuto autonomamente.

Esempio valido:
- Task T-008 "Implementare endpoint POST /users" (4h) contiene:
  - DTO + validation (45min)
  - Controller method (30min)
  - Service method (1h)
  - Repository call (30min)
  - Test integration (1.5h)
  - → 5 unità, decomposizione utile

Esempio NON valido:
- Task T-012 "Configurare Serilog" (1h) contiene:
  - Install package (5min)
  - Add to Program.cs (10min)
  - Configure sinks (20min)
  - Test logging (15min)
  - → step di esecuzione lineari di un task piccolo. NIENTE subtask. È rumore.

### Criterio 2: Dipendenza interna esplicita

Esiste un sub-step che blocca il resto. Decomporre rende esplicita la sequenza.

Esempio valido:
- Task "Implementare auth flow":
  - T-NNN.1: Definire schema JWT claims (output: decisione documentata)
  - T-NNN.2: Implementare JWT service (dipende da T-NNN.1)
  - T-NNN.3: Integrare in middleware (dipende da T-NNN.2)

### Criterio 3: Spike interno

Una parte del task è uno spike/decisione che precede l'implementazione. Decomporre per dare visibilità al fatto che c'è una decisione da prendere durante il task.

Esempio valido:
- Task "Aggiungere caching":
  - T-NNN.1: 🔬 Spike — confrontare in-memory vs Redis per il caso d'uso (output: decisione + ADR)
  - T-NNN.2: Implementare scelta da T-NNN.1

### Criterio 4: Componenti ortogonali nello stesso task

Il task tocca aree del codice che sono parallelizzabili o testabili indipendentemente.

Esempio valido:
- Task "Setup CI pipeline":
  - T-NNN.1: Build stage
  - T-NNN.2: Test stage
  - T-NNN.3: Deploy stage
  - (i tre stage si possono fare in qualsiasi ordine e testare separatamente)

## Anti-pattern: subtask come "step di esecuzione"

L'errore più comune è generare subtask che sono semplicemente i passaggi lineari per fare il task. Es:

❌ MAI generare subtask così:
- T-005.1: Crea il file
- T-005.2: Scrivi la classe
- T-005.3: Aggiungi using
- T-005.4: Compila

Questo è rumore puro. È lo flusso di esecuzione normale, non subtask.

## Formato dei subtask quando presenti

Nel brief:

```markdown
## Subtask

- **T-NNN.1** — [titolo] — effort: [Xh] — output: [cosa produce]
- **T-NNN.2** — [titolo] — effort: [Xh] — output: [cosa produce] — dipende da T-NNN.1
- **T-NNN.3** — [titolo] — effort: [Xh] — output: [cosa produce]
```

Regole:
- Effort dei subtask deve **sommare** all'effort del task originale (con tolleranza ±20%)
- Ogni subtask ha un **output osservabile** (file, decisione, test passante), non solo "completato"
- Dipendenze esplicitate
- Mai più di 5-6 subtask per task. Se ne servono di più, il task è strutturalmente troppo grande — fermarsi e suggerire di splittare il task con `planner`.

## Quando NON generare subtask anche se sembrano applicabili

- **Tutta la milestone è di task piccoli (<2h)**: i subtask diventano frammentazione esagerata.
- **Il task è di pura configurazione**: nessuna decomposizione utile.
- **L'utente ha già il task ben in mente**: i subtask sono ridondanti.

In tutti questi casi, output esplicito nel brief:

```markdown
## Subtask

**Nessun subtask necessario** — esecuzione lineare.
```

Senza spiegazioni aggiuntive. Una riga, secca.
