# Decomposition — da epic a feature sequenziali

La dimensione che epic-planner aggiunge rispetto a feature/project-planner: **spezzare un'implementazione grande in feature coese, ordinate, con confini netti.** È il passo che precede la materializzazione dei bundle e va **confermato dall'utente** prima di scrivere.

## Cos'è una "feature" dentro un epic

Una feature figlia è un'unità che:

- ha un **outcome osservabile** e una **DoD binaria** propria (non "metà di una cosa");
- sta in **1–8 task atomici** (regola di `../../feature-planner/feature-artifacts.md`); se >10 → non è una feature, ri-decomponi;
- è **deployabile/verificabile** il più possibile in isolamento (anche se dietro feature flag);
- tocca un **insieme coerente** di moduli (evita feature che spalmano mezzo codebase).

Se due "feature" condividono lo stesso file core e la stessa DoD, probabilmente sono **una** feature. Se una "feature" ha tre DoD scollegate, sono **tre** feature.

## Regole di decomposizione

1. **Sequenza per dipendenza tecnica reale, non per comodità narrativa.** L'ordine nasce da cosa abilita cosa: fondamenta condivise (schema, VO, contratti, infrastruttura) prima dei consumatori.
2. **Estrai prima il tronco comune.** Se più feature consumano lo stesso nuovo VO/endpoint/schema, quella base è la **feature 0** (categoria 🏗️/💻). Va nel `technical-context.md` condiviso e diventa dipendenza inter-feature delle altre.
3. **Minimizza le dipendenze inter-feature.** Più sono lineari (catena A→B→C) più l'epic è sano. Un grafo fitto = decomposizione sbagliata o scope da rivedere.
4. **Marca i fronti paralleli.** Feature senza dipendenze reciproche → eseguibili in parallelo: dichiaralo in `roadmap.md` (`whats-next` lo userà).
5. **Niente feature "spike-only" travestite.** Un'incognita tecnica è uno **spike dentro** la prima feature che la richiede (task 🔬), non una feature a sé.
6. **Confini espliciti.** Per ogni feature: cosa è in scope, cosa è fuori (rimandato a quale feature successiva). Gli "out of scope" di una feature spesso sono l'"in scope" della prossima.

## Dipendenze: due livelli

- **Inter-feature (feature → feature)**: vivono in `roadmap.md` (`Dipende da feature: <epic>-<feat>`). Sono la spina dorsale della sequenza. `whats-next` (epic-aware) le legge per ordinare il consiglio.
- **Intra-feature (task → task)**: vivono nel `Dipende da` del `tasks-active.md` della feature, come sempre. Risolte normalmente dai downstream.

> **Dipendenze task cross-source** (`Dipende da: <altra-feature>-NNN` dentro un tasks-file) sono **sconsigliate**: il calcolo "sbloccato" dei downstream è per-source e NON le risolve (vedi `epic-artifacts.md` § "Limiti onesti"). Esprimi la dipendenza a livello **feature** in `roadmap.md`, non a livello task tra source diverse.

## Anti-pattern

- ❌ Feature numerate "Fase 1 / Fase 2" senza outcome proprio → sono fasi, non feature. Le fasi sono di `project-planner`.
- ❌ Una feature "core" gigante da 20 task + tante feature satellite minuscole → la core è un epic dentro l'epic: ri-decomponi.
- ❌ Ordine deciso "perché mi va di iniziare da lì" senza dipendenza tecnica → la sequenza perde valore.
- ❌ Decomporre senza il tronco comune → ogni feature reinventa gli stessi VO/contratti → divergenza (vedi propagazione seed).

## Output della decomposizione (da confermare prima di materializzare)

Presenta all'utente, per conferma:

```
Epic: <epic>  —  [outcome d'insieme]
Feature (ordine):
  1. <epic>-foundation   🏗️  [goal]              dep: —            effort: X-Yh   ~N task
  2. <epic>-api          💻  [goal]              dep: foundation   effort: X-Yh   ~N task
  3. <epic>-ui           💻  [goal]              dep: api          effort: X-Yh   ~N task    ∥ con (4)
  4. <epic>-reporting    💻  [goal]              dep: api          effort: X-Yh   ~N task    ∥ con (3)
DoD epic: [criterio binario d'insieme]
Fronti paralleli: {3, 4} dopo (2)
```

Solo dopo l'ok dell'utente generi i bundle e `roadmap.md`.

## Quando l'epic è in realtà altro

- **Una sola feature emerge** dalla decomposizione → non è un epic: usa `feature-planner`.
- **Servono milestone, pitch, market, roadmap di prodotto** → è un progetto: usa `project-planner`.
- Dillo all'utente e fermati: non forzare la forma epic.
