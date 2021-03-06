#!/bin/bash dry-wit
# Copyright 2015-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME locale encoding
$SCRIPT_NAME [-h|--help]
(c) 2016-today Automated Computing Machinery S.L.
    Distributed under the terms of the GNU General Public License v3

Installs given locale.

Where:
  - locale: The locale to install (en_US.UTF-8, es_ES.ISO-8859-1, ...).
  - encoding: The encoding (UTF-8, ISO-8859-1, ...)

Common flags:
    * -h | --help: Display this message.
    * -v: Increase the verbosity.
    * -vv: Increase the verbosity further.
    * -q | --quiet: Be silent.
EOF
}

# Requirements
function defineRequirements() {
  checkReq locale-gen "LOCALEGEN_IS_NOT_INSTALLED";
  checkReq apt-get "APTGET_IS_NOT_INSTALLED";
}

## Defines the errors
## dry-wit hook
function defineErrors() {
  addError "INVALID_OPTION" "Unrecognized option";
  addError "LOCALEGEN_IS_NOT_INSTALLED" "locale-gen is not installed";
  addError "APTGET_IS_NOT_INSTALLED" "apt-get is not installed";
  addError "TARGET_LOCALE_IS_MANDATORY" "The locale parameter is mandatory";
  addError "TARGET_ENCODING_IS_MANDATORY" "The encoding parameter is mandatory";
}

## Validates the input.
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
      -h | --help | -v | -vv | -q)
         shift;
         ;;
      *) logDebugResult FAILURE "failed";
         exitWithErrorCode INVALID_OPTION;
         ;;
    esac
  done

  if isEmpty "${TARGET_LOCALE}"; then
    logDebugResult FAILURE "failed";
    exitWithErrorCode TARGET_LOCALE_IS_MANDATORY;
  elif isEmpty "${TARGET_ENCODING}"; then
      logDebugResult FAILURE "failed";
      exitWithErrorCode TARGET_ENCODING_IS_MANDATORY;
  else
    logDebugResult SUCCESS "valid";
  fi
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
    esac
  done

  if isEmpty "${TARGET_LOCALE}"; then
      TARGET_LOCALE="${1}";
      shift;
  fi

  if isEmpty "${TARGET_ENCODING}"; then
      TARGET_ENCODING="${1}";
  fi
}

## Checks if given locale identifier is supported.
## -> *: The locale identifier.
## <- 0/${TRUE} if the locale is supported; 1/${FALSE} otherwise.
## Example:
##  if is_locale_supported "en_US" "UTF-8"; then
##    echo "en_US with UTF-8 is supported"
##  fi
function is_locale_supported() {
  local _locale="${1}";
  local _encoding="${2}";
  local -i _rescode;

  checkNotEmpty "locale" "${_locale}" 1;
  checkNotEmpty "encoding" "${_encoding}" 2;

#  _debugEcho "${SUPPORTED_LOCALES_FOLDER}/${_locale%%_*}";

  if [ -f ${SUPPORTED_LOCALES_FOLDER}/${_locale%%_*} ]; then
      if is_locale_file_available "${_locale}"; then
          if is_locale_available_in_language_file "${_locale}" "${_encoding}"; then
              _rescode=${TRUE};
          else
            _rescode=${FALSE};
#            _debugEcho "not is_locale_available_in_language_file ${_locale} ${_encoding}"
          fi
      else
        _rescode=${FALSE};
#        _debugEcho "not is_locale_file_available ${_locale}"
      fi
  else
    _rescode=${FALSE};
#    _debugEcho "not -f ${SUPPORTED_LOCALES_FOLDER}/${_locale%%_*}"
  fi

  return ${_rescode};
}

## Checks if the locale file is available.
## -> 1: The locale.
## <- 0/${TRUE} if the locale file exists; 1/${FALSE} otherwise.
## Example:
##  if is_locale_file_available "en_US"; then
##    echo "English-US is available"
##  fi
function is_locale_file_available() {
  local _locale="${1}";
  local -i _rescode;

  checkNotEmpty "locale" "${_locale}" 1;

  if [ -f ${AVAILABLE_LOCALES_FOLDER}/${_locale} ]; then
      _rescode=${TRUE};
  else
    _rescode=${FALSE};
  fi

  return ${_rescode};
}

