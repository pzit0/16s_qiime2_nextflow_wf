#!/usr/bin/env nextflow

// Processes
process COUNT_BASES {

publishDir "results", mode: "copy"

input: 
path reads
each bases

output:
path "${bases}_count.txt"

script:
"zgrep -v '^>' ${reads} | grep -i -o ${bases} | wc -l > ${bases}_count.txt"
}

// Workflow
workflow{
	reads_ch = Channel.fromPath("/Users/pzito/Desktop/nextflow-test/RedClade-VA.genome.fasta")
	bases_ch = Channel.fromList(["A", "C", "G", "T"])
	COUNT_BASES(reads_ch, bases_ch)
}
