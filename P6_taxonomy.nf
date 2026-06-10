#!/usr/bin/env nextflow

process P6_TAXONOMY{
	publishDir "${launchDir}/results", mode: "copy"

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
		path("abs_taxonomy_${database}.qza"), 
		path("abs_taxonomy_${database}_lv${tax_level}.qza"), 
		emit: p6_taxonomy_tables
	path "abs_taxonomy_${database}.qzv"
	path "abs_taxonomy_${database}.barplot.qzv"
    path "rel_taxonomy_${database}_lv${tax_level}.qza"
    path "abs_taxonomy_${database}_lv${tax_level}"
    path "rel_taxonomy_${database}_lv${tax_level}"

	script:
	"""
    # obtain classifier
	wget -O ${classifier} ${url}

    # classify reads
	qiime feature-classifier classify-sklearn \
		--i-classifier ${classifier} \
		--i-reads ${reads} \
		--o-classification abs_taxonomy_${database}.qza
	
    # export into visualizable qiime object
	qiime metadata tabulate \
		--m-input-file abs_taxonomy_${database}.qza \
		--o-visualization abs_taxonomy_${database}.qzv

    # make barplot
	qiime taxa barplot \
		--i-table ${feature_table} \
		--i-taxonomy abs_taxonomy_${database}.qza \
		--m-metadata-file ${metadata} \
		--o-visualization abs_taxonomy_${database}.barplot.qzv

    # collapse taxonomic table to genus level
	qiime taxa collapse \
		--i-table ${feature_table} \
		--i-taxonomy abs_taxonomy_${database}.qza \
		--p-level ${tax_level} \
		--o-collapsed-table abs_taxonomy_${database}_lv${tax_level}.qza 	
	
    # export collapsed taxonomy absolute abundance to .BIOM objects
    qiime tools export \
        --input-path abs_taxonomy_${database}_lv${tax_level}.qza \
        --output-path abs_taxonomy_${database}_lv${tax_level}
    
    # convert .BIOM collapsed taxonomy absolute abundance into .tsv
    biom convert \
        -i abs_taxonomy_${database}_lv${tax_level}/feature-table.biom \
        -o abs_taxonomy_${database}_lv${tax_level}/abs_taxonomy_${database}_lv${tax_level}.tsv \
        --to-tsv

    # obtain collapsed taxonomy relative abundance
    qiime feature-table relative-frequency \
        --i-table abs_taxonomy_${database}_lv${tax_level}.qza \
        --o-relative-frequency-table rel_taxonomy_${database}_lv${tax_level}.qza
    
    # export collapsed taxonomy relative abundance to .BIOM objects
    qiime tools export \
        --input-path rel_taxonomy_${database}_lv${tax_level}.qza \
        --output-path rel_taxonomy_${database}_lv${tax_level}

    # convert .BIOM collapsed taxonomy relative abundance into .tsv
    biom convert \
        -i rel_taxonomy_${database}_lv${tax_level}/feature-table.biom \
        -o rel_taxonomy_${database}_lv${tax_level}/rel_taxonomy_${database} \
        --to-tsv
    """
}