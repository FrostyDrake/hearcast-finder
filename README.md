# HearCast Finder

HearCast Finder er et Android-fokuseret Flutter-appkoncept til at finde offentlige steder, der muligvis understotter Auracast eller Bluetooth LE Audio broadcasts.

Repositoryet starter den 12. august 2026 og bliver udviklet trinvist. Den nuvaerende version er stadig en tidlig prototype med simpel navigation og lokale eksempeldata.

## Nuvaerende Omfang

- Minimal Flutter entry point
- Simpelt Material theme
- Grundlaeggende bundnavigation
- Skaerme for Home, Locations, Map, Scan og Profile
- Statisk liste med kandidatsteder baseret paa de forste modeller
- Basal smoke test

## Ikke Implementeret Endnu

- Firebase login
- Firestore lagring
- Google Maps
- Native Android Bluetooth scanning
- Rapporter, anmeldelser, favoritter, ejerfunktioner eller adminfunktioner

## Udvikling

```powershell
C:\dev\flutter\bin\flutter.bat pub get
C:\dev\flutter\bin\flutter.bat test
```
