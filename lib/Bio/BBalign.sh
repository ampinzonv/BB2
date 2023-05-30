#!/usr/bin/env bash
# Created by: Andrés Pinzón (ampinzonv@unal.edu.co)

source $BASHUTILITY_LIB_PATH/file.sh
source $BASHUTILITY_LIB_PATH/string.sh
source $BASHUTILITY_LIB_PATH/feedback.sh
source $BASHUTILITY_LIB_PATH/os.sh
source $BASHUTILITY_LIB_PATH/io.sh
source $BIOBASH_LIB/process_optargs.sh;

# @file BioBash Alignments
# @brief 
#   Functions to handle sequence Alignments
#
# @description
#   BIOBASH module

# @brief Maps Fastq reads to reference genome.
# @description
# INPUT: 
# This function takes a SE or PE fastq file and maps it to a reference genome.
# The PE file can be interleaved or separated into forward and reverse files.
# If PE files are provided as two separate fastq files the complete path to both files must be
# provided comma separated as follows even if both fastq files reside in the same directory:
#
# The following is CORRECT:
#  --input /complete/path/to/fastq1,/complete/path/to/fastq2
#  --input /other/path/to/fastq1,/different/path/to/fastq2
#  --input fastq1,fastq2
# (Note that for the latter it is assumed that fastq1 and fastq2 are in the local directory.)
#
#  The following is WRONG:
# --input /complete/path/to/fastq1,fastq2
# (UNLESS fastq2 is located in the current directory)
#
# The genome index provided is used (-x/--index option) for mapping, please note that this index MUST BE
# created with BBindex::genome_indexing (or BBMap), indexes created with Bowtie2 or other software will not work.
# If a path to a valid index is not provided, a genome index will be created "on the fly" and used for mapping. 
# Note that this index will NOT BE WRITTEN to disk and therefore erased after mapping 
# (use the BBindex::genome_indexing function in BioBash to create a persistent index directory).
# Note that this function will also check for a directory named "ref" in the local directory if it is found it will
# use the "1" index inside the directory, even if a path is provided....
# 
# OUTPUT:
# A SAM file is written to the path provided with the -o/--output option. If the ".gz" extension is also used, the output file
# will be then compressed accordingly using GZIP. If not provided the name of the first input file will be used as base name
# and the ".sam" extension will be appended and then the file will be compressed. For example if you provided the reads.fq file
# the output will be: reads.sam.gz
# If the file name exists in current directory program will stop before proceeding.
#
# @example
# The following example will use PE reads (comma separated) and output a compressed SAM file using a pre-defined reference genome:
#
#  $(BBalign::map_reads_to_genome -i read1.fq,read2.fq -x "path/to/ref" -m 64 --jobs 10 --output "results/align.sam.gz")
#
# The following example will use a SE (or interleaved) fastq file and output a raw (not compressed) SAM file. The index will be created
# on memory before running the actual mapping.
# 
# $(BBalign::map_reads_to_genome -i reads.fq -m 64 --jobs 10 --output "results/align.sam")
#
# @arg  -i/--input    (required) path to fastq file(s). Comma separated if PE in different files.
# @arg  -j/--jobs     (optional) Number of CPU cores to use (default: use all available cores).
# @arg  -o/--output   (optional) Output SAM file name (default:same as input plus ".sam.gz" extension).
# @arg  -m/--memory   (optional) Amount of memory to be used in GB (default: all available memory).
# @arg  -p/--plot     (optional) Plot results.
BBalign::map_reads_to_genome(){
    
    # ...............................................................
    #
    # Initialise the necessary variables that will be checked / populated 
    # by process_optargs.
    #
    # ...............................................................
    local -A OPTIONS=()
    local -a ARGS=()
    local -a VALID_FLAG_OPTIONS=(  )
    local -a VALID_KEYVAL_OPTIONS=( -i/--input -j/--jobs -m/--memory -o/--output -p/--plot )
    local COMMAND_NAME="${FUNCNAME[0]}"

    # ...............................................................
    #
    # Perform the processing to populate the OPTIONS and ARGS arrays.
    #
    # ...............................................................
    process_optargs "$@" || exit 1


    # ...............................................................
    #
    #                       Check FASTQ input files
    # This function DOES NOT ACCEPT data from pipelines (stream of data)
    # so it requires a file. This is a characteristic of BBMAP.
    #
    # ...............................................................
    if   is_in '-i'      "${!OPTIONS[@]}"; then fastq="${OPTIONS[-i]}"
    elif is_in '--input' "${!OPTIONS[@]}"; then fastq="${OPTIONS[--input]}"
    else
        feedback::sayfrom "${COMMAND_NAME}: Input file required." "error"
        echo
        exit  1
    fi

    # If comma separated, split string into forward and reverse
    if [[ $fastq =~ "," ]];then 
        # We will need this variable to know which command to create ...later.
        twoFiles=true

        array=( $(string::split "${fastq}" ",") )
        fastq="${array[0]}" 
        fastq2="${array[1]}" 

    else
        twoFiles=false
    fi


    # ...............................................................
    #
    #                        Check Output file
    #
    # ...............................................................
    if   is_in '-o'      "${!OPTIONS[@]}"; then output="out=${OPTIONS[-o]}"
    elif is_in '--output' "${!OPTIONS[@]}"; then output="out=${OPTIONS[--output]}"
    else
        # If not provided create a name based on fastq(s) name.
        #outName=$(basename "${fastq}" | cut -d. -f1)
        outName=$(file::basename "${fastq}")
        outPath=$(file::dirname "${fastq}")
        

        output="${outPath}/${outName}.sam"
        echo $output
    fi
    # Check that file does not exist in local dir.
    # then create output name (reads.sam.gz)
    

    # if exists, warn and quit.

    # ...............................................................
    #
    #                           Check index
    #
    # ...............................................................

    # If empty or not provided change command.


    # ...............................................................
    #
    # CREATE AND RUN THE COMMAND
    #
    # ...............................................................

}