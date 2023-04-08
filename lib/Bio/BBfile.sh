#!/usr/bin/env bash
# BioBash Module for Bio::File
# Created by: Andrés Pinzón (ampinzonv@unal.edu.co)
#  
# @description
# This module contains functions to operate over bioinformatic files not over
# its content (for that matter BBFormat or BBSeq could be a better option).
# For general operations over files of any kind refer to bb_utility/io.sh file.
#

source $BASHUTILITY_LIB_PATH/file.sh
source $BASHUTILITY_LIB_PATH/os.sh
source $BASHUTILITY_LIB_PATH/io.sh
source $BIOBASH_LIB/process_optargs.sh;



# @description Checks if a file is valid fasta file. 
# @example
#   file::file_is_fasta -i/--input "./file.fa[,fasta]" 
#   #Output
#   Returns 0 if file is fasta, 1 if it is not.
#
# @arg -i/--input (mandatory) path to a file (unless input comes from pipe).
#
# @exitcode 0  On success 
# @exitcode 1  On failure
BBfile::is_fasta()
{

    # Initialise the necessary variables that will be checked / populated by process_optargs
    local -A OPTIONS=()
    local -a ARGS=()
    local -a VALID_FLAG_OPTIONS=( )
    #
    local COMMAND_NAME="BBfile::is_fasta"

    
    #----------------------------------------------------------------
    #          Data stream?   
    #----------------------------------------------------------------
    pipe=$(io::is_pipe)
    
    # "1" means __IT IS NOT__ a pipe.
    if [ "${pipe}" -eq 1 ]; then

        local -a VALID_KEYVAL_OPTIONS=( -i/--input )
        # Perform the processing to populate the OPTIONS and ARGS arrays.
        process_optargs "$@" || exit 1

        # Since is not pipe (data stream) we suposse it is a file
        # therefore we assign the value assigned to -i/--input key to "$file"".
        if   is_in '-i'      "${!OPTIONS[@]}"; then file="${OPTIONS[-i]}"
        elif is_in '--input' "${!OPTIONS[@]}"; then file="${OPTIONS[--input]}"

            # RUN #
            run=$(grep -c -m 1 "^>" "${file}")
            

        else
            #If -i/--input is not present then there is an error
            feedback::sayfrom "$COMMAND_NAME: Input file required." "error"
            echo ""
            exit  1
        fi
    else
        # If we are here it means we are dealing with data stream.
        local -a VALID_KEYVAL_OPTIONS=()
        process_optargs "$@" || exit 1

        
        # Data stream has to be captured. Note that the $file variabe in this case holds a data stream and
        # not a file. We keep the same name for further consistency in the script.
        file=$(io::get_data_stream)
        
        # RUN #
        run=$(echo -n "${file}" | grep -c "^>" -m 1)
        
    fi

    #----------------------------------------------------------------
    #                       RETURN
    #----------------------------------------------------------------
    # If the number of ">" is equal or greater than 1, is fasta.
    if [ "${run}" -ge 1 ]; then
        return=0
    else
        return=1
    fi

    #return
    printf "${return}"   

    exit 0 
}



# @description Checks if a file is a valid multiple fasta.
# @example
#   file::file_is_multiple_fasta -i/--input file.fa[,fasta] 
#   #Output
#   0
#
# @arg -i/--input (mandatory) path to a file (unless input comes from pipe). 
#
# @exitcode 0  
# @exitcode 1  
BBfile::is_multiple_fasta()
{
    # Initialise the necessary variables that will be checked / populated by process_optargs
    local -A OPTIONS=()
    local -a ARGS=()
    local -a VALID_FLAG_OPTIONS=( )
    #
    local COMMAND_NAME="BBfile::is_multiple_fasta"

    #----------------------------------------------------------------
    #          Data stream?   
    #----------------------------------------------------------------
    pipe=$(io::is_pipe)
    
    # "1" means __IT IS NOT__ a pipe.
    if [ "${pipe}" -eq 1 ]; then
        local -a VALID_KEYVAL_OPTIONS=( -i/--input )
        process_optargs "$@" || exit 1

        if   is_in '-i'      "${!OPTIONS[@]}"; then file="${OPTIONS[-i]}"
        elif is_in '--input' "${!OPTIONS[@]}"; then file="${OPTIONS[--input]}"
        
            # RUN #
            run=$(grep -c -m 2 "^>" "${file}")
        else
            feedback::sayfrom "$COMMAND_NAME: Input file required." "error"
            echo ""
            exit  1
        fi

    else
        #DATA COMES FROM STREAM
        local -a VALID_KEYVAL_OPTIONS=()
        process_optargs "$@" || exit 1

        file=$(io::get_data_stream)
        
        # RUN #
        run=$(echo -n "${file}" | grep -c "^>" -m 2)
        
    fi

    #----------------------------------------------------------------
    #                       RETURN
    #----------------------------------------------------------------
    if [ "${run}" -ge 2 ]; then
        return=0
    else
        return=1
    fi

    #return
    printf "${return}"   
    exit 0 
}


