#!/usr/bin/env nextflow

process P0_MANIFEST{
    publishDir "${launchDir}/data", mode: "copy"

    input:
    metadata
    data_dir

    output:
    path MANIFEST

    script:
    '''
    make_manifest.py -m ${metadata} -s ${data_dir}
    '''
}