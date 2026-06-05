#!/bin/bash -ue
zgrep -v '^>' RedClade-VA.genome.fasta | grep -i -o C | wc -l > C_count.txt
