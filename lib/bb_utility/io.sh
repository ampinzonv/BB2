#!/usr/bin/env bash
# bashutility+ module for handling input/output
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

source $BASHUTILITY_LIB_PATH/file.sh


# @brief Captures streamed data (such as the one that comes from a UNIX  pipe).
# @description  When data is passed to a script via a pipe, this function captures that dataframe.
#
#
# @example 
#   echo "AGCT" | myscript.sh
#   #inside myscript.sh
#   data=$(io::get_data_stream)
#   echo -n "$data" #Outputs: AGCT
#
# @arg none
#
# @exitcode 0 If succesful
# @exitcode 1 If not succesful
io::get_data_stream(){

    # $@ all positional arguments as separate strings. 
    # Since we expect only one (the streaned data), it makes sense.
    cat -- "$@"

}

# @brief Gets a data stream and save it to a temporary file
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
io::stream_to_tmp_file(){
    
    #Get data stream
    local data
    data=$(io::get_data_stream)

    #Create tmp file
    local tmpFile
    tmpFile=$(file::make_temp_file)

    #Save it
    echo -n "${data}" > "${tmpFile}"

    #return path
    printf "${tmpFile}"
}

# @brief Gets the exit code of the run function
# @description Reports the exit code of a given function
#
#
# @example
#   io::get_exit_code
#   or...
#   exitCode=$(io::get_exit_code)
#
# @arg none
#
# @exitcode 0 If succesful
# @exitcode 1 If not succesful
io::get_exit_code(){

    # The bash special variable: $? holds the exit value of the most 
    # recently completed process which was spawned by that shell.
    # https://www.quora.com/What-is-the-meaning-of-in-bash-script
    # More on exit codes: https://tldp.org/LDP/abs/html/exitcodes.html
    
    printf "$?"
}

# @description Evaluates if the script receives at least one argument
# @Description
#
# @arg $1  Bash "$#" special character.
# @return 0 if script has at least one argument.
# @return 1 if script has no arguments.
io::has_args(){
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
io::is_pipe(){
    
    # "0" (True) means that data comes from a pipe "|".

    if [ ! -t 0 ]; then
        pipe=0
    else
        pipe=1
    fi
    echo "${pipe}"
}