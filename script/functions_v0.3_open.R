# ----------------------------
# GENERAL UTILITY R FUNCTIONS
# author : Juliette Fabre
# creation : 11/2012
# last update : 03/2014
# ----------------------------



# -------------------------------------------------------------------------------------
# POSTGRESQL DATABASE
# -------------------------------------------------------------------------------------

# Connect to a PostgreSQL database by providing connection parameters
# Arguments:
# - dbname: name of the database
# - user: user login
# - password: user password
# - host: name of the host or IP address
# Values:
# - drv: driver object
# - con: PostgreSQL connection
connect_db <- function(dbname, user, password, host)
{
  library(RPostgreSQL)
	drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname = dbname, user = user, password = password, host = host)	
	return(list(drv = drv, con = con))
}


# Disconnect from a database
# Argument: 
# - con: object resulting from the connect_db function
disconnect_db <- function(con)
{
	dbDisconnect(connexion$con)
	dbUnloadDriver(connexion$drv)
}


# Connect to a database via RODBC and set to a specific schema
connect_db_rodbc <- function(schema)
{
	library(RODBC)
	channel <- odbcConnect("", uid = "", pwd = "")
	sqlQuery(channel, paste("SET search_path TO ", schema, sep = ""))
	return(channel)
}


# Return the existing values of a given field from a given table
# Arguments:
# - fields: vector of fields to select, or "*" for all fields
# - table: name of the table
# - schema: name of the schema, optional, default "public"
# - con: object resulting from the connect_db function
get_db_values <- function(fields, table, schema = "public", con)
{
	req <- paste("SELECT ", paste(fields, collapse = ", "), " FROM ", schema, ".", table, sep = "")
	if(length(fields) > 1 || fields == "*") values <- dbGetQuery(con, req) else values <- dbGetQuery(con, req)[[fields]]
	return(values)
}


# Return the field names of a given table
# Arguments:
# - table: name of the table
# - schema: name of the schema, optional, default "public"
# - con: object resulting from the connect_db function
get_db_colnames <- function(table, schema = "public", con)
{
	req <- paste("SELECT column_name FROM information_schema.columns WHERE table_schema = '", schema, "' AND table_name = '", table, "'", sep = "")
	names <- dbGetQuery(con, req)$column_name
	return(names)
}


# Reorganize a dataframe columns depending on the field names of a given table
# Arguments:
# - table: name of the table
# - schema: name of the schema, optional, default "public"
# - con: object resulting from the connect_db function
order_db_colnames <- function(data, table, schema = "public", con) 
{
	data <- data[, get_db_colnames(table, schema)]
	return(data)
}



# -------------------------------------------------------------------------------------
# DATA CHECKING
# These functions check a specific column of a dataframe
# Arguments:
# - col: name or index of the column to check
# - data: dataframe
# - sheet: optional, name of the Excel sheet. Is used to print the sheet concerned in case of Excel data file
# When it makes sense, a supplementary argument can be provided:
# - msg_type: optional, default 'wrong_values', type of message to return. If 'wrong_lines', a string containing the numbers of the problematic lines will be returned. If 'wrong_values', it will be a list with unique wrong values
# Values:
# - res: result of the test: 0 if it failed, 1 otherwise
# - msg: an empty string if the checking succeeded, and an error message if it failed
# -------------------------------------------------------------------------------------

# Check that there isn't any missing value in a given dataframe column
check_no_missing_value <- function(col, data, sheet = "")
{
  msg <- ""
  res <- 1
  if(any(is.na(data[, col]) | as.character(data[, col]) == "")) 
  {
    res <- 0
    if(nchar(sheet)) msg <- paste("'", toupper(sheet), "' : ", sep = "")
    msg <- paste(msg, "La colonne '", col, "' contient des données manquantes, ligne(s) :\n ", paste(as.integer(row.names(data[is.na(data[, col]) | data[, col] == "",])) + 1, collapse = " ; "), ".\n\n", sep = "")
  }
  return(list(res = res, msg = msg))
}


