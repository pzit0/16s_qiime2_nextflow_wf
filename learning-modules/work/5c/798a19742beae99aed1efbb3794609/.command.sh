#!/bin/bash -ue
mkdir 20130417_Racine_water4_1_L001_fastqc
fastqc 20130417_Racine_water4_1_L001_R1_001.fastq.gz 20130417_Racine_water4_1_L001_R2_001.fastq.gz -o 20130417_Racine_water4_1_L001_fastqc -t 2
