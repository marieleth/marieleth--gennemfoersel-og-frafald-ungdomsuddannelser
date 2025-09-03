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
  Hele.landet = Analyse_1_datasæt$`Hele landet`, # Kopierer Kommune-data over i en ny variabel
  Frafaldsprocent = Analyse_1_datasæt$afbrudt_procent  # Kopierer frafalds-data over i ny variabel
)

#Fjern observationer hvor frafaldsprocent er NA (Not available data), i dette tilfælde kun for Christiansø
kort_data <- kort_data[!is.na(kort_data$Frafaldsprocent), ]

#Ret kommunenavnet Høje Taastrup så stavemåden fra Danmarks Statistik matcher stavemåden fra Json-filen i Power BI
kort_data$Hele.landet <- gsub("-Taastrup", " Taastrup", kort_data$Hele.landet, useBytes = TRUE)

#Sørger for at Frafaldsprocent er numerisk og formateret korrekt
kort_data$Frafaldsprocent <- as.numeric(kort_data$Frafaldsprocent)

#Konverter til procent format (0.089 bliver til 8.9)
kort_data$Frafaldsprocent_pct <- kort_data$Frafaldsprocent * 100


#Tilføjer kategoriseringsvariabel
#Opret kategorier baseret på procent-værdierne
kort_data$Kategori <- cut(kort_data$Frafaldsprocent_pct, 
                          breaks = c(-Inf, 5, 7, 9, 11, Inf),
                          labels = c("Under 5 pct", "5-7 pct", "7-9 pct", "9-11 pct", "Over 11 pct"),
                          include.lowest = TRUE)

#Konverter kategori til character for bedre håndtering i Power BI
kort_data$Kategori <- as.character(kort_data$Kategori)

#Opret numerisk værdi til sortering af kategorier (hjælper Power BI med rækkefølgen)
kort_data$Kategori_sortering <- ifelse(kort_data$Kategori == "Under 5 pct", 1,
                                       ifelse(kort_data$Kategori == "5-7 pct", 2,
                                              ifelse(kort_data$Kategori == "7-9 pct", 3,
                                                     ifelse(kort_data$Kategori == "9-11 pct", 4, 5))))


#Se den nye variabel
print("Data til danmarkskort:")
print(kort_data)


#Gem fil til Power BI
write.csv2(kort_data, "Power BI, analyse 1b Danmarkskort.csv", row.names = FALSE)
print("Fil gemt som: Power BI, analyse 1b Danmarkskort.csv")

##-----------------------------------------------------------------------------------------##
###ANALYSE 1C: LANDSGENNEMSNIT af FRAFALDSPROCENT, ODENSES PLACERING IFT. RESTERENDE KOMMUNER SAMT TOP-10 OG BUND-10 KOMMUNER


#Del 1:Landsgennemsnit af frafaldsprocent
#Beregner landsgennemsnittet af frafaldsprocenten, NA-værdier ignoreres
gennemsnit_frafald <- mean(Analyse_1_datasæt$afbrudt_procent, na.rm = TRUE)

#Konverter til procent
gennemsnit_frafald_pct <- gennemsnit_frafald * 100
print(paste("Gennemsnitlig frafaldsprocent i Danmark:", round(gennemsnit_frafald_pct, 2), "%"))

#Find Odenses frafaldsprocent
odense_frafald <- Analyse_1_datasæt$afbrudt_procent[odense_række]
odense_frafald_pct <- odense_frafald * 100
print(paste("Odenses frafaldsprocent:", round(odense_frafald_pct, 2), "%"))

#Del 2:Beregning Odenses placering (rang)
#Sortér alle kommuner efter frafaldsprocent (højeste først)
sorteret_frafald <- sort(Analyse_1_datasæt$afbrudt_procent, decreasing = TRUE, na.last = NA)
odense_placering <- which(sorteret_frafald == odense_frafald)
print(paste("Odenses placering:", odense_placering))

#Del 3:Top-10 og bund-10 kommuner 
#Beregning af top-10 og bund-10 af kommuner ud fra frafaldsprocent
top_10_højest <- Analyse_1_datasæt[order(Analyse_1_datasæt$afbrudt_procent, decreasing = TRUE), ][1:10, ]
top_10_lavest <- Analyse_1_datasæt[order(Analyse_1_datasæt$afbrudt_procent, decreasing = FALSE), ][1:10, ]

#Vis resultaterne
print("Top 10 kommuner med højest frafaldsprocent:")
print(top_10_højest[, c(3, 11)])

print("Top 10 kommuner med lavest frafaldsprocent:")
print(top_10_lavest[, c(3, 11)])


# Gem top-10 og bund-10 til Power BI
write.csv2(top_10_højest[, c(3, 11)], "Power BI, analyse 1c top-10 højest frafald.csv", row.names = FALSE)
write.csv2(top_10_lavest[, c(3, 11)], "Power BI, analyse 1c bund-10 lavest frafald.csv", row.names = FALSE)

print("Filer gemt som:")
print("Power BI, analyse 1c top-10 højest frafald.csv")
print("Power BI, analyse 1c bund-10 lavest frafald.csv")

##-----------------------------------------------------------------------------------------##
###ANALYSE 2: PROCENTVISE FORDELING AF FULDFØRTE, AFBRUDTE OG IGANGVÆRENDE STUDERENDE I 2024 I ODENSE PÅ HHV. GYMNASIAL UDDANNELSE OG ERHVERVSFAGLIG UDDANNELSE

##HENTE DATA##
library(readr)
Analyse_2_datasæt <- read_csv("C:/Users/m_han/Desktop/Job/GitHub/Analyse af gennemførsel og frafald på danske ungdomsuddannelser – med Odense i fokus/Analyser/Analyse 2/Analyse 2 - datasæt, rå.csv",
                              locale = locale())
View(Analyse_2_datasæt)

##TILRETTELÆGGE DATA##
#Omdøb kolonner
names(Analyse_2_datasæt) <- c("Kommune", "Aar", "Status", 
                              "Gymnasiale_uddannelser", 
                              "Erhvervsfaglige_grundforloeb", 
                              "Erhvervsfaglige_uddannelser")

