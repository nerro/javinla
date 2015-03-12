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

declare -A java_versions
java_versions[8u11]="http://download.oracle.com/otn-pub/java/jdk/8u11-b12/server-jre-8u11-linux-x64.tar.gz"
java_versions[8u20]="http://download.oracle.com/otn-pub/java/jdk/8u20-b26/server-jre-8u20-linux-x64.tar.gz"
java_versions[8u25]="http://download.oracle.com/otn-pub/java/jdk/8u25-b17/server-jre-8u25-linux-x64.tar.gz"
java_versions[8u31]="http://download.oracle.com/otn-pub/java/jdk/8u31-b13/server-jre-8u31-linux-x64.tar.gz"
java_versions[8u40]="http://download.oracle.com/otn-pub/java/jdk/8u40-b25/server-jre-8u40-linux-x64.tar.gz"


#------------------------------------------------------------------------------
# function definitions
#------------------------------------------------------------------------------

function log()   { printf "%b\n" "${@}"; }
function error() { printf "%b\n" "[ERROR] ${@}" 1>&2; exit 1; }
function info()  { printf "%b\n" "[INFO] ${@}"; }

function show_help() {
  log "Usage: ${program} COMMAND"
  log ""
  log "Commands:"
  log "    install   Install the specified java version from Oracle site"
  log "    list      List of available java versions to download"
  log "    version   Show the Javinla version information"
  log ""
  exit 1
}

function subcommand_install() {
  log "not implemented yet"
}

function subcommand_list() {
  log "VERSION NUMBER\t\tURL"
  for java_version in "${!java_versions[@]}"; do
    log "${java_version}\t\t\t${java_versions["${java_version}"]}"
  done | sort
}

function subcommand_version() {
  log "${program} version: ${version}"
}


#------------------------------------------------------------------------------
# SCRIPT ENTRYPOINT
#------------------------------------------------------------------------------
#if [[ $EUID -ne 0 ]]; then
#  error "you cannot perform this operation unless you are root."
#fi

# exit if there are no arguments
if [[ $# -eq 0 ]]; then
  show_help
fi

# parse options to the `javinla` command
while getopts ":h" opt; do
  case ${opt} in
    h)
      show_help
      ;;

    \?)
      error "flag provided but not defined: -$OPTARG\nSee '${program} -h'"
      ;;
  esac
done
shift $((OPTIND-1))

# parse subcommands
subcommand=$1; shift
case "$subcommand" in
  install)
    subcommand_install
    ;;

  list)
    subcommand_list
    ;;

  version)
    subcommand_version
    ;;

  *)
    error "'${subcommand}' is not a javinla command. See '${program} -h'."
    ;;

esac

exit 0

