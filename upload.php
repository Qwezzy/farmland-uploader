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
    <link href="css/bootstrap.css" rel="stylesheet" />
    <link href="css/tQera.Uploader.Bootstrap.css" rel="stylesheet" />
    <link href="css/app.css" rel="stylesheet" />

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
          <li class="active"><a href="home.php">Home</a></li>
          <!--<li><a href="maquette/Format traps Solsona formatted_checked.xlsx">Sample Spreadsheet</a></li>-->
         <!-- <li><a href="maquette/Documentation.pdf" target="_blank">Documentation</a></li>-->
          <li><a href="index.php?action=logout">Log out</a></li>
        </ul>
        <h3 class="text-muted">Farmland Uploader</h3>
      </div>

      <div class="jumbotron">
       <p class="lead"> 
       
       <h2>Bienvenue:<?php echo $_SESSION['user']; ?></h2>
       <p>&nbsp;</p>
       <form action="test.php" method="post" accept-charset="utf-8" enctype="multipart/form-data" class="row-fluid" id="dropper">
        <div class="text-center">
            <input id="fileInput" name="fileInput" type="file" class="btn btn-file hide" multiple />
        </div>
        <div style="padding-bottom: 20px">
        </div>
        <div class="row-fluid text-center">
            <div class="span12 drop-zone" id="dropPlace">
            </div>
            <button type="submit" class="btn btn-success"><i class="icon-white icon-arrow-up"></i>Envoyer le fichier</button>
        </div>
        <div class="row-fluid images" id="imageHolder">
        </div>
    </form></p>

</div>

      <div class="row marketing"></div>
      
<script type="text/javascript" src="js/jquery-1.9.1.min.js"></script>
  <script type="text/javascript" src="js/tQera.Image.Uploader.js"></script>
    <script type="text/javascript" src="js/bootstrap.js"></script>
    <script>
        var d = new tQEraUploader(
{
    drop: true,
    imageHolder: document.getElementById("imageHolder"),
    dragHoverClass: "drop_hover",
    image_thumb_width: 128,
    image_thumb_height: 128,
    dropPlace: document.getElementById("dropPlace"),
    form: document.getElementById("dropper"),
    fileInput: document.getElementById("fileInput"),
    file_closebutton_class: "btn btn-danger close",
    file_class: "list-i",
    file_filter: "",
    image_thumb: false,
	icon_path: "FileIcons/",
			icon_default: "FileIcons/_blank.png",
    limit: 0,
    ajax: {
        url: 'Handler.php',
        clearAfterUpload: true
    },
    watermark: {
        text: ""
    },
    html5Error:
        function (uploader) {

            uploader.settings.imageHolder.style.display = "none";
            //document.getElementById("dropper").removeChild(imageholder);

            uploader.settings.dropPlace.style.display = "none";
            var error = document.createElement("p");
            error.className = "text-center";
            error.appendChild(document.createTextNode("Your browser doesn't support HTML5, we can offer you a new browser from here ! click!"));
            uploader.settings.form.appendChild(error);
        },
    progress:
                 function (data) {
                     var template = document.getElementById(data.template);
                     console.log(data.template);
                     if (template) {
                         var progress = document.getElementById("progress_" + data.template);

                         if (progress) {
                             progress.style.width = data.percent + "%";
                         }
                         else {
                             var div = document.createElement("div");
                             div.className = "progress progress-striped active";

                             progress = document.createElement("div");
                             progress.id = "progress_" + data.template;
                             progress.className = "bar";
                             progress.style.width = data.percent + "%";
                             div.appendChild(progress);

                             template.appendChild(div);
                         }
                     }

                 },
    success:
        function (event) {
            console.log("Its uploaded ");
        }
});
    </script>
      <div class="footer">
        <p>&copy; Farmland Biodiversity 2014</p>
      </div>

    </div> <!-- /container -->


   </body>
</html>
