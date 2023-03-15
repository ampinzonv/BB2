#!/bin/bash
# arg-utils.sh
#
# handy functions for flexibly managing function arguments in bash scripts
#
# Copyright 2006-2018 Alan K. Stebbens <aks@stebbens.org>
#

ARG_UTILS_VERSION="arg-utils.sh v2.2"

[[ "$ARG_UTILS_SH" = "$ARG_UTILS_VERSION" ]] && return
ARG_UTILS_SH="$ARG_UTILS_VERSION"



# local arg=`numarg_or_input $1`
#
# Return the numeric argument or read from stdin

# OLD name; deprecated
numarg_or_input() {
  __numarg_or_input "$@"
}

__numarg_or_input() {
  local -i arg
  if [[ $# -eq 0 || -z "$1" ]] ; then
    local func=`__calling_funcname`
    local -a args
    while (( ${#args[*]} == 0 )) ; do
      read -p "${func}? " args
    done
    arg=$(( 10#${args[0]} ))
  else
    arg=$(( 10#$1 ))
  fi
  echo $arg
}

# func=`__calling_funcname`
#
# Obtain the first function name not prefixed with "__"

__calling_funcname() {
  local _x=1
  local func="${FUNCNAME[1]}"
  for (( _x=1; _x <= ${#FUNCNAME[*]}; _x++ )); do
    func="${FUNCNAME[$_x]}"
    [[ "${func:0:2}" == '__' ]] && continue
    [[ "${func}" == 'arg_or_input' ]] && continue
    [[ "${func}" == 'args_or_input' ]] && continue
    [[ "${func}" == 'args_or_stdin' ]] && continue
    [[ "${func}" == 'numarg_or_input' ]] && continue
    break
  done
  echo "$func"
}

__dump_func_stack() {
  local _i
  for(( _i=0 ; _i <= ${#FUNCNAME[*]}; _i++ )) ; do
    printf 1>&2 "%2d: %s\n" $_i "${FUNCNAME[$_i]}"
  done
}

# local arg=`__arg_or_input "$1"`
#
# Return the argument given, or the first non-empty line from STDIN

# deprecated OLD name
arg_or_input() {
  __arg_or_input "$@"
}

__arg_or_input() {
  local arg
  if [[ $# -eq 0 || -z "$1" ]]; then
    local func=`__calling_funcname`
    local -a args
    while (( ${#args[*]} == 0 )) ; do
      read -p "${func}? " args
    done
    arg="${args[0]}"
  else
    arg="$1"
  fi
  echo "$arg"
}


# local args=( `__args_or_input "$@"` )
#
# Return the arguments or read a line of non-empty input

# deprecated OLD name

args_or_input() {
  __args_or_input "$@"
}

__args_or_input() {
  if (( $# == 0 )) ; then
    local -a args
    local func=`__calling_funcname`
    while (( ${#args[*]} == 0 )); do
      read -p "$func? " -a args
    done
    echo "${args[@]}"
  else
    echo "$@"
  fi
}

# some-pipe | __args_or_stdin "$@"
#
# return the given arguments, or read & return STDIN until EOF

# deprecated OLD name
args_or_stdin() {
  __args_or_stdin "$@"
}

__args_or_stdin() {
  if [[ $# -gt 0 ]] ; then
    echo "$*"
  else
    cat
  fi
}


# __append_arg  ARG
# __append_args ARGS
#
# appends ARGS to the next line of input, and return the entire string
#
#    echo SOMEDATA | __append_arg SOMEARG ==> SOMEDATA SOMEARG


__append_arg() {
  local -a data
  read -a data
  echo "${data[@]}" "$@"
}
__append_args() { __append_arg "$@" ; }

# deprecated OLD names
append_arg()  { __append_arg "$@" ; }
append_args() { __append_arg "$@" ; }

# end of arg-utils.sh
# vim: sw=2 ai


echo "TESTING"

while getopts i::h: option; do
		case "${option}" in
			i)
				input="$OPTARG";;
            h)
                input="$OPTARG";;
			\?)
				feedback::sayfrom "Unknown option." "error"
			exit;;
		esac
	    done

#arg_or_input "$1"
args_or_stdin "$@"