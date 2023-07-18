#!/usr/bin/env bash

source $BASHUTILITY_LIB_PATH/file.sh
source $BASHUTILITY_LIB_PATH/feedback.sh
source $BASHUTILITY_LIB_PATH/os.sh
source $BASHUTILITY_LIB_PATH/io.sh
source $BIOBASH_LIB/process_optargs.sh;

# @file BioBash Sequence
# @brief This module contains functions to operate over sequences itself (DNA/RNA/Protein)
# @description 
#   BIOBASH module

# @description This function retrieves different parts of fasta file.
# A fasta file has three main components:  
#   1) The header (which begins with the ">" sign)
#   2) The sequence ID (which is part of the header)*
#   3) The sequences itself
#   The porpouse of this function is to retrieve that information individually, wether
#   from a multiple or single sequence file.
#   Please note that it is assumed that Sequence ID is ANY STRING in the fasta
#   header between the ">" sign and the first space. So in a header like:
#       >KY560197.1 Acipenser ruthenus ApoE (apoE) mRNA, partial cds
#   It is assumed that KY560197.1 is the sequence ID.
#
# @example
#   Invoked without modifiers shows all info:
#   BBSeq::get_fasta_components -i "./file.fa[,fasta]" 
#   Output (tab separated one row per sequence)
#   SeqID   Description   Sequence  
#   When invoked with a modifier (-h, -d and/or -s) Displays appropriate info:
#   -h: header, -d sequence ID, -s Sequences
# 
# @arg  -i/--input    (required) path to a file.
# @arg  -h/--header   (optional) Show fasta header.
# @arg  -d/--id       (optional) Show sequence ID.
# @arg  -s/--sequence (optional) Show sequence.
# @arg  -j/--jobs     (optional) Number of CPU cores to use.
#
# @exitcode 0  on success
# @exitcode 1  on failure
BBSeq::get_fasta_components(){ 

    # Initialise the necessary variables that will be checked / populated by process_optargs
    local -A OPTIONS=()
    local -a ARGS=()
    local -a VALID_FLAG_OPTIONS=( -h/--header -s/--sequence -d/--id )
    local -a VALID_KEYVAL_OPTIONS=( -i/--input )
    local COMMAND_NAME="BBSeq::get_fasta_components"

    local pipe
    local file
    local jobs
    local BIN
    local sequence
    local seqID
    local header

    # Perform the processing to populate the OPTIONS and ARGS arrays.
    process_optargs "$@" || exit 1

    #----------------------------------------------------------------
    # WE NEED A FILE/STREAM TO CONTINUE
    #----------------------------------------------------------------
    pipe=$(io::is_pipe)
    

    # "1" means __IT IS NOT__ a pipe.
    if [ "${pipe}" -eq 1 ]; then

        if   is_in '-i'      "${!OPTIONS[@]}"; then file="${OPTIONS[-i]}"
        elif is_in '--input' "${!OPTIONS[@]}"; then file="${OPTIONS[--input]}"
        else
            feedback::sayfrom "BBSeq::get_fasta_components: Input file required." "error"
            echo
            exit  1
        fi
    else
        #$pipe == 0
        file=$(io::get_data_stream)
        
    fi
    # Up to this point if data comes from a file it is assigned to "$file".
    # If not means that data comes from a stream (pipe). So we can use that to change commands below.


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
    #                       DEFAULT COMMAND
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
    #echo "VARS: header=$header sequence=$sequence seqID=$seqID"
    
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
        
        if [ "${pipe}" -eq 0 ]; then
            echo "${file}" | ${BIN}
        else
            ${BIN} "${file}"
        fi
        exit 0  
    fi
    
    #case d is pretty much the same than case "a", just the opossite.
    if [[ "${header}" == "on" && "${sequence}" == "on" && "${seqID}" == "on" ]]; then
    
        if [ "${pipe}" -eq 0 ]; then
            echo "${file}" | ${BIN}
        else
            ${BIN} "${file}"
        fi
        exit 0
        
    fi

    # ---------------------------------------------------------------
    # Cases b. Here we have three options, one for each argument. In each case the process is quite
    # different, because seqkit do not provide all the flexibility we want in BB.
    # ---------------------------------------------------------------
    if [[ "${header}" == "on" && "${sequence}" == "off" && "${seqID}" == "off" ]]; then

        if [ "${pipe}" -eq 0 ]; then
            echo "${file}" | ${BIN} -n
        else
            ${BIN} -n  "${file}"
        fi
        exit 0
        

    elif [[ "${header}" == "off" && "${sequence}" == "on" && "${seqID}" == "off" ]]; then

        # Use the "-i" option because it outputs the sequence ID plus TAB plus sequence. It is easier to parse.
        if [ "${pipe}" -eq 0 ]; then
            echo "${file}" | ${BIN} -i | awk '{print $2}'
        else
            ${BIN} -i  "${file}" | awk '{print $2}'
        fi
        exit 0

    elif [[ "${header}" == "off" && "${sequence}" == "off" && "${seqID}" == "on" ]]; then
        
        # Use the "-i" option because it outputs the sequence ID plus TAB plus sequence. It is easier to parse.
        if [ "${pipe}" -eq 0 ]; then
            echo "${file}" | ${BIN} -i | awk '{print $1}'
        else
            
            ${BIN} -i "${file}" | awk '{print $1}'
            
        fi
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

        if [ "${pipe}" -eq 0 ]; then
            echo "${file}" | ${BIN} -n
        else
            ${BIN} -n "${file}"
        fi
        exit 0

    elif [[ "${header}" == "on" && "${sequence}" == "on" && "${seqID}" == "off" ]]; then
        # ¡¡¡¡¡¡¡¡ WARNING!!!!!!!!
        # Here we should display only the fasta header without the ID + sequence
        # BUT FOR NOW we are defaulting to show everything, because I have not found a easy way
        # to get rid of the first word of the (sequene ID) of the header fasta.
        # Meaning that -hs is equal to -hsd.
        if [ "${pipe}" -eq 0 ]; then
            echo "${file}" | ${BIN}
        else
            ${BIN} "${file}"
        fi
        exit 0

    elif [[ "${header}" == "off" && "${sequence}" == "on" && "${seqID}" == "on" ]]; then
        
        if [ "${pipe}" -eq 0 ]; then
            echo "${file}" | ${BIN} -i 
        else
            ${BIN} -i "${file}"
        fi
        exit 0

    else
    
        true

    fi
}


