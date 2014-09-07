<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Bootstrap demo</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="" />
    <meta name="author" content="" />
	<link href="css/bootstrap.css" rel="stylesheet" />
    <link href="css/tQera.Uploader.Bootstrap.css" rel="stylesheet" />
    <link href="css/app.css" rel="stylesheet" />
</head>
<body>
    <div class="container">
        <div class="masthead">
            <div class="navbar">
                <div class="navbar-inner">
                   <div class="header">
        <ul class="nav nav-pills pull-right">
          <li class="active"><a href="#">Home</a></li>
          <!--<li><a href="maquette/Format traps Solsona formatted_checked.xlsx">Sample Spreadsheet</a></li>-->
         <!-- <li><a href="maquette/Documentation.pdf" target="_blank">Documentation</a></li>-->
          <li><a href="index.php?action=logout">Log out</a></li>
        </ul>
        <h3 class="text-muted">Farmland Uploader</h3>
      </div><!-- <div class="container">
                        <ul class="nav">
                            <li class="active"><a href="Bootstrap.html">Default - Full Plugin</a> </li>	
                        </ul>
                    </div>-->
                </div>
            </div>
        </div>
        <div class="intro">
            <h1>Soumission d'un jeu de données</h1>
        </div>
        
		 <form class="row-fluid" id="dropper">
        <div class="text-center">
            <input id="fileInput" name="fileInput" type="file" class="btn btn-file hide" multiple />
        </div>
        <div style="padding-bottom: 20px">
        </div>
        <div class="row-fluid text-center">
            <div class="span12 drop-zone" id="dropPlace">
            </div>
            <button type="submit" class="btn btn-success"><i class="icon-white icon-arrow-up"></i>Start Upload</button>
        </div>
        <div class="row-fluid images" id="imageHolder">
        </div>
    </form>
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

		
        <hr />
        <div class="footer">
            <p>
                &copy; Farmland Biodiversity 2014</p>
        </div>
    </div>

</body>
</html>
