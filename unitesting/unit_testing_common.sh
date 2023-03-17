
#!/usr/bin/env bash

# Beautifying outputs
source "$BASHUTILITY_LIB_PATH/feedback.sh";
source "$BASHUTILITY_LIB_PATH/variable.sh";

# Common functions for all unit tests

# Evaluates if the outcome of a given unit test is the desired one.
# $1 result
# $2 Expected outcome
eval_outcome() {

    #is this a string?
    variable::is_numeric "$1"
    #Capture the "return" from last called function
    returned=$?

    #----------------------------------------------------------------
    # Check if we are evaluating a string or a number.
    #----------------------------------------------------------------
    
    #1==FALSE meaning it is a string
    if [[ $returned -eq 1 ]];then
        if [ "$1" == "$2" ];then         
            feedback::say "Success!" "success"  #both strings are equal
        else     
            feedback::say "Failed" "error" #both strings are different
        fi

    # So this is a number. But what kind?
    # If TRUE this is a float
    elif [[ $1 =~ [\.] || $2 =~ [\.] ]];then

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
        # ok, it seems we are dealing with integers.
        if [ "$1" -ne "$2" ]; then
            feedback::say "Failed" "error"
        else
            feedback::say "Success!" "success"
        fi
    fi
}