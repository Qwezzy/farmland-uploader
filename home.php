<?php 

// Needed when working with sessions
session_start();

// Variables that is true when the login goes wrong
$login_error = false;

if(isset($_POST['txtusername'])){
	
	// Load the login class en session class
	include("Login.php");
	include("Extensions/SessionLogin.php");
	
	// Create new instance of the SessionLogin class
	// Session login is just a simple extension upon the login class 
	// witch save the username in a session called user
	// This way the user doens't need to login again when reloading the page
	$Login = new SessionLogin();
	
	// Load the users data from users.xml file
	$Login->InitXml("users.xml");
	
	// Check if the submitted information is correct
	if($Login->Test($_POST['txtusername'], $_POST['txtpassword'])){
		
		// Login is correct
		// Do some extra code when login is ok
		// At this moment the session user is set with the username ($_SESSION['user'])
		
	}else{

		// Login is incorrect
		$login_error = true;
		
	}
}

// If action is set to logout then reset the session
// and refresh the page
if(isset($_GET['action']) && $_GET['action'] == "logout"){
	session_destroy();
	header("Location: index.php");
}

?><!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="shortcut icon" href="assets/ico/favicon.ico">

    <title>Farmland Data Uploader</title>

    <!-- Bootstrap core CSS -->
    <link href="css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="css/jumbotron-narrow.css" rel="stylesheet">

    <!-- Just for debugging purposes. Don't actually copy this line! -->
    <!--[if lt IE 9]><script src="../../assets/js/ie8-responsive-file-warning.js"></script><![endif]-->

    <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
      <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
<body>
  
<div class="container">
      <div class="header">
        <ul class="nav nav-pills pull-right">
          <li class="active"><a href="#">Home</a></li>
          <!--<li><a href="maquette/Format traps Solsona formatted_checked.xlsx">Sample Spreadsheet</a></li>-->
         <!-- <li><a href="maquette/Documentation.pdf" target="_blank">Documentation</a></li>-->
          <li><a href="index.php?action=logout">Log out</a></li>
        </ul>
        <h3 class="text-muted">Farmland Uploader</h3>
      </div>

      <div class="jumbotron">
       <p class="lead"> 
       
       <h2>Bienvenue:<?php echo $_SESSION['user']; ?></h2>
       <p>&nbsp;</p><form action="test.php" method="post" accept-charset="utf-8" class="form-inline" enctype="multipart/form-data"><br/><br/>
	      <input name="envoyer" type="submit" formnovalidate class="btn btn-lg btn-success" formaction="teampoistgres.php" value="Query" />   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
           <input type="submit" name="envoyer" class="btn btn-lg btn-success" value="Import" formaction="uploader.php" />
		</form></p>

</div>

      <div class="row marketing"></div>

      <div class="footer">
        <p>&copy; Farmland Biodiversity 2014</p>
      </div>

    </div> <!-- /container -->


   </body>
</html>
