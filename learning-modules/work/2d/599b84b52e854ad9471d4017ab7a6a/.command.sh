#!/bin/bash -ue
zgrep -v '^>' RedClade-VA.genome.fasta | grep -o T | wc -l
