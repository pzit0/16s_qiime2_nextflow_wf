#!/usr/bin/env nextflow

process P3_DENOISE {
    publishDir "${launchDir}/results", mode: "copy"

	input:
	path trimmed_artifact
	val forward_left
	val forward_right
	val reverse_left
	val reverse_right

	output:
	path "denoised_table.qza", emit: p3_denoised_table
	path "representative_sequences.qza", emit: p3_rep_seqs
	path "denoising_stats.qza"
	path "representative_sequences.qzv"
	path "denoising_stats.qzv"

	script:
	"""
	qiime dada2 denoise-paired \
		--i-demultiplexed-seqs ${trimmed_artifact} \
		--p-trunc-len-f ${forward_right} \
		--p-trunc-len-r ${reverse_right} \
		--p-trim-left-f ${forward_left} \
		--p-trim-left-r ${reverse_left} \
		--o-table denoised_table.qza \
		--o-representative-sequences representative_sequences.qza \
		--o-denoising-stats denoising_stats.qza \
        --verbose
	
	qiime feature-table tabulate-seqs \
		--i-data representative_sequences.qza \
		--o-visualization representative_sequences.qzv
	
	qiime metadata tabulate \
		--m-input-file denoising_stats.qza \
		--o-visualization denoising_stats.qzv
	"""
}