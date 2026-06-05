#!/usr/bin/env nextflow

process FASTQC {
  publishDir "results/fastqc/", mode: "copy"
  tag "tagging directive ${reads}"
  cpus 2
 
  input:
  tuple val(sample_id), path(reads)
  
  output:
  path "${sample_id}_fastqc/*"
 
  script:
  """
  mkdir ${sample_id}_fastqc
  fastqc ${reads} -o ${sample_id}_fastqc -t $task.cpus
  """
}

workflow {
  PairedReads_ch = Channel.fromFilePairs("/Users/pzito/Desktop/nextflow-test/16s_reads/*_R{1,2}_001.fastq.gz")
  PairedReads_ch.view()
  FASTQC(PairedReads_ch)
  FASTQC.out.view()
}
