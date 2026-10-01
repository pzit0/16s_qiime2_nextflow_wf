#!/usr/bin/env nextflow

process P3_DENOISE {
    publishDir "${launchDir}/results", mode: "copy"

	input:
	path trimmed_artifact
	val truncate_length_forward
	val truncate_length_reverse
	val trim_left_forward
	val trim_left_reverse

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
		--p-trunc-len-f ${truncate_length_forward} \
		--p-trunc-len-r ${truncate_length_reverse} \
		--p-trim-left-f ${trim_left_forward} \
		--p-trim-left-r ${trim_left_reverse} \
		--p-no-retain-all-samples \
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