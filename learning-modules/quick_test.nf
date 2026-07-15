#!/usr/bin/env nextflow 

// test parameters 
params.test = ["hello_world", "hola_mundo", "bonjour_monde", "bom_dia_mundo"]

// process
process testing{
    input:
    each greeting

    script:
    """
    echo ${greeting}
    """
}

// workflow
workflow{
    greetings_ch = Channel.fromList(params.test)
    testing(greetings_ch)
}