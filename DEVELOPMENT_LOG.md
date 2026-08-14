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
