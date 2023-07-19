#!/usr/bin/env bash
# Created by: Andrés Pinzón (ampinzonv@unal.edu.co)

source $BASHUTILITY_LIB_PATH/file.sh
source $BASHUTILITY_LIB_PATH/string.sh
source $BASHUTILITY_LIB_PATH/feedback.sh
source $BASHUTILITY_LIB_PATH/os.sh
source $BASHUTILITY_LIB_PATH/io.sh
source $BIOBASH_LIB/process_optargs.sh;

# @file BioBash Formatting routines
# @brief 
#   Functions to inter-convert between different Bioinformatics Formats
#
# @description
#   BIOBASH module

# @description 
#   Transforms a fastq file into a fasta file.
#   if only the fastq file argument is given it outputs the fasta format in STDOUT.
#   This input file can be compressed in gz format.
#   If a second (optional) argument is given (a string containing the desired name for FASTA output file)
#   STDOUT is then redirected to a file. If the string has a ".gz" extension, the output is also compressed.
# 
# @example
#   BBfile_fastq_to_fasta "./file.fastq[.gz]" 
#   #Output
#   file in FASTA format in STDOUT
#   
#   #Example 2
#   BBfile_fastq_to_fasta "./file.fastq[.gz]"  file.fa[.gz]
#   #Output
#   ./file.fa[.gz] 
#
# @arg -i/--input (Mandatory) path to fastq file.
# @arg -o/--output (Optional. Default STDOUT) name for output file. If ".gz" extension addedd then it is compressed.
# 
# @exitcode 0  On succes
# @exitcode 1  On failure
BBformat::fastq_to_fasta(){

    # Initialise the necessary variables that will be checked / populated by process_optargs
    local -A OPTIONS=()
    local -a ARGS=()
    local -a VALID_FLAG_OPTIONS=( )
    local -a VALID_KEYVAL_OPTIONS=( -i/--input -o/--output -j/--jobs)
    local COMMAND_NAME="BBfile::fastq_to_fasta"

    local outFile
    local jobs
    local file
    



    pipe=$(io::is_pipe)
    # "1" means __IT IS NOT__ a pipe.
    if [ "${pipe}" -eq 1 ]; then
    
    
        process_optargs "$@" || exit 1

        #-----------------------------------------------------------
        # Check if we have a second parameter. Note that seqkit output option is also "-o"
        #-----------------------------------------------------------
        if   is_in '-o'      "${!OPTIONS[@]}"; then outFile="-o ${OPTIONS[-o]}"
        elif is_in '--output' "${!OPTIONS[@]}"; then outFile="-o ${OPTIONS[--output]}"
        else
            outFile=""
        fi


        #-----------------------------------------------------------
        #Check if we have a third parameter for parallel processing.
        #-----------------------------------------------------------
        jobs=""
        if   is_in '-j'      "${!OPTIONS[@]}"; then jobs="-j ${OPTIONS[-j]}"
        elif is_in '--jobs' "${!OPTIONS[@]}"; then jobs="-j ${OPTIONS[--jobs]}"
        else
            #use defaults
            jobs=" -j $(os::default_number_of_cores)"
        fi

        #-----------------------------------------------------------
        # Check if we have an input file
        #-----------------------------------------------------------
        if   is_in '-i'      "${!OPTIONS[@]}"; then file="${OPTIONS[-i]}"  
            # RUN #
            $BIOBASH_BIN_OS/seqkit fq2fa $file $outFile $jobs
            exit 0

        elif is_in '--input' "${!OPTIONS[@]}"; then file="${OPTIONS[--input]}"

            # RUN #
            $BIOBASH_BIN_OS/seqkit fq2fa $file $outFile $jobs
            exit 0
            
        else
            #If -i/--input is not present then there is an error
            feedback::sayfrom "$COMMAND_NAME: Input file required." "error"
            echo ""
            exit  1
        fi

    else
        # If we are here it means we are dealing with data stream.


        local -a VALID_KEYVAL_OPTIONS=(-o/--output -j/--jobs)
        process_optargs "$@" || exit 1


        file=$(io::get_data_stream)
        #Check if we have a second parameter. Note that seqkit output option is also "-o"
        if   is_in '-o'      "${!OPTIONS[@]}"; then outFile="-o ${OPTIONS[-o]}"
        elif is_in '--output' "${!OPTIONS[@]}"; then outFile="-o ${OPTIONS[--output]}"
        else
            outFile=""
        fi

        #Check if we have a third parameter for parallel processing.
        jobs=""
        if   is_in '-j'      "${!OPTIONS[@]}"; then jobs="-j ${OPTIONS[-j]}"
        elif is_in '--jobs' "${!OPTIONS[@]}"; then jobs="-j ${OPTIONS[--jobs]}"
        else
            #use defaults
            jobs=" -j $(os::default_number_of_cores)"
        fi
        
        # RUN #
        echo $file | $BIOBASH_BIN_OS/seqkit fq2fa $outFile $jobs
        exit 0
        
    fi

}