# @description This function takes a fastq file as input and returns the average
# quality for each sequence in input file. Alternatively it will return a quality resume: the average of all
# summed sequences, max and min quality scores, and number of sequences.
#
# @example
#   Display each sequence quality average
#   BBSeq::get_fastq_quality -i file.fastq
#   8.51
#   10.43
#   7.27
#   8.66
#   7.75
#   8.85
#   8.19
#   Display quality report
#   BBSeq::get_fastq_quality -i file.fastq --report
#   File name       numseqs   sumlen   minlen   avg_len   max_len   Q20(%)   Q30(%)
#   example.fastq   4437      883678   115      199.2     438       26.63    6.09
#
# @arg  -i/--input    (required) path to a file.
# @arg  -r/--report   (optional) Show average, max and min quality score and number of sequences.
# @arg  -q/--quality  (optional) fastq quality encoding. available values: 'sanger', 'solexa', 'illumina-1.3+', 'illumina-1.5+', 'illumina-1.8+'. (default "sanger")
# @arg  -j/--jobs     (optional) Number of CPU cores to use.
#
# @exitcode 0  on success
# @exitcode 1  on failure
BBSeq::get_fastq_quality(){

    local -A OPTIONS=()
    local -a ARGS=()
    local -a VALID_FLAG_OPTIONS=( -r/--report )
    local -a VALID_KEYVAL_OPTIONS=( -i/--input -q/--quality -j/--jobs )
    local COMMAND_NAME="${FUNCNAME[0]}"

    # Perform the processing to populate the OPTIONS and ARGS arrays.
    process_optargs "$@" || exit 1


    #----------------------------------------------------------------
    #                       VALIDATION
    #----------------------------------------------------------------
    pipe=$(io::is_pipe)

    if [ "${pipe}" -eq 1 ]; then

        if   is_in '-i'      "${!OPTIONS[@]}"; then file="${OPTIONS[-i]}"
        elif is_in '--input' "${!OPTIONS[@]}"; then file="${OPTIONS[--input]}"
        else
            feedback::sayfrom "${COMMAND_NAME}: Input file required." "error"
            echo
            exit  1
        fi
    else
        file=$(io::get_data_stream)      
    fi

    # -- JOBS
    if   is_in '-j'      "${!OPTIONS[@]}"; then jobs="-j ${OPTIONS[-j]} "
    elif is_in '--jobs' "${!OPTIONS[@]}"; then jobs="-j ${OPTIONS[--jobs]} "
    else
        #use defaults
        jobs="-j $(os::default_number_of_cores) "
    fi

    # -- QUALITY ENCODING
    if   is_in '-q'      "${!OPTIONS[@]}"; then qual="-E ${OPTIONS[-q]} "
    elif is_in '--quality' "${!OPTIONS[@]}"; then qual="-E ${OPTIONS[--quality]} "
    else
        #use defaults. When EMPTY seqkit uses sanger.
        #we can default another one, for example: 
        #qual=" -E 'illumina-1.3+' "
        qual="-E sanger"
    fi

    # -- OUTPUT
    #  . . . DEPRECATED DEPRECATED DEPRECATED . . . 
    # BB outputs to STDOUT always, user should use  ">" for edirecttion and saving stuff...
    #
    # if   is_in '-o'      "${!OPTIONS[@]}"; then output="${OPTIONS[-o]} "
    # elif is_in '--output' "${!OPTIONS[@]}"; then output="${OPTIONS[--output]} "
    # else
    #     #use defaults
    #     output=""
    # fi
    

    # . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
    #
    #                       DEFAULTING COMMANDS
    # Note that this script has two "modes"
    # 1) Report mode, which shows a resumed report for all  input entries.
    # 2) List mode, which gets all quality scores for each input entry.
    #
    # Note that all outputs here were implemented using cat and ">" because there was a
    # difference between the output between 
    #
    #
    #
    # . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

    # ------------------------------------------------------------
    # REPORT MODE
    # ------------------------------------------------------------
    if is_in '-r' "${!OPTIONS[@]}" || is_in '--report' "${!OPTIONS[@]}"; then 

        if [ "${pipe}" -eq 1 ]; then
            
            $BIOBASH_BIN_OS/seqkit stats  -a -b -T ${jobs} ${qual}  ${file} | tail  -n 1 | awk '{print $1"    "$4 "   "$5"    "$6"    "$7"    "$8"    "$14"   "$15 }'
            
        else
        
            echo "${file}" | $BIOBASH_BIN_OS/seqkit stats  -a -b -T ${jobs}  ${qual} | tail  -n 1 | awk '{print $1"    "$4 "   "$5"    "$6"    "$7"    "$8"    "$14"   "$15 }'

        fi

    # ------------------------------------------------------------
    # LIST (DEFAULT) MODE
    # ------------------------------------------------------------
    else
        if [ "${pipe}" -eq 1 ]; then

            $BIOBASH_BIN_OS/seqkit fx2tab -q ${jobs}  ${file} | awk '{print $NF}'

        else
            
            echo "${file}" | $BIOBASH_BIN_OS/seqkit fx2tab -q ${jobs} | awk '{print $NF}'

        fi
    fi

    exit 0
}

    