# Check that all values are unique in a given dataframe column
# Supplementary argument:
# - check_consistency: optional, default false. If true, this test actually consists in checking the consistency between the attributes of each individual of the column, and it only changes the returned message (this should be used in case of repetitions of individuals in a column, with other columns containing features of the individuals).
check_unicity <- function(col, data, check_consistency = F, msg_type = "wrong_values", sheet = "")
{
  msg <- ""
  res <- 1
  if(any(table(data[, col]) > 1)) 
  {
    res <- 0
    if(nchar(sheet)) msg <- paste("'", toupper(sheet), "' : ", sep = "")
    if(check_consistency)
    {
      if(msg_type == "wrong_lines") 
      {
        msg <- paste(msg, "La colonne '", col, "' contient des éléments comportant des attributs différents, ligne(s) :\n", paste(as.integer(row.names(data[!is.na(data[, col]) & data[, col] == names(table(data[, col])[table(data[, col]) > 1]), ])) + 1, collapse = "\n"), ".\n\n", sep = "") 
      } else msg <- paste(msg, "La colonne '", col, "' contient des éléments comportant des attributs différents :\n", paste(names(table(data[, col])[table(data[, col]) > 1]), collapse = "\n"), ".\n\n", sep = "") 
    } else if(msg_type == "wrong_lines")
    {
      msg <- paste(msg, "La colonne '", col, "' contient plusieurs données du même nom, ligne(s) :\n", paste(as.integer(row.names(data[!is.na(data[, col]) & data[, col] == names(table(data[, col])[table(data[, col]) > 1]), ])) + 1, collapse = " ; "), ".\n\n", sep = "")
    }	else msg <- paste(msg, "La colonne '", col, "' contient plusieurs données du même nom :\n", paste(names(table(data[, col])[table(data[, col]) > 1]), collapse = " ; "), ".\n\n", sep = "") 
  }
  return(list(res = res, msg = msg))
}


# Check that all values of a given dataframe column belong to a given set
# Supplementary arguments:
# value_set: vector of accepted values
# value_description: textual description of the value set
check_belong <- function(col, data, value_set, value_description = "les valeurs autorisées", msg_type = "wrong_values", sheet = "")
{
  msg <- ""
  res <- 1
  if(any(!is.na(data[, col]) & !data[, col] %in% value_set))
  {
    res <- 0
    if(nchar(sheet)) msg <- paste("'", toupper(sheet), "' : ", sep = "")
    if(msg_type == "wrong_lines")
    {
      msg <- paste(msg, "La colonne '", col, "' contient des données qui n'existent pas dans ", value_description, ", ligne(s) : \n", paste(as.integer(row.names(data[!is.na(data[, col]) & !data[, col] %in% value_set, ])) + 1, collapse = " ; "), ".\n\n", sep = "") 
    } else msg <- paste(msg, "La colonne '", col, "' contient des données qui n'existent pas dans ", value_description, " : \n", paste(unique(data[!is.na(data[, col]) & !data[, col] %in% value_set, col]), collapse = " ; "), ".\n\n", sep = "") 
  }
  return(list(res = res, msg = msg))
}


# Check that a given dataframe column is numeric
check_numeric <- function(col, data, msg_type = "wrong_values", sheet = "")
{
  msg <- ""
  res <- 1
  if(any(!is.na(data[, col]) & is.na(as.numeric(data[, col])))) 
  {
    res <- 0
    if(nchar(sheet)) msg <- paste("'", toupper(sheet), "' : ", sep = "")
    if(msg_type == "wrong_lines")
    {
      msg <- paste(msg, "La colonne '", col, "' contient des données non numériques, ligne(s) :\n ", paste(as.integer(row.names(data[!is.na(data[, col]) & is.na(as.numeric(data[, col])), ])) + 1, collapse = " ; "), ".\n\n", sep = "")
    } else msg <- paste(msg, "La colonne '", col, "' contient des données non numériques :\n ", paste(unique(data[!is.na(data[, col]) & is.na(as.numeric(data[, col])), col]), collapse = " ; "), ".\n\n", sep="")
  } 
  return(list(res = res, msg = msg))
}


# Check that a given dataframe column is integer
check_integer <- function(col, data, msg_type = "wrong_values", sheet = "")
{
  msg <- ""
  res <- 1
  if(any((!is.na(data[, col]) & is.na(as.numeric(data[, col]))) | (!is.na(data[, col]) & !is.na(as.numeric(data[, col])) & round(as.numeric(data[, col])) != as.numeric(data[, col])))) 
  {
    if(nchar(sheet)) msg <- paste("'", toupper(sheet), "' : ", sep = "")
    if(msg_type == "wrong_lines")
    {
      msg <- paste(msg, "La colonne '", col, "' contient des données non entières, ligne(s): \n ", paste(as.integer(row.names(data[(!is.na(data[, col]) & is.na(as.numeric(data[, col]))) | (!is.na(data[, col]) & !is.na(as.numeric(data[, col])) & round(as.numeric(data[, col])) != as.numeric(data[, col])), ])) + 1, collapse = " ; "), ".\n\n", sep = "")
    } else msg <- paste(msg, "La colonne '", col, "' contient des données non entières : \n ", paste(unique(data[(!is.na(data[, col]) & is.na(as.numeric(data[, col]))) | (!is.na(data[, col]) & !is.na(as.numeric(data[, col])) & round(as.numeric(data[, col])) != as.numeric(data[, col])), col]), collapse = " ; "), ".\n\n", sep = "") 
  }
  return(list(res = res, msg = msg))
}


