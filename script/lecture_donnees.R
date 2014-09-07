# Script
# ------

# récupéerer les arguments
args <- commandArgs(TRUE)

# Positionner dans le bon répertoire
setwd=getwd()

# lecture du fichier des fonctions
source('script/functions_v0.3_open.R')
source('script/verification_donnees.R')

# paramètre java
options(java.parameters = "-Xmx1512m")

# libraries
library(RPostgreSQL) # connexion au SGBD postgres
library(XLConnect) # lecture de fichier xls
library(stringr) # traitement de chaine de caractères

# Connect to farmbiodiv database
connexion <- connect_db("farmbiodiv","quidoz","jpg!pcs","10.8.4.2")
con <- connexion$con

# initialisation 
nb_sheet <- 2 #nb de feuilles du classeur
verification <- F #vérification ok ou non

# destruction du fichier erreur.txt
if (file.exists('sortie/erreur.txt')) file.remove('erreur.txt')

# Nom du fichier à vérifier 
nom_fichier <- args[1]

fichier_a_traiter <- paste('donnee/',nom_fichier,sep='')

# récupération du nom du fichier (1 : Data ; 2 : protocole ; 3 : Région ; 4 : formatted)
structure_nom_fichier <- unlist (strsplit(nom_fichier, '_'))

# Recupération des noms des tables de données
region <- tolower(structure_nom_fichier[3])
protocole <- tolower(structure_nom_fichier[2])
  
# Nombre de feuilles de chaque classeur
if (protocole == 'bird' || protocole == 'predation') {
      nb_sheet=2
} else {
      nb_sheet=3
}
  
# lecture du classeur
wb <- loadWorkbook(fichier_a_traiter)
  
#### Traitement de la feuille des valeurs de références (la dernière du classeur)

# lecture de la feuille de référence
field <- readWorksheet(wb, sheet = nb_sheet)
# Traduction  en minuscule des noms de colonnes de la table
names(field) <- tolower(names(field)) 
# ajout de _field au nom de la table 
table_name_field <- paste(region,'_field',sep='')

# Destruction de la table stockée dans la BDD
req_field <- paste('DROP TABLE IF EXISTS ',protocole,'.',table_name_field,sep='') 
dbGetQuery(con,req_field) #reponse NULL#
# Insertion de la table dans la BDD
dbWriteTable(con, c(protocole, table_name_field), field, append = T, row.names = F) #reponse [1] TRUE#

#### Traitement des feuilles de données 

# calcul du nombre de feuilles de données
nb_data <- nb_sheet-1
for (j in 1:nb_data) {
    # lecture de(s) feuille(s) de données
    data <- readWorksheet(wb, sheet = j)
    # Traduction en minuscule des noms de colonnes de la table
    names(data) <- tolower(names(data))
    # ajout de _data_ + indice au nom de la table 
    table_name_data <- paste(region,'_data_',j,sep='')
	
    # vérification des données contenues dans la feuille
    verification <- verification_feuille (protocole, table_name_field, table_name_data, data)
      
    if (verification) {
      # Destruction de la table stockée dans la BDD
      req_data <- paste('DROP TABLE IF EXISTS ',protocole,'.',table_name_data,sep='') 
      dbGetQuery(con,req_data)
      # Insertion de la table dans la BDD
      dbWriteTable(con, c(protocole, table_name_data), data, append = T, row.names = F)
    }
}
    
# copie du fichier traité
file.copy(fichier_a_traiter,paste(fichier_a_traiter,'.traite.',Sys.Date(),sep=''),overwrite=TRUE)

# Déconnexion 
deconnect <- disconnect_db(connexion)
