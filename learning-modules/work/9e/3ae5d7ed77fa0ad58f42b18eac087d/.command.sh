#!/bin/bash -ue
printf "Number of sequences for chromosome Chr1:"
zgrep -c "^>Chr1" RedClade-VA.genome.fasta > seqs_in_Chr1.txt
