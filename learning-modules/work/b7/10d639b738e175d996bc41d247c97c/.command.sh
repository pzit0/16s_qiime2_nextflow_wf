#!/bin/bash -ue
zgrep -v '^>' RedClade-VA.genome.fasta | grep -i -o G | wc -l > G_count.txt
