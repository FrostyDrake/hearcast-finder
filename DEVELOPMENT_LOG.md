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

## 2026-08-22

Implementeret:

- Tilfojede VerificationRequest model og lokal VerificationRepository.
- Tilfojede demo scan result til Scan-skaermen, saa submission-flowet kan testes uden fysisk BLE capture.
- Tilfojede lokal scan evidence submission med valg af kandidatsted.
- Tilfojede liste over indsendt evidence med pending status.
- Tilfojede foerste owner dashboard med location draft-form.
- Udvidede Firestore rules med tidlig `verificationRequests` collection.
- Tilfojede tests for scan evidence submission, owner draft og verification model.

Problemer:

- Scan evidence og owner locations er stadig lokale i UI; rigtig persistence kommer med Firestore integration.

Naeste:

- Tilfoj admin review, rapporter/anmeldelser/favoritter og afsluttende test/docs cleanup.

## 2026-08-23

Implementeret:

- Tilfojede lokal admin review queue med approve/reject handling for verification requests.
- Tilfojede lokale favorites, reviews og reports paa location details.
- Tilfojede LocationFeedback modeller og lokal repository.
- Udvidede Firestore rules med foundation for admin updates, reviews, reports og favorites.
- Opdaterede smoke/model tests for admin review og location feedback.
- Opdaterede roadmap og docs til den sidste prototype-dag.

Problemer:

- Admin, feedback og favorites er stadig local-only UI, indtil rigtig Firestore persistence og Firebase Auth er koblet paa.
- Security rules er en foundation og skal emulator-testes med rigtige auth claims/roller.

Naeste:

- Commit den afsluttende prototype, test paa telefon, og planlaeg rigtig backend-integration som separat production hardening.

## 2026-08-25

Implementeret:

- Koerte FlutterFire CLI mod det eksisterende Firebase-projekt `hearcast-85115` og genererede `firebase_options.dart` + `google-services.json`.
- Tilfojede `Firebase.initializeApp()` i `main.dart`.
- Tilfojede `flutter_riverpod` til state management.
- Skrev `AuthService` om fra lokal fake-login til rigtig Firebase Authentication (sign in, register, sign out) med brugervenlige fejlbeskeder.
- Tilfojede `AuthGate`, der laaser hele appen bag login, saa ingen faner kan tilgaas foer man er logget ind.
- Flyttede login/register ud af Profile-fanen og ind i sit eget auth-flow.
- Foerste sign-in opretter nu automatisk `users/{uid}`-dokumentet i Firestore med default-rolle `user`.
- Rettede en fejl hvor INTERNET-permission kun laa i debug-manifestet, hvilket ville have blokeret release-builds fra at naa Firebase.
- Opdaterede tests til den nye auth-opsaetning og fjernede den nu forældede Firebase-setup-status test. Alle tests og en debug-build gaar igennem uden fejl.

Problemer:

- Kort, lokationsliste og admin/owner-dashboards bruger stadig lokale testdata; rigtig Firestore-integration mangler stadig.
- Der findes endnu ingen Cloud Functions, saa admin-CRUD er stadig kun lokalt.
- Login er endnu ikke testet paa en fysisk telefon.

Naeste:

- Test login paa fysisk Android 13+ telefon (register, log ud, log ind, log ud igen).
- Koble kort, lokationsliste og admin/owner-flows til rigtige Firestore-queries.
- Byg Cloud Functions til admin-CRUD (create/update/delete med rollekontrol).

## 2026-08-25 - Firestore-integration og Cloud Functions

Implementeret:

