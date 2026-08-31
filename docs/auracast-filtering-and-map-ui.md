# Auracast Filtering og Kort-UI

Denne omgang (31. august 2026) filtrerer scanningen til rigtige Auracast-broadcasts og gør kortet til en fuldskaerms, altid-aktiv oplevelse.

## Tilfojet Nu

- Native scanning (`MainActivity.kt`) filtrerer nu resultater: kun advertisements der annoncerer Basic Audio, Broadcast Audio eller Public Broadcast Announcement-servicen (Bluetooth SIG's officielle Auracast/LE Audio broadcast-UUID'er) vises. Almindelige BLE-enheder i naerheden (telefoner, ure, hovedtelefoner) bliver ikke laengere vist som scanresultater.
- Scanneren forsoeger at laese `Broadcast_Name` direkte fra advertisement-bytes, saa et rigtigt broadcast-navn vises fremfor enhedens Bluetooth-navn, hvor det er tilgaengeligt.
- Kort-fanen er skrevet om fra bunden: `GoogleMap` fylder nu hele skaermen og er altid aktiv (den gamle "Show interactive Google Map"-switch og den statiske oversigt er fjernet). Kortet laa foer nede i en scrollbar liste, hvilket gav gestus-konflikt mellem listens scroll og kortets pan/zoom — det er roden til at kortet foelte sig "meget daarligt" at bruge.
- Tryk paa en markoers infovindue aabner nu lokationsdetaljer direkte.
- En lille "N verified locations"-badge og evt. tilladelses-/tomtilstandsbeskeder vises som flydende kort ovenpaa kortet i stedet for i en liste under.

## Skal Testes Paa Telefon

1. Aabn Kort-fanen og bekraeft at kortet er fuldskaerm og reagerer korrekt paa pan/zoom uden at "kaempe" med anden scroll.
2. Tryk paa en markoer, og derefter paa dens infovindue, for at bekraefte navigation til lokationsdetaljer.
3. Koer en scanning i naerheden af en rigtig Auracast-sender (eller en telefon der broadcaster via LE Audio) og bekraeft at kun broadcast-relaterede resultater vises, ikke almindelige BLE-enheder.

## Kendte Begraensninger

- UUID-filtreringen er baseret paa Bluetooth SIG's dokumenterede assigned numbers for LE Audio broadcast-annonceringer, men er endnu ikke bekraeftet mod en rigtig fysisk Auracast-sender.
- Hvis en sender kun bruger en anden/ikke-standard annonceringsmetode, kan den blive filtreret fra ved en fejl — dette boer valideres saa snart en rigtig sender er tilgaengelig.
