##-----------------------------------------------------------------------------------------##
####ANALYSE AF GENNEMFØRSEL OG FRAFALD PÅ DANSKE UNGDOMSUDDANNELSER - MED ODENSE I FOKUS####
##-----------------------------------------------------------------------------------------##


###ANALYSE 1:  BEREGNING AF PROCENTFORDELING FOR FULDFØRTE, IGANGVÆRENDE, AFBRUDTE OG IKKE REGISTREREDE STUDERENDE - ODENSE 2024 ###

##HENTE DATA##
library(readr)
Analyse_1_datasæt <- read_csv("C:/Users/m_han/Desktop/Job/GitHub/Analyse af gennemførsel og frafald på danske ungdomsuddannelser – med Odense i fokus/Analyser/Analyse 1/Analyse 1 - datasæt, rå.csv", 
                              locale = locale())

##TILRETTELÆGGE DATA##
#Oprettelse af variable ud fra kolonnenumre
uddannelsesstatusialt <- 4  # Kolonne med uddannelsesstatus i alt
fuldførtuddannelse <- 5 # Kolonne med fuldført uddannelse
igangvaerendeuddannelse <- 6 # Kolonne med igangværende uddannelse
afbrudtuddannelse <- 7 # Kolonne med afbrudt uddannelse
ingenregistreretuddannelse <- 8 # Kolonne med ingen registreret uddannelse

##ANALYSE##
#Oprette variabel med totale antal unge for hver kommune
row_totals <- as.numeric(Analyse_1_datasæt[[uddannelsesstatusialt]])

#Beregning af fordeling i procent for hver kategori
Analyse_1_datasæt$fuldfoert_procent <- as.numeric(Analyse_1_datasæt[[fuldførtuddannelse]]) / row_totals
Analyse_1_datasæt$igangvaerende_procent <- as.numeric(Analyse_1_datasæt[[igangvaerendeuddannelse]]) / row_totals
Analyse_1_datasæt$afbrudt_procent <- as.numeric(Analyse_1_datasæt[[afbrudtuddannelse]]) / row_totals
Analyse_1_datasæt$ingenregistreret_procent <- as.numeric(Analyse_1_datasæt[[ingenregistreretuddannelse]]) / row_totals

Analyse_1_datasæt$fuldfoert_procent <- round(Analyse_1_datasæt$fuldfoert_procent,4)
Analyse_1_datasæt$igangvaerende_procent <- round(Analyse_1_datasæt$igangvaerende_procent,4)
Analyse_1_datasæt$afbrudt_procent <- round(Analyse_1_datasæt$afbrudt_procent,4)
Analyse_1_datasæt$ingenregistreret_procent <- round(Analyse_1_datasæt$ingenregistreret_procent,4)

#Kontrol af hvorvidt procentsatserne summerer til 100% for hver række
kontrolsum <- rowSums(Analyse_1_datasæt[, c("fuldfoert_procent", "igangvaerende_procent", 
                                            "afbrudt_procent", "ingenregistreret_procent")], 
                      na.rm = TRUE)
print("Kontrol - alle rækker skal være tæt på 100:")
print(round(kontrolsum, 1))
View(Analyse_1_datasæt)

##KLARGØRING AF DATA TIL POWER BI##
# Først identificeres hvilke rækkenummer Odense har i datasættet
View(Analyse_1_datasæt)

#Oprette ny variabel for Odense ud fra Odenses rækkenummer
odense_række <- 55

#Opret PowerBI data (kun 4 rækker)
powerbi_data <- data.frame(
  Kategori = c("Fuldført uddannelse", 
               "Igangværende uddannelse", 
               "Afbrudt uddannelse", 
               "Ingen registreret uddannelse"),
  Procent = c(
    Analyse_1_datasæt$fuldfoert_procent[odense_række],
    Analyse_1_datasæt$igangvaerende_procent[odense_række],
    Analyse_1_datasæt$afbrudt_procent[odense_række],
    Analyse_1_datasæt$ingenregistreret_procent[odense_række]
  )
)

#Se resultatet
print("Data til PowerBI:")
print(powerbi_data)

#Gem til fil
write.csv2(powerbi_data, "Power BI, analyse 1.csv", 
          row.names = FALSE,) 
print("Fil gemt som: Power BI, analyse 1.csv")


##-----------------------------------------------------------------------------------------##
###ANALYSE 1B: KORT SOM ILLUSTRERER FRAFALDSPROCENT FOR ALLE LANDETS KOMMUNER###

##KLARGØRING AF DATA TIL POWER BI##
#Opretter nyt data-frame til Danmarkskort-analyse
kort_data <- data.frame(
  Kommune = Analyse_1_datasæt$`Hele landet`, # Kopierer Kommune-data over i en ny variabel
  Frafaldsprocent = Analyse_1_datasæt$afbrudt_procent  # Kopierer frafalds-data over i ny variabel
)

#Fjern observationer hvor frafaldsprocent er NA (Not available data), i dette tilfælde kun for Christiansø
kort_data <- kort_data[!is.na(kort_data$Frafaldsprocent), ]

#Ret kommunenavnet Høje Taastrup så stavemåden fra Danmarks Statistik matcher stavemåden fra Json-filen i Power BI
kort_data$Kommune <- gsub("-Taastrup", " Taastrup", kort_data$Kommune, useBytes = TRUE)

#Sørger for at Frafaldsprocent er numerisk og formateret korrekt
kort_data$Frafaldsprocent <- as.numeric(kort_data$Frafaldsprocent)

#Konverter til procent format (0.089 bliver til 8.9)
kort_data$Frafaldsprocent_pct <- kort_data$Frafaldsprocent * 100

#Se den nye variabel
print("Data til danmarkskort:")
print(kort_data)

#Gem fil til Power BI
write.csv2(kort_data, "Power BI, analyse 1b Danmarkskort.csv", row.names = FALSE)
print("Fil gemt som: Power BI, analyse 1b Danmarkskort.csv")