- Tilfojede `ownerId` til `AuracastLocation` og nye scoped Firestore-queries i `LocationRepository` (`watchVerifiedLocations`, `watchCandidateLocations`, `watchLocationsByOwner`, `newLocationId`).
- Erstattede `sampleLocations` med rigtige Firestore-streams i Map- og Locations-fanen (kun `status: verified` vises for almindelige brugere).
- Koblede Owner-fanen til rigtig Firestore: et indsendt draft skrives nu direkte til `locations` med `status: candidate` og `ownerId`, og "Submitted locations" viser brugerens egne indsendelser live.
- Byggede et `functions/`-projekt (Node 22, firebase-admin + firebase-functions v2) med tre callable Cloud Functions: `createLocation`, `updateLocation`, `deleteLocation`. Alle tre tjekker `users/{uid}.role == 'admin'` foer de skriver, og bruger Admin SDK'en til at omgaa `firestore.rules`' `allow update, delete: if false` paa locations-collectionen.
- Deployede de tre functions til `hearcast-85115` (region us-central1, Node 22).
- Tilfojede `cloud_functions`-pakken og en `AdminLocationService`, der wrapper de tre callables med brugervenlige fejlbeskeder.
- Koblede Admin-fanen til rigtig data: viser candidate-locations fra Firestore, Approve kalder `updateLocation` (status -> verified), Reject kalder `deleteLocation`, og der er nu ogsaa en "Add a verified location"-formular, der kalder `createLocation` direkte.
- Seedede 25 rigtige testlokationer (fordelt over Kobenhavn, Aarhus, Odense og Aalborg, alle otte kategorier repraesenteret) via en midlertidig, hemmelighedsbeskyttet devTools-funktion, som blev fjernet igen straks efter brug.
- Tilfojede `fake_cloud_firestore` som devDependency, saa widget-tests kan kore et rigtigt Firestore-lignende write/read-flow (Owner-draft-testen) uden at ramme netvaerket.
- Opdaterede tests til den nye datamodel; alle tests, `flutter analyze` og en debug-build gaar igennem uden fejl.

Problemer:

- Der findes stadig ingen admin-bruger i Firestore, saa Admin-fanen kan ikke godkende noget for rigtigt endnu foer en konto faar `role: admin` (skal saettes manuelt i Firebase Console eller via en senere promote-funktion).
- Scanresultater og verification requests er stadig kun lokale i UI'en; det kommer med naeste skridt.
- Cloud Functions er kun testet via `flutter analyze`/`flutter test` og manuel deploy-verifikation, ikke med en fuld emulator-baseret integrationstest endnu.
- Firestore-rules begraenser ikke laesning til kun verificerede lokationer for almindelige brugere (det styres i stedet af app-forespoergslen); en admin-rolle-tjek paa laesning kunne styrke dette senere.

Naeste:

- Saet en foerste bruger til `role: admin` og gennemfoer en fuld godkend/afvis-test paa fysisk telefon.
- Gem verification requests fra scan-fanen rigtigt i Firestore, i stedet for kun lokalt.
- Tilfoj brugerens position paa kortet, og gennemgaa tom-/fejltilstande paa tvaers af appen.

## 2026-08-25 - Google Maps API key

Implementeret:

- Tilfojede `android/app/src/main/res/values/google_maps_api.xml` og `com.google.android.geo.API_KEY` meta-data i AndroidManifest.xml, som ikke fandtes i dette repo foer.
- Genbrugte den eksisterende Firebase Android-noegle (samme projekt, `hearcast-85115`) i stedet for at oprette en separat Maps-noegle.

Problemer:

- Kortet virker foerst, naar "Maps SDK for Android" er aktiveret for `hearcast-85115` i Google Cloud Console, hvilket kraever et manuelt klik der (ikke noget der kan automatiseres via Firebase CLI).

Naeste:

- Bekraeft at det interaktive kort rent faktisk virker paa telefonen, naar API'et er aktiveret.

## 2026-08-25 - Foerste admin-konto

Implementeret:

- Oprettede en test-admin-konto (`admin@hearcast.test`) via en midlertidig, hemmelighedsbeskyttet Cloud Function, som satte `role: admin` i Firestore. Funktionen blev fjernet igen straks efter brug.

Naeste:

- Log ind som admin-kontoen og test hele godkend/afvis-flowet for lokationer og verification requests paa fysisk telefon.

## 2026-08-25 - Verification requests, brugerposition og security rules-test

Implementeret:

