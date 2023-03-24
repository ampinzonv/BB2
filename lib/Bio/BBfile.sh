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



# @description Checks if a file is valid fasta file. 
# @example
#   file::file_is_fasta "./file.fa[,fasta]" 
#   #Output
#   0, 1 or 2.
#
# @arg $1 path to a file.
#
# @exitcode 0  
# @exitcode 1  
# @exitcode 2 
BBfile::is_fasta()
{
    declare fastaFile=$1
    if [ "$(grep -c "^>" $fastaFile)" -ge 1 ]; then
        return=0
    else
        return=1
    fi

    #return
    echo "$return"    
    exit 0

}



# @description Checks if a file is a valid multiple fasta.
# @example
#   file::file_is_multiple_fasta "./file.fa[,fasta]" 
#   #Output
#   0
#
# @arg 
#
# @exitcode 0  
# @exitcode 1  
# @exitcode 2 
BBfile::is_multiple_fasta()
{
    declare fastaFile=$1

    if [ "$(grep -c "^>" $fastaFile)" -ge 2 ]; then
        return=0
    else
        return=1
    fi

    #return
    echo "$return"
    exit
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
    #tomar la primera linea
    declare fastqFile=$1
    firstLine=$(head -n 1 $fastqFile)

    # ver si comienza con un "@"
    if [ "$(echo "$firstLine" | grep -c "^@")" -ge 1 ]; then
        return=0
    elif [ "$(echo "$firstLine" | grep -c "^@")" -lt 1 ]; then
        return=1
    else
        return=2
    fi

    echo "$return"
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
# @arg $1 path to fastq file.
# @arg $2 name for compressed output. If ".gz" extension addedd then it is compressed.
# 
# @exitcode 0  
# @exitcode 1  
BBfile::fastq_to_fasta(){

    if [ -z "$2" ];then
        outFile=" "
    else
        outFile="-o $2"
    fi

    $BIOBASH_BIN_OS/seqkit fq2fa $1 $outFile
}

# @brief Splits a multiple fasta file into single sequences.
# @description Splits a multiple fasta file into single sequences, where
# each sequence file is named using input file name and the description in the header fasta.
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
# @arg $1 path to fastq file.
# @arg $2 (optional) Output directory.
# 
# @exitcode 0  
# @exitcode 1
BBfile::multiple_fasta_to_singles(){

    # If outdir was not defined, create an output name to avoid seqkit weird behaviour
    # Note that by default seqkit outputs to the same directory where input file is.
    # We want to output to the current directory. 
    if [ -z "$2" ];then
            name=$(file::name $1)
            outDir=$(echo "${name}.singles")
        else
            outDir="$2"
    fi

    # Uncomment for debuggin'
    # echo "$BIOBASH_BIN_OS/seqkit split --quiet -i $1 -O $outDir"
    $BIOBASH_BIN_OS/seqkit split --quiet -i $1 -O ./$outDir

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

    # note that this does the same that zcat, but the latter fails in OSX.
    gunzip -c $1

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
