shootout
========

Taking a stab at a couple of the alioth programming language shootout benchmarks for v8.

http://benchmarksgame.alioth.debian.org/u32/performance.php?test=knucleotide

http://benchmarksgame.alioth.debian.org/u32/performance.php?test=revcomp

The `run.sh` script validates the output from the modified solutions against the reference output. Then, the reference input is expanded to be much larger (500x and 75,000x). Using the larger input files, the performance of the modified solutions are compared to the performance of the original solutions. 

Optionally, the larger files can be deleted when the process is finished (`-c` option). The full usage information for the script:

        Usage: ./run.sh [-hvcs] [-8 <d8-path>]
           Options:
               h    help       Print this message
               v    verbose    Print commands as they're executed
               c    clean      Delete the large input files when finished
               s    small      Do not run large tests
               8    v8         Path to v8 binary

            Example: ./run.sh -c8 /usr/local/v8/out/native/d8

Output when run on my MacBookPro:

    $ ./run.sh -c
    Creating a large knucleotide input file. 
        This may take a few minutes.
        data/knucleotide-input-500.txt
        bytes: 127063119

    Creating a large reverse-complement input file. 
        This may take a few minutes.
        data/revcomp-input-75k.txt
        bytes: 759450119


    KNUCLEOTIDE
    ===========

    Improved script processing time:

    real    0m20.638s
    user    0m20.366s
    sys     0m0.197s

    Original script processing time:

    real    1m35.820s
    user    1m35.338s
    sys     0m0.380s


    REVERSE-COMPLEMENT
    ==================

    Improved script processing time:

    real    0m23.232s
    user    0m21.643s
    sys     0m1.222s

    Original script processing time:

    real    0m35.121s
    user    0m32.464s
    sys     0m2.278s
