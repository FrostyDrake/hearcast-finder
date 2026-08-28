# Admin CRUD Setup

Dag 12 kobler kort, lokationsliste og admin/owner-flows til rigtig Firestore-data, og tilfojer Cloud Functions til admin-CRUD.

## Tilfojet Nu

- `AuracastLocation` har nu et `ownerId`-felt.
- `LocationRepository` har scoped queries: `watchVerifiedLocations`, `watchCandidateLocations`, `watchLocationsByOwner`, `newLocationId`.
- Map- og Locations-fanen viser rigtige Firestore-data (kun `status: verified`), ikke laengere `sampleLocations`.
- Owner-fanen skriver et rigtigt `status: candidate`-dokument til Firestore ved indsendelse, med `ownerId` sat fra den loggede ind bruger, og viser brugerens egne indsendelser live.
- Et `functions/`-projekt (Node 22) med tre callable Cloud Functions: `createLocation`, `updateLocation`, `deleteLocation`. Alle kraever `role: admin` i `users/{uid}` og bruger Admin SDK'en, som er den eneste maade at skrive til `locations` udover create, fordi `firestore.rules` blokerer `update`/`delete` direkte fra klienten.
- Functions deployeret til `hearcast-85115` (us-central1, Node 22).
- `AdminLocationService` i Flutter wrapper de tre callables med brugervenlige fejlbeskeder.
- Admin-fanen viser candidate-locations fra Firestore med Approve/Reject, plus en formular til direkte at oprette en verificeret lokation.
- 25 testlokationer seedet paa tvaers af Kobenhavn, Aarhus, Odense og Aalborg, alle otte kategorier repraesenteret.
- `fake_cloud_firestore` tilfojet som devDependency, saa Owner-draft-testen koerer et rigtigt write/read-flow uden netvaerk.

## Skal Testes Paa Telefon

1. Saet en testbruger til `role: admin` i Firestore Console (`users/{uid}` -> `role: "admin"`).
2. Log ind som den admin-bruger og aabn Admin-fanen.
3. Indsend en lokation som en anden (almindelig) bruger via Owner-fanen.
4. Bekraeft at den dukker op i admin's "Pending locations", og at Approve/Reject rent faktisk aendrer status/sletter dokumentet i Firestore.
5. Test ogsaa "Add a verified location"-formularen direkte fra Admin-fanen.

## Kendte Begraensninger

- Ingen admin-bruger findes endnu i Firestore; Admin-flowet er kun testet strukturelt, ikke fuldt end-to-end paa en rigtig konto.
- Verification requests fra scan-fanen er stadig kun lokale; Firestore-persistence for dem kommer i naeste skridt.
- Cloud Functions er ikke emulator-testet endnu, kun deployet og verificeret manuelt.
- Firestore rules haandhaever ikke selv at almindelige brugere kun kan laese verificerede lokationer; det er i dag alene en app-side query-begraensning.

## Naeste Skridt

Saet foerste admin-bruger og test hele godkend/afvis-flowet paa fysisk telefon. Derefter: gem scan-verification requests rigtigt i Firestore, tilfoj brugerposition paa kortet, og gennemgaa tom-/fejltilstande paa tvaers af appen.
