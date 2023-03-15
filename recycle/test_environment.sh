#!/usr/bin/env bash
# This is a simple development file that checks that libraries
# are in the path and functions can be retrieved.

# Sourcing environmental file. 
# This file shall be the env.dev.sh file renamed.
echo "lib: $SHML_LIB"
echo "home: $HOME"
source $SHML_LIB
source $BASHUTILITY_LIB
source $BB_NATIVE_LIB

# The following functions are called from SHML library.
# https://odb.github.io/shml/getting-started/

echo "

### Testing SHML Library ###
"
echo $(fgcolor green "RZA GZA") $(fgcolor end)
echo "$(bgc green)NUH you know name, now give me my money!$(bgc end)"
echo "$(attribute underline "So Underlined") $(attribute end)"
echo "$(color red)$(icon xmark)$(color end)TPS Reports $(color green)$(icon check)$(color end)Fishing"


#https://labbots.github.io/bash-utility/
echo "

### Testing bash-utility Library ###
"
echo "Creating temp file:"
echo "$(file::make_temp_file)"

echo "File system is: "
os::detect_os
echo ""
os::detect_linux_distro
echo "String to array: "
string="holamundo"
array=( $(string::split "a,b,c" ",") )
printf "%s\n" ${array[@]}

## TESTING NATIVE  ##
feedback::sayfrom "I am a warning" "warn"
echo "Saying with say:"
feedback::say "I am an error message" "error"

echo "## TESTING SEQTK ##"
$BIOBASH_BIN/seqtk
