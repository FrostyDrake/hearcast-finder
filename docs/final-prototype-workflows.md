# Final Prototype Workflows

Dag 10 samler de sidste local-only workflows, saa appen kan demonstrere hele MVP-loopen uden rigtig backend.

## Admin Review

- Admin-fanen viser en lokal pending verification request.
- Admin kan approve eller reject requesten.
- Status og pending count opdateres med det samme i UI.
- Firestore rules har nu en foundation for at lade admin-rollen opdatere verification status senere.

## Location Feedback

- Location details har lokal favorite-toggle.
- Brugeren kan tilfoje en simpel rating og review note.
- Brugeren kan koere en lokal report issue handling.
- Modellerne kan serialiseres til Firestore senere.

## Stadig Production Work

- Firebase Auth skal kobles paa rigtige brugere og roller.
- Firestore writes skal implementeres i repositories.
- Rules skal emulator-testes med rigtige auth claims.
- Native scan skal testes paa fysisk Android 13+ telefon med rigtige BLE captures.
