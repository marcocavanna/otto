# 02 — Abstract tecnico (FIXTURE)

> Vincoli strategici del progetto fittizio Acme Notes. Statico, versionato.

## Stack

- Backend: .NET 8 / C# 12.
- Frontend: React 18 + TypeScript strict.
- Persistenza: SQL (EF Core).

## Pattern strategici

- Layering domain / application / infrastructure sul backend.
- DTO ai boundary; entità di dominio mai esposte direttamente.
- Validazione vicino al boundary.

## Esclusioni tecniche

- NO MediatR (handler espliciti).
- NO AutoMapper (mapping manuale).
- NO realtime / SignalR.

## Nota fixture

Le esclusioni qui sono volutamente esplicite: servono a verificare che il loop
rispetti i vincoli strategici. Un golden-task che introducesse MediatR dovrebbe
risultare in conflitto strategico (categoria 1.5 di decision-classification).
