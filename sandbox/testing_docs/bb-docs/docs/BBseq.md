# BioBash Sequence

This module contains functions to operate over sequences itself (DNA/RNA/Protein)

## Overview

BIOBASH module

## Index

* [BBSeq::get_fasta_components](#bbseqget_fasta_components)
* [BBSeq::get_fastq_quality](#bbseqget_fastq_quality)

### BBSeq::get_fasta_components

This function retrieves different parts of fasta file.
A fasta file has three main components:  
1) The header (which begins with the ">" sign)
2) The sequence ID (which is part of the header)*
3) The sequences itself
The porpouse of this function is to retrieve that information individually, wether
from a multiple or single sequence file.
Please note that it is assumed that Sequence ID is ANY STRING in the fasta
header between the ">" sign and the first space. So in a header like:
>KY560197.1 Acipenser ruthenus ApoE (apoE) mRNA, partial cds
It is assumed that KY560197.1 is the sequence ID.

#### Example

```bash
  Invoked without modifiers shows all info:
  BBSeq::get_fasta_components -i "./file.fa[,fasta]" 
  Output (tab separated one row per sequence)
  SeqID   Description   Sequence  
  When invoked with a modifier (-h, -d and/or -s) Displays appropriate info:
  -h: header, -d sequence ID, -s Sequences

@arg  -i/--input    (required) path to a file.
@arg  -h/--header   (optional) Show fasta header.
@arg  -d/--id       (optional) Show sequence ID.
@arg  -s/--sequence (optional) Show sequence.
@arg  -j/--jobs     (optional) Number of CPU cores to use.
```

#### Exit codes

* **0**:  on success
* **1**:  on failure

### BBSeq::get_fastq_quality

This function takes a fastq file as input and returns the average
quality for each sequence in input file. Alternatively it will return a quality resume: the average of all
summed sequences, max and min quality scores, and number of sequences.

#### Example

```bash
Display each sequence quality average
BBSeq::get_fastq_quality -i file.fastq
8.51
10.43
7.27
8.66
7.75
8.85
8.19
Display quality report
BBSeq::get_fastq_quality -i file.fastq --report
File name       numseqs   sumlen   minlen   avg_len   max_len   Q20(%)   Q30(%)
example.fastq   4437      883678   115      199.2     438       26.63    6.09
```

#### Exit codes

* **0**:  on success
* **1**:  on failure

