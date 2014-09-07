verification_feuille <- function (protocole,reference,table,donnees)
{ 
	# initialisation 
	verif <- FALSE #vérification ok ou non
  
	if (protocole == 'bird' && table == 'solsona_data_1') {

	# verification des colonnes 
		for(var in names(donnees))
		{
			# Requete pour aller chercher les valeurs autorisées de visit.number dans la BDD
			req <- paste('SELECT DISTINCT "', var, '" FROM ',protocole,'.',reference,' WHERE "', var, '" IS NOT NULL',sep='') 
			valeurs_autorisees <- dbGetQuery(con,req)          
			# vérifier que les valeurs de variable sont bons
			resultat <- check_belong (var,donnees,valeurs_autorisees[[var]])
			if(!resultat$res) write.table(resultat$msg,file='sortie/erreur.txt',append = T, row.names = F, col.names = F, quote = F)
			verif <- verif && resultat$res
		}

    
	  # Create datetime column with date and corrected time (time + 51 minutes)
	  #donnees$datetime <-paste(as.character(donnees$date), substr(as.character(donnees$time + 51*60), 12, 19))
	
	  # extrait les lignes et les colonnes Region, Landscape, Sampling.site, Visit.number et Datetime du tableau de données
	  #rlsv <- unique(donnees[, c("region", "landscape", "sampling.site", "visit.number", "datetime")])
	
	  # parcours du tableau pour tester : unique datetime for each region/landscape/site/visit
	  #for(region in unique(rlsv$region))
	  #{
	  # donnees_r <- subset(rlsv, region == region) 
	  #  for(landscape in unique(donnees_r$landscape))
	 #   {
	  #    donnees_l <- subset(donnees_r, landscape == landscape) 
	   #   for(site in unique(donnees_l$sampling.site))
	   #   {
	   #     donnees_s <- subset(donnees_l, sampling.site == site) 
	   #   	for(visit in unique(donnees_s$visit.number))
	   #     {
	   #   	  donnees_v <- subset(donnees_s, visit.number == visit)
	   #       # Check if there is a unique datetime for each region/landscape/site/visit
	   #       if(nrow(donnees_v) > 1) print(paste("Different datetimes for (region, landscape, site, visit) : ", region, landscape, site, visit))     
	   #     }    
	   #     # Check if dates of visit are different for each region/landscape/site
	   #     if(length(donnees_s$datetime) > length(unique(donnees_s$datetime))) print(paste("There are visits with same datetimes for (region, landscape, site) : ", region, landscape, site))    
	   #   }
	   # }
#	  }
  }
return(verif) 
}

