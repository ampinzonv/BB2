#!/usr/bin/env bash
# Created by: Andrés Pinzón (ampinzonv@unal.edu.co)

source $BASHUTILITY_LIB_PATH/file.sh
source $BASHUTILITY_LIB_PATH/string.sh
source $BASHUTILITY_LIB_PATH/feedback.sh
source $BASHUTILITY_LIB_PATH/os.sh
source $BASHUTILITY_LIB_PATH/io.sh
source $BIOBASH_LIB/process_optargs.sh;

# @file BioBash Alignments
# @brief
#   Functions to handle sequence Alignments
#
# @description
#   BIOBASH module

# @brief Maps Fastq reads to reference genome.
# @description
# INPUT:
# This function takes a SE or PE fastq file and maps it to a reference genome.
# The PE file can be interleaved or separated into forward and reverse files.
# If PE files are provided as two separate fastq files the complete path to both files must be
# provided comma separated as follows even if both fastq files reside in the same directory:
#
# The following is CORRECT:
#  --input /complete/path/to/fastq1,/complete/path/to/fastq2
#  --input /other/path/to/fastq1,/different/path/to/fastq2
#  --input fastq1,fastq2
# (Note that for the latter it is assumed that fastq1 and fastq2 are in the local directory.)
#
#  The following is WRONG:
# --input /complete/path/to/fastq1,fastq2
# (UNLESS fastq2 is located in the current directory)
#
# The genome index provided is used (-x/--index option) for mapping, please note that this index MUST BE
# created with BBindex::genome_indexing (or BBMap), indexes created with Bowtie2 or other software will not work.
# The index MUST be located in a directory called "ref".
# If a path to a valid index is not provided, it will search for a index dir in local dir. If not found it will
# exit with errors.
# (use the BBindex::genome_indexing function in BioBash to create a valid index).
#

