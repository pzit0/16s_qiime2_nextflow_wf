#!/usr/bin/env nextflow 

process P7_DIVERSITY{
    publishDir "${launchDir}/results", mode: "copy"

	input:
	path rooted_tree
	path feature_table
	val sampling_depth
	path metadata
	each contrast

	output:
	path "core_metrics_${contrast}_results"

	script:
	"""
	qiime diversity core-metrics-phylogenetic \
		--i-phylogeny ${rooted_tree} \
		--i-table ${feature_table} \
		--p-sampling-depth ${sampling_depth} \
		--m-metadata-file ${metadata} \
		--output-dir core_metrics_${contrast}_results

	qiime diversity alpha-group-significance \
		--i-alpha-diversity core_metrics_${contrast}_results/evenness_vector.qza \
		--m-metadata-file ${metadata} \
		--o-visualization core_metrics_${contrast}_results/evenness_significance.qzv

	qiime diversity alpha-group-significance \
		--i-alpha-diversity core_metrics_${contrast}_results/faith_pd_vector.qza \
		--m-metadata-file ${metadata} \
		--o-visualization core_metrics_${contrast}_results/faith_pd_significance.qzv

	qiime diversity beta-group-significance \
		--i-distance-matrix core_metrics_${contrast}_results/unweighted_unifrac_distance_matrix.qza \
		--m-metadata-file ${metadata} \
		--m-metadata-column "${contrast}" \
		--p-pairwise \
		--o-visualization core_metrics_${contrast}_results/unweighted_unifrac_${contrast}.qzv
	"""
}