
#!/usr/bin/env bash

# Beautifying outputs
source "$BASHUTILITY_LIB_PATH/feedback.sh";
source "$BASHUTILITY_LIB_PATH/variable.sh";
source "$SHML_LIB";

# Common functions for all unit tests

# Evaluates if the outcome of a given unit test is the desired one.
# $1 result
# $2 Expected outcome
eval_outcome() {

    #is this a string?
    variable::is_numeric "$1"
    #Capture the "return" from last called function
    returned=$?
    
    A=$(variable::is_numeric "${1}")
    B=$(variable::is_numeric "${2}")

    #----------------------------------------------------------------
    # Check if we are evaluating a string or a number.
    #----------------------------------------------------------------
    
    #1==FALSE meaning it is a string
    if [[ $returned -eq 1 ]];then
        if [ "$1" == "$2" ];then         
            echo -n  "[Success]"   #both strings are equal
        else     
            echo -n "[Failed]"  #both strings are different
        fi

    # So this is a number. But what kind?
    # If TRUE this is a float
    elif [[ $1 =~ [\.] || $2 =~ [\.] ]];then

            # Transform the comparison to a binary comparison using BC.
            # Output: 1 if equal, 0 if not equal.
            # Check: https://stackoverflow.com/questions/25612017/integer-expression-expected-bash
            v=$(echo "$1 == $2" | bc -l)

            if [ "$v" -eq "0" ]; then
                echo -n "[Failed]" 
            else
                echo -n "[Success]" 
            fi
    
    else
        # ok, it seems we are dealing with integers.
        if [ "$1" -ne "$2" ]; then
            echo -n "[Failed]" 
        else
            echo -n "[Success]" 
        fi
    fi
}

#
# Simple function to format unit tests output footer.
#
#
#
unit_test_footer(){

    echo ""
}

#
# Simple function to format unit tests output header.
#
#
#
unit_test_header(){
    
    file=$(echo ${0} | sed 's/test_//g')
    feedback::say "${file}" "notice"  
}

#
# Calculates the number of spaces for better output
#
# $1 string 1 (i.e. ./my_script)
# $2 string 2 (i.e. [ Success ])
#
unit_test_spacer(){
    
    eval string1="$1"
    eval string2="$2"
    
    #echo -n $string1


    local Z=60 #Available space
    local X=$(echo -n "${string1}" | awk '{print length}' | tr -d '\t')
    local Y=$(echo  -n "${string2}" | awk '{print length}' | tr -d '\t')

    # $S holds the space between script name and eval_outcome response.
    local S=$(echo "${Z}-${X}-${Y}" | bc)

    #Uncomment for debuggin'
    #echo "${Z}-${X}-${Y} = ${S}"


    echo -n "$(hr '.' ${S})"

    # Work on coloring
    if [ "${string2}" = "[Success]" ];then
        echo -n $(fgcolor green " ${string2}") $(fgcolor end)
    else
        echo -n $(fgcolor red " ${string2}") $(fgcolor end)
    fi

    
    

}