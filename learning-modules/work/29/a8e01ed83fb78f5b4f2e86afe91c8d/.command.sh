#!/bin/bash -ue
mkdir 20130417_LisleVerte_water_4_L001_fastqc
fastqc 20130417_LisleVerte_water_4_L001_R1_001.fastq.gz 20130417_LisleVerte_water_4_L001_R2_001.fastq.gz -o 20130417_LisleVerte_water_4_L001_fastqc -t 2