#Sikre at data behandles som tal og ikke tekst 
Analyse_2_datasæt$Gymnasiale_uddannelser <- as.numeric(Analyse_2_datasæt$Gymnasiale_uddannelser)
Analyse_2_datasæt$Erhvervsfaglige_grundforloeb <- as.numeric(Analyse_2_datasæt$Erhvervsfaglige_grundforloeb)
Analyse_2_datasæt$Erhvervsfaglige_uddannelser <- as.numeric(Analyse_2_datasæt$Erhvervsfaglige_uddannelser)

#Opret samlet kategori for erhvervsfaglig uddannelse
Analyse_2_datasæt$Erhvervsfaglig_samlet <- Analyse_2_datasæt$Erhvervsfaglige_grundforloeb +
                                           Analyse_2_datasæt$Erhvervsfaglige_uddannelser


##ANALYSE##
#Udregn totale antal på gymnasiale uddannelse samt erhvervsfaglige uddannelse. Rækkerne summeres for at finde samlet antal.
gymnasial_total <- sum(Analyse_2_datasæt$Gymnasiale_uddannelser, na.rm = TRUE)
erhvervsfaglig_total <- sum(Analyse_2_datasæt$Erhvervsfaglig_samlet, na.rm = TRUE)
print(paste("Gymnasial total:", gymnasial_total))
print(paste("Erhvervsfaglig total:", erhvervsfaglig_total))                                
                                           
#Beregn procentsatser ud fra rækkenumre. Række 1 = Fuldført, Række 2 = Igangværende, Række 3 = Afbrudt
gymnasial_fuldfoert <- Analyse_2_datasæt$Gymnasiale_uddannelser[1] / gymnasial_total
gymnasial_igangvaerende <- Analyse_2_datasæt$Gymnasiale_uddannelser[2] / gymnasial_total
gymnasial_afbrudt <- Analyse_2_datasæt$Gymnasiale_uddannelser[3] / gymnasial_total

erhvervsfaglig_fuldfoert <- Analyse_2_datasæt$Erhvervsfaglig_samlet[1] / erhvervsfaglig_total
erhvervsfaglig_igangvaerende <- Analyse_2_datasæt$Erhvervsfaglig_samlet[2] / erhvervsfaglig_total
erhvervsfaglig_afbrudt <- Analyse_2_datasæt$Erhvervsfaglig_samlet[3] / erhvervsfaglig_total

# Afrund til 4 decimaler
gymnasial_fuldfoert <- round(gymnasial_fuldfoert, 4)
gymnasial_igangvaerende <- round(gymnasial_igangvaerende, 4)
gymnasial_afbrudt <- round(gymnasial_afbrudt, 4)
erhvervsfaglig_fuldfoert <- round(erhvervsfaglig_fuldfoert, 4)
erhvervsfaglig_igangvaerende <- round(erhvervsfaglig_igangvaerende, 4)
erhvervsfaglig_afbrudt <- round(erhvervsfaglig_afbrudt, 4)


##KLARGØRING AF DATA TIL POWER BI##
# Opret PowerBI data
powerbi_data2 <- data.frame(
  Status = rep(c("Fuldført uddannelse", "Igangværende uddannelse", "Afbrudt uddannelse"), 2),
  Uddannelsestype = c(rep("Gymnasial uddannelse", 3), rep("Erhvervsfaglig uddannelse", 3)),
  Procent = c(
    gymnasial_fuldfoert,
    gymnasial_igangvaerende,
    gymnasial_afbrudt,
    erhvervsfaglig_fuldfoert,
    erhvervsfaglig_igangvaerende,
    erhvervsfaglig_afbrudt
  ),
  Procent_pct = c(
    gymnasial_fuldfoert * 100,
    gymnasial_igangvaerende * 100,
    gymnasial_afbrudt * 100,
    erhvervsfaglig_fuldfoert * 100,
    erhvervsfaglig_igangvaerende * 100,
    erhvervsfaglig_afbrudt * 100
  )
)

# Afrund procent_pct til 2 decimaler
powerbi_data2$Procent_pct <- round(powerbi_data2$Procent_pct, 2)

# Se resultatet
print("Data til PowerBI, analyse 2:")
print(powerbi_data2)

# Gem til fil
write.csv2(powerbi_data2, "Power BI, analyse 2.csv", 
           row.names = FALSE)
print("Fil gemt som: Power BI, analyse 2.csv")
                                           
##-----------------------------------------------------------------------------------------##                                          
###ANALYSE 2b: UDVIKLING I FRAFALDSPROCENT I ODENSE OG SAMMENLIGNELIGE KOMMUNER PÅ GYMNASIALE UDDANNELSER


##HENTE DATA##
library(readr)
Analyse_2b_datasæt <- read_csv("C:/Users/m_han/Desktop/Job/GitHub/Analyse af gennemførsel og frafald på danske ungdomsuddannelser – med Odense i fokus/Analyser/Analyse 2b/Analyse 2b - datasæt, rå.csv",
                               locale = locale(),
                               col_names = FALSE)
View(Analyse_2b_datasæt)

##TILRETTELÆGGE DATA##
#Omdøb kolonner
names(Analyse_2b_datasæt) <- c("Status", "Uddannelsestype", "Kommune", 
                               "Aar_2017", "Aar_2018", "Aar_2019", 
                               "Aar_2020", "Aar_2021", "Aar_2022", 
                               "Aar_2023", "Aar_2024")

#Opretter ny variabel med datasæt som udelukkende består af rækker hvor uddannelsesstatus er "Uddannelsesstatus i alt" (alle kolonner medtages)
total_data <- Analyse_2b_datasæt[Analyse_2b_datasæt$Status == "Uddannelsesstatus i alt", ]

#Opretter ny variabel med datasæt som udelukkende består af rækker hvor uddannelsesstatus er "Afbrudt uddannelse" (alle kolonner medtages)
afbrudt_data <- Analyse_2b_datasæt[Analyse_2b_datasæt$Status == "Afbrudt uddannelse", ]

##ANALYSE - GYMNASIALE UDDANNELSER##
#Opret data frame med korrekte kolonner
gymnasial_frafald <- data.frame(
  Kommune = character(0),
  Uddannelsestype = character(0), 
  Aar = numeric(0),
  Frafaldsprocent = numeric(0)
)

#Definer de specifikke kommuner + hele landet
kommuner_liste <- c("Hele landet", "Aarhus", "Odense", "Aalborg", "Esbjerg")