# Check that all values in a given dataframe column respect a maximum number of characters
# Supplementary arguments:
# - nbchar: maximum number of characters
# - test: optional, default 'sup'. If 'equal', the functions tests if the length of each elements of the column is equal to nbchar, otherwise it tests if the length of each elements of the column is superior to nbchar
check_nb_character <- function(col, data, nbchar, test = "sup", msg_type = "wrong_values", sheet = "")
{
  msg <- ""
  res <- 1
  if(test == "equal" & any(nchar(data[, col]) != nbchar & !is.na(data[, col])))
  {
    res <- 0
    if(nchar(sheet)) msg <- paste("'", toupper(sheet), "' : ", sep = "")
    if(msg_type == "wrong_lines")
    {
      msg <- paste(msg, "La colonne '", col, "' contient des données qui ne font pas ", nbchar, " caractères, ligne(s) : \n", paste(as.integer(row.names(data[nchar(data[, col]) != nbchar & !is.na(data[, col]), ])) + 1, collapse = " ; "), ".\n\n", sep = "") 
    } else msg <- paste(msg, "La colonne '", col, "' contient des données qui ne font pas ", nbchar, " caractères : \n", paste(unique(data[nchar(data[, col]) != nbchar & !is.na(data[, col]), col]), collapse = " ; "), ".\n\n", sep = "") 
  }	else if(any(nchar(data[, col]) > nbchar)) 
  {
    res <- 0
    if(nchar(sheet)) msg <- paste("'", toupper(sheet), "' : ", sep  = "")
    if(msg_type == "wrong_lines")
    {
      msg <- paste(msg, "La colonne '", col, "' contient des données de plus de ", nbchar, " caractères, ligne(s) : ", paste(as.integer(row.names(data[nchar(data[, col]) > nbchar, ])) + 1, collapse = " ; "), ".\n\n", sep = "") 
    } else msg <- paste(msg, "La colonne '", col, "' contient des données de plus de ", nbchar, " caractères : \n", paste(unique(data[nchar(data[, col]) > nbchar, col]), collapse = " ; "), ".\n\n", sep = "") 
  }	
  return(list(res = res, msg = msg))
}


# Check that a given dataframe column is date-formatted (yyyy-mm-dd)
# Supplementary argument:
# - year_accepted: optional, default false. Should years be accepted as dates?
check_date <- function(col, data, year_accepted = F, msg_type = "wrong_values", sheet = "")
{
  msg <- ""
  res <- 1
  if(!year_accepted)
  {
    if(any(!is.na(data[, col]) & is.na(strptime(data[, col], "%Y-%m-%d")))) 
    {
      res <- 0
      if(nchar(sheet)) msg <- paste("'", toupper(sheet), "' : ", sep = "")
      if(msg_type == "wrong_lines")
      {
        msg <- paste(msg, "La colonne '", col, "' contient des dates qui ne sont pas au format date, ligne(s) :\n ", paste(as.integer(row.names(data[!is.na(data[, col]) & is.na(strptime(data[, col], "%Y-%m-%d")), ])) + 1, collapse = " ; "), ".\n\n", sep = "") 
      } else msg <- paste(msg, "La colonne '", col, "' contient des dates qui ne sont pas au format date :\n ", paste(unique(data[!is.na(data[, col]) & is.na(strptime(data[, col], "%Y-%m-%d")), col]), collapse = " ; "), ".\n\n", sep = "") 
    }
  } else if(any(!is.na(data[, col]) & is.na(strptime(data[, col], "%Y-%m-%d")) & !is_year(data[, col]))) 
  {
    res <- 0
    if(nchar(sheet)) msg <- paste("'", toupper(sheet), "' : ", sep = "")
    if(msg_type == "wrong_lines")
    {
      msg <- paste(msg, "La colonne '", col, "' contient des dates qui ne sont pas au format date, ligne(s) :\n ", paste(as.integer(row.names(data[!is.na(data[, col]) & is.na(strptime(data[, col], "%Y-%m-%d")) & !is_year(data[, col]), ])) + 1, collapse = " ; "), ".\n\n", sep = "") 
    } else msg <- paste(msg, "La colonne '", col, "' contient des dates qui ne sont pas au format date :\n ", paste(unique(data[!is.na(data[, col]) & is.na(strptime(data[, col], "%Y-%m-%d")) & !is_year(data[, col]), col]), collapse = " ; "), ".\n\n", sep = "") 
  }
  return(list(res = res, msg = msg))
}



