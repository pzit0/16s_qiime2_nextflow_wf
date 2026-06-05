#!/bin/bash -ue
printf "Number of sequences for chromosome MT:"
zgrep -c "^>MT" RedClade-VA.genome.fasta > seqs_in_MT.txt