#
# OUTPUT:
# A SAM file is written to the path provided with the -o/--output option. If the ".gz" extension is also used, the output file
# will be then compressed accordingly using GZIP. If -o/--output not provided the name of the first input file will be used as base name
# and the ".sam" extension will be appended.
# If the file name exists in current directory program will stop before proceeding.
#
# @example
# The following example will use PE reads (comma separated) and output a compressed SAM file using a pre-defined reference genome:
#
#  $(BBalign::map_reads_to_genome -i read1.fq,read2.fq -x "path/to/indexDir" -m 64 --jobs 10 --output "results/align.sam.gz")
#
# The following example will use a SE (or interleaved) fastq file and output a raw (not compressed) SAM file. The index will be created
# on memory before running the actual mapping.
#
# $(BBalign::map_reads_to_genome -i reads.fq -m 64 --jobs 10 --output "results/align.sam")
#
# @arg  -i/--input    (required) path to fastq file(s). Comma separated if PE in different files.
# @arg  -j/--jobs     (optional) Number of CPU cores to use (default: use all available cores).
# @arg  -o/--output   (optional) Output SAM file name (default:same as input plus ".sam.gz" extension).
# @arg  -m/--memory   (optional) Amount of memory to be used IN GB FORMAT (default: all available memory).
# @arg  -x/--index    (required) Path to index directory.
BBalign::map_reads_to_genome(){

    # ...............................................................
    #
    # Initialise the necessary variables that will be checked / populated
    # by process_optargs.
    #
    # ...............................................................
    local -A OPTIONS=()
    local -a ARGS=()
    local -a VALID_FLAG_OPTIONS=(  )
    local -a VALID_KEYVAL_OPTIONS=( -i/--input -j/--jobs -m/--memory -o/--output -x/--index )
    local COMMAND_NAME="${FUNCNAME[0]}"

    local fastq
    local output
    local idx
    local jobs
    local mem

    # ...............................................................
    #
    # Perform the processing to populate the OPTIONS and ARGS arrays.
    #
    # ...............................................................
    process_optargs "$@" || exit 1


    # ...............................................................
    #
    #                       Check FASTQ input files
    # This function DOES NOT ACCEPT data from pipelines (stream of data)
    # so it requires a file. This is a characteristic of BBMAP.
    #
    # ...............................................................
    if   is_in '-i'      "${!OPTIONS[@]}"; then fastq="${OPTIONS[-i]}"
    elif is_in '--input' "${!OPTIONS[@]}"; then fastq="${OPTIONS[--input]}"
    else
        feedback::sayfrom "${COMMAND_NAME}: Input file required." "error"
        echo
        exit  1
    fi

    # If comma separated, split string into forward and reverse
    if [[ $fastq =~ "," ]];then
        # We will need this variable to know which command to create ...later.
        twoFiles=true

        array=( $(string::split "${fastq}" ",") )
        fastq="${array[0]}"
        fastq2="${array[1]}"

        # From: https://github.com/BioInfoTools/BBMap/blob/master/docs/UsageGuide.txt
        reads="in1=${fastq} in2=${fastq2}"

    else
        twoFiles=false

        # From: https://github.com/BioInfoTools/BBMap/blob/master/docs/UsageGuide.txt
        reads="in=${fastq}"
    fi


    # ...............................................................
    #
    #                        Check Output file
    #
    # ...............................................................
    if   is_in '-o'      "${!OPTIONS[@]}"; then output="${OPTIONS[-o]}"
    elif is_in '--output' "${!OPTIONS[@]}"; then output="${OPTIONS[--output]}"
    else
        # If not provided create a name based on fastq(s) name.
        #outName=$(basename "${fastq}" | cut -d. -f1)
        outName=$(file::basename "${fastq}")
        outPath=$(file::dirname "${fastq}")

        output="${outPath}/${outName}.sam"

    fi
    #To this point we have an $output name, wether based on input or used provided.
    # Check that file does not exist in local dir.
    go=$(file::file_exists "${output}")

    # if exists, warn and quit.
    if [[ "${go}" -eq 0 ]];then
        feedback::sayfrom "File \"${output}\" already exists in destination folder.\n
        I am not allowed to overwrite this kind of files. Please rename/move file or change output file name. Bye!." "Error"
        exit 1
    fi

    # Prepare output name to be used in command (out=reads.sam.gz)
    output="out=${output}"


    # ...............................................................
    #
    #                           CHECK INDEX
    # Note that BBMap default behaviour is to also index if a path to a reference genome
    # is provided. In that fashion user is able to map or index and map at the same time.
    # BB phylosophy is that each function does exactly ONE THING it is  wether you map or
    # you index but not both. That is why BB options here differ from the ones that
    # are allowed in BBMap. It means that in this function we are NOT ALLOWED to index just map.
    # ...............................................................

    # If provided we have an index in "path"
    if   is_in '-x'      "${!OPTIONS[@]}"; then idx="${OPTIONS[-x]}"
    elif is_in '--index' "${!OPTIONS[@]}"; then idx="${OPTIONS[--index]}"
    else
        # If empty or not provided, means that it will check for a index "ref" in local dir.
        idx=""
    fi

    # Let's check that "ref" directory exists in provided path.
    go=$(file::file_exists "${idx}/ref")
    if [[ "${go}" -eq 0 ]];then

        idx="path=${idx}"

    else

        feedback::sayfrom "Directory \"ref\" holding indexed references not found inside provided path: \" ${idx}\". Please check
        . Bye!." "Error"
        exit 1
    fi

    # ...............................................................
    #
    #                         CHECK FOR OTHER OPTIONALS
    #
    # ...............................................................

    #--Jobs
    if   is_in '-j'      "${!OPTIONS[@]}"; then jobs="${OPTIONS[-j]} "
    elif is_in '--jobs' "${!OPTIONS[@]}"; then jobs="${OPTIONS[--jobs]} "
    else
        #use defaults
        # NOTE: BB default number of cores is 1!!!!!!!!
        jobs="$(os::default_number_of_cores)"
    fi
    #Transform
    jobs="t=${jobs}"

    #--Memory
    if   is_in '-m'      "${!OPTIONS[@]}"; then mem="${OPTIONS[-m]} "
    elif is_in '--memory' "${!OPTIONS[@]}"; then mem="${OPTIONS[--memory]} "
    else
        #use defaults
        mem=$(os::show_system_memory "giga")
    fi
    mem="-Xmx${mem}g"

    # ...............................................................
    #
    #                         CREATE AND RUN THE COMMAND
    #
    # These are the possibilities
    # from: https://github.com/BioInfoTools/BBMap/blob/master/docs/guides/BBMapGuide.txt
    #
    # BBMap must index a reference before mapping to it, which is relatively fast.  By default, it will write
    # this index to disk so that it can be loaded more quickly next time, but this can be suppressed with the "nodisk" flag.
    # The index is written to the location /ref/.  In other words, if you run BBMap from the location /bob/work/,
    # then the directory /bob/work/ref/ will be created and an index written to it; if there is already an index at
    # that location which matches the reference you are using, the existing index will be loaded.
    # If it does not match, a new index will be written.  For example, if you do these steps in order:

    # 1) "bbmap.sh in=reads.fq" will look for an index in /ref/, not find anything, and so will quit without mapping.
    # 2) "bbmap.sh in=reads.fq ref=A.fa nodisk" will generate an index in memory and write nothing to disk.
    # 3) "bbmap.sh in=reads.fq ref=A.fa" will generate an index and write it to /ref/.
    # 4) "bbmap.sh in=reads.fq" will look for an index in /ref/, and load it.
    # 5) "bbmap.sh in=reads.fq ref=A.fa" will look in ref, see that A is already indexed, and load the existing index.
    # 6) "bbmap.sh in=reads.fq ref=B.fa" will overwrite the index in A with a new index for B.
    # 7) "bbmap.sh in=reads.fq ref=C.fa build=2" will write a new index for C in the /ref/ folder.  At this point there will be an index for be (stored as build 1) and an index for C (stored as build 2).
    # 8) "bbmap.sh in=reads.fq ref=D.fa path=/another/location/" will write an index for D into /another/location/ref/.
    # #
    # ...............................................................

    COMMAND="${BIOBASH_BIN}/all/bbmap/bbmap.sh ${reads} ${output} ${idx} ${jobs} ${mem}"

    # Run Forest ...run! (It is possible to redirect this output using: 1>out.txt 2>err.txt)
    ${COMMAND}

}