#Løkke til beregning af årlige frafaldsprocenter
for(kommune in kommuner_liste) {
  
  #Find data for denne kommune og gymnasiale uddannelser
  total_række <- total_data[total_data$Kommune == kommune & 
                              total_data$Uddannelsestype == "H20 Gymnasiale uddannelser", ]
  
  afbrudt_række <- afbrudt_data[afbrudt_data$Kommune == kommune & 
                                  afbrudt_data$Uddannelsestype == "H20 Gymnasiale uddannelser", ]
  
  #Tjek om data findes
  if(nrow(total_række) > 0 & nrow(afbrudt_række) > 0) {
    
    #Beregn frafaldsprocent for hvert år
    for(år in 2017:2024) {
      år_kolonne <- paste0("Aar_", år)
      
      frafald_procent <- round((afbrudt_række[[år_kolonne]] / total_række[[år_kolonne]]), 4)
      
      gymnasial_frafald <- rbind(gymnasial_frafald, data.frame(
        Kommune = kommune,
        Uddannelsestype = "Gymnasiale uddannelser",
        Aar = år,
        Frafaldsprocent = frafald_procent
      ))
    }
  }
}

##Tilføj sorteringskolonne, så kommuner vises i denne rækkefølge i Power BI
library(dplyr)
gymnasial_frafald$Kommune_Order <- case_when(
  gymnasial_frafald$Kommune == "Hele landet" ~ 1,
  gymnasial_frafald$Kommune == "Aarhus" ~ 2,
  gymnasial_frafald$Kommune == "Odense" ~ 3,
  gymnasial_frafald$Kommune == "Aalborg" ~ 4,
  gymnasial_frafald$Kommune == "Esbjerg" ~ 5
)

#Se resultatet for gymnasiale uddannelser
print("Frafaldsprocenter gymnasiale uddannelser:")
print(gymnasial_frafald)

##KLARGØRING AF DATA TIL POWER BI - GYMNASIALE UDDANNELSER##
# Gem til fil
write.csv2(gymnasial_frafald, "Power BI, analyse 2b gymnasiale.csv", 
           row.names = FALSE)

print("Fil gemt som: Power BI, analyse 2b gymnasiale.csv")

##-----------------------------------------------------------------------------------------##
###ANALYSE 2C: UDVIKLING I FRAFALDSPROCENT I ODENSE OG SAMMENLIGNELIGE KOMMUNER PÅ ERHVERVSFAGLIGE UDDANNELSER


##HENTE DATA##
library(readr)
library(dplyr)
Analyse_2c_datasæt <- read_csv("C:/Users/m_han/Desktop/Job/GitHub/Analyse af gennemførsel og frafald på danske ungdomsuddannelser – med Odense i fokus/Analyser/Analyse 2c/Analyse 2c - datasæt, rå.csv",
                               locale = locale(encoding = "windows-1252"),
                               col_names = FALSE)
View(Analyse_2c_datasæt)

##TILRETTELÆGGE DATA##
#Omdøb kolonner
names(Analyse_2c_datasæt) <- c("Status", "Uddannelsestype", "Kommune", 
                               "Aar_2017", "Aar_2018", "Aar_2019", 
                               "Aar_2020", "Aar_2021", "Aar_2022", 
                               "Aar_2023", "Aar_2024")

#Opretter ny variabel med datasæt som udelukkende består af rækker hvor uddannelsesstatus er "Uddannelsesstatus i alt" (alle kolonner medtages)
total_data <- Analyse_2c_datasæt[Analyse_2c_datasæt$Status == "Uddannelsesstatus i alt", ]

#Opretter ny variabel med datasæt som udelukkende består af rækker hvor uddannelsesstatus er "Afbrudt uddannelse" (alle kolonner medtages)
afbrudt_data <- Analyse_2c_datasæt[Analyse_2c_datasæt$Status == "Afbrudt uddannelse", ]

##ANALYSE - ERHVERVSFAGLIGE UDDANNELSER##
#Opret data frame med korrekte kolonner
erhvervsfaglig_frafald <- data.frame(
  Kommune = character(0),
  Uddannelsestype = character(0), 
  Aar = numeric(0),
  Frafaldsprocent = numeric(0)
)

#Definer de specifikke kommuner + hele landet
kommuner_liste <- c("Hele landet", "Aarhus", "Odense", "Aalborg", "Esbjerg")

#Løkke til beregning af årlige frafaldsprocenter
for(kommune in kommuner_liste) {
  
  total_række <- total_data %>%
    filter(Kommune == kommune, 
           grepl("H29|H30", Uddannelsestype)) %>%
    summarise(Kommune = kommune,
              across(starts_with("Aar_"), sum, na.rm = TRUE))
  
  afbrudt_række <- afbrudt_data %>%
    filter(Kommune == kommune, 
           grepl("H29|H30", Uddannelsestype)) %>%
    summarise(Kommune = kommune,
              across(starts_with("Aar_"), sum, na.rm = TRUE))
  
  #Tjek om data findes
  if(nrow(total_række) > 0 & nrow(afbrudt_række) > 0) {
    
    #Beregn frafaldsprocent for hvert år
    for(år in 2017:2024) {
      år_kolonne <- paste0("Aar_", år)
      
      frafald_procent <- round((afbrudt_række[[år_kolonne]] / total_række[[år_kolonne]]), 4)
      
      erhvervsfaglig_frafald <- rbind(erhvervsfaglig_frafald, data.frame(
        Kommune = kommune,
        Uddannelsestype = "Erhvervsfaglige uddannelser",
        Aar = år,
        Frafaldsprocent = frafald_procent
      ))
    }
  }
}

##Tilføj sorteringskolonne, så kommuner vises i denne rækkefølge i Power BI
library(dplyr)
erhvervsfaglig_frafald$Kommune_Order <- case_when(
  erhvervsfaglig_frafald$Kommune == "Hele landet" ~ 1,
  erhvervsfaglig_frafald$Kommune == "Aarhus" ~ 2,
  erhvervsfaglig_frafald$Kommune == "Odense" ~ 3,
  erhvervsfaglig_frafald$Kommune == "Aalborg" ~ 4,
  erhvervsfaglig_frafald$Kommune == "Esbjerg" ~ 5
)

