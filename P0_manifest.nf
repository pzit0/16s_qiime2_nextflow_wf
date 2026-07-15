#!/usr/bin/env nextflow

process P0_MANIFEST{
    publishDir "${launchDir}/results", mode: "copy"
    
    label: "make_manifest"

    input:
    path metadata
    path data_dir

    output:
    path "MANIFEST", emit manifest

    script:
    """
    ${projectDir}/make_manifest.py -m ${metadata} -s ${data_dir} -o scripts/MANIFEST
    """
}