# @brief Runs the NCBI-BLAST implementation.
# @description
# This function runs  any of the following BLAST algorithms: blastn (and its variants such as megablast), blastp or blastx.
#
#
# INPUT:
# Although there are several options, this function requires only 2 inputs. 1) A valid fasta file. 2) A blast formatted database.
#
# For blastx it is important to note that it is possible to selectan appropriate genetic code for translation, using the "-c/--code" option.
# Please visit the following link for details:
# Genetic codes: https://www.ncbi.nlm.nih.gov/Taxonomy/taxonomyhome.html/index.cgi?chapter=cgencodes
#
#
# OUTPUT:
# @example
#
# @arg  -i/--input     (required) path to fasta.
# @arg  -d/--database  (required) Path to BLAST formatted query database.
# @arg  -j/--jobs      (optional) Number of CPU cores to use (default: use all available cores).
# @arg  -o/--output    (optional) Name for results file. Default same as input file but outputs to local dir.
# @arg  -f/--format    (optional) Format of  results file. It can be anything from 0 to 18. Defaults to 6 (Tabular).
# @arg  -h/--header    (optional) [flag] Print header line in results file. Only works when -f/--format is 6.
# @arg  -s/--strand    (optional) Strand to search on. It can be minus, plus or both (default). Do not work on blastx.
# @arg  -e/--evalue    (optional) Expected value. Defaults to 1E-3 (Note that differs from the value of 10 in NCBI-BLAST).
# @arg  -c/--code      (optional) In blastx, genetic code to use for DNA translation (See documentation for details). defaul: 1 (standard code).
# @arg  -a/--algorithm (optional) Blast type (algorithm): blastn (and its variants such as megablast), blastp or blastx only supported. Default: blastn).
# @arg  -t/--targets   (optional) Max number of target sequences (Any integer value >5). Default 250.




