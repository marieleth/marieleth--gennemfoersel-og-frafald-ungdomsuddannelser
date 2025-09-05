# Marie Leth - Gennemførsel og frafald på danske ungdomsuddannelser

 
## Projektbeskrivelse
- Dette projekt analyserer gennemførsel og frafald på ungdomsuddannelser i Danmark med særligt fokus på Odense Kommune. Analysen er baseret på data fra Danmarks Statistik og omfatter 18-25-årige og deres uddannelsesstatus.
- Dataen fra Danmarks Statistik er først analyseret i R, og dataen er herefter gemt i csv-filer. Ud fra denne data er Power BI-rapporten blevet udarbejdet.
- Projektet belyser centrale spørgsmål omkring uddannelsesfrafald: Hvor stor en andel af de unge afbryder deres uddannelse i Odense? Hvilke forskelle findes der mellem gymnasiale og erhvervsfaglige uddannelser i Odense? Hvordan har frafaldsprocenten udviklet sig på gymnasiale og erhvervsfaglige uddannelser siden 2017 i Odense og en række andre kommuner? Hvordan varierer frafaldsmønstrene på tværs af køn, herkomst og forældres uddannelsesniveau? 

## Indhold
- Data: Indeholder rå data downloadet fra Danmarks Statistik samt bearbejdet data efter analyse i R.
- Power BI: Indeholder Power BI rapport i pbix-format og pdf-format
- R-script, analyse af gennemførsel og frafald.R : R-koder til dataanalysen
- README.md: Denne fil

## Oversigt over Power BI rapport
Rapporten består af fem sider:
1.	Uddannelsesstatus: Odenses nøgletal samt frafaldsprocenter for alle danske kommuner
2.	Uddannelsestype: Sammenligning af frafald på gymnasiale og erhvervsfaglige ungdomsuddannelser i Odense og en række andre kommuner
3.	Frafaldsanalyse fordelt efter køn og herkomst
4.	Frafaldsanalyse fordelt efter forældres højest gennemførte uddannelse
5.	Datagrundlag og metode


## Datagrundlag
- Analysens data er hentet fra Danmarks Statistik. Til Analyse 1, 1b, 1c, 2, 2b, 2c (rapport side 1 og 2) benyttes tabel STATUSU6. Til analyse 3 og 4 (rapport side 3) benyttes tabel STATUSU1. Til analyse 5 på (rapport side 4) benyttes tabel STATUSU2.
- I størstedelen af analyserne benyttes data fra 2024. Data fra 2024 viser uddannelsesstatus på opgørelsestidspunktet, men frafald kan være sket på forskellige tidspunkter. Det betyder altså, at hvis en person eksempelvis afsluttede en uddannelse i 2022 og siden har arbejdet, vil deres uddannelsesstatus være "fuldført uddannelse" i 2024.  I analyse 2b og 2c benyttes data fra 2017, 2018, 2019, 2020, 2021, 2022, 2023 og 2024.
- Analysen omfatter unge mellem 18-25 årige og deres uddannelsesstatus. Dette er opgjort på tidspunktet hvor individerne var 13 år gamle. Tilhørskommunen er opgjort efter i hvilken kommune individerne gik i skole, da de var 13 år gamle.
- I analysens tal tages der ikke højde for om de unge har skiftet uddannelsesgruppe, så som eksempelvis et skifte fra STX til HF. Derudover gælder det, at har en elev afsluttet en uddannelse og er siden gået igang med en ny, vil de tælle med i "Fuldført uddannelse".


## Metode 
- Analyse 1, 1b, 1c, 3, 4, 5 omfatter hele populationen af unge mellem 18 og 25 år, inklusiv dem uden registreret uddannelse. Frafaldsprocenten er beregnet som andelen af unge med "afbrudt uddannelse", i forhold til den samlede population af unge (som udgør variablen “uddannelsesstatus i alt”). "Uddannelsesstatus i alt" dækker konkret over unge med status "fuldført uddannelse", "igangværende uddannelse", "afbrudt uddannelse" og "ingen registreret uddannelse".
- Analyse 2 omfatter specifikt de unge mellem 18 og 25 år, der har påbegyndt enten en gymnasial eller en erhvervsfaglig ungdomsuddannelse. Frafaldsprocenten er beregnet som andelen af unge med status ”afbrudt uddannelse” i forhold til gruppen af unge med status ”fuldført uddannelse”, ”igangværende uddannelse” og ”afbrudt uddannelse”.
- Kommunerne i analyse 2 er udvalgt ud fra deres størrelse og placering. Kommunerne Aarhus, Aalborg og Esbjerg ligger alle vest for Storebælt og har en sammenlignelig størrelse med Odense.

## Sådan køres analysen
Klon repositoriet: 
 
     git clone https://github.com/marieleth/marieleth--gennemfoersel-og-frafald-ungdomsuddannelser.git

Kør R-scriptet: 
- Åbn R-script, analyse af gennemførsel og frafald.R  i RStudio
- Kør scriptet for at generere CSV-filer til Power BI

Åbn Power BI rapporten: 
- Åbn Power BI rapporten Power Bi rapport - Analyse af gennemførsel og frafald.pbix i Power BI Desktop
- Opdater datakilder til at pege på de genererede CSV-filer

## Kontakt
Har du spørgsmål til projektet, er du velkommen til at skrive til mig på marielhansen94@gmail.com