#Se resultatet for gymnasiale uddannelser
print("Frafaldsprocenter erhvervsfaglige uddannelser:")
print(erhvervsfaglig_frafald)

##KLARGØRING AF DATA TIL POWER BI - GYMNASIALE UDDANNELSER##
# Gem til fil
write.csv2(erhvervsfaglig_frafald, "Power BI, analyse 2c erhvervsfaglige.csv", 
           row.names = FALSE)

print("Fil gemt som: Power BI, analyse 2c erhvervsfaglige.csv")

##-----------------------------------------------------------------------------------------##
###ANALYSE 3: PROCENTVIS FORDELING PÅ UDDANNELSESSTATUS EFTER KØN###

##HENTE DATA##
library(readr)
Analyse_3_datasæt <- read_csv("C:/Users/m_han/Desktop/Job/GitHub/Analyse af gennemførsel og frafald på danske ungdomsuddannelser – med Odense i fokus/Analyser/Analyse 3/Analyse 3 - datasæt, rå.csv",
                              locale = locale())
##TILRETTELÆGGE DATA##
#Oprettelse af variable ud fra kolonnenumre
uddannelsesstatus_kolonne <- 4  # Kolonne med uddannelsesstatus (tekstbeskrivelse)
maend_kolonne <- 5              # Kolonne med mænd
kvinder_kolonne <- 6            # Kolonne med kvinder

##ANALYSE##
#Hent data for mænd og kvinder fra de specifikke rækker
fuldfoert_maend <- as.numeric(Analyse_3_datasæt[[maend_kolonne]][1])                 # Fuldført uddannelse - mænd
igangvaerende_maend <- as.numeric(Analyse_3_datasæt[[maend_kolonne]][2])             # Igangværende uddannelse - mænd
afbrudt_maend <- as.numeric(Analyse_3_datasæt[[maend_kolonne]][3])                   # Afbrudt uddannelse - mænd
ingenregistreret_maend <- as.numeric(Analyse_3_datasæt[[maend_kolonne]][4])          # Ingen registreret uddannelse - mænd

fuldfoert_kvinder <- as.numeric(Analyse_3_datasæt[[kvinder_kolonne]][1])             # Fuldført uddannelse - kvinder
igangvaerende_kvinder <- as.numeric(Analyse_3_datasæt[[kvinder_kolonne]][2])         # Igangværende uddannelse - kvinder
afbrudt_kvinder <- as.numeric(Analyse_3_datasæt[[kvinder_kolonne]][3])               # Afbrudt uddannelse - kvinder
ingenregistreret_kvinder <- as.numeric(Analyse_3_datasæt[[kvinder_kolonne]][4])      # Ingen registreret uddannelse - kvinder

#Beregn totaler for hver køn (svarer til "uddannelsesstatus i alt")
total_maend <- fuldfoert_maend + igangvaerende_maend + afbrudt_maend + ingenregistreret_maend
total_kvinder <- fuldfoert_kvinder + igangvaerende_kvinder + afbrudt_kvinder + ingenregistreret_kvinder

#Beregning af fordeling i procent for mænd
fuldfoert_maend_procent <- fuldfoert_maend / total_maend
igangvaerende_maend_procent <- igangvaerende_maend / total_maend
afbrudt_maend_procent <- afbrudt_maend / total_maend
ingenregistreret_maend_procent <- ingenregistreret_maend / total_maend

#Beregning af fordeling i procent for kvinder
fuldfoert_kvinder_procent <- fuldfoert_kvinder / total_kvinder
igangvaerende_kvinder_procent <- igangvaerende_kvinder / total_kvinder
afbrudt_kvinder_procent <- afbrudt_kvinder / total_kvinder
ingenregistreret_kvinder_procent <- ingenregistreret_kvinder / total_kvinder

#Afrunding til 4 decimaler
fuldfoert_maend_procent <- round(fuldfoert_maend_procent, 4)
igangvaerende_maend_procent <- round(igangvaerende_maend_procent, 4)
afbrudt_maend_procent <- round(afbrudt_maend_procent, 4)
ingenregistreret_maend_procent <- round(ingenregistreret_maend_procent, 4)

fuldfoert_kvinder_procent <- round(fuldfoert_kvinder_procent, 4)
igangvaerende_kvinder_procent <- round(igangvaerende_kvinder_procent, 4)
afbrudt_kvinder_procent <- round(afbrudt_kvinder_procent, 4)
ingenregistreret_kvinder_procent <- round(ingenregistreret_kvinder_procent, 4)

#Kontrol af hvorvidt procentsatserne summerer til 100% for hver køn
kontrolsum_maend <- fuldfoert_maend_procent + igangvaerende_maend_procent + 
  afbrudt_maend_procent + ingenregistreret_maend_procent
kontrolsum_kvinder <- fuldfoert_kvinder_procent + igangvaerende_kvinder_procent + 
  afbrudt_kvinder_procent + ingenregistreret_kvinder_procent

print("Kontrol - skal være tæt på 1.0000:")
print(paste("Mænd:", round(kontrolsum_maend, 4)))
print(paste("Kvinder:", round(kontrolsum_kvinder, 4)))

View(Analyse_3_datasæt)

##KLARGØRING AF DATA TIL POWER BI##
#Opret PowerBI data
powerbi_data3 <- data.frame(
  Koen = rep(c("Mænd", "Kvinder"), each = 4),
  Kategori = rep(c("Fuldført uddannelse", 
                   "Igangværende uddannelse", 
                   "Afbrudt uddannelse", 
                   "Ingen registreret uddannelse"), 2),
  Procent = c(
    fuldfoert_maend_procent,
    igangvaerende_maend_procent,
    afbrudt_maend_procent,
    ingenregistreret_maend_procent,
    fuldfoert_kvinder_procent,
    igangvaerende_kvinder_procent,
    afbrudt_kvinder_procent,
    ingenregistreret_kvinder_procent
  ),
  Antal = c(
    fuldfoert_maend,
    igangvaerende_maend,
    afbrudt_maend,
    ingenregistreret_maend,
    fuldfoert_kvinder,
    igangvaerende_kvinder,
    afbrudt_kvinder,
    ingenregistreret_kvinder
  )
)

#Se resultatet
print("Data til PowerBI:")
print(powerbi_data3)