BBalign::run_blast(){

    local -A OPTIONS=()
    local -a ARGS=()
    local -a VALID_FLAG_OPTIONS=(  -h/--header )
    local -a VALID_KEYVAL_OPTIONS=( -i/--input -j/--jobs -o/--output -s/--strand -d/--database  -c/--code -a/--algorithm -f/--format -t/--targets -v/--evalue )
    local COMMAND_NAME="${FUNCNAME[0]}"

    local queryFile db header alg jobs mem output strand code format targets evalue

    # ...............................................................
    #
    # Perform the processing to populate the OPTIONS and ARGS arrays.
    #
    # ...............................................................
    process_optargs "$@" || exit 1

    # ...............................................................
    #
    #                       Check FLAGS
    #
    # ...............................................................
    if is_in '-h' "${!OPTIONS[@]}" || is_in '--header' "${!OPTIONS[@]}"
        then
        header="true"
    fi
    # ...............................................................
    #
    #                       CHECK OPTIONS
    # This function DOES NOT ACCEPT data from pipelines (stream of data)
    # so it requires a file. This is a characteristic of BLAST.
    #
    # ...............................................................
    #INPUT FILE
    if   is_in '-i'      "${!OPTIONS[@]}"; then queryFile="${OPTIONS[-i]}"
    elif is_in '--input' "${!OPTIONS[@]}"; then queryFile="${OPTIONS[--input]}"
    else
        feedback::sayfrom "${COMMAND_NAME}: Input file (-i/--input option) required." "error"
        echo
        exit  1
    fi

    #OUTPUT
    if   is_in '-o'      "${!OPTIONS[@]}"; then output="${OPTIONS[-o]} "
    elif is_in '--output' "${!OPTIONS[@]}"; then output="${OPTIONS[--output]} "
    else
        #use defaults
        output_a="$(file::basename ${queryFile})"
        output=$(echo -n "${output_a}.blast.out")
    fi

    #TARGET DATABASE
    if   is_in '-d'      "${!OPTIONS[@]}"; then db="${OPTIONS[-d]}"
    elif is_in '--database' "${!OPTIONS[@]}"; then db="${OPTIONS[--database]}"
    else
        feedback::sayfrom "${COMMAND_NAME}: Target database (-d/--database option) required." "error"
        echo
        exit  1
    fi

    #BLAST ALGORITHM
    if   is_in '-a'      "${!OPTIONS[@]}"; then alg="${OPTIONS[-a]}"
    elif is_in '--algorithm' "${!OPTIONS[@]}"; then alg="${OPTIONS[--algorithm]}"
    else
        alg="blastn"
    fi

    #JOBS
    if   is_in '-j'      "${!OPTIONS[@]}"; then jobs="${OPTIONS[-j]} "
    elif is_in '--jobs' "${!OPTIONS[@]}"; then jobs="${OPTIONS[--jobs]} "
    else
        #use defaults
        # NOTE: BB default number of cores is alla vailable
        jobs="$(os::default_number_of_cores)"
    fi


    #STRAND
    if   is_in '-s'      "${!OPTIONS[@]}"; then strand="${OPTIONS[-o]} "
    elif is_in '--strand' "${!OPTIONS[@]}"; then strand="${OPTIONS[--output]} "
    else
        #use defaults
        strand="both"
    fi


    #FORMAT
    if   is_in '-f'      "${!OPTIONS[@]}"; then format="${OPTIONS[-f]} "
    elif is_in '--format' "${!OPTIONS[@]}"; then format="${OPTIONS[--format]} "
    else
        #use defaults
        format=6
    fi

    #TARGETS
    if   is_in '-t'      "${!OPTIONS[@]}"; then format="${OPTIONS[-t]} "
    elif is_in '--targets' "${!OPTIONS[@]}"; then format="${OPTIONS[--targets]} "
    else
        #use defaults
        targets=250
    fi

    #EVALUE
    if   is_in '-e'      "${!OPTIONS[@]}"; then format="${OPTIONS[-v]} "
    elif is_in '--evalue' "${!OPTIONS[@]}"; then format="${OPTIONS[--evalue]} "
    else
        #use defaults
        evalue="1E-3"
    fi

    #CODE. Only works if blastx is used.
    if [[ "${alg}" == "blastx" ]];then
        if   is_in '-c'      "${!OPTIONS[@]}"; then code="${OPTIONS[-c]} "
        elif is_in '--code' "${!OPTIONS[@]}"; then code="${OPTIONS[--code]} "
        else
            #use defaults
            code=1

        fi
        # Create the whole key/value to pass to command line
        code=$(echo " -query_gencode ${code} ")

    else
        # Otherwise output nothing since we will no need this in other blast algorithms.
        code=""
    fi


    # ...............................................................
    #
    #                         CREATE AND RUN THE COMMAND
    #
    # ...............................................................

    


    # SOOO dirty peace of code! This can be greatly improved. Just a quick fix because
    # blastp does not allow the "-strand" option. That is the only difference between both
    # command lines below.
    if [[ "${alg}" == "blastp" ]];then

        local runblast=$(echo "$BIOBASH_BIN_OS/blast/${alg}\
        -query ${queryFile} \
        -db ${db}\
        -num_threads ${jobs}\
        -out ${output}\
        -outfmt ${format}\
        -max_target_seqs ${targets}\
        -evalue ${evalue}\
        ${code}")

    else

        local runblast=$(echo "$BIOBASH_BIN_OS/blast/${alg}\
        -query ${queryFile} \
        -db ${db}\
        -num_threads ${jobs}\
        -out ${output}\
        -strand ${strand}\
        -outfmt ${format}\
        -max_target_seqs ${targets}\
        -evalue ${evalue}\
        ${code}")

     fi

    #Actually run
    ${runblast}



    #Should we add a header to output file?
    if [[ "${header}" == "true" && ${format} -eq 6 ]];then

        # Ahead, a creepy workaround to have sed working on linux as well as in OSX machines.
        local os=$(os::detect_os)

        # If OSX
        if [[ "${os}" == "mac" ]];then
            # Note that the double quoting after the "-i" is necessary for OSX compatibility.
            sed -i '' '1s/^/qseqid sseqid  pident  length  mismatch    gapopen qstart  qend    sstart  send    evalue  bitscore\n/' ${output}
        fi

        # If LINUX
        if [[ "${os}" == "linux" ]];then
            sed -i '1s/^/qseqid sseqid  pident  length  mismatch    gapopen qstart  qend    sstart  send    evalue  bitscore\n/' ${output}
        fi
    fi

}