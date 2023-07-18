#!/usr/bin/env bash
# BioBash Module for Bio::File
# Created by: Andrés Pinzón (ampinzonv@unal.edu.co)
#  

source $BASHUTILITY_LIB_PATH/file.sh
source $BASHUTILITY_LIB_PATH/os.sh
source $BASHUTILITY_LIB_PATH/io.sh
source $BIOBASH_LIB/process_optargs.sh;


# @file BioBash File
# @brief 
#   Management and operations over bioinformatics related files.
#
# @description
# This module contains functions to operate over bioinformatics files not over
# its content (for that matter BBFormat or BBSeq could be a better option).
# For general operations over files of any kind refer to bb_utility/io.sh file.
#

# @description Checks if a file is valid fasta file. 
#
# @example
#   file::file_is_fasta -i/--input "./file.fa[,fasta]" 
#   #Output
#   Returns 0 if file is fasta, 1 if it is not.
#
# @arg -i/--input (mandatory) path to a file (unless input comes from pipe).
#
# @exitcode 0  On success 
# @exitcode 1  On failure
BBfile::is_fasta(){

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
#
# @example
#   file::file_is_multiple_fasta -i/--input file.fa[,fasta] 
#   #Output
#   0
#
# @arg -i/--input (mandatory) path to a file (unless input comes from pipe). 
#
# @exitcode 0  
# @exitcode 1  
BBfile::is_multiple_fasta(){
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
#
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
BBfile::is_fastq(){
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
# @arg -j/--jobs Number of CPU cores to use.
# 
# @exitcode 0  On succes
# @exitcode 1  On failure
BBfile::fastq_to_fasta(){

    # Initialise the necessary variables that will be checked / populated by process_optargs
    local -A OPTIONS=()
    local -a ARGS=()
    local -a VALID_FLAG_OPTIONS=( )
    local -a VALID_KEYVAL_OPTIONS=( -i/--input -o/--output -j/--jobs)
    local COMMAND_NAME="BBfile::fastq_to_fasta"
    local file pipe outFile jobs 


    
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

        # The following was commented since it does not make sense, this var was already
        # declared at the beginning of the function, nevertheles I keep it here as reference.
        # When uncommented it creates a conflict when the functions is called via STDIN without
        # any other argument, because in that case -i/--input is a not valid option.
        # local -a VALID_KEYVAL_OPTIONS=(-o/--output -j/--jobs)
        
        process_optargs "$@" || exit 1
        


        #file=$(io::get_data_stream)
        file=$(io::stream_to_tmp_file)

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
        
        # RUN 
        # This was a possible better option to avoid the overhead of writing to a file but
        #there are issues with this option and callinf this function froma  script via STDIN.
        #echo $file | $BIOBASH_BIN_OS/seqkit fq2fa $outFile $jobs

        $BIOBASH_BIN_OS/seqkit fq2fa ${file} ${outFile} ${jobs}
        exit 0
        
    fi

}

# @description 
#   Splits a multiple fasta file into single sequences, where:
#   1) If -o/--output is defined, a directory is created accordingly. 
#   2) If -o/--output is not defined, a directory is created IN THE SAME PATH where the input file resides
#   In both cases splitted files are named  after file name.
#   A similar behavior can be expected if data comes from STDIN and not from a file:
#   4) If -o/--output is defined, a directory is created accordingly. 
#   5) If -o/--output is not defined a directory named "stdin.split" is created. 
#   In both cases splitted files are prefixed with "stdin.part_"
#   If input is a compressed file, each outputed individual file is also compressed.
#
# @example
#   cat file.fasta
#   >A
#   AGCT
#   >B
#   TTTT
#   BBfile_multiple_fasta_to_singles "./file.fasta[.gz]" 
#   #Output
#   file.fasta[.gz].singles/clear
#       file.part_A.fasta[.gz]
#       file.part_B.fasta[.gz]
#   
#
# @arg -i/--input (mandatory) path to fastq file (overriden if data comes from STDIN).
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

    # defining a command like this in a variable, requires the use of "eval" below
    # Check this for more info:
    # https://stackoverflow.com/questions/4668640/how-can-i-execute-a-command-stored-in-a-variable
    # https://stackoverflow.com/questions/11065077/the-eval-command-in-bash-and-its-typical-uses
    #
    # The "-i" here means: split fasta files based on sequence ID.
    local RUN=$(echo -n "$BIOBASH_BIN_OS/seqkit split --quiet -i")
    
    # Args can be processed here...
    process_optargs "$@" || exit 1

    #-----------------------------------------------------------
    # Check if we have an output... 
    #-----------------------------------------------------------
    if   is_in '-o'      "${!OPTIONS[@]}"; then outDir=" -O ${OPTIONS[-o]}"
    elif is_in '--output' "${!OPTIONS[@]}"; then outDir=" -O ${OPTIONS[--output]}"
    else
        local outDir=""
    fi
    #-----------------------------------------------------------
    # Check if we have a parameter for parallel processing.
    #-----------------------------------------------------------
    jobs=""
    if   is_in '-j'      "${!OPTIONS[@]}"; then jobs="-j ${OPTIONS[-j]}"
    elif is_in '--jobs' "${!OPTIONS[@]}"; then jobs="-j ${OPTIONS[--jobs]}"
    else
        #use defaults
        local jobs=" -j $(os::default_number_of_cores)"
    fi
    
    

    #-----------------------------------------------------------
    # Test if we have a Data stream or a file.
    #-----------------------------------------------------------
    pipe=$(io::is_pipe)
    # "1" means __IT IS NOT__ a pipe.
    if [ "${pipe}" -eq 1 ]; then
    
        if   is_in '-i'      "${!OPTIONS[@]}"; then file="${OPTIONS[-i]}"  
            # RUN #
            eval "${RUN}" "${file}" "${outDir}" "${jobs}"

        elif is_in '--input' "${!OPTIONS[@]}"; then file="${OPTIONS[--input]}"

            # RUN #
            eval "${RUN}" "${file}" "${outDir}" "${jobs}"
                
        else
            feedback::sayfrom "$COMMAND_NAME: Input file required." "error"
            echo ""     
        fi

    else

        file=$(io::get_data_stream)

        # RUN #
        echo "${file}" | eval "${RUN}" "${outDir}" "${jobs}"
    
    fi

    #See: https://stackoverflow.com/questions/21476033/splitting-a-multiple-fasta-file-into-separate-files-keeping-their-original-names
    #For a possible solution based on AWK.
    
}


# @description 
#   Uncompresses a gunzipped file
# @example
#   BBfile::uncompress file.gz 
#   #Output
#   The uncompressed file to STDOUT
#
# @arg -i/--input path to compressed file.
# @arg -o/--outputh path to output file.
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

# @description 
#   Checks if a file is nucleotide or protein.
#
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
BBfile::guess_sequence_type(){
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
