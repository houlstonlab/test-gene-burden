#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { READ }      from './modules/read.nf'
include { TEST }      from './modules/test.nf'

// Define input channels
cohorts_ch = Channel.fromPath(params.cohorts)
        | splitCsv(header: true, sep: ',')
        | map { row -> [
            row.cohort, row.type, row.size, 
            row.category,
            file(row.file)
        ] }

model_ch = Channel.of('DOM', 'REC')

workflow  {
    // Load cohorts
    cohorts_ch
        | READ
        | branch {
            cases: it[1] == 'cases'
            controls: it[1] == 'controls'
        }
        | set { counts }

    // Run tests
    counts.cases 
        | combine(counts.controls, by: 2)
        | combine(model_ch)
        | filter { it[0] != 'ALL' }
        | TEST
        | collectFile (
            keepHeader: true,
            storeDir: "${params.output_dir}/summary",
        )
        { it -> [ "${it[1]}.${it[2]}.test.tsv", it.last() ] } 
}
