# Högersits: första kommandosteget

Implementerat för test: NAV-huvudström (inte batteri/generatorer), RNAV,
VOR/ILS-inställningar, kurs, heading, ADF, DME, QNH, FR31:s kontrollpanel,
FR33:s frekvensvred och transponder inklusive IDENT.

Vänstersits behåller systemens tillstånd. Högersits skickar begränsade
kommandon; resultatet kommer tillbaka i ordinarie panelsynk. Inga
spekulativa systemändringar utförs i högersits. Transporten begränsar
enheter/kommandoområden, och vänstersits verifierar varje exakt kommando
innan något utförs. Motorstart, bränslepumpar, cutoff/idle-brytare,
beväpning och huvudström ingår inte. EFM har också spärr för högersitsens
direkta motorstartkommandon medan Crew är aktivt.

IDENT och RNAV CHK släpps vid avbrott. Köer töms vid en ny anslutningsgeneration;
gamla knapptryckningar spelas inte upp efter återanslutning. Samtidiga
inmatningar från båda sitter behandlas i vänstersitsens exekveringsordning.

Radioinställningar delas, medan PTT/ljudvolym är lokala. Moddens befintliga
FR31-begränsning kvarstår: logisk VHF/FM kan användas via SRS; native
avUHF_ARC_164 ligger kvar på UHF/AM. FR33:s native frekvens uppdateras.

## Flygning med J – återstår

Användaren har valt DCS inbyggda J-överlämning. Ingen separat Crew-överlämning
eller transport av flygaxlar har införts. Denna version är INTE klar för
kontrollöverlämning under flygning.

Koden kontrollerar IsFmMaster() i ed_fm_simulate och returnerar direkt för
den station som inte äger flygmodellen. Därmed stannar även den stationens
DCMS-, mätar- och radio-EFM-uppdatering. Crew har samtidigt fast vänstersits
som statuskälla och stoppar högersitsens lokala delade Lua-system.

Nödvändigt nästa integrationsarbete:

1. Skilj DCS flygmodellägare från gemensam systemägare. En J-överlämning får
   inte byta eller förlora NAV/RNAV-programmering, radioinmatning och elstatus.
2. Överför uttryckligt, validerat dynamiskt EFM-tillstånd till den nya ägaren:
   motorernas privata N2-tillstånd, bränsleflöde/tryck, pump- och idle-status,
   bränslemängd samt relevanta trim-, broms- och aktuatorlägen. Enbart RPM som
   instrumentvärde räcker inte för att fortsätta motorsimuleringen.
3. Växla publicering av flyg- och motorvärden när DCS ändrar ägare, utan att
   den fasta vänstersitssynken skriver över den aktiva flygmodellens utdata.
4. Verifiera J åt båda håll med startade motorer, olika gaslägen, trim,
   anslutningsavbrott och återanslutning. DCS måste fortsatt bestämma
   kontrollinnehavet; nätverkspaket får inte själva ge flygkontroll.

## Test av nu levererad avionik

Båda uppdaterar Crew och DCS-stödet med DCS stängt. Starta med vänstersits
som flyger. Prova varje ovan nämnt system från högersits och kontrollera
värdena hos vänstersits. Kontrollera även vänstersitsens egna ändringar.
Tryck/släpp IDENT och RNAV CHK och testa avbrott under nedtryckt knapp.
Motorstart från högersits ska inte påverka vänstersitsens motorer.

Automatiserade tester använder riktiga Lua-enheter för NAV, FR31, FR33 och
transponder med simulerade DCS-API:er. De ersätter inte ett tvådatorstest i DCS
eller ett faktiskt radiosamband med DCS/SRS.
