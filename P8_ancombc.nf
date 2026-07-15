#!/usr/bin/env nextflow 

process P8_ANCOMBC{
    publishDir "${launchDir}/results", mode: "copy"

	input:
	path feature_table
	path metadata
	each contrast
	val sig_threshold
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
	qiime composition ancombc \
		--i-table ${feature_table} \
		--m-metadata-file ${metadata} \
		--p-formula "${contrast}" \
		--o-differentials ancombc_${database}_${contrast}.qza \
		--verbose

	qiime composition da-barplot \
		--i-data ancombc_${database}_${contrast}.qza \
		--p-significance-threshold ${sig_threshold} \
		--o-visualization da_barplot_${database}_${contrast}.qzv \
		--verbose
		
	qiime composition ancombc \
		--i-table ${collapsed_taxonomy} \
		--m-metadata-file ${metadata} \
		--p-formula "${contrast}" \
		--o-differentials ancombc_${database}_${contrast}_lv${tax_level}.qza \
		--verbose
	
	qiime composition da-barplot \
		--i-data ancombc_${database}_${contrast}_lv${tax_level}.qza \
		--p-significance-threshold ${sig_threshold} \
		--o-visualization da_barplot_${database}_${contrast}_lv${tax_level}.qzv \
		--verbose
	"""
}