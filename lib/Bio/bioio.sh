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


# @description Opens a file or data buffer
#
# @example
#   
#
# @arg 
#
# @exitcode 0 If ...
# @exitcode 2 If ...
BioIO::Open(){
    break
}


# @description 
#
# @example
#   
#
# @arg 
#
# @exitcode 0 If ...
# @exitcode 2 If ...
BioIO::Close(){
    break

}

# @description 
#
# @example
#   
#
# @arg 
#
# @exitcode 0 If ...
# @exitcode 2 If ...
BioIO::Is_fasta(){
    break

}

# @description 
#
# @example
#   
#
# @arg 
#
# @exitcode 0 If ...
# @exitcode 2 If ...
BioIO::Is_fastq(){
    break

}

# @description 
#
# @example
#   
#
# @arg 
#
# @exitcode 0 If ...
# @exitcode 2 If ...
BioIO::Fastq_to_fasta(){
    break

}