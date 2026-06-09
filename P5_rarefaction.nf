#!/usr/bin/env nextflow

process P5_RAREFACTION{
    publishDir "${launchDir}/results", mode: "copy"

	input:
	path feature_table
	path rooted_tree
	path metadata
	val max_depth
	val steps
	val metrics	

	output: 
	path "rarefaction_curve.qzv"

	script:
	"""
	qiime diversity alpha-rarefaction \
		--i-table ${feature_table} \
		--i-phylogeny ${rooted_tree} \
		--m-metadata-file ${metadata} \
		--p-max-depth ${max_depth} \
		--p-steps ${steps} \
		--p-metrics ${metrics} \
		--o-visualization rarefaction_curve.qzv
	"""
}