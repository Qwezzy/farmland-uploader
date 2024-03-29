# Script
# ------

# r�cup�erer les arguments
args <- commandArgs(TRUE)

# Positionner dans le bon r�pertoire
setwd=getwd()

# lecture du fichier des fonctions
source('script/functions_v0.3_open.R')
source('script/verification_donnees.R')

# param�tre java
options(java.parameters = "-Xmx1512m")

# libraries
library(RPostgreSQL) # connexion au SGBD postgres
library(XLConnect) # lecture de fichier xls
library(stringr) # traitement de chaine de caract�res

# Connect to farmbiodiv database
connexion <- connect_db("farmbiodiv","quidoz","jpg!pcs","10.8.4.2")
con <- connexion$con

# initialisation 
nb_sheet <- 2 #nb de feuilles du classeur
verification <- F #v�rification ok ou non

# destruction du fichier erreur.txt
if (file.exists('sortie/erreur.txt')) file.remove('erreur.txt')

# Nom du fichier � v�rifier 
nom_fichier <- args[1]

fichier_a_traiter <- paste('donnee/',nom_fichier,sep='')

# r�cup�ration du nom du fichier (1 : Data ; 2 : protocole ; 3 : R�gion ; 4 : formatted)
structure_nom_fichier <- unlist (strsplit(nom_fichier, '_'))

# Recup�ration des noms des tables de donn�es
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
  
#### Traitement de la feuille des valeurs de r�f�rences (la derni�re du classeur)

# lecture de la feuille de r�f�rence
field <- readWorksheet(wb, sheet = nb_sheet)
# Traduction  en minuscule des noms de colonnes de la table
names(field) <- tolower(names(field)) 
# ajout de _field au nom de la table 
table_name_field <- paste(region,'_field',sep='')

# Destruction de la table stock�e dans la BDD
req_field <- paste('DROP TABLE IF EXISTS ',protocole,'.',table_name_field,sep='') 
dbGetQuery(con,req_field) #reponse NULL#
# Insertion de la table dans la BDD
dbWriteTable(con, c(protocole, table_name_field), field, append = T, row.names = F) #reponse [1] TRUE#

#### Traitement des feuilles de donn�es 

# calcul du nombre de feuilles de donn�es
nb_data <- nb_sheet-1
for (j in 1:nb_data) {
    # lecture de(s) feuille(s) de donn�es
    data <- readWorksheet(wb, sheet = j)
    # Traduction en minuscule des noms de colonnes de la table
    names(data) <- tolower(names(data))
    # ajout de _data_ + indice au nom de la table 
    table_name_data <- paste(region,'_data_',j,sep='')
	
    # v�rification des donn�es contenues dans la feuille
    verification <- verification_feuille (protocole, table_name_field, table_name_data, data)
      
    if (verification) {
      # Destruction de la table stock�e dans la BDD
      req_data <- paste('DROP TABLE IF EXISTS ',protocole,'.',table_name_data,sep='') 
      dbGetQuery(con,req_data)
      # Insertion de la table dans la BDD
      dbWriteTable(con, c(protocole, table_name_data), data, append = T, row.names = F)
    }
}
    
# copie du fichier trait�
file.copy(fichier_a_traiter,paste(fichier_a_traiter,'.traite.',Sys.Date(),sep=''),overwrite=TRUE)

# D�connexion 
deconnect <- disconnect_db(connexion)
