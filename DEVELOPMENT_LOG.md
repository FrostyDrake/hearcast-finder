# Udviklingslog

## 2026-08-12

Implementeret:

- Oprettede det forste Flutter-projektskelet.
- Tilfojede en simpel forside, der forklarer app-ideen.
- Tilfojede en lille statisk liste med eksempler paa kandidatsteder.
- Tilfojede en basal widget smoke test.
- Skrev en indledende udviklingsplan.

Problemer:

- Ingen endnu. Projektet undgaar bevidst backend, kort og native scan-arbejde paa dag 1.

Naeste:

- Tilfoj grundlaeggende navigation og begynd at forme de forste rigtige datamodeller.

## 2026-08-12 - Naeste udviklingsskridt

Implementeret:

- Delte den forste single-file prototype op i en lille app shell og feature-mapper.
- Tilfojede bundnavigation til Home, Locations, Map, Scan og Profile.
- Tilfojede de forste simple modeller for brugere, steder, broadcasts og scan-resultater.
- Flyttede eksempelstederne ind i locations-featuren.
- Tilfojede basale tests for navigation og de forste modelregler.

Problemer:

- Ingen backend eller native scan-arbejde endnu; skaermene er stadig bevidst lette.

Naeste:

- Tilfoj et simpelt location details-flow og begynd paa soegning/filtrering.

## 2026-08-13

Implementeret:

- Tilfojede et simpelt location details-flow fra kandidatlisten.
- Tilfojede soegning paa navn, adresse, by, kategori, status og noter.
- Tilfojede kategorifilter til location-listen.
- Udvidede kandidatstederne med korte noter.
- Tilfojede unit tests for filtrering og modelsoegning.
- Udvidede widget-testen, saa den daekker soegning og location details.

Problemer:

- Data er stadig lokal og statisk; persistence venter til Firebase-dagene.

Naeste:

- Forbered Firebase-plan og begynd at tilfoje auth/Firestore-afhaengigheder uden at koble hele appen op endnu.

## 2026-08-14

Implementeret:

- Tilfojede Firebase dependencies: core, auth og Firestore.
- Tilfojede `firebase.json` med Auth- og Firestore-emulatorer.
- Tilfojede en foerste lukket `firestore.rules`, saa databasen ikke er aaben ved et uheld.
- Tilfojede dansk Firebase setup-dokumentation.
- Tilfojede en lille statusmodel, der viser hvilke Firebase-setupdele der er klar.
- Tilfojede test for Firebase setup-status.

Problemer:

- Appen kan ikke forbinde til Firebase endnu, fordi `firebase_options.dart` og Android-konfiguration ikke er genereret.

Naeste:

- Begynd paa login/register-skaerme og koble dem paa Firebase, naar konfigurationen er paa plads.

## 2026-08-17 - Weekend + mandag

Implementeret:

- Tilfojede lokal login/register UI under Profile.
- Tilfojede simpel auth service-struktur, som senere kan udskiftes med Firebase Auth.
- Tilfojede validering for navn, email og password.
- Tilfojede Firestore mapping til AppUser og AuracastLocation.
- Tilfojede foerste UserRepository og LocationRepository.
- Udvidede Firestore rules med tidlige users/locations-regler.
- Tilfojede tests for auth service, validators, model mapping og profile-flow.

Problemer:

- Login er stadig lokal/demo, fordi Firebase-options og Android app-konfiguration ikke er oprettet i dette nye repo endnu.

Naeste:

- Tilfoj rigtig Firebase initialisering og begynd at gemme brugerprofil/location-data via repositories.

## 2026-08-18

Implementeret:

- Tilfojede `google_maps_flutter` som dependency.
- Tilfojede en lille MapService, der kan lave markers og camera position ud fra locations.
- Erstattede map placeholder med en map preview-skaerm.
- Tilfojede statisk map summary, saa appen stadig virker uden Maps API key.
- Tilfojede valgfri interaktiv Google Map-visning til senere Android-konfiguration.
- Tilfojede tests for MapService og map preview navigation.

Problemer:

- Google Maps kan ikke bruges fuldt paa Android foer API key og platform-konfiguration er paa plads.

Naeste:

- Begynd paa native Android scan bridge og scan UI, stadig med tydelige fallback states.

## 2026-08-18 - Senere udviklingsskridt

Implementeret:

- Genererede Android-platformen for Flutter-projektet.
- Satte Android package name til `com.hearcast.hearcast_finder`.
- Satte Android minSdk til 33.
- Tilfojede Bluetooth scan/connect/location permissions.
- Tilfojede native Kotlin MethodChannel `hearcast/auracast_scanner`.
- Implementerede native capability check, permission request, startScan og stopScan foundation.
- Tilfojede Dart NativeScanService og scan-result parsing.
- Erstattede scan placeholder med scan UI.
- Tilfojede tests for native scan parsing og scan-tab smoke flow.

Problemer:

- Real scan kan foerst valideres paa en fysisk Android 13+ telefon.
- Native scan er stadig en foundation; Auracast-specifik parsing skal forbedres med rigtige captures.

Naeste:

- Tilfoj scan evidence submission og begynd paa owner/location workflow.
