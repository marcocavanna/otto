# Revision

Regole per il mode `revise` — aggiornare il piano quando un'assunzione cambia o una decisione viene rivista.

## Trigger tipici

- Utente cambia stack ("ho deciso di usare X invece di Y")
- Utente cambia scope ("aggiungo feature Z" / "tolgo feature W")
- Utente cambia vincoli ("ora ho più/meno tempo a settimana")
- Utente revisiona un'assunzione che era marcata come `active`
- Utente chiede di rigenerare un artefatto specifico

## Workflow

1. **Identificare cosa cambia**. Chiedere all'utente:
   - Quale assunzione viene rivista (ASSUMPTION-NNN)? OPPURE quale parte del contesto cambia?
   - Quale è il nuovo valore?

2. **Calcolare l'impatto**. Leggere `00-context.md` e identificare:
   - Quali artefatti sono linkati a quell'assunzione (campo `Impatta:`)
   - Quali sezioni specifiche di quegli artefatti referenziano l'assunzione

3. **Presentare il piano di revisione prima di eseguirlo**:
   ```
   La modifica impatta:
   - 02-abstract.md: sezione "Stack" e "Trade-off"
   - 03-milestones.md: M1 (effort), M3 (DoD)
   - 05-tasks-active.md: 4 task atomici diventano obsoleti

   Procedo con l'aggiornamento? [si/no/modifica]
   ```

4. **Eseguire le modifiche** preservando:
   - Struttura dei file (non riscrivere tutto da zero)
   - Sezioni non impattate (toccare solo ciò che cambia)
   - Storia delle assunzioni: l'assunzione vecchia diventa `superseded`, la nuova viene aggiunta come nuovo ID

5. **Incrementare il versionamento**: ogni file modificato ha `Versione: N+1` nel footer.

6. **Aggiornare il README.md**: campo "Ultimo update".

## Gestione assunzioni superseded

Quando un'assunzione viene rivista, NON cancellarla. Marcarla così in `00-context.md`:

```
### ASSUMPTION-003
- **Descrizione**: Stack frontend = Vue
- **Scelta**: Vue 3 + Vite
- **Status**: ⛔ superseded da ASSUMPTION-007
- **Data**: 2025-03-10
- **Superseded il**: 2025-04-22

### ASSUMPTION-007
- **Descrizione**: Stack frontend = React (sostituisce ASSUMPTION-003)
- **Scelta**: React 19 + Vite
- **Motivo cambio**: maggior familiarità del team, ecosistema più solido per il dominio
- **Impatta**: 02-abstract.md, 05-tasks-active.md (T-005, T-009)
- **Status**: ✅ active
- **Data**: 2025-04-22
```

Questo crea un audit trail. Per progetti personali può sembrare overkill ma serve quando dopo 3 mesi non ricordi perché hai fatto una scelta.

## Casi limite

### Modifica che invalida la milestone attiva

Se la revisione invalida significativamente la milestone attiva (es. cambio stack mid-milestone):

1. Avvisare esplicitamente.
2. Proporre 3 opzioni:
   - **a)** Completare M1 con stack vecchio, applicare cambio da M2
   - **b)** Pausare M1, ricominciare con nuovo stack
   - **c)** Spike per validare il cambio prima di committarsi

3. Aspettare scelta utente prima di procedere.

### Modifica che invalida la metrica di successo

Se E1 cambia, l'ultima milestone va probabilmente rivista. Trattare come revisione strutturale, non superficiale.

### Conflitto tra assunzioni

Se la nuova assunzione contraddice un'altra assunzione `active`, sollevare il conflitto:

```
⚠ Conflitto: ASSUMPTION-007 (nuovo: stack React) è in conflitto con
ASSUMPTION-004 (active: SSR obbligatorio per SEO).
Stack React richiede di scegliere tra Next.js, Remix o accettare client-only.
Quale risolviamo prima?
```

## Out of scope per revise

`revise` non gestisce:
- Re-elicitation completa (per quello c'è `init`, ma richiede di archiviare la cartella esistente)
- Refactoring del pitch dopo pivot di prodotto (per quello, meglio archiviare e fare nuovo init)
- Auto-detection delle modifiche di contesto: l'utente deve esplicitamente dire cosa cambia

Se l'utente sta chiedendo qualcosa che non rientra nel mode `revise`, suggerire l'alternativa appropriata.
