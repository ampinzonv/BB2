#!/usr/bin/env bash

# @file File
# @brief Functions for handling files.

# @description Create temporary file.
# Function creates temporary file with random name. The temporary file will be deleted when script finishes.
#
# @example
#   echo "$(file::make_temp_file)"
#   #Output
#   tmp.vgftzy
#
# @noargs
#
# @exitcode 0  If successful.
# @exitcode 1 If failed to create temp file.
#
# @stdout file name of temporary file created.
file::make_temp_file() {
    declare temp_file
    type -p mktemp &> /dev/null && { temp_file="$(mktemp -u)" || temp_file="${PWD}/$((RANDOM * 2)).LOG"; }
    trap 'rm -f "${temp_file}"' EXIT
    printf "%s" "${temp_file}"
}

# @description Creates a tmp file from data stream.
# Function creates temporary file with random name from data stream. 
#
# @example
#   echo "$(file::make_file_from_stream)"
#   #Output
#   tmp.vgftzy
#
# @noargs
#
# @exitcode 0  If successful.
# @exitcode 1 If failed to create temp file.
#
# @stdout file name of temporary file created.






# @description Create temporary directory.
# Function creates temporary directory with random name. The temporary directory will be deleted when script finishes.
#
# @example
#   echo "$(utility::make_temp_dir)"
#   #Output
#   tmp.rtfsxy
#
# @arg $1 string Temporary directory prefix
# @arg $2  string Flag to auto remove directory on exit trap (true)
#
# @exitcode 0  If successful.
# @exitcode 1 If failed to create temp directory.
# @exitcode 2 Missing arguments.
#
# @stdout directory name of temporary directory created.
file::make_temp_dir() {
    [[ $# = 0 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
    declare temp_dir prefix="${1}" trap_rm="${2}"
    temp_dir=$(mktemp -d 2>/dev/null || mktemp -d -t "${prefix}")
    if [[ -n "${trap_rm}" ]]; then
        trap 'rm -rf "${temp_dir}"' EXIT
    fi
    printf "%s" "${temp_dir}"
}

# @description Get only the filename from string path.
#
# @example
#   echo "$(file::name "/path/to/test.md")"
#   #Output
#   test.md
#
# @arg $1 string path.
#
# @exitcode 0  If successful.
# @exitcode 2 Function missing arguments.
#
# @stdout name of the file with extension.
file::name() {
    [[ $# = 0 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
    printf "%s" "${1##*/}"
}

# @description Get the basename of file from file name.
#
# @example
#   echo "$(file::basename "/path/to/test.md")"
#   #Output
#   test
#
# @arg $1 string path.
#
# @exitcode 0  If successful.
# @exitcode 2 Function missing arguments.
#
# @stdout basename of the file.
file::basename() {
    [[ $# = 0 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2

    declare file basename
    file="${1##*/}"
    basename="${file%.*}"

    printf "%s" "${basename}"
}

# @description Get the extension of file from file name.
#
# @example
#   echo "$(file::extension "/path/to/test.md")"
#   #Output
#   md
#
# @arg $1 string path.
#
# @exitcode 0  If successful.
# @exitcode 1 If no extension is found in the filename.
# @exitcode 2 Function missing arguments.
#
# @stdout extension of the file.
file::extension() {
    [[ $# = 0 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
    declare file extension
    file="${1##*/}"
    extension="${file##*.}"
    [[ "${file}" = "${extension}" ]] && return 1

    printf "%s" "${extension}"
}

# @description Get directory name from file path.
#
# @example
#   echo "$(file::dirname "/path/to/test.md")"
#   #Output
#   /path/to
#
# @arg $1 string path.
#
# @exitcode 0  If successful.
# @exitcode 2 Function missing arguments.
#
# @stdout directory path.
file::dirname() {
    [[ $# = 0 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2

    declare tmp=${1:-.}

    [[ ${tmp} != *[!/]* ]] && { printf '/\n' && return; }
    tmp="${tmp%%"${tmp##*[!/]}"}"

    [[ ${tmp} != */* ]] && { printf '.\n' && return; }
    tmp=${tmp%/*} && tmp="${tmp%%"${tmp##*[!/]}"}"

    printf '%s' "${tmp:-/}"
}

# @description Get absolute path of file or directory.
#
# @example
#   file::full_path "../path/to/file.md"
#   #Output
#   /home/labbots/docs/path/to/file.md
#
# @arg $1 string relative or absolute path to file/direcotry.
#
# @exitcode 0  If successful.
# @exitcode 1  If file/directory does not exist.
# @exitcode 2 Function missing arguments.
#
# @stdout Absolute path to file/directory.
file::full_path() {
    [[ $# = 0 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
    declare input="${1}"
    if [[ -f ${input} ]]; then
        printf "%s/%s\n" "$(cd "$(file::dirname "${input}")" && pwd)" "${input##*/}"
    elif [[ -d ${input} ]]; then
        printf "%s\n" "$(cd "${input}" && pwd)"
    else
        return 1
    fi
}

# @description Get mime type of provided input.
#
# @example
#   file::mime_type "../src/file.sh"
#   #Output
#   application/x-shellscript
#
# @arg $1 string relative or absolute path to file/directory.
#
# @exitcode 0  If successful.
# @exitcode 1  If file/directory does not exist.
# @exitcode 2 Function missing arguments.
# @exitcode 3 If file or mimetype command not found in system.
#
# @stdout mime type of file/directory.
file::mime_type() {
    [[ $# = 0 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
    declare mime_type
    if [[ -f "${1}" ]] || [[ -d "${1}" ]]; then
        if type -p mimetype &> /dev/null; then
            mime_type=$(mimetype --output-format %m "${1}")
        elif type -p file &> /dev/null; then
            mime_type=$(file --brief --mime-type "${1}")
        else
            return 3
        fi
    else
        return 1
    fi
    printf "%s" "${mime_type}"
}

# @description Search if a given pattern is found in file.
#
# @example
#   file::contains_text "./file.sh" "^[ @[:alpha:]]*"
#   file::contains_text "./file.sh" "@file"
#   #Output
#   0
#
# @arg $1 string relative or absolute path to file/directory.
# @arg $2 string search key or regular expression.
#
# @exitcode 0  If given search parameter is found in file.
# @exitcode 1  If search paramter not found in file.
# @exitcode 2 Function missing arguments.
file::contains_text() {
    [[ $# -lt 2 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 1
    declare -r file="$1"
    declare -r text="$2"
    grep -q "$text" "$file"
}


# @description Chek if a file or directory exists.
#
# @example
#   file::file_exists "./file.sh" 
#   #Output
#   0
#
# @arg $1 string relative or absolute path to file/directory.
#
# @exitcode 0  If file exists.
# @exitcode 1  If file doe not exist.
# @exitcode 2 If missing arguments.
file::file_exists() {

    if [[ -z "$1" ]];then
        return=2 #Missing argument
    fi

    local -r file="$1"
    if [[ -e "$file" ]];then
        return=0
    else
        return=1
    fi
    
    echo "$return"
    exit 0
}


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
file::is_fasta()
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
file::is_multiple_fasta()
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
file::is_fastq()
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
file::guess_sequence_type()
{
    # This is not a trivial problem. actually A,C,G and T are also part of protein
    # sequences and it is hard to tell which is which with high confidence.
    # This link shows the discussion about it:  https://www.biostars.org/p/82471/
    #
    # So it seems that the best approach is to check for he general sequence content
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

