#!/usr/bin/env nextflow

// Include Modules
include { P1_IMPORT } from "./P1_import.nf"
include { P2_FILTER } from "./P2_import.nf"

// Worflow
workflow{
    manifest_ch = Channel.fromPath(params.manifest, type: "dir")
    P1_IMPORT(manifest_ch)
    P2_FILTER(P1_IMPORT.out.p1_results.collect(),
		params.p2_forward_primer, 
		params.p2_reverse_primer)
}