#Gem til fil
write.csv2(powerbi_data3, "Power BI, analyse 3.csv", 
           row.names = FALSE)
print("Fil gemt som: Power BI, analyse 3.csv")

##-----------------------------------------------------------------------------------------##
###ANALYSE 4: PROCENTVIS FORDELING PÅ UDDANNELSESSTATUS EFTER HERKOMST###

##HENTE DATA##
library(readr)
Analyse_4_datasæt <- read_csv("C:/Users/m_han/Desktop/Job/GitHub/Analyse af gennemførsel og frafald på danske ungdomsuddannelser – med Odense i fokus/Analyser/Analyse 4/Analyse 4 - datasæt, rå.csv",
                              locale = locale())

View(Analyse_4_datasæt)


##TILRETTELÆGGE DATA##
#Oprettelse af variable ud fra kolonnenumre
etnisk_danske_kolonne <- 5      # Kolonne med personer med dansk oprindelse
indvandrere_kolonne <- 6        # Kolonne med indvandrere  
efterkommere_kolonne <- 7       # Kolonne med efterkommere

##ANALYSE##
#Hent data for hver etnisk gruppe fra de specifikke rækker
# Række 1 = Fuldført, Række 2 = Igangværende, Række 3 = Afbrudt, Række 4 = Ingen registreret

danske_fuldfoert <- as.numeric(Analyse_4_datasæt[[etnisk_danske_kolonne]][1])
danske_igangvaerende <- as.numeric(Analyse_4_datasæt[[etnisk_danske_kolonne]][2])
danske_afbrudt <- as.numeric(Analyse_4_datasæt[[etnisk_danske_kolonne]][3])
danske_ingenregistreret <- as.numeric(Analyse_4_datasæt[[etnisk_danske_kolonne]][4])

indvandrere_fuldfoert <- as.numeric(Analyse_4_datasæt[[indvandrere_kolonne]][1])
indvandrere_igangvaerende <- as.numeric(Analyse_4_datasæt[[indvandrere_kolonne]][2])
indvandrere_afbrudt <- as.numeric(Analyse_4_datasæt[[indvandrere_kolonne]][3])
indvandrere_ingenregistreret <- as.numeric(Analyse_4_datasæt[[indvandrere_kolonne]][4])

efterkommere_fuldfoert <- as.numeric(Analyse_4_datasæt[[efterkommere_kolonne]][1])
efterkommere_igangvaerende <- as.numeric(Analyse_4_datasæt[[efterkommere_kolonne]][2])
efterkommere_afbrudt <- as.numeric(Analyse_4_datasæt[[efterkommere_kolonne]][3])
efterkommere_ingenregistreret <- as.numeric(Analyse_4_datasæt[[efterkommere_kolonne]][4])

#Beregn totaler for hver gruppe (summér de fire kategorier)
danske_total <- danske_fuldfoert + danske_igangvaerende + danske_afbrudt + danske_ingenregistreret
indvandrere_total <- indvandrere_fuldfoert + indvandrere_igangvaerende + indvandrere_afbrudt + indvandrere_ingenregistreret
efterkommere_total <- efterkommere_fuldfoert + efterkommere_igangvaerende + efterkommere_afbrudt + efterkommere_ingenregistreret

print("Totaler for hver gruppe:")
print(paste("Etnisk danske total:", danske_total))
print(paste("Indvandrere total:", indvandrere_total))
print(paste("Efterkommere total:", efterkommere_total))

#Beregn procentsatser for hver etnisk gruppe
# Etnisk danske
danske_fuldfoert_procent <- danske_fuldfoert / danske_total
danske_igangvaerende_procent <- danske_igangvaerende / danske_total
danske_afbrudt_procent <- danske_afbrudt / danske_total
danske_ingenregistreret_procent <- danske_ingenregistreret / danske_total

# Indvandrere
indvandrere_fuldfoert_procent <- indvandrere_fuldfoert / indvandrere_total
indvandrere_igangvaerende_procent <- indvandrere_igangvaerende / indvandrere_total
indvandrere_afbrudt_procent <- indvandrere_afbrudt / indvandrere_total
indvandrere_ingenregistreret_procent <- indvandrere_ingenregistreret / indvandrere_total

# Efterkommere
efterkommere_fuldfoert_procent <- efterkommere_fuldfoert / efterkommere_total
efterkommere_igangvaerende_procent <- efterkommere_igangvaerende / efterkommere_total
efterkommere_afbrudt_procent <- efterkommere_afbrudt / efterkommere_total
efterkommere_ingenregistreret_procent <- efterkommere_ingenregistreret / efterkommere_total

# Afrund til 4 decimaler
danske_fuldfoert_procent <- round(danske_fuldfoert_procent, 4)
danske_igangvaerende_procent <- round(danske_igangvaerende_procent, 4)
danske_afbrudt_procent <- round(danske_afbrudt_procent, 4)
danske_ingenregistreret_procent <- round(danske_ingenregistreret_procent, 4)

indvandrere_fuldfoert_procent <- round(indvandrere_fuldfoert_procent, 4)
indvandrere_igangvaerende_procent <- round(indvandrere_igangvaerende_procent, 4)
indvandrere_afbrudt_procent <- round(indvandrere_afbrudt_procent, 4)
indvandrere_ingenregistreret_procent <- round(indvandrere_ingenregistreret_procent, 4)

efterkommere_fuldfoert_procent <- round(efterkommere_fuldfoert_procent, 4)
efterkommere_igangvaerende_procent <- round(efterkommere_igangvaerende_procent, 4)
efterkommere_afbrudt_procent <- round(efterkommere_afbrudt_procent, 4)
efterkommere_ingenregistreret_procent <- round(efterkommere_ingenregistreret_procent, 4)

#Kontrol af hvorvidt procentsatserne summerer til 100% for hver gruppe
kontrolsum_danske <- danske_fuldfoert_procent + danske_igangvaerende_procent + 
  danske_afbrudt_procent + danske_ingenregistreret_procent
kontrolsum_indvandrere <- indvandrere_fuldfoert_procent + indvandrere_igangvaerende_procent + 
  indvandrere_afbrudt_procent + indvandrere_ingenregistreret_procent
kontrolsum_efterkommere <- efterkommere_fuldfoert_procent + efterkommere_igangvaerende_procent + 
  efterkommere_afbrudt_procent + efterkommere_ingenregistreret_procent

