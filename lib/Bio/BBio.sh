#!/usr/bin/env bash
# BioBash Module for Bio::IO
# Created by: Andrés Pinzón (ampinzonv@unal.edu.co)
#  
# @description
# This module contains functions to manage data stream buffers (as those coming from pipes in BASH).
# The functions here, should send and receive data sent to a given script and care for sending it
# as temporary files or buffers in memory. It also cares for opening and closing files (mostly 
# temporary files) created during execution and validate that tey are readable and that correspond to
# the specific file type required for the script.
#
# In the same spirit this module takes care of closing files safely (for instance take care 
# of not to harm user data) or erase input files if they were temporary created by the running script.


# @brief Captures streamed data (such the one that comes from a UNIX  pipe.
# @description
#
#
# @example
#   
#
# @arg 
#
# @exitcode 0 If ...
# @exitcode 2 If ...
BBIO::get_data_stream(){

    # $@ all positional arguments as separate strings. 
    # Since we expect only one (the streaned data), it makes sense.
    cat -- "$@"

}




# @description Evaluates if the script receives at least one argument
# @Description
#
# @arg $1  Bash "$#" special character.
# @return 0 if script has at least one argument.
# @return 1 if script has no arguments.
BBIO::has_args(){
    local args
    #By default we expect arguments
    args=0
    # When script is called without arguments.
    if [[ $1 -eq 0 ]]; then 
        args=1
    fi
    
    echo "${args}"
}



# @description Evaluates if input comes from a pipe or a file
# @Description
#
# @noargs
# @return 0 if script is piped
# @return 1 any other circumstance.
BBIO::is_pipe(){
    
    # "0" (True) means that data comes from a pipe "|".

    if [ ! -t 0 ]; then
        pipe=0
    else
        pipe=1
    fi
    echo "${pipe}"
}