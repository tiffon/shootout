## Please excuse the dead links in this repo while I figure out what happened to the whole Programming Language Shootout website and why all the URLs on the new site point to the same incorrect file.

# shootout

Taking a stab at the [reverse-compliment](http://benchmarksgame.alioth.debian.org/u32/performance.php?test=revcomp) and [k-nucleotide](http://benchmarksgame.alioth.debian.org/u32/performance.php?test=knucleotide) benchmarks from the alioth programming language shootout.

## Improvement over previous solutions

The modified [k-nucleotide solution](http://benchmarksgame.alioth.debian.org/u32/program.php?test=knucleotide&lang=v8&id=5) reduced the _Elapsed secs_ metric from `5 minutes` to `95.68 seconds` and reduced the _Memory KB_ metric from `462,252` to `36,672`. At the time of this writing, it's the most memory efficient solution, for any language, and is the fastest JavaScript solution (disregarding my previous attempt which is posted in the "less comparable programs" section).

The modified [reverse-compliment solution](http://benchmarksgame.alioth.debian.org/u32/program.php?test=revcomp&lang=v8&id=4) reduced the _Elapsed secs_ metric from `12.80 seconds` to `9.35 seconds` and reduced the _Memory KB_ metric from `347,808` to `252,288`. At the time of this writing, it's the fastest and most memory efficient JavaScript solution.

## `run.sh`

The `run.sh` script validates the output from the modified solutions against the reference output. Then, the reference input is expanded to be much larger (500x and 75,000x). Using the larger input files, the performance of the modified solutions are compared to the performance of the original solutions. 

Optionally, the larger files can be deleted when the process is finished (`-c` option). The full usage information for the script:

    Usage: ./run.sh [-hvcskr] [-8 <d8-path>]
       Options:
           -h    help       Print this message
           -v    verbose    Print commands as they're executed
           -c    clean      Delete the large input files when finished
           -s    small      Do not run large tests
           -k    knuc       Run only the knucleotide tests
           -r    rev-comp   Run only the reverse-complement tests
           -8    v8         Path to v8 binary

        Example: ./run.sh -c8 /usr/local/v8/out/native/d8

Output when run on my MacBookPro:

    $ ./run.sh -c
    Validate output from modified solution:
        knucleotide:        success
        reverse-complement: success

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

    real    0m27.552s
    user    0m27.365s
    sys 0m0.167s

    Original script processing time:

    real    1m39.854s
    user    1m39.403s
    sys 0m0.360s


    REVERSE-COMPLEMENT
    ==================

    Improved script processing time:

    real    0m23.252s
    user    0m22.159s
    sys 0m1.044s

    Original script processing time:

    real    0m34.330s
    user    0m32.162s
    sys 0m2.007s

