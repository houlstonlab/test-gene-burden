process TEST {
    tag "${category}:${case_cohort}:${cont_cohort}:${model}"

    label 'simple'
    label 'rocker'

    publishDir("${params.output_dir}/tests", mode: 'copy')

    input:
    tuple val(category),
          val(case_cohort), val(case_type), path(case_file),
          val(cont_cohort), val(cont_type), path(cont_file),
          val(model)

    output:
    tuple val(category), val(case_cohort), val(cont_cohort), val(model),
          path("${category}.${case_cohort}.${cont_cohort}.${model}.tsv")

    script:
    """
    #!/bin/bash
    burden_test.R ${case_file} ${cont_file} ${model} ${params.n_cases} ${params.n_vars} ${category}.${case_cohort}.${cont_cohort}.${model}.tsv
    """
}
