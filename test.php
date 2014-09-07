<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>Test FarmLand</title>
	<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
	<meta name="description" content="DESCRIPTION DU SITE ICI"/>
	<meta name="keywords" content="MOTS CLES DU SITE ICI"/> 
	<meta name="author" content=""/> 
</head>

<body>

<?php
	$dossier = 'donnee/';
	$fichier = basename($_FILES['nom_fichier']['name']);
	$taille_maxi = 100000;
	$taille = filesize($_FILES['nom_fichier']['size']);
	$extensions = array('.xls', '.xlsx');
	$extension = strrchr($_FILES['nom_fichier']['name'], '.'); 
	//Début des vérifications de sécurité...
	if(!in_array($extension, $extensions)) //Si l'extension n'est pas dans le tableau
	{
		$erreur = 'Vous devez uploader un fichier de type xls ou xlsx';
	}
	if($taille>$taille_maxi) //Si le fichier est trop gros
	{
		$erreur = 'Le fichier est trop gros...';
	}
	if(!isset($erreur)) //S'il n'y a pas d'erreur, on upload
	{
		//On formate le nom du fichier ici...
		$fichier = strtr($fichier, 
			'ÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÝàáâãäåçèéêëìíîïðòóôõöùúûüýÿ', 
			'AAAAAACEEEEIIIIOOOOOUUUUYaaaaaaceeeeiiiioooooouuuuyy');
		$fichier = preg_replace('/([^.a-z0-9]+)/i', '_', $fichier);
		if(move_uploaded_file($_FILES['nom_fichier']['tmp_name'], $dossier . $fichier)) //Si la fonction renvoie TRUE, c'est que ça a fonctionné...
		{
			// Upload effectué avec succès ! le script R est en cours d execution
			exec("script/lecture_donnees.R ".$fichier, $out, $error);
			//le script R est terminé mais dans quel état			
			
			if(!empty($error)) //le script R a rencontré un problème
			{	
				echo 'Le script R a rencontré un problème. Contacter votre administrateur';
				// echo "error : ".$error; Juliette
			} else if(file_exists('sortie/erreur.txt')) //des erreurs exixtent dans la base
					{
						echo 'Les données n ont pas été validées, lisez le fichier "erreur" disponible sur';
						echo 'sortie/erreur.txt';
					} else 
					{
						echo 'Fichier de donnée inséré avc succès';
						//echo "out :"; Juliette
						//print_r($out);	
					}
		} else //Sinon (la fonction renvoie FALSE)
		{
			echo 'Le fichier n a pas été transféré';
		}
	} else
	{
		echo $erreur;
	}
?>

</body>
</html>