## Checks if locale requires appending the encoding or not.
## -> 1: the locale.
## -> 2: the encoding.
## <- 0/${TRUE} if the locale requires the encoding suffix; 1/${FALSE} otherwise.
## Example:
##    if locale_requires_encoding_suffix "${locale}" "${encoding}"; then
##      locale Definition="${locale}.${encoding}";
##    fi
function locale_requires_encoding_suffix() {
  local _locale="${1}";
  local _encoding="${2}";
  local -i _rescode;

  checkNotEmpty "locale" "${_locale}" 1;
  checkNotEmpty "encoding" "${_encoding}" 2;

  grep "${_locale}.${_encoding} ${_encoding}" "${SUPPORTED_LOCALES_FILE}" > /dev/null 2>&1;
  _rescode=$?;

  return ${_rescode};
}

## Checks if given locale + encoding is supported.
## -> 1: The locale.
## -> 2: The encoding.
## <- 0/${TRUE} if the language is supported; 1/${FALSE} otherwise.
## <- RESULT: The supported locales.
## Example:
##  is_locale_available_in_language_file "en_US" "UTF-8";
##  echo "Supported English locales: ${RESULT}";
function is_locale_available_in_language_file() {
  local _locale="$1";
  local _encoding="$2";
  local -i _rescode;
  local _language;

  checkNotEmpty "locale" "${_locale}" 1;
  checkNotEmpty "encoding" "${_encoding}" 2;

  if is_locale_file_available "${_locale}"; then
      if locale_requires_encoding_suffix "${_locale}" "${_encoding}"; then
          _rescode=${TRUE}; # Implicit since it greps the same file.
      else
        grep "${_locale} ${_encoding}" ${SUPPORTED_LOCALES_FILE} > /dev/null 2>&1;
        _rescode=$?;
      fi
  else
#    _debugEcho "not is_locale_file_available"
    _rescode=${FALSE};
  fi

  return ${_rescode};
}

## Installs given locale.
## -> 1: The locale.
## <- 0/${TRUE} if the locale is installed; 1/${FALSE} otherwise.
## Example:
##   if install_locale "en_US UTF-8"; then
##     echo "Locale en_US UTF-8 installed successfully";
##   fi
function install_locale() {
  local _locale="${1}";
  local _encoding="${2}";
  local _rescode=${FALSE};

  checkNotEmpty "locale" "${_locale}" 1;
  checkNotEmpty "encoding" "${_encoding}" 2;

  local _lang="${_locale%_*}";

  logInfo -n "Checking if ${_locale} is already installed";
  if is_locale_supported "${_locale}" "${_encoding}"; then
      logInfoResult SUCCESS "installed";
  else
    logInfoResult SUCCESS "missing";
    DEBIAN_FRONTEND="noninteractive" apt-get install -y --reinstall language-pack-${_lang}-base
  fi
  logInfo -n "Checking if ${_locale} ${_encoding} is supported";
  if is_locale_supported "${_locale}" "${_encoding}"; then
      logInfoResult SUCCESS "valid";
      if locale_requires_encoding_suffix "${_locale}" "${_encoding}"; then
          logInfo "Generating '${_locale}.${_encoding} ${_encoding}' locale";
          echo "${_locale}.${_encoding} ${_encoding}" >> ${LOCALEGEN};
          locale-gen "${_locale}.${_encoding}"
      else
        logInfo "Generating '${_locale} ${_encoding}' locale";
        echo "${_locale} ${_encoding}" >> ${LOCALEGEN};
        locale-gen "${_locale}"
      fi
#      dpkg-reconfigure locales
      localepurge
      _rescode=${TRUE};
  else
    logInfoResult FAILURE "unsupported";
  fi

  return ${_rescode};
}

## Main logic
## dry-wit hook
function main() {
  install_locale "${TARGET_LOCALE}" "${TARGET_ENCODING}";
}
