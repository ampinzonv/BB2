#!/usr/bin/env bash
# This file sets up the environment for BIOBASH to run. Basically
# it writes a set of environment variables  to .bashrc file.

source lib/shml/shml.sh


#Check that $HOME var is not empty. "-z" means IT IS EMPTY.
if [[ -z "${HOME}" ]];then
	echo "$(fgcolor red)The HOME variable is empty (that's weird!). Please fix this issue before installing BioBash.$(fgcolor end)"
	exit 1
fi

#Check that $HOME var is writable (one never knows).
if [ ! -w "${HOME}" ];then
	echo "$(fgcolor red)I can not write to HOME: ${HOME}. Please make sure you have the right permissions.$(fgcolor end)"
	exit 1
fi


# If we reached this point HOME is a valid path and it is writable.
# ----- check that  ~/.bashrc file exists ---------

if [[ ! -e "${HOME}/.bashrc" ]];then
	echo "
	$(fgcolor green) bashrc file is not present, so I will create one for you. This is safe and will not affect your
	system performance or configuration.$(fgcolor end)
	"
	#Flow control. Answer should be "y" or "n"
	continue=0
	until [ $continue  == "y" ] || [ $continue == "n" ]
	do
	    read -p 'Proceed? [y/n]: ' continue
	done

	if [[ $continue == "n" ]]; then
	    echo "
		$(fgcolor green)
	    Thank you for your interest in BioBash. Nothing done. Quitting installation.
    
	    Bye!
		$(fgcolor end)
	    "
	    exit 0
    
	elif [[ $continue == "y" ]];then
		echo "$(fgcolor green)Creating a brand new .bashrc file just for you!$(fgcolor end)"
		touch "${HOME}"/.bashrc 
		echo "#This file was automatically created by BioBash" >> "${HOME}"/.bashrc
	else
	    echo "ERROR: Installation could not proceed during creation of a new bashrc file. Unknown reason."
	    exit 1
	fi
fi


#------------    Check that BIOBASH_HOME is not pre-existent in bashrc   ----------
# To this point there is a .bashrc file, wether just created by this script or previously
# by the user/system.

# Nevertheless is KEY to check if the .bashrc file was previously modified by BioBash and
# variables are already present in that file. This is problematic because a new set of
# variables will be appended and a big conflict can arise from contradicting paths.
# That is way here we check that the current .bashrc file is not holding at least the 
# BIOBASH_HOME variable which is key the root of all other variables.

mod=$(grep -c "BIOBASH_HOME" "${HOME}"/.bashrc)
if [[ $mod -gt 0 ]];then
	echo " $(fgcolor red)
	$(emoji x) [ERROR]: The BIOBASH_HOME variable is present in your .bashrc file.
	This is due wether to a previous or an actual BioBash installation in
	your system.
	Since appending a new set of variables along with the old ones can create
	a conflict in your system, $(attribute bold 'INSTALLATION WILL BE STOPPED') $(attribute end).
	$(fgcolor end)

	$(fgcolor white) Nevertheless this can be fixed easily. Please fix your .bashrc file by taking 
	any of the following actions:

	1. Erasing the whole BioBash section from the ~/.bashrcfile.
	2. Running the bb_unistall_biobash utility.
	$(fgcolor end)
	"
	exit 1
fi


#------------      Backup bashrc        ----------
rightNow=$(date +%m-%d-%Y)

echo "
$(emoji bell) $(fgcolor yellow)[NOTICE]$(fgcolor end) $(fgcolor gray) In order to function properly, BioBash requires to modify 
  your $HOME/.bashrc file. Basically I will append some variables at 
  the end of the file and $(fgcolor end) $(fgcolor yellow)WILL NOT AFFECT$(fgcolor end) $(fgcolor gray)your actual configuration.
  Nevertheless I will also create a backup of your actual .bashrc file in 
  the same place where your actual.bashrc file is. This file will be 
  named: .bashrc_BB.backup.${rightNow} $(fgcolor end)