# @description Checks if a file is valid fastq file.
# @example
#   file::is_fastq "./file.fq" 
#   #Output
#   0
#
# @arg $1 path to fastq file.
#
# @exitcode 0  
# @exitcode 1  
# @exitcode 2 
BBfile::is_fastq()
{
    # Initialise the necessary variables that will be checked / populated by process_optargs
    local -A OPTIONS=()
    local -a ARGS=()
    local -a VALID_FLAG_OPTIONS=( )
    #
    local COMMAND_NAME="BBfile::is_fastq"

    
     #----------------------------------------------------------------
    #          Data stream?   
    #----------------------------------------------------------------
    pipe=$(io::is_pipe)
    
    # "1" means __IT IS NOT__ a pipe.
    if [ "${pipe}" -eq 1 ]; then

        local -a VALID_KEYVAL_OPTIONS=( -i/--input )
        # Perform the processing to populate the OPTIONS and ARGS arrays.
        process_optargs "$@" || exit 1

        # Check input file (REQUIRED!)
        if   is_in '-i'      "${!OPTIONS[@]}"; then file="${OPTIONS[-i]}"
        elif is_in '--input' "${!OPTIONS[@]}"; then file="${OPTIONS[--input]}"
        
            firstLine=$(head -n 1 $file)
            
        else
            feedback::sayfrom "$COMMAND_NAME: Input file required." "error"
            echo ""
            exit  1
        fi
    else
        # If we are here it means we are dealing with data stream.
        local -a VALID_KEYVAL_OPTIONS=()
        process_optargs "$@" || exit 1

        
        # Data stream has to be captured. Note that the $file variabe in this case holds a data stream and
        # not a file. We keep the same name for further consistency in the script.
        file=$(io::get_data_stream)
        firstLine=$(echo $file | head -n 1)
    fi

    # RUN #
    run=$(echo "${firstLine}" | grep -c "^@")

    if [ "${run}" -ge 1 ]; then
        return=0
    elif [ "${run}" -lt 1 ]; then
        return=1
    else
        return=2
    fi

    echo "${return}"
    exit
}



