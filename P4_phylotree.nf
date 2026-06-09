#!/usr/bin/env nextflow

process P4_PHYLOTREE{
    publishDir "${launchDir}/results", mode: "copy"

	input: 
	path representative_sequences

	output:
	path "representative_sequences.mafft.qza"
	path "representative_sequences.masked.mafft.qza"
	path "unrooted_tree.qza", emit: p4_unrooted_tree
	path "rooted_tree.qza", emit: p4_rooted_tree
    path "unrooted_tree"
    path "rooted_tree"

	script:
	"""
	qiime phylogeny align-to-tree-mafft-fasttree \
		--i-sequences ${representative_sequences} \
		--o-alignment representative_sequences.mafft.qza \
		--o-masked-alignment representative_sequences.masked.mafft.qza \
		--o-tree unrooted_tree.qza \
		--o-rooted-tree rooted_tree.qza
    
    qiime tools export \
        --input-path unrooted_tree.qza \
        --output-path unrooted_tree

    qiime tools export \
        --input-path rooted_tree.qza \
        --output-path rooted_tree
	"""
}