# Check that a given dataframe column is datetime-formatted (yyyy-mm-dd HH:MM:SS)
check_datetime <- function(col, data, msg_type = "wrong_values", sheet = "")
{
  msg <- ""
  res <- 1
  if(any(!is.na(data[, col]) & is.na(strptime(data[, col], "%Y-%m-%d %H:%M:%S")))) 
  {
    res <- 0 
    if(nchar(sheet)) msg <- paste("'", toupper(sheet), "' : ", sep = "")
    if(msg_type == "wrong_lines") 
    {
      msg <- paste(msg, "La colonne '", col, "' contient des dates qui ne sont pas au format datetime, ligne(s) :\n ", paste(as.integer(row.names(data[!is.na(data[, col]) & is.na(strptime(data[, col], "%Y-%m-%d %H:%M:%S")), ])) + 1, collapse = " ; "), ".\n\n", sep = "") 
    } else msg <- paste(msg, "La colonne '", col, "' contient des dates qui ne sont pas au format datetime, ligne(s) :\n ", paste(unique(data[!is.na(data[, col]) & is.na(strptime(data[, col], "%Y-%m-%d %H:%M:%S")), col]), collapse = " ; "), ".\n\n", sep = "")
  }
  return(list(res = res, msg = msg))
}



# Check that a given dataframe column is time-formatted (HH:MM:SS)
check_time <- function(col, data, msg_type = "wrong_values", sheet = "")
{
  msg <- ""
  res <- 1
  if(any(!is.na(data[, col]) & is.na(strptime(data[, col], "%H:%M:%S")))) 
  {
    res <- 0 
    if(nchar(sheet)) msg <- paste("'", toupper(sheet), "' : ", sep = "")
    if(msg_type == "wrong_lines") 
    {
      msg <- paste(msg, "La colonne '", col, "' contient des heures qui ne sont pas au format hh:mm:ss, ligne(s) :\n ", paste(as.integer(row.names(data[!is.na(data[, col]) & is.na(strptime(data[, col], "%H:%M:%S")), ])) + 1, collapse = " ; "), ".\n", sep = "") 
    } else msg <- paste(msg, "La colonne '", col, "' contient des heures qui ne sont pas au format hh:mm:ss :\n ", paste(unique(data[!is.na(data[, col]) & is.na(strptime(data[, col], "%H:%M:%S")), col]), collapse = " ; "), ".\n", sep = "") 
  } 
  return(list(res = res, msg = msg))
}


# -------------------------------------------------------------------------------------
# DATA TREATMENT
# -------------------------------------------------------------------------------------

# Remove spaces at the beginning and end of a vector of strings
trim <- function(x) 
{
	gsub("^[[:space:]]+|[[:space:]]+$", "", x)
}	

# Return indices of lines that contain a string s in a dataframe data
get_line <- function(data, s)
{
	return(which(regexpr(s, data) != -1))
}

# Return the content of lines that contain a string s in a dataframe data
get_line_c <- function(data, s)
{
	return(data[which(regexpr(s, data) != -1)])
}

# Return the remaining content after replacement of a string s in all lines that contain s in a dataframe data
get_line_r <- function(data, s)
{
	return(trim(gsub(s, "", get_line_c(data, s))))
}

# Tests if values of a vector look like a year
is_year <- function(x)
{
	options(warn = -1)
	return(is.na(x) | (regexpr("^[0-9]{4}$", x) != -1 & as.numeric(x) <= 3000))
}

# Return a vector of file names without their extension
get_file_without_ext <- function(x)
{
	return(gsub("[.]\\w+$", "", x))
}

# Removes final ".0" from a character vector
remove_final_zero <- function(x)
{
  return(gsub("\\.0$", "", x))
}