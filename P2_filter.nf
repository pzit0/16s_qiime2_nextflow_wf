#!/usr/bin/env nextflow

process P2_FILTER {
	publishDir "${launchDir}/results", mode: "copy"

	input:
	path demuxed_artifact
	val forward_primer
	val reverse_primer

	output:
	path "trimmed.qza", emit: p2_results
	path "trimmed.qzv"
	
	script:
	"""
	qiime cutadapt trim-paired \
		--i-demultiplexed-sequences ${demuxed_artifact} \
		--p-front-f ${forward_primer} \
		--p-front-r ${reverse_primer} \
		--p-minimum-length 1 \
		--p-no-discard-untrimmed \
		--o-trimmed-sequences trimmed.qza \
		--verbose

	qiime demux summarize \
		--i-data trimmed.qza \
		--o-visualization trimmed.qzv
	"""
}