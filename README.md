![](web/bash_logo.png) 

# Official repository of the BioBash (BB) project.

## About BioBash
This project is aimed to develope a Bioinformatics library for common tasks in the field of Computational Biology (mainly Bioinformatics) using the BASH language.
It is leaded by [Andrés M. Pinzón](https://www.researchgate.net/profile/Andres-Pinzon-13/research) , full time professor at [Bioinformatics and Systems Biology Laboratory](https://gibbslab.github.io/) , [Institute for Genetics](https://genetica.unal.edu.co/)  - [National University of Colombia](http://unal.edu.co/)  in south America. 

## Why BioBash?
Basically [this library has been around for several years in our laboratory](https://github.com/gibbslab/biobash), as a bunch of routines programmed for common bioinformatics tasks such as dealing with FASTA headers and FQ files, as well as with manipulation of lists of genes etc.

After years of using this BioBash two things became clear. **First** it was really, really useful and **second**, I found myself re-inventing the wheel  (in BASH!).
Since there are hundreds of useful and optimized bioinformatics tools, why create something like BioBash? Well there are two answers: **First**, not everything has been already done in Bioinformatics, and there is room for a couple of things. **Second**, I found myself , students and  colleagues adapting to the way different tools manipulate files, inputs and outputs, so there was a learning curve in every single tool.

## A matter of consistency and efficiency
So one of the main aims of BioBash is to have a consistent interface for common analysis in the field, without re-inventing the wheel and in a common ambient for Computational Biologists (e.i. BASH). 
In this regard, on one hand BioBash is a wrapper for several pre-existent bioinformatics tools, such as clustalw, seqtk, BWA, Bowtie, EMBOSS, NCBI-BLAST etc, with a consistent interface for all of them. On the other hand it also provides brand new routines for file manipulation and other Bioinformatics-related tasks common in the field (dealing with lists anyone?), and for that regard uses core utils that come with any installation of BASH.

For example, if you have a list of genes in a text file and you want to know how many of these are unique genes, and how many are over-represented in the list, one way is to use common core BASH commands such as sort and unique, to obtain that information, OR use the BioBash "bb_get_nr_list" command and forget about all the command line options needed for each program.

Another example, if you have two multiple  FASTA files, and you want to BLAST one to each other and see how they match, you can use NCBI-BLAST's formatdb command, create the database, and then use blastp or blastn (or any other variant), perform the alignment (with all the options necessary) and obtain your results. OR you can use the bb_blast_seqs commmand from BioBash and then go for a cup of coffee, and let BioBash deal with routes, temporary files, re-naming, threading  etc.

So I believe BioBash can make you more efficient through a consistent interface, all commands in BioBash behave, respond and output  in a similar way, no matter what is happening behind scenes.

## Quick notes about BioBash development
BB is supported for  other third party libraries  and coding standards worth mentioning.

### Third party libraries
An awesome library call [SHML](https://odb.github.io/shml/) (Shell Markup Language) is used for "stylizing" shell output. All coloring, font sizes, icons, emojis etc., used in our scripts are possible thanks to SHML.

Another amazing library used behind the scenes by BB is [Bash-Utility](https://github.com/labbots/bash-utility), which provides a series of functions and helpers for Bash programming that saves you much time and effort.

Although BB is perhaps the most complete Bash library for Bioinformatics, this is not really a new idea in the community, several other projets under the same name has been started (and abandoned) with the same name, and some of the ideas and even part of the code of these projects was used in the [first version of this library](https://github.com/gibbslab/biobash). 

Nevertheless, since the whole idea of BB as a pure Bash scripts for Bioinformatics was switched to Bash interfaces to other tools, it is hard to find pieces of code from other projects here and if so, clarifications are made in documentation for each BB function and/or script that uses them. Finally, to my knowledge  the only worth mentioning BioBash project is [Simon Frost's](https://github.com/sdwfrost/biobash) Biobash, really nice scripts although poorly documented. 


### Coding standards
A key component on any coding  project is to follow a good coding standard and do your best to implement good programming practices into your code. This makes code more accesible to anyone willing to contribute, makes debug easier (bugs are less common) and also helps to speed up the generation of documentation.

The standards followed by BB are the [Shell Style Guide](https://google.github.io/styleguide/shellguide.html)  suggested by the [Google Style Guides](https://google.github.io/styleguide/) community, as well as the ones suggested by [Jeff Lindsay at Progrium](https://github.com/progrium/bashstyle). I think these are must follow rules for everyone programming in BASH.

Code documentation is automatically generated with another amazing library called [shdoc](https://github.com/reconquest/shdoc).

### Side note
In case this can be interesting to anyone, this project has been developed both under OSX and Linux machines (depending if I am at home or at work) using VSCode as code editor, supported by the Bash IDE, Bats, indent-rainbow, shell-format and ShellCheck extensions for VSCode. Nice ones!.

## Cool stuff helped BioBash development
Several sources were used while developing BioBash (apart from the Third Party libraries above). Some of these are:

* [Pure Bash Bible](https://github.com/dylanaraps/pure-bash-bible).
* [Bioinformatics Oneliners](https://github.com/stephenturner/oneliners).













