#!/usr/bin/env nextflow

// Include Modules
include { P1_IMPORT } from "./P1_import.nf"
include { P2_FILTER } from "./P2_filter.nf"
include { P3_DENOISE } from "./P3_denoise.nf"
include { P4_PHYLOTREE } from "./P4_phylotree.nf"
include { P5_RAREFACTION } from "./P5_rarefaction.nf" 
include { P6_TAXONOMY } from "./P6_taxonomy.nf"

// Worflow
workflow{
    manifest_ch = Channel.fromPath(params.manifest, type: "dir")
    metadata_ch = Channel.fromPath(params.metadata)
    classifiers_ch = Channel.fromList(params.p6_classifiers)

    P1_IMPORT(manifest_ch)
    P2_FILTER(P1_IMPORT.out.p1_results.collect(),
		params.p2_forward_primer, 
		params.p2_reverse_primer)
    P3_DENOISE(P2_FILTER.out.p2_results.collect(), 
		params.p3_forward_left, 
		params.p3_forward_right, 
		params.p3_reverse_left, 
		params.p3_reverse_right)
    P4_PHYLOTREE(P3_DENOISE.out.p3_rep_seqs.collect())
    P5_RAREFACTION(P3_DENOISE.out.p3_denoised_table.collect(),
        P4_PHYLOTREE.out.p4_rooted_tree.collect(),
        metadata_ch,
        params.p5_max_depth,
        params.p5_steps,
        params.p5_metrics)
    P6_TAXONOMY(classifiers_ch,
        P3_DENOISE.out.p3_rep_seqs,
        P3_DENOISE.out.p3_denoised_table,
        metadata_ch,
        params.p6_tax_level_collapse)
}