print("Kontrol - skal være tæt på 1.0000:")
print(paste("Etnisk danske:", round(kontrolsum_danske, 4)))
print(paste("Indvandrere:", round(kontrolsum_indvandrere, 4)))
print(paste("Efterkommere:", round(kontrolsum_efterkommere, 4)))

##KLARGØRING AF DATA TIL POWER BI##
# Opret PowerBI data
powerbi_data4 <- data.frame(
  Status = rep(c("Fuldført uddannelse", "Igangværende uddannelse", "Afbrudt uddannelse", "Ingen registreret uddannelse"), 3),
  Herkomst = c(rep("Etnisk danske", 4), rep("Indvandrere", 4), rep("Efterkommere", 4)),
  Procent = c(
    danske_fuldfoert_procent,
    danske_igangvaerende_procent,
    danske_afbrudt_procent,
    danske_ingenregistreret_procent,
    indvandrere_fuldfoert_procent,
    indvandrere_igangvaerende_procent,
    indvandrere_afbrudt_procent,
    indvandrere_ingenregistreret_procent,
    efterkommere_fuldfoert_procent,
    efterkommere_igangvaerende_procent,
    efterkommere_afbrudt_procent,
    efterkommere_ingenregistreret_procent
  ),
  Procent_pct = c(
    danske_fuldfoert_procent * 100,
    danske_igangvaerende_procent * 100,
    danske_afbrudt_procent * 100,
    danske_ingenregistreret_procent * 100,
    indvandrere_fuldfoert_procent * 100,
    indvandrere_igangvaerende_procent * 100,
    indvandrere_afbrudt_procent * 100,
    indvandrere_ingenregistreret_procent * 100,
    efterkommere_fuldfoert_procent * 100,
    efterkommere_igangvaerende_procent * 100,
    efterkommere_afbrudt_procent * 100,
    efterkommere_ingenregistreret_procent * 100
  )
)

# Afrund procent_pct til 2 decimaler
powerbi_data4$Procent_pct <- round(powerbi_data4$Procent_pct, 2)

# Tilføj sorteringskolonne for korrekt rækkefølge i Power BI
powerbi_data4$Herkomst_Order <- case_when(
  powerbi_data4$Herkomst == "Etnisk danske" ~ 1,
  powerbi_data4$Herkomst == "Indvandrere" ~ 2,
  powerbi_data4$Herkomst == "Efterkommere" ~ 3
)

# Se resultatet
print("Data til PowerBI, analyse 4:")
print(powerbi_data4)

# Gem til fil
write.csv2(powerbi_data4, "Power BI, analyse 4.csv", 
           row.names = FALSE)
print("Fil gemt som: Power BI, analyse 4.csv")


##-----------------------------------------------------------------------------------------##
###ANALYSE 5: PROCENTVIS FORDELING PÅ UDDANNELSESSTATUS EFTER FORÆLDRES HØJESTE GENNEMFØRTE UDDANNELSE


##HENTE DATA##
library(readr)
Analyse_5_datasæt <- read_csv("C:/Users/m_han/Desktop/Job/GitHub/Analyse af gennemførsel og frafald på danske ungdomsuddannelser – med Odense i fokus/Analyser/Analyse 5/Analyse 5 - datasæt, rå.csv",
                              locale = locale(),
                              col_names = FALSE)
View(Analyse_5_datasæt)

##TILRETTELÆGGE DATA##
#Omdøb kolonner
names(Analyse_5_datasæt) <- c("Ialt", "År", "Forældres højest fuldførte uddannelse", 
                              "Uddannelsesstatus i alt", "Fuldført uddannelse", "Igangværende uddannelse", 
                              "Afbrudt uddannelse", "Ingen registreret uddannelse")

#Oprettelse af variable ud fra kolonnenumre
uddannelsesstatus_kolonne <- 4  # Kolonne med uddannelsesstatus i alt
fuldfoert_kolonne <- 5          # Kolonne med fuldført uddannelse
igangvaerende_kolonne <- 6      # Kolonne med igangværende uddannelse
afbrudt_kolonne <- 7            # Kolonne med afbrudt uddannelse
ingenregistreret_kolonne <- 8   # Kolonne med ingen registreret uddannelse

##ANALYSE##
#Hent data for hver forældregruppe fra de specifikke rækker
# Række 1 = Grundskole, Række 2 = Gymnasiale, Række 3 = Erhvervsfaglige
# Række 4 = Korte videregående, Række 5 = Bacheloruddannelser, Række 6 = Lange videregående

# Grundskole (Række 1)
grundskole_total <- as.numeric(Analyse_5_datasæt[[uddannelsesstatus_kolonne]][1])
grundskole_fuldfoert <- as.numeric(Analyse_5_datasæt[[fuldfoert_kolonne]][1])
grundskole_igangvaerende <- as.numeric(Analyse_5_datasæt[[igangvaerende_kolonne]][1])
grundskole_afbrudt <- as.numeric(Analyse_5_datasæt[[afbrudt_kolonne]][1])
grundskole_ingenregistreret <- as.numeric(Analyse_5_datasæt[[ingenregistreret_kolonne]][1])

# Gymnasiale uddannelser (Række 2)
gymnasial_total <- as.numeric(Analyse_5_datasæt[[uddannelsesstatus_kolonne]][2])
gymnasial_fuldfoert <- as.numeric(Analyse_5_datasæt[[fuldfoert_kolonne]][2])
gymnasial_igangvaerende <- as.numeric(Analyse_5_datasæt[[igangvaerende_kolonne]][2])
gymnasial_afbrudt <- as.numeric(Analyse_5_datasæt[[afbrudt_kolonne]][2])
gymnasial_ingenregistreret <- as.numeric(Analyse_5_datasæt[[ingenregistreret_kolonne]][2])

# Erhvervsfaglige uddannelser (Række 3)
erhverv_total <- as.numeric(Analyse_5_datasæt[[uddannelsesstatus_kolonne]][3])
erhverv_fuldfoert <- as.numeric(Analyse_5_datasæt[[fuldfoert_kolonne]][3])
erhverv_igangvaerende <- as.numeric(Analyse_5_datasæt[[igangvaerende_kolonne]][3])
erhverv_afbrudt <- as.numeric(Analyse_5_datasæt[[afbrudt_kolonne]][3])
erhverv_ingenregistreret <- as.numeric(Analyse_5_datasæt[[ingenregistreret_kolonne]][3])

