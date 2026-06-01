# Protocollo di lock source-level — `flow-run`

> Single-source del protocollo di lock. Consumato da: `SKILL.md` § Claim source,
> `topology-concurrency-core-002` (PROGRESS per-source), `topology-concurrency-core-004` (auto-archivio).
> Nessun altro file ridefinisce la soglia o la struttura del lock: la citano da qui.

Lock advisory POSIX a grana-**source**. Un flow possiede una source per tutta la durata
(ASSUMPTION-topology-concurrency-core-001); i task interni sono seriali. `planning` è un singolo lock.

## Struttura lock

```
.flow/locks/<slug>/               ← directory (creazione atomica POSIX)
.flow/locks/<slug>/heartbeat.ts   ← timestamp Unix decimale in secondi (stringa)
```

`<slug>` è lo slug della source (es. `topology-concurrency-core`, `planning`).

La directory è il lock: `mkdir` di una directory esistente fallisce (EEXIST) ed è atomico
su filesystem POSIX. Questo è il primitivo di mutua esclusione — non si usano file di lock
separati né flock (non portabili allo stesso modo).

## Costante: soglia di reclaim

```
RECLAIM_TTL = 300   # secondi (5 minuti)
```

Motivazione del valore: abbastanza lungo da assorbire task lunghi (effort massimo ~4h con
heartbeat aggiornato a ogni transizione di stato, non un singolo write ogni 4h); abbastanza
corto da non bloccare il re-claim a lungo dopo il crash di un flow. È l'**unica** definizione
della soglia: gli altri moduli la leggono da qui.

## Formato `heartbeat.ts`

Timestamp Unix in secondi, stringa decimale (es. `1748793600`). Scritto con il tempo corrente
del flow al momento della transizione. Lettura del mtime per il calcolo dello stantio: usare
il **mtime del file**, non il contenuto, per evitare drift fra ciò che è scritto e quando è
stato scritto.

Lettura portabile del mtime (secondi):

```sh
# macOS / BSD
stat -f%m .flow/locks/<slug>/heartbeat.ts
# Linux / GNU
stat -c%Y .flow/locks/<slug>/heartbeat.ts
```

Wrapper portabile:

```sh
mtime() { stat -f%m "$1" 2>/dev/null || stat -c%Y "$1" 2>/dev/null; }
now()   { date +%s; }
```

## Semantica "source viva"

Una source è **viva** sse:

```
lock esiste  AND  (now - mtime(heartbeat.ts)) < RECLAIM_TTL
```

È **stantia** sse il lock esiste ma `(now - mtime(heartbeat.ts)) >= RECLAIM_TTL`
(flow crashato o sospeso oltre soglia). È **libera** sse il lock non esiste.

## Algoritmo claim

Scan delle source con task `pending`, in ordine. Per ciascuna:

```
1. mkdir .flow/locks/<slug>/
   → successo (lock acquisito):
       scrivi heartbeat.ts (now)
       procedi: source acquisita, esci dallo scan
   → fallisce (EEXIST):
       ts=$(mtime heartbeat.ts)
       se ts assente (lock parziale: dir senza heartbeat) → trattare come stantio
       se (now - ts) < RECLAIM_TTL  → source VIVA  → skip, prossima source
       se (now - ts) >= RECLAIM_TTL → source STANTIA → reclaim (vedi sotto), poi acquisita
```

Se lo scan termina senza acquisire alcuna source → vedi § Assenza di source.

## Reclaim su stantio

```
rmdir .flow/locks/<slug>/          # ignora ENOENT: già rimosso da un altro flow
mkdir .flow/locks/<slug>/          # se fallisce qui → un altro flow ha vinto il reclaim: skip, prossima source
scrivi heartbeat.ts (now)
```

Il `rmdir` può fallire con ENOENT se nel frattempo un altro flow ha già rilasciato/reclaimato:
si ignora e si prova `mkdir`. Se anche `mkdir` fallisce (EEXIST), un altro flow ha vinto la
corsa al reclaim → la source è di nuovo viva sotto altro owner → skip alla prossima source.
Questo chiude RISK-topology-concurrency-core-002 (lock orfano) senza introdurre la race di
RISK-topology-concurrency-core-001 (chi perde il `mkdir` passa oltre, non forza).

> Nota: `rmdir` su lock con `heartbeat.ts` ancora presente fallisce (directory non vuota).
> Rimuovere prima il contenuto: `rm -f .flow/locks/<slug>/heartbeat.ts` poi `rmdir`. In
> pratica conviene `rm -rf .flow/locks/<slug>/` (idempotente) seguito da `mkdir`.

## Aggiornamento heartbeat

L'heartbeat **non** è un daemon periodico: è legato alle transizioni di stato del flow.
A ogni write su `.flow/sources/<slug>/PROGRESS.json` si aggiorna contestualmente `heartbeat.ts`.

Ordine obbligatorio:

```
scrivi PROGRESS.json  →  aggiorna heartbeat.ts (now)  →  transizione considerata completata
```

L'heartbeat dopo il PROGRESS: se il flow crasha fra i due, il PROGRESS è già durevole e
l'heartbeat resta al valore precedente (al più anticipa lo stantio, mai lo posticipa —
fail-safe verso il reclaim, non verso il lock orfano).

Transizioni che aggiornano l'heartbeat: claim iniziale, attivazione di ogni task, ogni
avanzamento di stato del task, release (l'ultimo write può essere omesso perché segue il rilascio).

## Release

A fine source (o ad abbandono):

```
rm -rf .flow/locks/<slug>/   # idempotente: nessun errore se già assente
```

Idempotente per costruzione: una doppia release o una release su lock già rimosso da un
reclaim non è un errore.

## Assenza di source disponibili

Se lo scan termina e nessun claim è riuscito (tutte le source pending sono vive sotto altri
flow, oppure non esistono source pending — es. `planning` già esaurito):

```
log "nessuna source disponibile"  →  exit 0
```

Non è un errore: è la condizione normale quando tutto è già preso o concluso. Il flow lo
riporta nel summary e termina con successo.

## Portabilità bash

- `mkdir` / `rmdir` / `rm -rf`: POSIX, comportamento atomico di `mkdir` garantito su FS locali.
- `stat`: diverge fra BSD (`-f%m`) e GNU (`-c%Y`) → usare il wrapper `mtime()` sopra.
- `date +%s`: POSIX, secondi dall'epoch.
- Nessuna dipendenza esterna oltre coreutils + bash 5.
