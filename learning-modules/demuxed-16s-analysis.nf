#!/usr/bin/env nextflow

//////// Processes
process 01_IMPORT {
	input:
	tuple val(sample_id) path(reads)
	path metadata
	path manifest

	output:
	path "demuxed.qza", emit: 01_results

	script:
	"""
	qiime tools import \
		--type 'SampleData[PairedEndSequencesWithQuality]' \
		--input-path ${reads} \
		--input-fromat ${sample_id} \
		--output-path demuxed.qza
	"""
}

process 02_FILTER {
	input:
	path demuxed_artifact
	val forward_primer
	val reverse_primer

	output:
	path "trimmed.qza", emit: 02_results
	path "trimmed.qzv"
	
	script:
	"""
	qiime cutadapt trim-paired \
		--i-demultiplexed-sequences ${demuxed_artifact} \
		--p-front-f ${forward_primer} \
		--p-front-r ${reverse_primer} \
		--p-discard-untrimmed \
		--p-no-indels \
		--o-trimmed-sequences trimmed.qza

	qiime demux summarize \
		--i-data trimmed.qza \
		--o-visualization trimmed.qzv
	"""
}

process 03_DENOISE {
	input:
	path trimmed_artifact
	val forward_left
	val forward_right
	val reverse_left
	val forward_right

	output:
	path "denoised_table.qza", emit: 03_denoised_table
	path "representative_sequences.qza", emit: 03_rep_seqs
	path "denoising_stats.qza"
	path "representative_sequences.qzv"
	path "denoising_stats.qzv"

	script:
	"""
	qiime dada2 denoise-paired \
		--i-demultiplexed-seqs ${trimmed_artifact} \
		--p-trunc-len-f ${forward_left} \
		--p-trunc-len-r ${reverse_left} \
		--p-trim-left-f ${forward_right} \
		--p-trim-left-r ${reverse_right} \
		--o-table denoised_table.qza \
		--o-representative-sequences representative_sequences.qza \
		--o-denoising-stats denoising_stats.qza 
	
	qiime feature-table tabulate-seqs \
		--i-data representative_sequences.qza \
		--o-visualization representative_sequences.qzv
	
	qiime metadata tabulate \
		--m-input-file denoising_stats.qza \
		--o-visualization denoising_stats.qzv
	"""
}

process 04_PHYLOTREE{
	input: 
	path representative_sequences

	output:
	path "representative_sequences.mafft.qza"
	path "representative_sequences.masked.mafft.qza"
	path "unrooted_tree.qza", emit: 04_unrooted_tree
	path "rooted_tree.qza", emit: 04_rooted_tree

	script:
	"""
	qiime phylogeny align-to-tree-mafft-fasttree \
		--i-sequences ${representative_sequences} \
		--o-alignment representative_sequences.mafft.qza \
		--o-masked-alignment representative_sequences.masked.mafft.qza \
		--o-tree unrooted_tree.qza \
		--o-rooted-tree rooted_tree.qza
	"""
}

process 05_RAREFACTION{
	input:
	path feature_table
	path rooted-tree
	path metadata
	val max_depth
	val steps
	val metrics	

	output: 
	path "rarefaction_curve.qzv", emit: 05_rarefaction_curve

	script:
	"""
	qiime diversity alpha-rarefaction \
		--i-table ${feature_table} \
		--i-phylogeny ${rooted-tree} \
		--m-metadata-file ${metadata} \
		--p-max-depth ${max_depth} \
		--p-steps ${steps} \
		--p-metrics ${metrics} \
		--o-visualization rarefaction_curve.qzv
	"""
}

process 06_TAXONOMY{
	input:
	tuple val(database), 
		val(classifier), 
		val(url)
	path reads
	path feature_table
	path metadata
	val tax_level

	output:
	tuple val(database), 
		path("taxonomy.${database}.qza"), 
		path("taxonomy.${database}_lv${tax_level}.qza"), 
		emit: 06_taxonomy_tables
	path "taxonomy.${database}.qzv"
	path "taxonomy.${database}.barplot.qzv"

	script:
	"""
	wget -0 ${classifier} ${url}

	
	qiime feature-classifier classify-sklearn \
		--i-classifier ${classifier} \
		--i-reads ${reads} \
		--o-classification taxonomy.${database}.qza
	
	qiime metadata tabulate \
		--m-input-file taxonomy.${database}.qza \
		--o-visualization taxonomy.${database}.qzv

	qiime taxa barplot \
		--i-table ${feature_table} \
		--i-taxonomy taxonomy.${database}.qzv \
		--m-metadata-file ${metadata} \
		--o-visualization taxonomy.${database}.barplot.qzv \
	
	qiime taxa collapse \
		--i-table ${feature_table} \
		--i-taxonomy ${taxonomy} \
		--p-level ${tax_level} \
		--o-collapsed-table taxonomy_${database}_lv${tax_level}.qza 	
	"""
}

