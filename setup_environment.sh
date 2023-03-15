#!/usr/bin/env bash
# This file sets up the environment for BIOBASH to run. Basically
# it writes a set of environment variables  to .bashrc file.

source lib/shml/shml.sh


#Check that $HOME var is not empty. "-z" means IT IS EMPTY.
if [[ -z "${HOME}" ]];then
	echo "The HOME variable is empty (that's weird!). Please fix this issue before installing BioBash."
	exit 1
fi

#Check that $HOME var is writable (one never knows).
if [ ! -w "${HOME}" ];then
	echo "I can not write to HOME: ${HOME}. Please make sure you have the right permissions."
	exit 1
fi


# If we reached this point HOME is a valid path and it is writable.
# ----- check that  ~/.bashrc file exists ---------

if [[ ! -e "${HOME}/.bashrc" ]];then
	echo "bashrc file is not present, so I will create one for you. This is safe and will not affect your
	system performance or configuration.
	"
	#Flow control. Answer should be "y" or "n"
	continue=0
	until [ $continue  == "y" ] || [ $continue == "n" ]
	do
	    read -p 'Proceed? [y/n]: ' continue
	done

	if [[ $continue == "n" ]]; then
	    echo "
	    Thank you for your interest in BioBash.
	    Nothing done. Quitting installation.
    
	    Bye!
    
	    "
	    exit 0
    
	elif [[ $continue == "y" ]];then
		echo "Creating a brand new .bashrc file just for you!"
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
	echo " 
	$(emoji x) [ERROR]: The BIOBASH_HOME variable is present in your .bashrc file.
	This can be due to a previous BioBash installation. Since appending a new set of variables
	along with the old ones can create a conflict in your system, $(attribute bold 'INSTALLATION WILL BE STOPPED') $(attribute end).
	Please fix your .bashrc file by erasing the whole BioBash section and re-try this installation.
	"
	
	exit 1
fi


#------------      Backup bashrc        ----------
rightNow=$(date +%m-%d-%Y)

echo "
$(emoji bell) [NOTICE!] In order to function properly, BioBash requires to modify your $HOME/.bashrc file.
Basically I will append some variables at the end and will not modify your pre-existent
configuration.
Nevertheless I will also create a backup of your actual .bashrc file in the same place where your actual
.bashrc file is. This file will be named: .bashrc_BB.backup.${rightNow}
"
#Flow control. Answer should be "y" or "n"
continue=0
until [ $continue  == "y" ] || [ $continue == "n" ]
do
    read -p 'Proceed? [y/n]: ' continue
done

if [[ $continue == "n" ]]; then
	echo "
	Thank you for your interest in BioBash.
	Nothing done. Quitting installation.
    
	Bye!
    "
	exit 0
    
elif [[ $continue == "y" ]];then
	echo "Creating back up."
	cp "$HOME"/.bashrc "$HOME"/.bashrc_BB.backup."${rightNow}"
	echo "Done."
else
	 echo "ERROR: Installation can not proceed. Unknown reason."
	 exit 1
fi


#------------    Check OPERAING SYSTEM   ----------
#
# Depending on the OS we are installing we will need to adapt
# the routes to pre-installed binaries and other stuff
#--------------------------------------------------------
if [ "$(uname)" == "Darwin" ]; then
    OS="osx"
    echo "OSX Darwin detected."
elif [ "$(uname)" == "Linux" ];then
    OS="linux"
    echo "Linux OS detected."
else
    echo "
    Impossible to detect the operating system you are installing BioBash on.
	Please manually select your operating system.:
    "
    
    myos=0
    
    until [ $myos  == "Linux" ] || [ $myos == "OSX" ]
    do
        read -p 'Please select between: Linux or OSX: ' continue
    done
    
	#BE CAREFUL here with Linux (capital L) and linux.
    if [[ $myos == "Linux" ]];then

        OS="linux"

    elif [[ $myos == "OSX" ]];then

        OS="osx"

    else
        echo "[ERROR] Unable to detect which Operating System we are working on. Quitting"
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
    echo "[ERROR] Unable to detect which Operating System we are working on. Quitting"
    exit 1
fi



if [ -n "$numCores" ] && [ "$numCores" -eq "$numCores" ] 2>/dev/null; then
	true
else

	echo "[WARNING] Unable to determine the number of CPU cores in the systems. Defaulting to 1.
	This is not harmful but in some cases will slow down some routines that benefit from 
	multi-core architectures."

	numCores=1
fi



if [ -n "$arch" ] && [ "$arch" -eq "$arch" ] 2>/dev/null; then
	true
else

	echo "[WARNING] Unable to determine the architechture of your system. Defaulting to 32bits.
	This is not harmful but in some cases will slow down BioBash because 32 bits versions of
	pre-installed software will be used."
	
	arch=32
fi


#------------    WRITE BASHRC   ----------

#--------------------------------------------------------
#This $1 variable comes from installbiobash script. Basically it is the installDir path +
# biobash version, converted into a directory.
BIOBASH_HOME=$1

BIOBASH_LIB="$BIOBASH_HOME/lib"
BIOBASH_BIN="$BIOBASH_HOME/bin"
BIOBASH_OS="$OS"


SHML_LIB="$BIOBASH_LIB/shml/shml.sh" 
BASHUTILITY_LIB_PATH="$BIOBASH_LIB/bash-utility"
BASHUTILITY_LIB="$BASHUTILITY_LIB_PATH/bash_utility.sh"
BIOBASH_NATIVE_LIB_PATH="$BIOBASH_LIB/bb_native"
BIOBASH_NATIVE_LIB="$BB_NATIVE_LIB_PATH/bb_native.sh"
BIOBASH_CORES=$numCores

if [[ $OS == "linux" ]];then
    BIOBASH_BIN_OS="$BIOBASH_BIN/$BIOBASH_OS/$arch"
fi
if [[ $OS == "osx" ]];then
    BIOBASH_BIN_OS="$BIOBASH_BIN/$BIOBASH_OS/$arch"
fi


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

SHML_LIB="$SHML_LIB"
BASHUTILITY_LIB_PATH="$BASHUTILITY_LIB_PATH"
BASHUTILITY_LIB="$BASHUTILITY_LIB"
BIOBASH_NATIVE_LIB_PATH="$BIOBASH_NATIVE_LIB_PATH"
BIOBASH_NATIVE_LIB="$BIOBASH_NATIVE_LIB"
BIOBASH_CORES="$BIOBASH_CORES"


export BIOBASH_HOME
export BIOBASH_LIB
export BIOBASH_BIN
export BIOBASH_OS
export BIOBASH_BIN_OS
export SHML_LIB
export BASHUTILITY_LIB_PATH
export BASHUTILITY_LIB
export BIOBASH_NATIVE_LIB_PATH
export BIOBASH_NATIVE_LIB
export BIOBASH_CORES


export PATH="$BIOBASH_HOME:$BIOBASH_BIN:\$PATH"

#BIOBASH-END
" >> "$HOME"/.bashrc

#Make all variables accesible to this shell.
source "$HOME"/.bashrc

#Create a flag to continue installation
touch environ_ok

exit 0
