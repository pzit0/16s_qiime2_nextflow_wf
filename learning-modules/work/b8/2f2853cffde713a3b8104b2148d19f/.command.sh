#!/bin/bash -ue
zgrep -v '^>' RedClade-VA.genome.fasta | grep -i -o T | wc -l > T_count.txt