# Korte videregående uddannelser (Række 4)
korte_total <- as.numeric(Analyse_5_datasæt[[uddannelsesstatus_kolonne]][4])
korte_fuldfoert <- as.numeric(Analyse_5_datasæt[[fuldfoert_kolonne]][4])
korte_igangvaerende <- as.numeric(Analyse_5_datasæt[[igangvaerende_kolonne]][4])
korte_afbrudt <- as.numeric(Analyse_5_datasæt[[afbrudt_kolonne]][4])
korte_ingenregistreret <- as.numeric(Analyse_5_datasæt[[ingenregistreret_kolonne]][4])

# Bacheloruddannelser (Række 5)
bachelor_total <- as.numeric(Analyse_5_datasæt[[uddannelsesstatus_kolonne]][5])
bachelor_fuldfoert <- as.numeric(Analyse_5_datasæt[[fuldfoert_kolonne]][5])
bachelor_igangvaerende <- as.numeric(Analyse_5_datasæt[[igangvaerende_kolonne]][5])
bachelor_afbrudt <- as.numeric(Analyse_5_datasæt[[afbrudt_kolonne]][5])
bachelor_ingenregistreret <- as.numeric(Analyse_5_datasæt[[ingenregistreret_kolonne]][5])

# Lange videregående uddannelser (Række 6)
lange_total <- as.numeric(Analyse_5_datasæt[[uddannelsesstatus_kolonne]][6])
lange_fuldfoert <- as.numeric(Analyse_5_datasæt[[fuldfoert_kolonne]][6])
lange_igangvaerende <- as.numeric(Analyse_5_datasæt[[igangvaerende_kolonne]][6])
lange_afbrudt <- as.numeric(Analyse_5_datasæt[[afbrudt_kolonne]][6])
lange_ingenregistreret <- as.numeric(Analyse_5_datasæt[[ingenregistreret_kolonne]][6])

print("Totaler for hver forældregruppe:")
print(paste("Grundskole total:", grundskole_total))
print(paste("Gymnasial total:", gymnasial_total))
print(paste("Erhvervsfaglig total:", erhverv_total))
print(paste("Korte videregående total:", korte_total))
print(paste("Bachelor total:", bachelor_total))
print(paste("Lange videregående total:", lange_total))

#Beregning af fordeling i procent for hver gruppe
# Grundskole
grundskole_fuldfoert_procent <- grundskole_fuldfoert / grundskole_total
grundskole_igangvaerende_procent <- grundskole_igangvaerende / grundskole_total
grundskole_afbrudt_procent <- grundskole_afbrudt / grundskole_total
grundskole_ingenregistreret_procent <- grundskole_ingenregistreret / grundskole_total

# Gymnasial uddannelser
gymnasial_fuldfoert_procent <- gymnasial_fuldfoert / gymnasial_total
gymnasial_igangvaerende_procent <- gymnasial_igangvaerende / gymnasial_total
gymnasial_afbrudt_procent <- gymnasial_afbrudt / gymnasial_total
gymnasial_ingenregistreret_procent <- gymnasial_ingenregistreret / gymnasial_total

# Erhvervsfaglige uddannelser
erhverv_fuldfoert_procent <- erhverv_fuldfoert / erhverv_total
erhverv_igangvaerende_procent <- erhverv_igangvaerende / erhverv_total
erhverv_afbrudt_procent <- erhverv_afbrudt / erhverv_total
erhverv_ingenregistreret_procent <- erhverv_ingenregistreret / erhverv_total

# Korte videregående
korte_fuldfoert_procent <- korte_fuldfoert / korte_total
korte_igangvaerende_procent <- korte_igangvaerende / korte_total
korte_afbrudt_procent <- korte_afbrudt / korte_total
korte_ingenregistreret_procent <- korte_ingenregistreret / korte_total

# Bachelor
bachelor_fuldfoert_procent <- bachelor_fuldfoert / bachelor_total
bachelor_igangvaerende_procent <- bachelor_igangvaerende / bachelor_total
bachelor_afbrudt_procent <- bachelor_afbrudt / bachelor_total
bachelor_ingenregistreret_procent <- bachelor_ingenregistreret / bachelor_total

# Lange videregående
lange_fuldfoert_procent <- lange_fuldfoert / lange_total
lange_igangvaerende_procent <- lange_igangvaerende / lange_total
lange_afbrudt_procent <- lange_afbrudt / lange_total
lange_ingenregistreret_procent <- lange_ingenregistreret / lange_total

#Afrunding til 4 decimaler
grundskole_fuldfoert_procent <- round(grundskole_fuldfoert_procent, 4)
grundskole_igangvaerende_procent <- round(grundskole_igangvaerende_procent, 4)
grundskole_afbrudt_procent <- round(grundskole_afbrudt_procent, 4)
grundskole_ingenregistreret_procent <- round(grundskole_ingenregistreret_procent, 4)

gymnasial_fuldfoert_procent <- round(gymnasial_fuldfoert_procent, 4)
gymnasial_igangvaerende_procent <- round(gymnasial_igangvaerende_procent, 4)
gymnasial_afbrudt_procent <- round(gymnasial_afbrudt_procent, 4)
gymnasial_ingenregistreret_procent <- round(gymnasial_ingenregistreret_procent, 4)

erhverv_fuldfoert_procent <- round(erhverv_fuldfoert_procent, 4)
erhverv_igangvaerende_procent <- round(erhverv_igangvaerende_procent, 4)
erhverv_afbrudt_procent <- round(erhverv_afbrudt_procent, 4)
erhverv_ingenregistreret_procent <- round(erhverv_ingenregistreret_procent, 4)

korte_fuldfoert_procent <- round(korte_fuldfoert_procent, 4)
korte_igangvaerende_procent <- round(korte_igangvaerende_procent, 4)
korte_afbrudt_procent <- round(korte_afbrudt_procent, 4)
korte_ingenregistreret_procent <- round(korte_ingenregistreret_procent, 4)

