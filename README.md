# HearCast Finder

HearCast Finder er et Android-fokuseret Flutter-appkoncept til at finde offentlige steder, der muligvis understotter Auracast eller Bluetooth LE Audio broadcasts.

Repositoryet starter den 12. august 2026 og bliver udviklet trinvist. Den nuvaerende version er stadig en tidlig prototype med simpel navigation og lokale eksempeldata.

## Nuvaerende Omfang

- Minimal Flutter entry point
- Simpelt Material theme
- Grundlaeggende bundnavigation
- Skaerme for Home, Locations, Map, Scan, Owner, Admin og Profile
- Statisk liste med kandidatsteder baseret paa de forste modeller
- Basal smoke test
- Firebase dependencies til naeste backend-milepael
- Firebase emulator config og lukket starterregel til Firestore
- Lokal login/register UI i Profile
- Foerste Firestore-klare repositories for users og locations
- Google Maps dependency og en foerste map preview baseret paa lokale locations
- Android platform folder med native Bluetooth MethodChannel foundation
- Scan UI med capability check, permission request og start/stop handling
- Lokal scan evidence submission til pending verification requests
- Foerste owner dashboard til lokale location drafts
- Lokal admin review af pending verification requests
- Lokale favoritter, anmeldelser og rapporter via location details
- Rigtig Firebase login-forbindelse
- Rigtig Firestore lagring i appen
- Google Maps Android API key og fuld native map-konfiguration
- Verificeret fysisk Android Bluetooth scan via telefon