"
#Flow control. Answer should be "y" or "n"
continue=0
until [ $continue  == "y" ] || [ $continue == "n" ]
do
    read -p 'Proceed? [y/n]: ' continue
done

if [[ $continue == "n" ]]; then
	echo "
	$(fgcolor green)Thank you for your interest in BioBash.
	Nothing done. Quitting installation.
    
	Bye!
	$(fgcolor end)
    "
	exit 0
    
elif [[ $continue == "y" ]];then
	echo -n "$(fgcolor green) Creating a back up for your bashrc file. $(fgcolor end)"
	cp "$HOME"/.bashrc "$HOME"/.bashrc_BB.backup."${rightNow}"
	echo "$(fgcolor green)...Done!$(fgcolor end)"
else
	 echo "$(fgcolor yellow){ERROR}: Installation can not proceed. Unknown reason.$(fgcolor end)"
	 exit 1
fi


#------------    Check OPERAING SYSTEM   ----------
#
# Depending on the OS we are installing we will need to adapt
# the routes to pre-installed binaries and other stuff
#
# THIS ROUTINE IS DEPRECATED!
# I will keep here just "in case" we want to support OSX again?!
#By now this should always default to Linux.
#--------------------------------------------------------
if [ "$(uname)" == "Darwin" ]; then
    OS="osx"
    echo "$(fgcolor green) Adapting paths for OSX Darwin.$(fgcolor end)"
elif [ "$(uname)" == "Linux" ];then
    OS="linux"
    echo "$(fgcolor green) Adapting paths for Linux OS.$(fgcolor end)"
else
    echo " $(fgcolor red)
     Impossible to detect the operating system you are installing BioBash on.
	 Please select your operating system.:$(fgcolor end)
    "
    
    myos=0
    
    until [ $myos  == "Linux" ] || [ $myos == "OSX" ]
    do
        read -p ' Please select between: Linux or OSX: ' continue
    done
    
	#BE CAREFUL here with Linux (capital L) and linux.
    if [[ $myos == "Linux" ]];then

        OS="linux"

    elif [[ $myos == "OSX" ]];then

        OS="osx"

    else
        echo "$(fgcolor red)[ERROR] Unable to detect which Operating System we are working on. Quitting$(fgcolor end)"
        exit 1
    fi
    
fi


#------------    SYSTEM ARCHITECTURE   ----------
#
# Now that we have assesed the OS, let's determine the architecture.
# This info will be used to call appropriate pre-installed binaries (BLAST, seqkit etc)
# As well as to be aware of available cores.
#--------------------------------------------------------
if [[ $OS == "linux" ]];then

	numCores=$(cat /proc/cpuinfo | grep processor | wc -l)
	arch=$(getconf LONG_BIT)

elif [[ $OS == "osx" ]];then

	numCores=$(sysctl machdep.cpu.core_count | awk '{ print $2 }')
	arch=$(getconf LONG_BIT)

else
    echo "$(fgcolor red) [ERROR] Unable to detect which Operating System we are working on. Quitting$(fgcolor end)"
    exit 1
fi



if [ -n "$numCores" ] && [ "$numCores" -eq "$numCores" ] 2>/dev/null; then
	true
else

	echo "$(fgcolor yellow)[WARNING] Unable to determine the number of CPU cores in the systems. Defaulting to 1.
	This is not harmful but in some cases will slow down some routines that benefit from 
	multi-core architectures.$(fgcolor end)"

	numCores=1
fi



if [ -n "$arch" ] && [ "$arch" -eq "$arch" ] 2>/dev/null; then
	true
else

	echo "$(fgcolor yellow)[WARNING] Unable to determine the architechture of your system. Defaulting to 32bits.
	This is not harmful but in some cases will slow down BioBash because 32 bits versions of
	pre-installed software will be used.$(fgcolor end)"
	
	arch=32
fi


#------------    WRITE BASHRC   ----------

#--------------------------------------------------------
#This $1 variable comes from installbiobash script. Basically it is the installDir path +
# biobash version, converted into a directory.
echo "$(fgcolor green) Adding BIOBASH variables to bashrc file. $(fgcolor end)
"

