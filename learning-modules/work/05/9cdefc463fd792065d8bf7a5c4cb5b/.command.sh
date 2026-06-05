#!/bin/bash -ue
zgrep -v '^>' RedClade-VA.genome.fasta | grep -o A | wc -l > A_count.txt
