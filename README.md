# HearCast Finder

HearCast Finder er en Android-app udviklet i Flutter, som gør det nemmere at finde offentlige steder med **Auracast / Bluetooth LE Audio**.

Appen kombinerer et kort over kendte Auracast-lokationer med en rigtig Bluetooth-scanning på telefonen, så brugeren både kan finde steder på forhånd og kontrollere, om der faktisk bliver sendt et Auracast-signal på stedet.

Projektet er udviklet som svendeprøve til **Datatekniker med speciale i programmering** på TEC Ballerup.

## Funktioner

- Login og oprettelse af bruger
- Liste over verificerede Auracast-lokationer
- Søgning og filtrering efter kategori
- Google Maps med lokationer og brugerens position
- Detaljeside for hver lokation
- Reel Bluetooth LE-scanning på Android
- Filtrering af Auracast / LE Audio broadcasts
- Visning af signalstyrke som RSSI
- Indsendelse af scanresultater som dokumentation
- Indsendelse af nye lokationer
- Admin-godkendelse af lokationer og scanresultater
- Broadcast-profiler for kendte udsendelser
- Lyst og mørkt tema
- Fokus på tilgængelighed og WCAG-kontrast

## Brugerroller

| Rolle | Muligheder |
|---|---|
| `user` | Se lokationer, bruge kortet, scanne og indsende dokumentation |
| `owner` | Indsende nye lokationer og følge deres status |
| `admin` | Godkende/afvise indsendelser og administrere lokationer |

## Teknologier

- Flutter / Dart
- Kotlin
- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Functions
- Riverpod
- Google Maps
- Geolocator
- Android Bluetooth API

## Installation

### Krav

- Flutter
- Android SDK
- Android 13 eller nyere
- Firebase-projekt
- Google Maps API-nøgle

### Klon projektet

```bash
git clone https://github.com/FrostyDrake/hearcast-finder.git
cd hearcast-finder
flutter pub get
```

### Firebase

Konfigurer projektet med FlutterFire:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

### Kør appen

```bash
flutter run
```

Bluetooth-scanning bør testes på en fysisk Android-enhed.

## Test

Projektet indeholder i alt **49 automatiserede tests**:

- 38 Flutter-tests
- 11 tests af Firestore-sikkerhedsregler

Kør Flutter-tests med:

```bash
flutter test
```

## Begrænsninger

Appen:

- afspiller ikke selve Auracast-lyden
- beregner ikke præcis afstand ud fra RSSI
- scanner ikke kontinuerligt i baggrunden
- understøtter ikke iOS


## Projekt

**Udvikler:** Andrei Flavius Brazda  
**Uddannelse:** Datatekniker med speciale i programmering  
**Skole:** Technical Education Copenhagen, Ballerup  
**Projektperiode:** 03.08.2026 – 07.09.2026

## Repository

https://github.com/FrostyDrake/hearcast-finder
