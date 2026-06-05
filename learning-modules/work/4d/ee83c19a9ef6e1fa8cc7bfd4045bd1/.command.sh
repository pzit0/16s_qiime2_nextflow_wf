#!/bin/bash -ue
printf "Number of sequences for chromosome Chr2:"
zgrep -c "^>Chr2" RedClade-VA.genome.fasta > seqs_in_Chr2.txt