process 07_DIVERSITY{
	input:
	path rooted_tree
	path feature_table
	val sampling_depth
	path metadata
	each contrast

	output:
	path "core_metrics_results.tar.gz"

	script:
	"""
	qiime diversity core-metrics-phylogenetic \
		--i-phylogeny ${rooted_tree} \
		--i-table ${feature_table} \
		--p-sampling-depth ${sampling_depth} \
		--m-metadata-file ${metadata} \
		--output-dir core_metrics_results

	qiime diversity alpha-group-significance \
		--i-alpha-diversity core_metrics_results/evenness_vector.qza \
		--m-metadata-file ${metadata} \
		--o-visualization core_metrics_results/evenness_significance.qzv

	qiime diversity alpha-group-significance \
		--i-alpha-diversity core_metrics_results/faith_pd_vector.qza \
		--m-metadata-file ${metadata} \
		--o-visualization core_metrics_results/faith_pd_significance.qzv

	qiime diversity beta-group-significance \
		--i-distance-matrix core_metrics_results/unweighted_unifrac_distance_matrix.qza \
		--m-metadata-file ${metadata} \
		--m-metadata-columns ${contrast} \
		--p-pairwise \
		--o-visualization core_metrics_results/unweighted_unifrac_${contrast}.qzv

	tar cfv core_metrics_results.tar.gz core_metrics_results
	"""
}

process 08_ANCOMBC{
	input:
	path feature_table
	path metadata
	each contrast
	val sig_threhold
	tuple val(database), 
		path(taxonomy), 
		path(collapsed_taxonomy)
	val tax_level
	
	output:
	path "ancombc_${database}_${contrast}.qza"
	path "da_barplot_${database}_${contrast}.qzv"
	path "ancombc_${database}_${contrast}_lv${tax_level}.qza"
	path "da_barplot_${database}_${contrast}_lv${tax_level}.qzv"
	
	script:
	"""
	qiime composition ancomb \
		--i-table ${feature_table} \
		--m-metadata-file ${metadata} \
		--p-formula ${contrast} \
		--o-differentials ancombc_${database}_${contrast}.qza \
		--verbose

	qiime composition da-barplot \
		--i-data ancombc_${contrast}.qza \
		--p-significance-threshold ${sig_threshold} \
		--o-visualization da_barplot_${database}_${contrast}.qzv \
		--verbose
		
	qiime composition ancombc \
		--i-table ${collapsed_taxonomy} \
		--m-metadata-file ${metadata} \
		--p-formula ${contrast} \
		--o-differentials ancombc_${database}_${contrast}_lv${tax_level}.qza \
		--verbose
	
	qiime composition da-barplot \
		--i-data ancombc_${contrast}_lv${tax_level}.qzv \
		--p-significance-threshold ${sig_threshold} \
		--o-visualization da_barplot_${database}_${contrast}_lv${tax_level}.qzv \
		--verbose
	"""
}


//////// Workflow

workflow{
	seqDir_ch = Channel.fromPath(params.seqDir)
	metadata_ch = Channel.fromPath(params.metadata)
	manifest_ch = Channel.fromPath(params.manifest)
	metrics_ch = Channel.value(params.05_metrics)
	classifiers_ch = Channel.fromList(params.06_classifiers)
	contrast_ch = Channel.fromList(params.contrast)

	01_IMPORT(seqDir_ch)
	02_FILTER(02_results.out.collect(),
		params.02_forward_primer, 
		params.02_reverse_primer)
	03_DENOISE(03_results.out.collect(), 
		params.03_forward_left, 
		params.03_forward_right, 
		params.03_reverse_left, 
		params.03_reverse_right)
	04_PHYLOTREE(03_rep_seqs.out.collect())
	05_RAREFACTION(03_denoise_table.out.collect(), 
		04_rooted_tree.out.collect(), 
		metadata_ch, 
		params.05_max_depth, 
		params.05_steps, 
		metrics_ch)
	06_TAXONOMY(classifiers_ch, 
		03_rep_seqs.out.collect(), 
		03_denoise_table.out.collect(), 
		metadata_ch,
		params.06_tax_level_collapse)
	07_DIVERSITY(04_rooted_tree.out.collect(),
		03_denoise_table.out.collect(),
		params.07_sampling_depth,
		metadata_ch,
		contrast_ch)
	08_ANCOMBC(03_denoise_table.out.collect(),
		metadata_ch,
		contrast_ch,
		params.08_significance_threhold,
		06_taxonomy_tables.out.collect(),
		params.06_tax_level_collapse)
}

