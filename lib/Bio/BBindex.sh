#!/usr/bin/env bash
# Created by: Andrés Pinzón (ampinzonv@unal.edu.co)

source $BASHUTILITY_LIB_PATH/file.sh
source $BASHUTILITY_LIB_PATH/feedback.sh
source $BASHUTILITY_LIB_PATH/os.sh
source $BASHUTILITY_LIB_PATH/io.sh
source $BIOBASH_LIB/process_optargs.sh;


# @file BioBash Index
# @brief 
#   Functions for the indexing biological data
#
# @description
#   BIOBASH module

# @description This function indexes genomic sequences using BBMap.
#
# @example
#   result=$(BBindex::genome_indexing -i genome.fa -m 64 --jobs 10)
#
# This will run using 64GB of memory, 10 CPU cores and will create a folder maned "ref" (default)
# in the local directory, with the following structure:
#
# ref
# ├── genome
# │   └── 1
# │       ├── chr1.chrom.gz
# │       ├── info.txt
# │       ├── scaffolds.txt.gz
# │       └── summary.txt
# └── index
#     └── 1
#         ├── chr1_index_k13_c8_b1.block
#         └── chr1_index_k13_c8_b1.block2.gz
#
#  If used with the -o/--output [out_name] option, the "ref" directory will be created inside
# the argument passed in [out_name] as follows:

# out_name
#       ├──ref
#           ├── genome
#               └── 1
#        ...
#
# @arg  -i/--input    (required) path to a file.
# @arg  -j/--jobs     (optional) Number of CPU cores to use (default: use all available cores).
# @arg  -o/--output   (optional) Output file to save (default: "./ref")
# @arg  -m/--memory   (optional) Amount of memory to be used in GB (default: all available memory)
#
# @exitcode 0  on success
# @exitcode 1  on failure
BBindex::genome_indexing(){
    
    # Initialise the necessary variables that will be checked / populated by process_optargs
    local -A OPTIONS=()
    local -a ARGS=()
    local -a VALID_FLAG_OPTIONS=(  )
    local -a VALID_KEYVAL_OPTIONS=( -i/--input -j/--jobs -m/--memory -o/--output )
    local COMMAND_NAME="${FUNCNAME[0]}"

    

    # ...............................................................
    #
    # Perform the processing to populate the OPTIONS and ARGS arrays.
    #
    # ...............................................................
    process_optargs "$@" || exit 1

    
    # ...............................................................
    #
    # This function DOES NOT ACCEPT data from pipelines (stream of data)
    # so it requires a file. This is a characteristic of BBMAP.
    # ...............................................................
    if   is_in '-i'      "${!OPTIONS[@]}"; then ref="ref=${OPTIONS[-i]}"
    elif is_in '--input' "${!OPTIONS[@]}"; then ref="ref=${OPTIONS[--input]}"
    else
        feedback::sayfrom "${COMMAND_NAME}: Input file required." "error"
        echo
        exit  1
    fi

    # ...............................................................
    #
    # Assign values to remaining command arguments
    #
    # ...............................................................
    if   is_in '-j'      "${!OPTIONS[@]}"; then jobs="threads=${OPTIONS[-j]} "
    elif is_in '--jobs' "${!OPTIONS[@]}"; then jobs="threads=${OPTIONS[--jobs]} "
    else
        # use defaults
        # Note that here is not necessary to assign this default value, since BBmap 
        # by default uses all available cores
        # jobs="-threads $(os::default_number_of_cores) "
        jobs="threads=auto"
    fi

    #--
    if   is_in '-m'      "${!OPTIONS[@]}"; then memory="-Xmx${OPTIONS[-m]}g "
    elif is_in '--memory' "${!OPTIONS[@]}"; then memory="-Xmx${OPTIONS[--memory]}g "
    else
        sm=$(os::show_system_memory "giga")
        memory="-Xmx${sm}g"
    fi

    #--
    if   is_in '-o'      "${!OPTIONS[@]}"; then output="path=${OPTIONS[-o]}"
    elif is_in '--output' "${!OPTIONS[@]}"; then output="path=${OPTIONS[--output]}"
    else
        output="path=./"
    fi


    # ...............................................................
    #
    # CREATE AND RUN THE COMMAND
    #
    # ...............................................................
    COMMAND="${BIOBASH_BIN}/all/bbmap/bbmap.sh ${ref} ${memory} ${jobs} ${output}"
    echo $COMMAND
    exit

}