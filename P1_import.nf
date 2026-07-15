#!/usr/bin/env nextflow

process P1_IMPORT {
    publishDir "${launchDir}/results", mode: "copy"

	input:
	path MANIFEST

	output:
	path "demuxed.qza", emit: p1_results

	script:
	"""
	qiime tools import \
		--type 'SampleData[PairedEndSequencesWithQuality]' \
		--input-path ${MANIFEST} \
		--input-format PairedEndFastqManifestPhred33V2 \
		--output-path demuxed.qza
	"""
}