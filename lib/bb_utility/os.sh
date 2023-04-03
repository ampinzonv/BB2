#!/usr/bin/env bash

# @file Operating System
# @brief Functions to detect Operating system and version.

# @description Identify the OS the function is run on.
#
# @noargs
#
# @example
#   os::detect_os
#   #Output
#   linux
#
# @exitcode 0  If OS is successfully detected.
# @exitcode 1 If unable to detect OS.
#
# @stdout Operating system name (linux, mac or windows).
os::detect_os() {
    declare uname os
    uname=$(command -v uname)

    case $("${uname}" | tr '[:upper:]' '[:lower:]') in
    linux*)
        os="linux"
        ;;
    darwin*)
        os="mac"
        ;;
    msys* | cygwin* | mingw* | nt | win*)
        # or possible 'bash on windows'
        os="windows"
        ;;
    *)
        return 1
        ;;
    esac
    printf "%s" "${os}"
}

# @description Identify the distribution flavour of linux.
#
# @noargs
#
# @example
#   os::detect_linux_distro
#   #Output
#   ubuntu
# @exitcode 0  If Linux distro is successfully detected.
# @exitcode 1 If unable to detect OS distro.
#
# @stdout Linux OS distribution name (ubuntu, debian, suse, etc.,).
os::detect_linux_distro() {
    declare distro
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . "/etc/os-release"
        distro="${NAME}"
    elif type lsb_release >/dev/null 2>&1; then
        # linuxbase.org
        distro=$(lsb_release -si)
    elif [[ -f /etc/lsb-release ]]; then
        # For some versions of Debian/Ubuntu without lsb_release command
        # shellcheck disable=SC1091
        . /etc/lsb-release
        distro="${DISTRIB_ID}"
    elif [[ -f /etc/debian_version ]]; then
        # Older Debian/Ubuntu/etc.
        distro="debian"
    elif [[ -f /etc/SuSe-release ]]; then
        # Older SuSE/etc.
        distro="suse"
    elif [[ -f /etc/redhat-release ]]; then
        # Older Red Hat, CentOS, etc.
        distro="redhat"
    else
        return 1
    fi
    printf "%s" "${distro}" | tr '[:upper:]' '[:lower:]'
}

# @description Identify the Linux version.
#
# @noargs
#
# @example
#   os::detect_linux_version
#   #Output
#   20.04
#
# @exitcode 0  If Linux version is successfully detected.
# @exitcode 1 If unable to detect Linux version.
#
# @stdout Linux OS version number (18.04, 20.04, etc.,).
os::detect_linux_version() {
    declare distro_version
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . "/etc/os-release"
        distro_version="${VERSION_ID}"
    elif type lsb_release >/dev/null 2>&1; then
        # linuxbase.org
        distro_version=$(lsb_release -sr)
    elif [[ -f /etc/lsb-release ]]; then
        # For some versions of Debian/Ubuntu without lsb_release command
        # shellcheck disable=SC1091
        . /etc/lsb-release
        distro_version="${DISTRIB_RELEASE}"
    else
        return 1
    fi
    printf "%s" "${distro_version}"
}

# @description Identify the MacOS version.
#
# @noargs
#
# @example
#   os::detect_linux_version
#   #Output
#   10.15.7
# @exitcode 0  If MacOS version is successfully detected.
# @exitcode 1 If unable to detect MacOS version.
#
# @stdout MacOS version number (10.15.6, etc.,)
os::detect_mac_version() {
    if [[ "$(os::detect_os)" = "mac" ]]; then
        declare mac_version
        mac_version="$(sw_vers -productVersion)"
        printf "%s" "${mac_version}"
    else
        return 1
    fi
}

# @brief Returns the number of default cores to use.
# @description During BIOBASH installation the global variable $BIOBASH_CORES is set.
# This variable holds the actual number of cores in the system. Nevertheless usually we do not
# want to run a process using all cores available, this should be set by user. So this function
# provides a "default" number of processors to use, something that could be 1/3 of all cores available.
#
# @noargs
#
# @example
#   os::default_number_of_cores
#   #Output
#   an Integer
#
# @exitcode 0  On success
# @exitcode 1  On failure
#
os::default_number_of_cores() {

    # In some weird cases during installation if BB installer is not able
    # to asses the number of cores, this variables is set to 1. So it makes not sense to go 
    # further and try to divide this number.
    if [ $BIOBASH_CORES -eq 1 ];then
        printf $BIOBASH_CORES
        exit 0
    fi

    #                        PLEASE READ THE FOLLOWING!!! 
    # My first idea was to set $cores to a 1/3 of total cores
    # but in huge infraestructures for simple processes this could get things worst than better,
    # we could be trying to convert a fastq file to fasta using 35 or more cpu cores!
    # So the following code can be used if somehow we realize that using a default value of 1/3 (or
    # whatever) is better than 1. So uncomment the following if that is the case (and comment line below also):
    #
    # factor=3
    # cores=$(echo "${BIOBASH_CORES}/${factor}" | bc)


    #...Otherwise let the following untouched.
    cores=1 # Comment if changed above.

    
    printf "${cores}"
}
