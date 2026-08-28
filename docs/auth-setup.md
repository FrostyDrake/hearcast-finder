# Auth Setup

Dag 11 kobler appen til et rigtigt Firebase-projekt og udskifter det lokale fake login med rigtig Firebase Authentication.

## Tilfojet Nu

- `flutterfire configure` koert mod det eksisterende Firebase-projekt `hearcast-85115` (Android-appen og Firestore-databasen fandtes allerede fra foer).
- `lib/firebase_options.dart` og `android/app/google-services.json` genereret.
- `Firebase.initializeApp()` tilfojet i `main.dart`.
- `flutter_riverpod` tilfojet til state management.
- `AuthService` skrevet om fra lokalt fake login til rigtig `firebase_auth` (sign in, register, sign out, med brugervenlige fejlbeskeder for svage kodeord, forkert login og manglende netvaerk).
- `AuthGate` tilfojet (Riverpod StreamProvider paa `authStateChanges()`), som nu laaser hele appen bag login.
- Login/register flyttet ud af Profile-fanen og ind i sit eget auth-flow.
- Foerste sign-in opretter automatisk `users/{uid}`-dokumentet i Firestore med default-rolle `user`.
- INTERNET-permission tilfojet til hoved-AndroidManifest. Den laa foer kun i debug-manifestet, hvilket ville have blokeret en rigtig release-build fra nogensinde at naa Firebase.

## Skal Testes Paa Telefon

1. Installer appen paa en rigtig Android 13+ telefon (eller emulator med Play Services).
2. Registrer en ny konto.
3. Log ud og log ind igen med samme konto.
4. Bekraeft at Admin/Owner/Scan-fanerne slet ikke kan tilgaas foer login.

## Kendte Begraensninger

- Kort, lokationsliste og admin/owner-dashboards bruger stadig lokale testdata, ikke rigtige Firestore-queries.
- Der findes endnu ingen Cloud Functions, saa admin-CRUD er stadig kun lokalt.
- `users/{uid}` faar ikke et `createdAt`-felt endnu, selvom det er en del af den planlagte datamodel.

## Naeste Skridt

Rigtig login er nu paa plads. Naeste reelle skridt er at koble kort, lokationsliste og admin/owner-flows til rigtige Firestore-queries, og at faa Cloud Functions op at staa til admin-CRUD.
