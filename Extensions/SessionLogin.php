<?php

class SessionLogin extends Login {
	
	public function Test($user="", $pass=""){
		$result = parent::Test($user, $pass);
		
		if($result){
			$_SESSION['user'] = $user;
		}else{
			$_SESSION['user'] = "";
		}
		
		return $result;
	}
	
}