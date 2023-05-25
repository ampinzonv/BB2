# BioBash File

## Overview

This module contains functions to operate over bioinformatics files not over
its content (for that matter BBFormat or BBSeq could be a better option).
For general operations over files of any kind refer to bb_utility/io.sh file.

## Index

* [BBfile::is_fasta](#bbfileis_fasta)
* [BBfile::is_multiple_fasta](#bbfileis_multiple_fasta)
* [BBfile::is_fastq](#bbfileis_fastq)
* [BBfile::fastq_to_fasta](#bbfilefastq_to_fasta)
* [BBfile::multiple_fasta_to_singles](#bbfilemultiple_fasta_to_singles)
* [BBfile::uncompress](#bbfileuncompress)
* [BBfile::guess_sequence_type](#bbfileguess_sequence_type)

### BBfile::is_fasta

Checks if a file is valid fasta file. 

#### Example

```bash
file::file_is_fasta -i/--input "./file.fa[,fasta]" 
#Output
Returns 0 if file is fasta, 1 if it is not.
```

#### Exit codes

* **0**:  On success 
* **1**:  On failure

### BBfile::is_multiple_fasta

Checks if a file is a valid multiple fasta.

#### Example

```bash
file::file_is_multiple_fasta -i/--input file.fa[,fasta] 
#Output
0
```

#### Exit codes

* **0**:  
* **1**:  

### BBfile::is_fastq

Checks if a file is valid fastq file.

#### Example

```bash
file::is_fastq "./file.fq" 
#Output
0
```

#### Arguments

* **$1** (path): to fastq file.

#### Exit codes

* **0**:  
* **1**:  
* **2**: 

### BBfile::fastq_to_fasta

Transforms a fastq file into a fasta file.
if only the fastq file argument is given it outputs the fasta format in STDOUT.
This input file can be compressed in gz format.
If a second (optional) argument is given (a string containing the desired name for FASTA output file)
STDOUT is then redirected to a file. If the string has a ".gz" extension, the output is also compressed.

#### Example

```bash
BBfile_fastq_to_fasta "./file.fastq[.gz]" 
#Output
file in FASTA format in STDOUT

#Example 2
BBfile_fastq_to_fasta "./file.fastq[.gz]"  file.fa[.gz]
#Output
./file.fa[.gz] 
```

#### Exit codes

* **0**:  On succes
* **1**:  On failure

### BBfile::multiple_fasta_to_singles

Splits a multiple fasta file into single sequences, where:
1) If -o/--output is defined, a directory is created accordingly. 
2) If -o/--output is not defined, a directory is created IN THE SAME PATH where the input file resides
In both cases splitted files are named  after file name.
A similar behavior can be expected if data comes from STDIN and not from a file:
4) If -o/--output is defined, a directory is created accordingly. 
5) If -o/--output is not defined a directory named "stdin.split" is created. 
In both cases splitted files are prefixed with "stdin.part_"
If input is a compressed file, each outputed individual file is also compressed.

#### Example

```bash
cat file.fasta
>A
AGCT
>B
TTTT
BBfile_multiple_fasta_to_singles "./file.fasta[.gz]" 
#Output
file.fasta[.gz].singles/clear
    file.part_A.fasta[.gz]
    file.part_B.fasta[.gz]

```

#### Exit codes

* **0**:  
* 1

### BBfile::uncompress

Uncompresses a gunzipped file

#### Example

```bash
BBfile::uncompress file.gz 
#Output
The uncompressed file to STDOUT
```

#### Exit codes

* **0**:  on success
* **1**:  on failure

### BBfile::guess_sequence_type

Checks if a file is nucleotide or protein.

#### Example

```bash
file::guess_sequence_type "./file.fasta" 
#Output
0
```

#### Arguments

* **$1** (path): to fasta file.

#### Exit codes

* **0**:  
* **1**:  
* **2**: 

