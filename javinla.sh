#!/usr/bin/env bash
#
# Install Java Server JREs from Oracle site.
#

#------------------------------------------------------------------------------
# configuration variables
#------------------------------------------------------------------------------
set -o errexit    # abort script at first error
set -o pipefail   # return the exit status of the last command in the pipe
set -o nounset    # treat unset variables and parameters as an error

readonly program=$(basename $0)
readonly version="0.1.0"


#------------------------------------------------------------------------------
# function definitions
#------------------------------------------------------------------------------

function log()   { printf "%b\n" "${@}"; }
function error() { printf "%b\n" "[ERROR] ${@}" 1>&2; exit 1; }
function info()  { printf "%b\n" "[INFO] ${@}"; }

function usage() {
  log "Usage: ${program} COMMAND"
  log ""
  log "Commands:"
  log "    list      List of available java versions to download"
  log "    version   Show the Javinla version information"
  log ""
  exit 1
}

function show_version() {
  log "${program} version: ${version}"
}

function show_list() {
  log "not yet implemented."
}


#------------------------------------------------------------------------------
# SCRIPT ENTRYPOINT
#------------------------------------------------------------------------------
#if [[ $EUID -ne 0 ]]; then
#  error "you cannot perform this operation unless you are root."
#fi

# exit if there are no arguments
if [[ $# -eq 0 ]]; then
  usage
fi

# parse subcommands
subcommand=$1; shift
case "$subcommand" in
  version)
    show_version
    ;;
 
  list)
    show_list
    ;;
  
esac

exit 0

