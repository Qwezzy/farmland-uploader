<?php

class LogLogin extends Login {
	
	public function Test($user="", $pass=""){
		$result = parent::Test($user, $pass);
		
		$log_file = "log.txt";
		if(!file_exists($log_file)){
			$fh = fopen($log_file, 'w') or die("Can't open file");
			fclose($fh);
		}else{
			$fh = fopen($log_file, 'r');
			$content = fread($fh, filesize($log_file));
		}
		$fh = fopen($log_file, 'w') or die("Can't open file");
		if($result){
			$line = "Login " . $user . "\n";
		}else{
			$line = "Wrong: " . $user . "\n";
		}
		fwrite($fh, $content . $line);
		fclose($fh);
		
		return $result;
	}
	
}