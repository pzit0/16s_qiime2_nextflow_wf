#!/bin/bash -ue
zgrep -v '^>' RedClade-VA.genome.fasta | grep -i -o A | wc -l > A_count.txt
