#!/usr/bin/env bash
# A simple Script to create BioBash API documentation.
# Created by: ampinzonv@unal.edu.co

source $BASHUTILITY_LIB_PATH/file.sh
source $BASHUTILITY_LIB_PATH/date.sh

# Relevant paths and file names.
sourceFiles="${BIOBASH_LIB}"/Bio
docsBuildDir="${BIOBASH_HOME}/builddoc"
actualDate=$(date +%e%m%y-%H%M%S)
docFinalName=$(echo "publish.${actualDate}")

# Iterate over files
for i in $(ls "$sourceFiles"/*.sh);do

    #Retrieve base name
    baseName=$(file::basename "$i")
    echo $baseName

    # Create the MDs
    shdoc < "${i}" > "${baseName}".md

done

# Move MDs into MKDOCS default docs folder.
mv *.md "${docsBuildDir}"/docs


# Build static
cd "${docsBuildDir}"
mkdocs build

# rename site to reflect versions
mv site $docFinalName

# Publish
#scp -r "{$docFinalName}"/* 127.0.0.1:/var/html/sitio/
