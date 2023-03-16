#!/usr/bin/env bash

# @file io
# @brief Functions for handling input/output


#####################################################################
# @description Evaluates if the script receives at least one argument
# @Description
#
# @arg $1  Bash "$#" special character.
# @return 0 if script has at least one argument.
# @return 1 if script has no arguments.
#####################################################################
io::script_has_args(){
    local args
    #By default we expect arguments
    args=0
    # When script is called without arguments.
    if [[ $1 -eq 0 ]]; then 
        args=1
    fi
    
    echo "${args}"
}


#####################################################################
# @description Evaluates if input comes from a pipe or a file
# @Description
#
# @noargs
# @return 0 if script is piped
# @return 1 any other circumstance.
#####################################################################
io::input_is_pipe(){
    
    # "0" (True) means that data comes from a pipe "|".

    if [ ! -t 0 ]; then
        pipe=0
    else
        pipe=1
    fi
    echo "${pipe}"
}