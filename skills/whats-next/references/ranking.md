# Ranking cross-plan — euristica esposta

Si applica **solo in modalità global** (più piani attivi). Produce una raccomandazione ordinata, **sempre overridabile dall'utente**: non è una decisione, è un consiglio motivato. In modalità scoped (plan/milestone/feature) non c'è ranking: si mostra il next di quel solo piano.

Zero stato, zero campi nuovi: l'ordine si calcola dai dati già nei piani + stato riconciliato (`reconcile.md`).

## Le tre leve, in ordine di priorità

### 1. WIP avanzato — "finiscila prima di aprirne un'altra"
Il rischio più costoso del lavoro in parallelo: feature avviate e lasciate quasi finite → debito cognitivo (reload costoso ad ogni ripresa).

Trigger: un piano (feature o milestone) con **avanzamento ≳ 75%** **e** fermo (nessun task `in-progress`, nessun `RESULT.json` recente) **e** con almeno un task sbloccato.

Motivazione da dare: *"<piano> è al N%, fermo: chiudilo, ogni giorno aperto è costo di reload."* Questa leva **batte** anche il critical-path del macro-plan: un fronte quasi chiuso che si riapre è peggio di un macro-plan che avanza di un task.

### 2. Critical path del macro-plan — "sblocca il maggior numero di task"
Il macro-plan è la spina dorsale strategica. Tra i suoi task sbloccati, privilegia quello con **peso di critical-path** più alto = quanti task lo elencano in `Dipende da` (diretti; se calcolabile, transitivi).

Motivazione: *"T-012 sblocca N task: massimizza il lavoro reso disponibile."*

### 3. Quick win — "se hai poco tempo"
Task sbloccato con **effort basso** (estremo superiore del range ≤ 2h). Utile come riempitivo o quando il contesto dell'utente è frammentato.

Motivazione: *"export-002 è <2h e sbloccato: chiusura rapida."* Segnala anche i quick win che **sbloccano** un fronte fermo (massimo valore per minimo effort).

## Forma della raccomandazione

1-3 mosse, ciascuna con: **cosa** (ID + titolo), **perché** (quale leva), **comando** (`flow-run <id>`). Esempio:

```
1. auth-007 — WIP: auth è all'88% e ferma, chiudila.            → flow-run auth-007
2. T-012   — critical-path: sblocca 3 task del macro-plan.       → flow-run T-012
3. export-001 — quick win <2h che sblocca tutto il fronte export. → flow-run export-001
```

Chiudi sempre ribadendo che la scelta macro-vs-feature è dell'utente: la skill ordina, non comanda.

## Degradazioni oneste

- **Nessuna dipendenza dichiarata** ovunque → la leva 2 non è calcolabile: ordina per fase/categoria e **dillo** ("critical-path non calcolabile, niente deps dichiarate").
- **Effort assente/uniforme** → la leva 3 non discrimina: ometti i quick win invece di inventarli.
- **Un solo piano attivo** → niente ranking cross-plan: degrada a "next del piano" (di fatto modalità plan).
- **Avanzamento ambiguo** (drift non risolto) → calcola sul dato canonico ma segnala l'incertezza nella motivazione.
