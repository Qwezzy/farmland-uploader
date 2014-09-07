<?php

error_reporting(E_ALL);

/*
$Login = new Login();
$Login->InitDatabase("10.0.100.55", "root", "DMaX", "wiki", "wp_users", "user_login", "user_pass");
$Login->SetPasswordEncoder("custom");
if($Login->Test("admin", "test")){
	echo "Login ok";
}else{
	echo $Login->GetError() . "<br />";
	echo "Login fout";
}

function custom($password, $fields=""){
	return md5($password . $fields->user_nicename);
}*/


/**
 * Universal login class
 *
 */
class Login {
	
	/**
	 * Error messages
	 */
	const ERROR_EMPTY_FIELD = "Make sure you fill username and password field.";
	const ERROR_WRONG_LOGIN	= "Your username or password was incorrect.";
	
	/**
	 * Characters that is used in CSV to separate fields
	 *
	 * @var string
	 */
	const CSV_SEPARATOR = ";";
	
	/**
	 * Datasources
	 */
	const SOURCE_CSV	= "csv";
	const SOURCE_XML	= "xml";
	const SOURCE_DB		= "db";
	
	/**
	 * Array that holds usernames and passwords
	 *
	 * @var array
	 */
	private $_users = array();
	
	/**
	 * String that holds the current error
	 * 
	 * @var string
	 */
	private $_error_string = "";
	
	/**
	 * String that holds the current datasource
	 * 
	 * @var string
	 */
	private $_datasource = "";
	
	/**
	 * Encoding function for the password
	 * 
	 * @var string
	 */
	private $_pass_encoding_func = "";
	
	/**
	 * Database connection
	 * 
	 * @var resource
	 */
	private $_database = "";
	
	/**
	 * Database user table info
	 *
	 * @var string
	 */
	private $_database_table = "";
	private $_database_user_field = "";
	private $_database_pass_field = "";
	
	public function __construct(){}
	
	/**
	 * Use database as datasource
	 *
	 * @param string $host
	 * @param string $user
	 * @param string $pass
	 * @param string $database
	 * @param string $table
	 * @param string $user_field
	 * @param string $pass_field
	 * @param int $port
	 * @return bool
	 */
	public function InitDatabase($host, $user, $pass, $database, $table, $user_field, $pass_field, $port=3306){
		$this->_datasource = Login::SOURCE_DB;
		$link = mysql_connect($host . ":" . $port, $user, $pass);
		if (!$link) {
		    trigger_error("Could not connect to MySQL server.", E_USER_ERROR);
		    return false;
		}
		if(!mysql_select_db($database,$link)){
			 trigger_error("Could not select MySQL database " . $database . ".", E_USER_ERROR);
			 return false;
		}
		$this->_database_table = $table;
		$this->_database_user_field = $user_field;
		$this->_database_pass_field = $pass_field;
		$this->_database = $link;
		return true;
	}
	
	/**
	 * Use XML file as datasource
	 *
	 * @param string $file
	 * @return void
	 */
	public function InitXml($file){
		$this->_datasource = Login::SOURCE_XML;
		$this->readFile($file, "xml");
	}
	
	/**
	 * Use Csv file as datasource
	 *
	 * @param string $file
	 * @return void
	 */
	public function InitCsv($file){
		$this->_datasource = Login::SOURCE_CSV;
		$this->readFile($file, "csv");
	}
	
	/**
	 * Select function to encode/hash the password
	 *
	 * @param string $function
	 * @return bool;
	 */
	public function SetPasswordEncoder($function="md5"){
		if($function != "" && function_exists($function)){
			$this->_pass_encoding_func = $function;
			return true;
		}else{
			trigger_error("This encoding function can't be used.", E_USER_WARNING);
			return false;
		}
	}
	
	/**
	 * Test if login data is correct
	 *
	 * @param string $user
	 * @param string $pass
	 * @return bool/object
	 */
	public function Test($user="", $pass=""){
		if(!empty($user) && !empty($pass)){
			return $this->tryLogin($user, $pass);
		}else{
			$this->_error_string = Login::ERROR_EMPTY_FIELD;
			return false;
		}
	}
	
	/**
	 * Get error string if something has gone wrong
	 *
	 * @return string/bool
	 */
	public function GetError(){
		if(!empty($this->_error_string)){
			return $this->_error_string;
		}
		return false;
	}
	
	/**
	 * Load data from file
	 *
	 * @param string $file
	 * @param string $type
	 */
	private function readFile($file, $type="xml"){
		
		// Read content of the file
		$fh = fopen($file, 'r');
		$content = fread($fh, filesize($file));
		fclose($fh);
		
		if($type=="xml"){
			$Xml = simplexml_load_string($content);
			foreach ($Xml->user as $user){
				$this->_users[] = array("username" => trim($user->username), "password" => trim($user->password));
			}
		}else{
			$lines = explode("\n", $content);
			foreach ($lines as $line){
				$parts = explode(Login::CSV_SEPARATOR , $line);
				if(isset($parts[0]) && isset($parts[1])){
					$this->_users[] = array("username" => trim($parts[0]), "password" => trim($parts[1]));
				}
			}
		}

	}
	
	/**
	 * Try to do a login
	 *
	 * @param string $username
	 * @param string $password
	 * @return bool/object
	 */
	private function tryLogin($username, $password){
		
		// Send error if there is not datasource set
		if(empty($this->_datasource)) trigger_error("There is no datasource set (Database/Xml/Csv)", E_USER_ERROR);

		switch ($this->_datasource){
			case Login::SOURCE_DB:
				$query = "SELECT * FROM " . $this->_database_table . " WHERE " . $this->_database_user_field . "='" . mysql_real_escape_string($username) . "'";
				$result = mysql_query($query);
				while($data = mysql_fetch_object($result)){
					if(!empty($this->_pass_encoding_func)){
						$password = $this->passwordEncoding($password, $data);
					}
					$pass_field = $this->_database_pass_field;
					if($data->$pass_field == $password) return $data;
				}
				break;
			case Login::SOURCE_CSV:
			case Login::SOURCE_XML:
				
				// Encode password
				if(!empty($this->_pass_encoding_func)){
					$password = $this->passwordEncoding($password);
				}
				foreach ($this->_users as $user){
					if($user['username'] == $username && $user['password'] == $password){
						return true;
					}
				}
				break;
		}
		$this->_error_string = Login::ERROR_WRONG_LOGIN;
		return false;
	}
	
	/**
	 * Get current url
	 * 
	 * @return string
	 */
	private function currentUrl(){
		return "http://" . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'];
	}
	
	/**
	 * Call password encoding
	 * 
	 * @param string $password
	 * @param array/object $data
	 * @return string
	 */
	private function passwordEncoding($password, $data=null){
		if(in_array($this->_pass_encoding_func, array("md5", "sha1"))){
			return call_user_func_array($this->_pass_encoding_func, array($password));
		}else{
			return call_user_func_array($this->_pass_encoding_func, array($password, $data));
		}
	}
	
}