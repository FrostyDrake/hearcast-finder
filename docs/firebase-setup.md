# Firebase Setup

Dette dokument beskriver den tidlige Firebase-plan for HearCast Finder. Dag 4 handler kun om fundamentet, ikke fuld login eller Firestore-integration.

## Tilfojet Nu

- Firebase dependencies i Flutter:
  - `firebase_core`
  - `firebase_auth`
  - `cloud_firestore`
- `firebase.json` med Auth- og Firestore-emulatorer.
- `firestore.rules` med lukket standardregel.
- Foerste repositories for `users` og `locations`.

## Mangler Stadig

- Opret Firebase-projekt.
- Registrer Android-app i Firebase.
- Koer FlutterFire CLI og generer `firebase_options.dart`.
- Tilfoj Android-konfiguration, naar Android-platformen bliver genereret.
- Aktiver Email/Password login i Firebase Console.
- Test Firestore rules i emulatoren, naar dataflows er implementeret.

## Lokalt Senere

```powershell
firebase emulators:start
```

Naar Firebase-projektet er oprettet:

```powershell
flutterfire configure
```

## Designbeslutning

Appen skal foerst bruge Firebase til:

1. Login og brugerroller.
2. Gemte kandidatsteder.
3. Scan-evidens og admin-godkendelse.

Native Bluetooth scan og Google Maps kommer i senere udviklingsdage.