# @description 
#  Converts from SAM to BAM format.
# For conversion you can wether:
# 1) Keep/erase the original SAM (default is keep it): set -k/--keep to false to delete SAM after BAM creation.
# 2) Sort/ not sort the obtained BAM file (default is sort it): set -s/--sort to false to obtain the unsorted BAM version.

#  @example
#  Convert file.sam into a sorted file.bam, keeping the SAM file intact. Use defaults for memory and processors.
#  BBformat::sam_to_bam -i file.sam
#
# Convert file.sam  into the unsorted renamed_file.bam, use 3 processors, 16GB of memory and delete SAM file.
#  BBformat::sam_to_bam -i file.sam -j 3 -m 16 --keep false -s false --output renamed_file.bam
#
# @arg -i/--input  (required) A valid SAM file.
# @arg -o/--output (optional) Name for output file in BAM format.
# @arg -j/--jobs   (optional) Number of processors to use.
# @arg -m/--memory (optional) Amount of memory to use in GB.
# @arg -k/--keep   (optional) Wether to keep or not the SAM file after conversion. Default: true
# @arg -s/--sort   (optional) Wether to sort or not the obtained BAM file. Default: true

BBformat::sam_to_bam(){

    # ...............................................................
    #
    # Initialise the necessary variables that will be checked / populated 
    # by process_optargs.
    #
    # ...............................................................
    local -A OPTIONS=()
    local -a ARGS=()
    local -a VALID_FLAG_OPTIONS=(  )
    local -a VALID_KEYVAL_OPTIONS=( -i/--input -j/--jobs -m/--memory -o/--output -k/--keep -s/--sort )
    local COMMAND_NAME="${FUNCNAME[0]}"
    
    local samFile
    local bamFile
    local sort
    local keep

    # ...............................................................
    #
    # Perform the processing to populate the OPTIONS and ARGS arrays.
    #
    # ...............................................................
    process_optargs "$@" || exit 1

    # ...............................................................
    #
    #                       Check SAM input file
    # This function DOES NOT ACCEPT data from pipelines (stream of data)
    # I find it not "smart/feasible" to hold such amount of info in memory.
    # ...............................................................
    if   is_in '-i'      "${!OPTIONS[@]}"; then samFile="${OPTIONS[-i]}"
    elif is_in '--input' "${!OPTIONS[@]}"; then samFile="${OPTIONS[--input]}"
    else
        feedback::sayfrom "${COMMAND_NAME}: Input file required." "error"
        echo
        exit  1
    fi



    # ...............................................................
    #
    #                        Check Output file
    #
    # samtools view -bS align.sam > align.unsorted.bam
    # We could also have an option to SORT the obtained bam:
    # samtools sort align.unsorted.bam -o align.sorted.bam
    #
    # ...............................................................
    if   is_in '-o'      "${!OPTIONS[@]}"; then bamFile="${OPTIONS[-o]}"
    elif is_in '--output' "${!OPTIONS[@]}"; then bamFile="${OPTIONS[--output]}"
    else
        # If not provided create a name based on input name.
        #outName=$(basename "${samFile}" | cut -d. -f1)
        outName=$(file::basename "${samFile}")
        outPath=$(file::dirname "${samFile}")

        bamFile="${outPath}/${outName}.bam"

    fi

    # To this point we have an $output name, wether based on input or used provided.
    # Check that file does not exist in local dir.
    go=$(file::file_exists "${bamFile}")
    
    # if exists, warn and quit.
    if [[ "${go}" -eq 0 ]];then
        feedback::sayfrom "File \"${bamFile}\" already exists in destination folder.\n
        I am not allowed to overwrite this kind of files. Please rename/move file or change output file name. Bye!." "Error"
        exit 1
    fi
    
    # ...............................................................
    #
    #                        Sort not to sort BAM file?
    #
    # ...............................................................
    
    # Check if -s was settled 
    if   is_in '-s'      "${!OPTIONS[@]}"; then sort="${OPTIONS[-s]}"
    #If not, check if --sort was settled
    elif is_in '--sort' "${!OPTIONS[@]}"; then sort="${OPTIONS[--sort]}"
    #If not then set it to default
    else
        sort="true"
    fi

    #To this point we should check that "sort" is a valid "true" or "false"
    if [ "$sort" != "true" ] && [ "$sort" != "false" ]; then

        feedback::sayfrom "${COMMAND_NAME}: -s/--sort options should be only true or false. Please check your options. Bye." "error"
        echo
        exit  1
    fi

    # ...............................................................
    #
    #                        KEEP OR NOT SAM FILE
    #
    # ...............................................................
    if   is_in '-k'      "${!OPTIONS[@]}"; then keep="${OPTIONS[-k]}"
    elif is_in '--keep' "${!OPTIONS[@]}"; then keep="${OPTIONS[--keep]}"
    else
        keep="true"
    fi

    #Check that we have a valid "keep" variable assignment.
    if [ "$keep" != true ] && [ "$keep" != false ]; then

        feedback::sayfrom "${COMMAND_NAME}: Unknown \"${keep}\" option  in -k/--keep. It should be only true or false. Please check your options. Bye." "error"
        echo
        exit  1
    fi

    

    # ...............................................................
    #
    #                         CREATE AND RUN THE FIRST COMMAND
    #
    # ................................................................

    # I really do not know why, but if I use the following code to run the command:
    # COMMAND="$BIOBASH_BIN_OS/bbsamtools/bin/samtools view -bS ${samFile}  > ${bamFile}"
    # ${COMMAND}
    #
    # The following error appears:
    # [E::idx_find_and_load] Could not retrieve index file for '/Users/andres/Dev/repo/sandbox/bbsam.sam'
    # samtools view: Random alignment retrieval only works for indexed SAM.gz, BAM or CRAM files.
    #
    # But if I just put the same code plain like here, it runs without any problem:

    $BIOBASH_BIN_OS/bbsamtools/bin/samtools view -bS ${samFile} > ${bamFile}


    # ...............................................................
    #
    #                        SORT IF NEEDED
    #
    # ................................................................
    if [[ "${sort}" == "true" ]]; then

        # This is necessary to rename the BAM file and append the "sorted" string.
        f=$(file::basename "${bamFile}")
        d=$(file::dirname "${bamFile}")
        sbf="${d}/${f}.sorted.bam"
        
        $BIOBASH_BIN_OS/bbsamtools/bin/samtools sort ${bamFile} -o ${sbf}

    fi

    # ...............................................................
    #
    #                        REMOVE SAM FILE IF ASKED
    #
    # ................................................................
    if [[ "${keep}" == "false" ]]; then
    
        rm ${samFile}

    fi

}

