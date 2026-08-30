# Verification Requests, Location og Security Rules Setup

Denne omgang (25. august 2026) lukker scan-til-verification-loopen, tilfojer brugerposition paa kortet, og faar et rigtigt security rules-testsetup op at koere.

## Tilfojet Nu

- `VerificationRequest` har et `userId`-felt; `VerificationRepository` skriver rigtige dokumenter til `verificationRequests` i Firestore.
- Scan-fanens lokationsvaelger bruger rigtige verificerede Firestore-lokationer, ikke `sampleLocations`.
- Admin-fanen har en "Verification requests"-sektion: viser ventende scan-evidens live og skriver Approve/Reject direkte til Firestore (tilladt af `firestore.rules` for admin-rollen, saa ingen Cloud Function er noedvendig her).
- `geolocator` tilfojet. Brugerens position paa kortet: tilladelse spoerges foerst naar det interaktive kort slaas til; `myLocationEnabled`/`myLocationButtonEnabled` afspejler resultatet. Kortet virker uden tilladelse.
- Et rigtigt security rules-testsetup i `firestore-tests/` (`@firebase/rules-unit-testing`, koert mod den lokale Firestore-emulator).
- En foerste test-admin-konto oprettet (`admin@hearcast.test`).

## Skal Testes Paa Telefon

1. Log ind som admin-kontoen.
2. Kør en scan, tilfoej et demo-resultat eller et rigtigt BLE-fund, og indsend evidens mod en verificeret lokation.
3. Bekraeft at requesten dukker op i Admin-fanens "Verification requests", og at Approve/Reject rent faktisk aendrer status i Firestore.
4. Slaa det interaktive kort til og bekraeft at "min position"-knappen og den blaa prik virker naar lokationstilladelse er givet.

## Kendte Begraensninger

- Real-scan mod en fysisk Auracast/BLE-sender er stadig ikke testet.
- IFK08's 1.000-lokations skalatest og en opdateret kravspecifikation/acceptancetabel (AC01-10) er bevidst fravalgt for nu; 25 rigtige lokationer daekker allerede AC02's krav om mindst 20.
- Firestore rules haandhaever stadig ikke selv at almindelige brugere kun kan laese verificerede lokationer.

## Naeste Skridt

Test hele appen paa en fysisk Android 13+ telefon: login, kort, scan mod en rigtig sender, og admin-godkendelse. Overvej IFK08-skalatest og kravspec-opdatering, hvis der er tid tilbage foer 01.09.
