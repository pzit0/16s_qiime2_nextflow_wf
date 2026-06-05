#!/bin/bash -ue
printf "Number of sequences for chromosome Chr4:"
zgrep -c "^>Chr4" RedClade-VA.genome.fasta > seqs_in_Chr4.txt