BIOBASH_HOME=$1

BIOBASH_LIB="$BIOBASH_HOME/lib" # Holds all BB libraries including "Bio"
BIOBASH_BIN="$BIOBASH_HOME/bin" # Holds all the external software dependencies for Biobash
BIOBASH_OS="$OS"


SHML_LIB="$BIOBASH_LIB/shml/shml.sh" 
BASHUTILITY_LIB_PATH="$BIOBASH_LIB/bb_utility"   # This is a "fork" of bash-utility
BASHUTILITY_LIB="$BIOBASH_LIB/bash_utility.sh"   # Aggregates all the modules in one big file.
BIOBASH_NATIVE_LIB_PATH="$BIOBASH_LIB/Bio"
BIOBASH_NATIVE_LIB="$BIOBASH_LIB/biobash.sh"     # Aggregates all the modules in one big file.
BIOBASH_CORES=$numCores
BIOBASH_EXEC=$BIOBASH_HOME/exec  				 # Holds all the BB user executables (scripts).


if [[ $OS == "linux" ]];then
    BIOBASH_BIN_OS="$BIOBASH_BIN/$BIOBASH_OS/$arch"
fi
if [[ $OS == "osx" ]];then
    BIOBASH_BIN_OS="$BIOBASH_BIN/$BIOBASH_OS/$arch"
fi

# The following is a special case for software that is OS agnostic (ej. java-based).
BIOBASH_BIN_ALL="$BIOBASH_BIN/all"


# Since we are installing particular versions of BLAST, seqtk, clustalw (and maybe more)...
# BIOBASH_BIN_OS should not be exported to PATH only as env var. It could create conflicts with 
# existing versions of the same software installed by user. 
# Deprecated:
# export PATH="$BIOBASH_HOME:$BIOBASH_BIN_OS:$BIOBASH_BIN:\$PATH"
#
# Now using:
# export PATH="$BIOBASH_HOME:$BIOBASH_BIN:\$PATH"


echo "
#BIOBASH-BEGIN
# This section was automatically added to your .bashrc file by the
# BIOBASH installer on: ${rightNow}.
# A copy of your original .bashrc file was created with name: .bashrc_BB.backup.${rightNow}

# DO NOT modify below unless you are completely sure what you are doing
# otherwise BIOBASH may not function at all.
#

BIOBASH_HOME="$BIOBASH_HOME"
BIOBASH_LIB="$BIOBASH_LIB" 
BIOBASH_BIN="$BIOBASH_BIN"
BIOBASH_OS="$BIOBASH_OS"
BIOBASH_BIN_OS="$BIOBASH_BIN_OS"
BIOBASH_BIN_ALL="$BIOBASH_BIN_ALL"

SHML_LIB="$SHML_LIB"
BASHUTILITY_LIB_PATH="$BASHUTILITY_LIB_PATH"
BASHUTILITY_LIB="$BASHUTILITY_LIB"
BIOBASH_NATIVE_LIB_PATH="$BIOBASH_NATIVE_LIB_PATH"
BIOBASH_NATIVE_LIB="$BIOBASH_NATIVE_LIB"
BIOBASH_CORES="$BIOBASH_CORES"
BIOBASH_EXEC="$BIOBASH_EXEC"


export BIOBASH_HOME
export BIOBASH_LIB
export BIOBASH_BIN
export BIOBASH_OS
export BIOBASH_BIN_OS
export BIOBASH_BIN_ALL
export SHML_LIB
export BASHUTILITY_LIB_PATH
export BASHUTILITY_LIB
export BIOBASH_NATIVE_LIB_PATH
export BIOBASH_NATIVE_LIB
export BIOBASH_CORES
export BIOBASH_EXEC


export PATH="$BIOBASH_HOME:$BIOBASH_EXEC:\$PATH"

#BIOBASH-END
" >> "$HOME"/.bashrc

#Make all variables accesible to this shell.
source "$HOME"/.bashrc

#Create a flag to continue installation
touch environ_ok

exit 0
