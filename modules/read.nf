process READ {
    tag "${cohort}:${category}"

    label 'simple'
    label 'rocker'

    publishDir("${params.output_dir}/counts", mode: 'copy')

    input:
    tuple val(cohort), val(type), val(size), val(category), path(file)

    output:
    tuple val(cohort), val(type), val(category),
          path("${type}.${cohort}.${category}.tsv")
    
    script:
    """
    #!/bin/bash
    read_frequency.R ${type} ${cohort} ${category} ${file} ${size} ${type}.${cohort}.${category}.tsv
    """
}
