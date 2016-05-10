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

declare is_wget_installed="false"
declare is_curl_installed="false"
declare java_version_to_install=""
declare -A java_versions
java_versions[8u11]="http://download.oracle.com/otn-pub/java/jdk/8u11-b12/server-jre-8u11-linux-x64.tar.gz"
java_versions[8u20]="http://download.oracle.com/otn-pub/java/jdk/8u20-b26/server-jre-8u20-linux-x64.tar.gz"
java_versions[8u25]="http://download.oracle.com/otn-pub/java/jdk/8u25-b17/server-jre-8u25-linux-x64.tar.gz"
java_versions[8u31]="http://download.oracle.com/otn-pub/java/jdk/8u31-b13/server-jre-8u31-linux-x64.tar.gz"
java_versions[8u40]="http://download.oracle.com/otn-pub/java/jdk/8u40-b25/server-jre-8u40-linux-x64.tar.gz"
java_versions[8u45]="http://download.oracle.com/otn-pub/java/jdk/8u45-b14/server-jre-8u45-linux-x64.tar.gz"
java_versions[8u51]="http://download.oracle.com/otn/java/jdk/8u51-b16/server-jre-8u51-linux-x64.tar.gz"
java_versions[8u60]="http://download.oracle.com/otn-pub/java/jdk/8u60-b27/server-jre-8u60-linux-x64.tar.gz"
java_versions[8u65]="http://download.oracle.com/otn-pub/java/jdk/8u65-b17/server-jre-8u65-linux-x64.tar.gz"
java_versions[8u66]="http://download.oracle.com/otn-pub/java/jdk/8u66-b17/server-jre-8u66-linux-x64.tar.gz"


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
  if [[ -z "${java_version_to_install}" ]]; then
    error "no version defined"
  fi

  if [[ ${java_versions[${java_version_to_install}]+version_exists} ]]; then
    log ":: Retrieving version ${java_version_to_install}..."
    local download_url="${java_versions[${java_version_to_install}]}"
    local java_tarball="${java_version_to_install}.tar.gz"
    if [[ "${is_curl_installed}" == "true" ]]; then
      download_vith_curl
    elif [[ "${is_wget_installed}" == "true" ]]; then
      download_vith_wget
    fi

    log ":: Extracting tarball..."
    (mkdir -p /opt/java/${java_version_to_install})
    (tar -xzf /tmp/${java_tarball} -C /opt/java/${java_version_to_install} --strip-components=1)
    [[ $? -ne 0 ]] && error "extracting the tarball failed"

    log ":: Configuring environment variables..."
    (ln -sf /opt/java/${java_version_to_install} /opt/java/jre)
    (ln -sf /opt/java/jre/bin/java /usr/local/bin/java)

    log ":: Cleaning..."
    (rm -rf /tmp/${java_tarball})
    (rm -rf /var/log/*)

  else
    error "version not found: ${java_version_to_install}"
  fi
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

function check_preconditions() {
  (command -v curl > /dev/null 2>&1)
  [[ $? -eq 0 ]] && is_curl_installed="true"

  (command -v wget > /dev/null 2>&1)
  [[ $? -eq 0 ]] && is_wget_installed="true"

  if [[ "${is_wget_installed}" == "false" && "${is_curl_installed}" == "false" ]]; then
    error "curl or wget not found."
  fi
}

function download_vith_curl {
  local java_tarball=$1
  local download_url=$2

  cd /tmp
  (curl --location --insecure --junk-session-cookies --output ${java_tarball} \
        --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
        ${download_url})
  [[ $? -ne 0 ]] && error "retrieving version file from Oracle failed"
}

function download_vith_wget {
  local java_tarball=$1
  local download_url=$2

  cd /tmp
  (wget --no-check-certificate --output-document ${java_tarball} \
        --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
        ${download_url})
  [[ $? -ne 0 ]] && error "retrieving version file from Oracle failed"
}


#------------------------------------------------------------------------------
# SCRIPT ENTRYPOINT
#------------------------------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
  error "you cannot perform this operation unless you are root."
fi

# exit if there are no arguments
if [[ $# -eq 0 ]]; then
  show_help
fi

# exit if no curl or wget installed
check_preconditions

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
    # exit if there is no version to install
    if [[ $# -eq 0 ]]; then
      error "specify a java version to install"
    fi

    java_version_to_install=$1; shift
    subcommand_install ${java_version_to_install}
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
