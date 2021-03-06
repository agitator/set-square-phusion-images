#!/bin/bash /usr/local/bin/dry-wit
# Copyright 2014-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME [-v[v]|-q|--quiet] [-u|--user] user [-p|--password] password [[-db|--database] database]? [[-f|--file] file]?
$SCRIPT_NAME [-h|--help]
(c) 2015-today Automated Computing Machinery S.L.
    Distributed under the terms of the GNU General Public License v3
 
Connects to a PostgreSQL server and processes the SQL files in a volume.

Where:
  * -u | --user: the database user. Defaults to "${DEFAULT_DB_USER}".
  * -p | --password: the database password.
  * -db | --database: The database name. Defaults to "${DEFAULT_DB_NAME}".
  * -f | --file: the input file. Optional. If not specified, all files in the mounted /sql volume will be used as input.
Common flags:
    * -h | --help: Display this message.
    * -v: Increase the verbosity.
    * -vv: Increase the verbosity further.
    * -q | --quiet: Be silent.
EOF
}

# Requirements
function checkRequirements() {
  checkReq awk AWK_NOT_INSTALLED;
  checkReq envsubst ENVSUBST_NOT_INSTALLED;
  checkReq tr TR_NOT_INSTALLED;
}

# Error messages
function defineErrors() {
  addError INVALID_OPTION "Unrecognized option";
  addError AWK_NOT_INSTALLED "awk is not installed";
  addError ENVSUBST_NOT_INSTALLED "envsubst is not installed";
  addError TR_NOT_INSTALLED "tr is not installed";
  addError NO_DB_USER_SPECIFIED "The database user cannot be empty";
  addError NO_DB_NAME_SPECIFIED "The database name cannot be empty";
  addError NO_SQL_FOLDER_SPECIFIED "The SQL folder is mandatory";
  addError NO_SQL_FILES_FOUND "No SQL files found in ${SQL_FOLDER}";
  addError SQL_FILE_NOT_FOUND "The specified file does not exist";
  addError SQL_FILE_NOT_READABLE "The specified file is not readable";
  addError SQL_FILE_IS_NOT_A_FILE "The specified file is not a file";
}

## Parses the input
## dry-wit hook
function parseInput() {

  local _flags=$(extractFlags $@);
  local _flagCount;
  local _currentCount;

  # Flags
  for _flag in ${_flags}; do
    _flagCount=$((_flagCount+1));
    case ${_flag} in
      -h | --help | -v | -vv | -q)
         shift;
         ;;
      -u | --user)
         shift;
         DB_USER="${1}";
         shift;
         ;;
      -p | --password)
         shift;
         DB_PASSWORD="${1}";
         shift;
         ;;
      -db | --database)
         shift;
         DB_NAME="${1}";
         shift;
         ;;
      -f | --file)
         shift;
         SQL_FILE="${1}";
         shift;
         ;;
    esac
  done

  if [[ -z ${DB_USER} ]]; then
    DB_USER="${DEFAULT_DB_USER}";
  fi

  if [[ -z ${DB_NAME} ]]; then
    DB_NAME="${DEFAULT_DB_NAME}";
  fi

  # Parameters
  if [[ -z ${SQL_FOLDER} ]]; then
    SQL_FOLDER="$1";
    shift;
  fi
}

## Checking input
## dry-wit hook
function checkInput() {

  local _flags=$(extractFlags $@);
  local _flagCount;
  local _currentCount;
  logDebug -n "Checking input";

  # Flags
  for _flag in ${_flags}; do
    _flagCount=$((_flagCount+1));
    case ${_flag} in
      -h | --help | -v | -vv | -q | --quiet | -u | --user | -p | --password | -db | --database | -f | --file)
         ;;
      *) logDebugResult FAILURE "fail";
         exitWithErrorCode INVALID_OPTION ${_flag};
         ;;
    esac
  done

  if [[ -z ${DB_USER} ]]; then
    logDebugResult FAILURE "fail";
    exitWithErrorCode NO_DB_USER_SPECIFIED;
  fi

  if [[ -z ${DB_NAME} ]]; then
    logDebugResult FAILURE "fail";
    exitWithErrorCode NO_DB_NAME_SPECIFIED;
  fi

  if [[ -z ${SQL_FOLDER} ]]; then
    if [[ -z ${SQL_FILE} ]]; then
      logDebugResult FAILURE "fail";
      exitWithErrorCode NO_SQL_FOLDER_SPECIFIED;
    else
      if [[ -e ${SQL_FILE} ]]; then
        if [[ -r ${SQL_FILE} ]]; then
          if [[ -f ${SQL_FILE} ]]; then
            logDebugResult SUCCESS "valid";
          else
            logDebugResult FAILURE "fail";
            exitWithErrorCode SQL_FILE_IS_NOT_A_FILE;
          fi
        else
          logDebugResult FAILURE "fail";
          exitWithErrorCode SQL_FILE_NOT_READABLE;
        fi
      else
        logDebugResult FAILURE "fail";
        exitWithErrorCode SQL_FILE_NOT_FOUND;
      fi
    fi
  else
    logDebugResult SUCCESS "valid";
  fi
}

