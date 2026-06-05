#!/bin/bash -ue
printf "Number of sequences for chromosome Chr3:"
zgrep -c "^>Chr3" RedClade-VA.genome.fasta > seqs_in_Chr3.txt
