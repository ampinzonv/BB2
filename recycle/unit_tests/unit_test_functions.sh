#!/usr/bin/env bash

# Beautifying outputs
source "$BIOBASH_NATIVE_LIB_PATH/feedback.sh";

#Global vars. Common to all functions.
testData="$BIOBASH_HOME/testdata"
fromFile="Using input file: "
fromSTDIN="Using data from STDIN: "


#Dummy function
test_hello_world() {

    echo "Hello world"
}

#
# Evaluates if the outcome of a given unit test is the desired one.
# $1 result
# $2 Expected outcome
eval_outcome() {

    # Is this float?
    if [[ $1 =~ [\.] || $2 =~ [\.] ]]
        then
            # Transform the comparison to a binary comparison using BC.
            # Output: 1 if equal, 0 if not equal.
            # Check: https://stackoverflow.com/questions/25612017/integer-expression-expected-bash
            v=$(echo "$1 == $2" | bc -l)

            if [ "$v" -eq "0" ]; then
            feedback::say "Failed" "error"
        else
            feedback::say "Success!" "success"
        fi
    
    else
        # Since we have integer values we can make a direct comparison.
        if [ "$1" -ne "$2" ]; then
            feedback::say "Failed" "error"
        else
            feedback::say "Success!" "success"
        fi
    fi
}



test_count_seqs() {

    #Arrange
    feedback::say "...Testing: bb_count_seqs" "notice"
    inputFile=$testData/apoe.fasta
    script=$BIOBASH_BIN/bb_count_seqs
    outcome=1

    #Act
    A=$($script -i $inputFile)
    B=$(cat $inputFile | $script)


    #Assert
    printf "$fromFile"
    eval_outcome $A $outcome

    printf "$fromSTDIN"
    eval_outcome $B $outcome

    echo ""

}


test_extract_subset_from_list() {

    #Arrange
    feedback::say "...Testing: bb_extract_subset_from_list" "notice"
    inputFile=$testData/mets.lst
    script=$BIOBASH_BIN/bb_extract_subset_from_list
    outcome=1
    outcome2=12

    #Act
    A=$($script -i $inputFile -p ADP+ | wc -l)
    B=$(cat $inputFile | $script -p ADP+ -r | wc -l)


    #Assert
    printf "$fromFile"
    eval_outcome $A $outcome

    # Note that we are runnin $B with the "-r" option that is not tested with A.
    # I think it is not necessary to run all the possible options...
    printf "$fromSTDIN"
    eval_outcome $B $outcome2

    echo ""

}




test_get_fasta_headers() {

    #Arrange
    feedback::say "...Testing: bb_get_fasta_headers" "notice"
    inputFile=$testData/apoe.fasta
    script=$BIOBASH_BIN/bb_get_fasta_headers
    outcome=1

    #Act
    A=$($script -i $inputFile | wc -l)
    B=$(cat $inputFile | $script | wc -l)

    #Assert
    printf "$fromFile"
    eval_outcome $A $outcome

    printf "$fromSTDIN"
    eval_outcome $B $outcome

    echo ""

}

test_get_nr_list() {
    #Arrange
    feedback::say "...Testing: get_nr_list" "notice"
    inputFile=$testData/mets.lst
    script=$BIOBASH_BIN/bb_get_nr_list
    outcome=9
    outcome2=23.07

    #Act
    A=$($script -i $inputFile | wc -l)
    B=$(cat $inputFile | $script -f | head -n 1 | awk '{print $2}')

    #Assert
    printf "$fromFile"
    eval_outcome $A $outcome

    printf "$fromSTDIN"
    eval_outcome $B $outcome2

    echo ""
}

test_file_info() {

# NOTICE that this test only checks for the parsing of FASTA files.
  #Arrange
    feedback::say "...Testing: file_info" "notice"
    inputFile=$testData/apoe.fasta
    script=$BIOBASH_BIN/bb_file_info
    outcome=48.99

    #Act
    A=$($script -i $inputFile | awk '{print $9}')
    B=$(cat $inputFile | $script  |  awk '{print $9}')

    #Assert
    printf "$fromFile"
    eval_outcome $A $outcome

    printf "$fromSTDIN"
    eval_outcome $B $outcome

    echo ""
}
