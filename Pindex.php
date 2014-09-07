<?php

include("Loginform/Login.php");

$Login = new Login();
$Login->InitXml("Loginform/users.xml");

if($Login->Test("admin", "test")){
	echo "Correct";
}else{
	echo "Incorrect";
}