## Checks whether given SQL file is marked as processed.
## -> 1: The SQL folder.
## -> 2: The SQL file.
## <- 0 if it's marked as processed already, 1 otherwise.
## Example:
##   if is_sql_file_marked_as_processed /tmp my.sql; then echo "/tmp/my.sql Already processed" ; fi
function is_sql_file_marked_as_processed() {
  local _folder="${1}";
  local _file="${2}";
  local _rescode=0;
  if [ -e "${_folder}"/."${_file}".done ]; then
    _rescode=0;
  else
    _rescode=1;
  fi
  return $?;
}

## Marks given SQL file as processed.
## -> 1: The SQL folder.
## -> 2: The SQL file.
## <- 0 if it's marked successfully, 1 otherwise.
## Example:
##   if ! mark_sql_file_as_processed /tmp my.sql; then echo "Cannot mark SQL file as processed"; fi
function mark_sql_file_as_processed() {
  local _folder="${1}";
  local _file="${2}";
  touch "${_folder}"/."${_file}".done 2> /dev/null
  return $?;
}

## Finds the SQL files in given folder.
## -> 1: The folder
## <- RESULT: A space-separated list of file names (relative to the folder).
## Example:
##   for f in find_sql_files /tmp; do echo "Found SQL: $f"; done
function find_sql_files() {
  local _folder="${1}";
  local _result=();

  for _aux in $(ls -a "${_folder}" | grep -v '^\..*$'); do
    if is_sql_file_marked_as_processed "${_folder}" "${_aux}"; then
      _result[${#_result[@]}]="${_aux}";
    fi
  done
  export RESULT=${_result[@]};
}

## Replaces any placeholders in given file.
## -> 1: The SQL file to process.
## <- 0 if the file is processed, 1 otherwise.
## <- RESULT: the path of the processed file.
function replace_placeholders() {
  local _file="${1}";
  local _rescode;
  createTempFile;
  local _output="${RESULT}";
  local _env="$(IFS=" \t" env | awk -F'=' '{printf("%s=\"%s\" ", $1, $2);}')";
  local _envsubstDecl=$(echo -n "'"; IFS=" \t" env | cut -d'=' -f 1 | awk '{printf("${%s} ", $0);}'; echo -n "'";);

  echo "${_env} envsubst ${_envsubstDecl} < ${_file} > ${_output}" | sh;
  _rescode=$?;
  export RESULT="${_output}";
  return ${_rescode};
}

## Processes given SQL file.
## -> 1: The SQL file to process.
## <- 0 if the file is processed, 1 otherwise.
## Example:
##   if process_sql_file /tmp/my.sql; then echo "Done"; else echo "Failed"; fi
function process_sql_file() {
  local _file="${1}";
  local _inputFile;
  local _logFile;
  logInfo -n "Processing ${_file}";
  if replace_placeholders "${_file}"; then
    _inputFile="${RESULT}";
  else
    _inputFile="${_file}";
  fi
  createTempFile;
  _logFile="${RESULT}";
  if [[ -z ${DB_PASSWORD} ]]; then
    /usr/bin/psql -X -n -h ${DB_HOST} -f ${_file} -o ${_logFile} -U ${DB_USER} -w --dbname=${DB_NAME} 2>&1
  else
    PGPASSWORD="${DB_PASSWORD}" /usr/bin/psql -X -n -h ${DB_HOST} -f ${_file} -o ${_logFile} -U ${DB_USER} --dbname=${DB_NAME} 2>&1
  fi
  if [ $? -eq 0 ]; then
    if ! mark_sql_file_as_processed "$(dirname "${_file}")" "$(basename "${_file}")"; then
      logInfoResult SUCCESS "warning";
      logInfo "Cannot mark ${_file} as processed";
    else
      logInfoResult SUCCESS "done";
    fi
  else
    logInfoResult FAILURE "failed";
    cat ${_logFile};
  fi
}

## Main logic
## dry-wit hook
function main() {
  local _sqlFiles;
  local _atLeastOneFile=${FALSE};

  if [[ -n ${SQL_FILE} ]]; then
    _atLeastOneFile=${TRUE};
    process_sql_file "${SQL_FOLDER}/${SQL_FILE}";
  else
    find_sql_files "${SQL_FOLDER}";
    _sqlFiles="${RESULT}";
    for _file in ${_sqlFiles}; do
      _atLeastOneFile=${TRUE};
      process_sql_file "${SQL_FOLDER}/${_file}";
    done
    if [ ${_atLeastOneFile} -ne ${TRUE} ]; then
      exitWithErrorCode NO_SQL_FILES_FOUND;
    fi
  fi
}
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