# @brief converts a fastq file to a fasta format (compressed or uncompressed in GZ format).
# @description Transforms a fastq file into a fasta file.
# if only the fastq file argument is given it outputs the fasta format in STDOUT.
# This input file can be compressed in gz format.
# If a second (optional) argument is given (a string containing the desired name for FASTA output file)
# STDOUT is then redirected to a file. If the string has a ".gz" extension, the output is also compressed.
# 
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
#
# @arg -i/--input (Mandatory) path to fastq file.
# @arg -o/--output (Optional. Default STDOUT) name for output file. If ".gz" extension addedd then it is compressed.
# 
# @exitcode 0  
# @exitcode 1  
BBfile::fastq_to_fasta(){

    # Initialise the necessary variables that will be checked / populated by process_optargs
    local -A OPTIONS=()
    local -a ARGS=()
    local -a VALID_FLAG_OPTIONS=( )
    local -a VALID_KEYVAL_OPTIONS=( -i/--input -o/--output -j/--jobs)
    local COMMAND_NAME="BBfile::fastq_to_fasta"



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

# @brief Splits a multiple fasta file into single sequences.
# @description Splits a multiple fasta file into single sequences, where
# each sequence file is named using the input file name and the description in the header fasta.
#  If an outdir is not defined, a directory is created and named after the input file name
# plus the .singles extension. If input is a compressed file, each outputed individual file is also compressed.
# PLEASE notice that this function ALWAYS OUTPUTS to the current directory, even if you define the output
# as a complete path. For example a command like:
#
# BBfile::multiple_fasta_to_singles input.fa /home/andres/outputs
#
# Will put the single files in ./home/andres/outputs so it will create the whole directory tree
# from ./home to outputs and put the files there.
#
# @example
#   cat file.fasta
#   >A
#   AGCT
#   >B
#   TTTT
#
#
#   BBfile_multiple_fasta_to_singles "./file.fasta[.gz]" 
#   #Output
#   file.fasta[.gz].singles/clear
#       file.part_A.fasta[.gz]
#       file.part_B.fasta[.gz]
#   
#
#
# @arg -i/--input (mandatory) path to fastq file.
# @arg -o/--output (optional) Output directory.
# @arg -j/--jobs (optional) Number of cores to use. See documentation for default number (usually 1).
# 
# @exitcode 0  
# @exitcode 1
BBfile::multiple_fasta_to_singles(){

    # Initialise the necessary variables that will be checked / populated by process_optargs
    local -A OPTIONS=()
    local -a ARGS=()
    local -a VALID_FLAG_OPTIONS=( )
    local -a VALID_KEYVAL_OPTIONS=( -i/--input -o/--output -j/--jobs)
    local COMMAND_NAME="BBfile::multiple_fasta_to_singles"

    # Perform the processing to populate the OPTIONS and ARGS arrays.
    process_optargs "$@" || exit 1

    #----------------------------------------------------------------
    # WE NEED A FILE TO CONTINUE
    #----------------------------------------------------------------
    # Check input file (REQUIRED!)
    if   is_in '-i'      "${!OPTIONS[@]}"; then file="${OPTIONS[-i]}"
    elif is_in '--input' "${!OPTIONS[@]}"; then file="${OPTIONS[--input]}"
    else
        feedback::sayfrom "$COMMAND_NAME: Input file required." "error"
        echo ""
        exit  1
    fi

    #Check if we have a second parameter. Note that seqkit output option is also "-o"
    if   is_in '-o'      "${!OPTIONS[@]}"; then outDir="${OPTIONS[-o]}"
    elif is_in '--output' "${!OPTIONS[@]}"; then outDir="${OPTIONS[--output]}"
    else
        name=$(file::name $file)
        outDir=$(echo "${name}.singles")
    fi

     #Check if we have a second parameter. Note that seqkit output option is also "-o"
    if   is_in '-o'      "${!OPTIONS[@]}"; then outDir="${OPTIONS[-o]}"
    elif is_in '--output' "${!OPTIONS[@]}"; then outDir="${OPTIONS[--output]}"
    else
        name=$(file::name $file)
        outDir=$(echo "${name}.singles")
    fi


    #Check if we have a third parameter for parallel processing.
    jobs=""
    if   is_in '-j'      "${!OPTIONS[@]}"; then jobs="-j ${OPTIONS[-j]}"
    elif is_in '--jobs' "${!OPTIONS[@]}"; then jobs="-j ${OPTIONS[--jobs]}"
    else
        #use defaults
        jobs=" -j $(os::default_number_of_cores)"
    fi

    # Uncomment for debuggin'
    #echo "$BIOBASH_BIN_OS/seqkit split --quiet -i ${file} -O ${outDir} ${jobs}"
    $BIOBASH_BIN_OS/seqkit split --quiet -i ${file} -O ./${outDir} ${jobs}

    #See: https://stackoverflow.com/questions/21476033/splitting-a-multiple-fasta-file-into-separate-files-keeping-their-original-names
    #For a possible solution based on AWK.
}


# @description Uncompresses a gunzipped file
# @example
#   BBfile::uncompress file.gz 
#   #Output
#   The uncompressed file to STDOUT
#
# @arg $1 path to compressed file.
#
# @exitcode 0  on success
# @exitcode 1  on failure
BBfile::uncompress(){


    # Initialise the necessary variables that will be checked / populated by process_optargs
    local -A OPTIONS=()
    local -a ARGS=()
    local -a VALID_FLAG_OPTIONS=( )
    local -a VALID_KEYVAL_OPTIONS=( -i/--input -o/--output )
    local COMMAND_NAME="BBfile::uncompress"

    # Perform the processing to populate the OPTIONS and ARGS arrays.
    process_optargs "$@" || exit 1

    #----------------------------------------------------------------
    # WE NEED A FILE TO CONTINUE
    #----------------------------------------------------------------
    # Check input file (REQUIRED!)
    if   is_in '-i'      "${!OPTIONS[@]}"; then file="${OPTIONS[-i]}"
    elif is_in '--input' "${!OPTIONS[@]}"; then file="${OPTIONS[--input]}"
    else
        feedback::sayfrom "$COMMAND_NAME: Input file required." "error"
        echo ""
        exit  1
    fi

    # note that this does the same that zcat, but the latter fails in OSX.
    gunzip -c $file

}

# @description Checks if a file is nucleotide or protein.
# @example
#   file::guess_sequence_type "./file.fasta" 
#   #Output
#   0
#
# @arg $1 path to fasta file.
#
# @exitcode 0  
# @exitcode 1  
# @exitcode 2 
BBfile::guess_sequence_type()
{
    # This is not a trivial problem. actually A,C,G and T are also part of protein
    # sequences and it is hard to tell which is which with high confidence.
    # This link shows the discussion about it:  https://www.biostars.org/p/82471/
    #
    # So it seems that the best approach is to check for the general sequence content
    # over a pre-defined window of "n" bases.

    # Overall the algorithm to asses this could be something like:

    # 0) Ommit fasta header
    # 1) asses sequence length = TSL
    # 2) Start reading each base from position 1 towards the end (or a pre-defined threshold)
    # 3) count any occurrence of A, G, C OR T  until end or pre-defined threshold.
    # 4) if any of the following characters (E, F, I, L, P, or Q) appears then break. It is a PROTEIN!***
    # 5) If end is reached and A+G+C+T = TSL, most probably this is a Nucleotide sequence.
    
    
    # According to the official IUPAC code:
    # ***
    # http://www.bioinformatics.org/sms/iupac.html
    # E, F, I, L, P, and Q are exclusive for proteins. On the other hand the letter "B" is exclusive
    # to nucleotide sequences.

    # diff -y --suppress-common-lines prot.sort nuc.sort 
	#						      >	-
	#						      >	.
	#						      >	B
    # E							  <
    # F							  <
    # I							  <
    # L							  <
    # P							  <
    # Q							  <
    #                             > U

true 
}
