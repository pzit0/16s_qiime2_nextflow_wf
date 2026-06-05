#!/usr/bin/env nextflow

// Include Modules
include { P1_IMPORT } from "./16s_modules/P1_import.nf"

// Worflow
workflow{
    seqDir_ch = Channel.fromPath(params.seqDir, type: "dir")
    P1_IMPORT(seqDir_ch)
}