#!/bin/bash dry-wit
# Copyright 2015-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME
$SCRIPT_NAME [-h|--help]
(c) 2015-today Automated Computing Machinery S.L.
    Distributed under the terms of the GNU General Public License v3

Backs up a given VOLUME.

Common flags:
    * -h | --help: Display this message.
    * -v: Increase the verbosity.
    * -vv: Increase the verbosity further.
    * -q | --quiet: Be silent.
EOF
}

## Defines the errors
## dry-wit hook
function defineErrors() {
  export INVALID_OPTION="Unrecognized option";

  ERROR_MESSAGES=(\
    INVALID_OPTION \
  );

  export ERROR_MESSAGES;
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

  logDebugResult SUCCESS "valid";
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
}

## Processes the volumes from a given Dockerfile.
## -> 1: the Dockerfile.
## Example:
##   process_volumes /Dockerfiles/Dockerfile
function process_volumes() {
  local _dockerfile="${1}";
  local _aux;
  local _single;
  grep -e '^\s*VOLUME\s' "${_dockerfile}" > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    local _oldIFS="${IFS}";
    IFS=$'\n';
    for _aux in $(grep -e '^\s*VOLUME\s' "${_dockerfile}" 2> /dev/null | cut -d' ' -f 2- | sed -e 's/^ \+//g'); do
      IFS="${_oldIFS}";
      logInfo -n "Backing up ${_aux} to ${SQ_IMAGE}-backup";
      /usr/local/bin/backup-folder.sh "${_aux}" "${_aux}";
      logInfoResult SUCCESS "done";
    done
  fi
}

## Main logic
## dry-wit hook
function main() {
  if    [[ -z "${DOBACKUP}" ]] \
     || [[ "${DOBACKUP}" != "true" ]]; then
    logDebug "Backup disabled";
  else
    for p in $(ls ${DOCKERFILES_LOCATION} | grep -v -e '^Dockerfile'); do
      process_volumes "${DOCKERFILES_LOCATION}/${p}";
    done
  fi
}
