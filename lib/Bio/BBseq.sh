#!/usr/bin/env bash
# BioBash Module for Bio::Seq
# Created by: Andrés Pinzón (ampinzonv@unal.edu.co)
#  
# @description
# This module contains functions to operate over sequences itself (DNA/RNA/Protein)
# things like extract fasta headers, translate, count number of entries should beplaced here.

source $BASHUTILITY_LIB_PATH/file.sh
source $BASHUTILITY_LIB_PATH/feedback.sh
source $BASHUTILITY_LIB_PATH/os.sh
source $BIOBASH_LIB/process_optargs.sh;


# @brief Retrieves the components from a fasta entry/entries 
# @description A fasta file has three main components:
# 1) The header (which begins with the ">" sign)
# 2) The sequence ID (which is part of the header)*
# 2) The sequences itself
#
# # The porpouse of this function is to retrieve that information individually, wether
# # from a multiple or single sequence file.
#
# *Please note that it is assumed that Sequence ID is ANY STRING in the fasta
# header between the ">" sign and the first space. So in a header like:
#
#       >KY560197.1 Acipenser ruthenus ApoE (apoE) mRNA, partial cds
#
# It is assumed that KY560197.1 is the sequence ID.
#
# @example
# Invoked without modifiers shows all info:
#   BBSeq::get_fasta_components -i "./file.fa[,fasta]" 
#   #Output (tab separated one row per sequence)
#   SeqID   Description   Sequence  
#  When invoked with a modifier (-h, -d and/or -s) Displays appropriate info:
#  -h: header, -d sequence ID, -s Sequences
# 
#
# @arg -i/--input    (required) path to a file.
# @arg -h/--header   (optional) Show fasta header.
# @arg -d/--id       (optional) Show sequence ID.
# @arg -s/--sequence (optional) Show sequence.
# @arg -j/--jobs     (optional) Number of CPU cores to use.
#
# @exitcode 0  on success
# @exitcode 1  on failure
BBSeq::get_fasta_components()
{ 

    # Initialise the necessary variables that will be checked / populated by process_optargs
    local -A OPTIONS=()
    local -a ARGS=()
    local -a VALID_FLAG_OPTIONS=( -h/--header -s/--sequence -d/--id )
    local -a VALID_KEYVAL_OPTIONS=( -i/--input )
    local COMMAND_NAME="BBSeq::get_fasta_components"

    # Perform the processing to populate the OPTIONS and ARGS arrays.
    process_optargs "$@" || exit 1

    #----------------------------------------------------------------
    # WE NEED A FILE TO CONTINUE
    #----------------------------------------------------------------

    # Check input file (REQUIRED!)
    if   is_in '-i'      "${!OPTIONS[@]}"; then file="${OPTIONS[-i]}"
    elif is_in '--input' "${!OPTIONS[@]}"; then file="${OPTIONS[--input]}"
    else
        feedback::sayfrom "BBSeq::get_fasta_components: Input file required." "error"
        echo
        exit  1
    fi


    # Since this script has many users cases and command varies accordingly, it is better to standarized
    # the number of cores from the very begininng
    

    #Check if we have a third parameter for parallel processing.
    jobs=""
    if   is_in '-j'      "${!OPTIONS[@]}"; then jobs=" -j ${OPTIONS[-j]} "
    elif is_in '--jobs' "${!OPTIONS[@]}"; then jobs=" -j ${OPTIONS[--jobs]} "
    else
        #use defaults
        jobs=" -j $(os::default_number_of_cores) "
    fi

    #----------------------------------------------------------------
    # DEFAULT COMMAND
    #----------------------------------------------------------------
    BIN="$BIOBASH_BIN_OS/seqkit fx2tab ${jobs} "


    #----------------------------------------------------------------
    # Check flags and key/values status
    #----------------------------------------------------------------

    #Header line
    if is_in '-h' "${!OPTIONS[@]}" || is_in '--header' "${!OPTIONS[@]}"
        then header="on"
    else
        header="off"
    fi

    #Sequence
    if is_in '-s' "${!OPTIONS[@]}" || is_in '--sequence' "${!OPTIONS[@]}"
        then sequence="on"
    else
        sequence="off"
    fi

    #sequence ID
    if is_in '-d' "${!OPTIONS[@]}" || is_in '--id' "${!OPTIONS[@]}"
        then seqID="on"
    else
        seqID="off"
    fi

    #Uncomment for debugging
    echo "VARS: header=$header sequence=$sequence seqID=$seqID"
    
    #----------------------------------------------------------------
    #                       TEST OPTIONS
    #----------------------------------------------------------------
    # Test different options we have:
    # a) Just Fasta file provided
    # b) Fasta file + one argument (h, d or s)
    # c) Fasta file + two arguments (hd, hs, ds)
    # d) Fasta file +  three arguments (which defualts to case "a")

    #case a. The function is called without any flag
    if [[ "${header}" == "off" && "${sequence}" == "off" && "${seqID}" == "off" ]]; then
        COMMAND=$(echo "${BIN}" "${file}")
        $COMMAND
        exit 0
    fi
    
    #case d is pretty much the same than case "a", just the opossite.
    if [[ "${header}" == "on" && "${sequence}" == "on" && "${seqID}" == "on" ]]; then
        COMMAND=$(echo "${BIN}" "${file}")
        $COMMAND
        exit 0
    fi

    # ---------------------------------------------------------------
    # Cases b. Here we have three options, one for each argument. In each case the process is quite
    # different, because seqkit do not provide all the flexibility we want in BB.
    # ---------------------------------------------------------------
    if [[ "${header}" == "on" && "${sequence}" == "off" && "${seqID}" == "off" ]]; then

        COMMAND=$(echo "${BIN}" " -n " "${file}")
        $COMMAND
        exit 0

    elif [[ "${header}" == "off" && "${sequence}" == "on" && "${seqID}" == "off" ]]; then

        # Use the "-i" option because it outputs the sequence ID plus TAB plus sequence. It is easier to parse.
        COMMAND=$(echo "${BIN}" " -i " "${file}")
        $COMMAND | awk '{print $2}'
        exit 0

    elif [[ "${header}" == "off" && "${sequence}" == "off" && "${seqID}" == "on" ]]; then
        
        # Use the "-i" option because it outputs the sequence ID plus TAB plus sequence. It is easier to parse.
        COMMAND=$(echo "${BIN}" " -i " "${file}")
        $COMMAND | awk '{print $1}'
        exit 0

    else
        # We have to test another possible case. Series C
        true

    fi

    # ---------------------------------------------------------------
    # Cases C. Here we have three options, one for each argument. 
    # Fasta file (default) + a combination of two arguments (hd, hs, ds)
    # ---------------------------------------------------------------
    if [[ "${header}" == "on" && "${sequence}" == "off" && "${seqID}" == "on" ]]; then

        COMMAND=$(echo "${BIN}" " -n " "${file}")
        $COMMAND
        exit 0

    elif [[ "${header}" == "on" && "${sequence}" == "on" && "${seqID}" == "off" ]]; then
        # ¡¡¡¡¡¡¡¡ WARNING!!!!!!!!
        # Here we should display only the fasta header without the ID + sequence
        # BUT FOR NOW we are defaulting to show everything, because I have not found a easy way
        # to get rid of the first word of the (sequene ID) of the header fasta.
        # Meaning that -hs is equal to -hsd.
        COMMAND=$(echo "${BIN}" "${file}")
        $COMMAND
        exit 0

    elif [[ "${header}" == "off" && "${sequence}" == "on" && "${seqID}" == "on" ]]; then
        
        COMMAND=$(echo "${BIN}" " -i " "${file}")
        $COMMAND
        exit 0

    else
    
        true

    fi
}