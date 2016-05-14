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
readonly version="0.2.0"
readonly oraclelicence_header="Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie"

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
java_versions[8u71]="http://download.oracle.com/otn/java/jdk/8u71-b15/server-jre-8u71-linux-x64.tar.gz"
java_versions[8u72]="http://download.oracle.com/otn/java/jdk/8u72-b15/server-jre-8u72-linux-x64.tar.gz"
java_versions[8u73]="http://download.oracle.com/otn/java/jdk/8u73-b02/server-jre-8u73-linux-x64.tar.gz"
java_versions[8u74]="http://download.oracle.com/otn/java/jdk/8u74-b02/server-jre-8u74-linux-x64.tar.gz"
java_versions[8u77]="http://download.oracle.com/otn/java/jdk/8u77-b03/server-jre-8u77-linux-x64.tar.gz"
java_versions[8u91]="http://download.oracle.com/otn-pub/java/jdk/8u91-b14/server-jre-8u91-linux-x64.tar.gz"
java_versions[8u92]="http://download.oracle.com/otn-pub/java/jdk/8u92-b14/server-jre-8u92-linux-x64.tar.gz"


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

  # exit if no curl or wget installed
  check_preconditions

  if [[ ${java_versions[${java_version_to_install}]+version_exists} ]]; then
    log ":: Retrieving version ${java_version_to_install}..."
    local java_tarball="${java_version_to_install}.tar.gz"
    local download_url="${java_versions[${java_version_to_install}]}"
    if [[ "${is_curl_installed}" == "true" ]]; then
      download_with_curl ${java_tarball} ${download_url}
    elif [[ "${is_wget_installed}" == "true" ]]; then
      download_with_wget ${java_tarball} ${download_url}
    fi

    log ":: Extracting tarball..."
    (mkdir -p /opt/java/${java_version_to_install})
    (tar -xzf /tmp/${java_tarball} -C /opt/java/${java_version_to_install} --strip-components=1)
    if [[ $? -ne 0 ]]; then
      error "extracting the tarball failed"
    fi

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
  if hash curl 2>/dev/null; then
    is_curl_installed="true"
  fi
  if hash wget 2>/dev/null; then
    is_wget_installed="true"
  fi

  if [[ "${is_wget_installed}" == "false" && "${is_curl_installed}" == "false" ]]; then
    error "curl or wget not found."
  fi
}

function download_with_curl {
  local java_tarball=$1
  local download_url=$2

  cd /tmp
  (curl --location --insecure --junk-session-cookies --output ${java_tarball} \
        --header "${oraclelicence_header}" \
        ${download_url})
  if [[ $? -ne 0 ]]; then
    error "retrieving version file from Oracle failed"
  fi
}

function download_with_wget {
  local java_tarball=$1
  local download_url=$2

  cd /tmp
  (wget --no-check-certificate --output-document ${java_tarball} \
        --header "${oraclelicence_header}" \
        ${download_url})
  if [[ $? -ne 0 ]]; then
    error "retrieving version file from Oracle failed"
  fi
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
