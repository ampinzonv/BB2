#!/usr/bin/env bash
# Created by: Andrés Pinzón (ampinzonv@unal.edu.co)

# @file BioBash Databases
# @brief 
#   Functions to handle operations over biological databases.
#

source $BIOBASH_LIB/process_optargs.sh;
source $BASHUTILITY_LIB_PATH/file.sh
source $BASHUTILITY_LIB_PATH/feedback.sh
source $BASHUTILITY_LIB_PATH/string.sh;


# @description Creates a nucleotide or protein database in NCBI's format. 
#
# @example
#   BBdb::make_blast_db -i <FASTA file> -t P -n E
#   #Output
#   Returns 0 if file is fasta, 1 if it is not.
#
# @arg -i/--input  (mandatory) path to a FASTA file.
# @arg -t/--type   (mandatory) Database type: nucl or prot Default: nucl
# @arg -r/--rname   (optional) Database name. Default: same as input file.
# @arg -o/--output (optional) Base name for the database directory and files. Defaults to same name as input file.


#
# @exitcode 0  On success 
# @exitcode 1  On failure
BBdb::make_blast_db(){

# Initialise the necessary variables that will be checked / populated by process_optargs
    local -A OPTIONS=()
    local -a ARGS=()
    local -a VALID_FLAG_OPTIONS=( )
    local -a VALID_KEYVAL_OPTIONS=( -i/--input -o/--output -t/--type -r/--rename )
    local COMMAND_NAME="BBdb::make_blast_db"
    local inFile 


    process_optargs "$@" || exit 1

    # ...................................................................................
    #  Chek for input file
    # ...................................................................................

    if   is_in '-i'      "${!OPTIONS[@]}"; then inFile="${OPTIONS[-i]}"
        elif is_in '--input' "${!OPTIONS[@]}"; then inFile="${OPTIONS[--input]}"
        else
            feedback::sayfrom "${COMMAND_NAME}: Input file required." "error"
            echo
            exit  1
    fi

    # ...................................................................................
    #  Chek for output file
    # This will be used to create a directory with database files inside.
    # This differs from default NCBI's BLAST behavior which creates files in local dir.
    # ...................................................................................
    if   is_in '-o'      "${!OPTIONS[@]}"; then local outFile="${OPTIONS[-o]}"
    elif is_in '--output' "${!OPTIONS[@]}"; then local outFile="${OPTIONS[--output]}"
    else
        
        local outFile=$(file::basename "${inFile}")
    
    fi

    # ...................................................................................
    #  DO NOT DESTROY USER DATA
    # ...................................................................................
    local a=$(file::file_exists "${outFile}")
    if [ "${a}" -eq 0 ];then

        feedback::sayfrom "Directory '${outFile}' exists. I am not allowed to remove it. Please re-name or remove before proceeding."
        exit 1
    fi

    # ...................................................................................
    #  DATA TYPE
    # ...................................................................................
    if   is_in '-t'      "${!OPTIONS[@]}"; then local dbType="${OPTIONS[-t]}"
    elif is_in '--type' "${!OPTIONS[@]}"; then local dbType="${OPTIONS[--type]}"
    else
        
        local dbType="N"
    
    fi


    if [[ "${dbType}" != [nN] && "${dbType}" != [pP] ]];then

        feedback::sayfrom "A -t/--type option should be: N, n, P or p." "error"
        exit 1
    fi

    # Trasnform to BLAST+ language
    if [[ "${dbType}" == [nN] ]];then

        local dbType="nucl"

    elif [[ "${dbType}" == [pP] ]]; then

        local dbType="prot"
    else
        # Theoretically we shoul never reach this point.. but who knows.
        feedback::sayfrom "Something went wrong: -t/--type option should be: N, n, P or p." "error"
        exit 1
    fi
    

    # ...................................................................................
    #  DATABASE NAME
    # ...................................................................................
    if   is_in '-r'      "${!OPTIONS[@]}"; then local dbName="${OPTIONS[-r]}"
    elif is_in '--rename' "${!OPTIONS[@]}"; then local dbName="${OPTIONS[--rename]}"
    else
        # Defaults to in file name.
        local dbName=$(file::basename "${inFile}")
    
    fi

    # ...................................................................................
    #
    #  RUN
    #
    # ...................................................................................
    mkdir $outFile
    $BIOBASH_BIN_OS/blast/makeblastdb -dbtype "${dbType}" -in "${inFile}" -title "${dbName}" -out "${outFile}/${outFile}" -parse_seqids
    
}