bachelor_fuldfoert_procent <- round(bachelor_fuldfoert_procent, 4)
bachelor_igangvaerende_procent <- round(bachelor_igangvaerende_procent, 4)
bachelor_afbrudt_procent <- round(bachelor_afbrudt_procent, 4)
bachelor_ingenregistreret_procent <- round(bachelor_ingenregistreret_procent, 4)

lange_fuldfoert_procent <- round(lange_fuldfoert_procent, 4)
lange_igangvaerende_procent <- round(lange_igangvaerende_procent, 4)
lange_afbrudt_procent <- round(lange_afbrudt_procent, 4)
lange_ingenregistreret_procent <- round(lange_ingenregistreret_procent, 4)

#Kontrol af hvorvidt procentsatserne summerer til 100% for hver gruppe
kontrolsum_grundskole <- grundskole_fuldfoert_procent + grundskole_igangvaerende_procent + 
  grundskole_afbrudt_procent + grundskole_ingenregistreret_procent
kontrolsum_gymnasial <- gymnasial_fuldfoert_procent + gymnasial_igangvaerende_procent + 
  gymnasial_afbrudt_procent + gymnasial_ingenregistreret_procent
kontrolsum_erhverv <- erhverv_fuldfoert_procent + erhverv_igangvaerende_procent + 
  erhverv_afbrudt_procent + erhverv_ingenregistreret_procent
kontrolsum_korte <- korte_fuldfoert_procent + korte_igangvaerende_procent + 
  korte_afbrudt_procent + korte_ingenregistreret_procent
kontrolsum_bachelor <- bachelor_fuldfoert_procent + bachelor_igangvaerende_procent + 
  bachelor_afbrudt_procent + bachelor_ingenregistreret_procent
kontrolsum_lange <- lange_fuldfoert_procent + lange_igangvaerende_procent + 
  lange_afbrudt_procent + lange_ingenregistreret_procent

print("Kontrol - skal være tæt på 1.0000:")
print(paste("Grundskole:", round(kontrolsum_grundskole, 4)))
print(paste("Gymnasial:", round(kontrolsum_gymnasial, 4)))
print(paste("Erhvervsfaglig:", round(kontrolsum_erhverv, 4)))
print(paste("Korte videregående:", round(kontrolsum_korte, 4)))
print(paste("Bachelor:", round(kontrolsum_bachelor, 4)))
print(paste("Lange videregående:", round(kontrolsum_lange, 4)))

##KLARGØRING AF DATA TIL POWER BI##
# Opret PowerBI data
powerbi_data5 <- data.frame(
  Status = rep(c("Fuldført uddannelse", "Igangværende uddannelse", "Afbrudt uddannelse", "Ingen registreret uddannelse"), 6),
  Foraeldre_uddannelse = c(
    rep("Grundskole", 4), 
    rep("Gymnasiale uddannelser", 4), 
    rep("Erhvervsfaglige uddannelser", 4),
    rep("Korte videregående uddannelser", 4),
    rep("Bacheloruddannelser", 4),
    rep("Lange videregående uddannelser", 4)
  ),
  Procent = c(
    grundskole_fuldfoert_procent,
    grundskole_igangvaerende_procent,
    grundskole_afbrudt_procent,
    grundskole_ingenregistreret_procent,
    gymnasial_fuldfoert_procent,
    gymnasial_igangvaerende_procent,
    gymnasial_afbrudt_procent,
    gymnasial_ingenregistreret_procent,
    erhverv_fuldfoert_procent,
    erhverv_igangvaerende_procent,
    erhverv_afbrudt_procent,
    erhverv_ingenregistreret_procent,
    korte_fuldfoert_procent,
    korte_igangvaerende_procent,
    korte_afbrudt_procent,
    korte_ingenregistreret_procent,
    bachelor_fuldfoert_procent,
    bachelor_igangvaerende_procent,
    bachelor_afbrudt_procent,
    bachelor_ingenregistreret_procent,
    lange_fuldfoert_procent,
    lange_igangvaerende_procent,
    lange_afbrudt_procent,
    lange_ingenregistreret_procent
  ),
  Procent_pct = c(
    grundskole_fuldfoert_procent * 100,
    grundskole_igangvaerende_procent * 100,
    grundskole_afbrudt_procent * 100,
    grundskole_ingenregistreret_procent * 100,
    gymnasial_fuldfoert_procent * 100,
    gymnasial_igangvaerende_procent * 100,
    gymnasial_afbrudt_procent * 100,
    gymnasial_ingenregistreret_procent * 100,
    erhverv_fuldfoert_procent * 100,
    erhverv_igangvaerende_procent * 100,
    erhverv_afbrudt_procent * 100,
    erhverv_ingenregistreret_procent * 100,
    korte_fuldfoert_procent * 100,
    korte_igangvaerende_procent * 100,
    korte_afbrudt_procent * 100,
    korte_ingenregistreret_procent * 100,
    bachelor_fuldfoert_procent * 100,
    bachelor_igangvaerende_procent * 100,
    bachelor_afbrudt_procent * 100,
    bachelor_ingenregistreret_procent * 100,
    lange_fuldfoert_procent * 100,
    lange_igangvaerende_procent * 100,
    lange_afbrudt_procent * 100,
    lange_ingenregistreret_procent * 100
  )
)

# Afrund procent_pct til 2 decimaler
powerbi_data5$Procent_pct <- round(powerbi_data5$Procent_pct, 2)

# Tilføj sorteringskolonne for korrekt rækkefølge i Power BI
powerbi_data5$Foraeldre_Order <- case_when(
  powerbi_data5$Foraeldre_uddannelse == "Grundskole" ~ 1,
  powerbi_data5$Foraeldre_uddannelse == "Gymnasiale uddannelser" ~ 2,
  powerbi_data5$Foraeldre_uddannelse == "Erhvervsfaglige uddannelser" ~ 3,
  powerbi_data5$Foraeldre_uddannelse == "Korte videregående uddannelser" ~ 4,
  powerbi_data5$Foraeldre_uddannelse == "Bacheloruddannelser" ~ 5,
  powerbi_data5$Foraeldre_uddannelse == "Lange videregående uddannelser" ~ 6
)

# Se resultatet
print("Data til PowerBI, analyse 5:")
print(powerbi_data5)

# Gem til fil
write.csv2(powerbi_data5, "Power BI, analyse 5.csv", 
           row.names = FALSE)
print("Fil gemt som: Power BI, analyse 5.csv")