- `VerificationRequest` faar nu et `userId`-felt, og `VerificationRepository` skriver rigtige dokumenter til `verificationRequests` i Firestore i stedet for kun at bygge et lokalt objekt.
- Scan-fanens lokationsvaelger bruger nu ogsaa rigtige verificerede Firestore-lokationer i stedet for `sampleLocations`.
- Admin-fanen har nu en "Verification requests"-sektion, der viser ventende scan-evidens live fra Firestore med Approve/Reject. Det skriver direkte til Firestore (ikke via Cloud Function), fordi `firestore.rules` allerede giver admin-rollen lov til at opdatere status der.
- Tilfojede `geolocator` og kobler brugerens position til kortet: tilladelse spørges foerst naar det interaktive kort slaas til, og `myLocationEnabled`/`myLocationButtonEnabled` afspejler om tilladelsen blev givet. Kortet virker stadig fint uden.
- Rettede forældet forside-tekst, der stadig sagde at "kort, konti og scanning kommer senere" — det er ikke laengere sandt.
- Tilfojede et rigtigt security rules-testsetup i `firestore-tests/` med `@firebase/rules-unit-testing`, koert mod den lokale Firestore-emulator: bekraefter at en udlogget bruger ikke kan laese lokationer, at en normal bruger ikke kan oprette en lokation som allerede verificeret, at INGEN klient (heller ikke en admin) kan opdatere eller slette en lokation direkte, at kun ens egen brugerprofil kan oprettes med rolle 'user', og at kun en admin kan godkende en verification request eller laese rapporter. Alle 9 tests bestaar.
- Opdaterede tests til de nye providers; alle 31 Flutter-tests, `flutter analyze` og et release-build gaar igennem.

Problemer:

- Real-scan mod en fysisk Auracast/BLE-sender er stadig ikke testet.
- 1.000-lokations skalatest (IFK08) og en opdateret kravspecifikation/acceptancetabel (AC01-10) er bevidst fravalgt for nu — 25 rigtige lokationer daekker allerede AC02's krav om mindst 20.

Naeste:

- Test hele appen paa en fysisk Android 13+ telefon: login, kort, scan mod en rigtig sender, og admin-godkendelse.
- Overvej IFK08-skalatest og kravspec-opdatering, hvis der er tid tilbage foer 01.09.

## 2026-08-31 - Auracast-filtrering og kort-UI

Implementeret:

- Native scanning (`MainActivity.kt`) filtrerer nu resultater efter Bluetooth SIG's officielle service-UUID'er for LE Audio broadcast-annonceringer (Basic Audio, Broadcast Audio og Public Broadcast Announcement), saa almindelige BLE-enheder i naerheden ikke laengere vises som scanresultater.
- Scanneren parser advertisement-bytes for `Broadcast_Name` (AD type 0x30) og bruger det som visningsnavn, hvis det findes, i stedet for kun enhedens Bluetooth-navn.
- Kort-fanen er skrevet helt om: `GoogleMap` fylder nu hele skaermen og er altid aktiv. Det gamle design havde kortet i en fast-hoejde boks nede i en scrollbar liste, hvilket gav gestus-konflikt mellem listens scroll og kortets pan/zoom — det var aarsagen til at kortet var svaert at bruge.
- Markoerers infovindue kan nu trykkes for at aabne lokationsdetaljer direkte.
- Opdaterede `MapService.markersForLocations` til at tage en valgfri `onInfoWindowTap`-callback (bagudkompatibel — eksisterende kald uden callback virker stadig).
- Opdaterede tests til den nye kort-UI; alle 31 Flutter-tests og `flutter analyze` gaar igennem.

Problemer:

- UUID-filtreringen for Auracast er baseret paa Bluetooth SIG's dokumenterede assigned numbers, men er endnu ikke bekraeftet mod en rigtig fysisk sender.

Naeste:

- Test scanningen mod en rigtig Auracast/BLE-sender og bekraeft at filtreringen rent faktisk fanger den.
- Test det nye kort-UI paa telefonen: pan/zoom, markoer-tryk, infovindue-tryk til detaljer.
