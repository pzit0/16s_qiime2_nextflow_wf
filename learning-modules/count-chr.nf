#!/usr/bin/env nextflow

params.reads = "/Users/pzito/Desktop/nextflow-test/RedClade-VA.genome.fasta"
params.chr = ["Chr1", "Chr2", "Chr3", "Chr4", "MT"]

process COUNT_SEQ_PER_CHR{
publishDir "results", mode: "copy"

input: 
path reads
each chr

output:
path "seqs_in_${chr}.txt"

script:
"""
printf "Number of sequences for chromosome ${chr}:"
zgrep -c "^>${chr}" ${reads} > seqs_in_${chr}.txt
"""
}

workflow {
	read_ch = Channel.fromPath(params.reads)
	chr_ch = Channel.fromList(params.chr) 
	COUNT_SEQ_PER_CHR(read_ch, chr_ch)
}
