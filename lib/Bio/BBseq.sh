#!/usr/bin/env bash
# BioBash Module for Bio::Seq
# Created by: Andrés Pinzón (ampinzonv@unal.edu.co)
#  
# @description
# This module contains functions to operate over sequences itself (DNA/RNA/Protein)
# things like extract fasta headers, translate, count number of entries should beplaced here.

source $BASHUTILITY_LIB_PATH/file.sh


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
# Invoked without modifieres shows all info:
#   BBSeq::get_fasta_components "./file.fa[,fasta]" 
#   #Output (tab separated one row per sequence)
#   SeqID   Description   Sequence  
#  When invoked with a modifier (-h, -d and/or -s) Displays appropriate info:
#  -h: header, -d sequence ID, -s Sequences
# 
#
# @arg $1 path to a file.
# @arg $2 (optional) Any modifier or a set of them 
#
# @exitcode 0  on success
# @exitcode 1  on failure
BBSeq::get_fasta_components()
{

    # Test different options we have:
    # a) Just Fasta file provided
    # b) Fasta file + one argument (h, d or s)
    # c) Fasta file + two arguments (hd, hs, ds)
    # d) Fasta file +  three arguments (which defualts to case "a")


    # Fasta file only provided
    if [ $# -eq 1  ];then
        cat $1 | awk 'BEGIN {RS = ">"; FS = "\n"} NR>1{printf "%s\t", ">"$1} {for(i=2;i<=NF;i+=1) printf "%s", $i}{printf "%s","\n"}'
    else
        # agiven argument was provided

        echo "Con argumentos"
    fi
}