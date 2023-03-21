#!/usr/bin/env bash
# BioBash Module for Bio::IO
# Created by: Andrés Pinzón (ampinzonv@unal.edu.co)
#  
# @description
# This module contains functions to manage IO specifically related to bioinformatics data.
# This module handles specific operations over bioinformatics files, such as:
# convert from one format to other, validate if a file is  a valid fastq or fasta file.
#
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
