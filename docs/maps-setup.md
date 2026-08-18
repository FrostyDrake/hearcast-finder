# Google Maps Setup

Dag 7 tilfojer kun fundamentet for Google Maps. Appen har nu en map preview, men rigtig Android-visning kraever stadig API key setup.

## Tilfojet Nu

- `google_maps_flutter` dependency.
- `MapService` til markers og camera position.
- Map preview med lokale kandidatsteder.
- Valgfri interaktiv Google Map-visning i UI.

## Mangler Stadig

- Opret eller vaelg Google Cloud projekt.
- Aktiver Maps SDK for Android.
- Opret Android API key.
- Tilfoj Android package name og SHA-1 restriction.
- Tilfoj Android manifest/meta-data, naar platform setup er klar.

## Noter

Indtil API key er klar, bruger appen den statiske map summary som fallback. Det goer det muligt at udvikle location-flowet uden at blokere paa Google Cloud-konfiguration.
