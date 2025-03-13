[![Runs successfully](https://github.com/houlstonlab/test-gene-burden/actions/workflows/runs-successfully.yml/badge.svg?branch=main)](https://github.com/houlstonlab/test-gene-burden/actions/workflows/runs-successfully.yml)
### Introduction

This workflow tests the excess burden of variants in cases of a certain 
phenotype compared to a control poulation. The fisher's exact test is applied 
per gene, as a 2 x 2 table of cases with and without variants, compared to 
controls with and without variants. The cases with variants are counted from 
genotype dataset, and the controls are estimated from a summary public dataset. 
The workflow is designed and tested on a cohort generated using 
[this](https://github.com/houlstonlab/select-cohort-variants) workflow, and the 
GnomAD dataset summary processed using [this](https://github.com/houlstonlab/tabulate-gnomad-variants) workflow.

### Usage

The typical command looks like the following. `--cohorts` is the only required 
inputs

Different versions of the workflow can be called using `-r` and output directed 
to `--output_dir`

```bash
nextflow run houlstonlab/test-gene-burden \
    -r main \
    --output_dir results/ \
    --cohorts input/cohorts_info.csv
```

### Inputs & Parameters

- `cohorts`: a csv file with five columns `cohort`, `type`, `size`, `category`
and `file`. `file` has the aggregated counts of qualifying variants:
  - For cases, it expects 4 columns `gene`, `nvar`, `het`, `hom`, and `ch`
  - For controls, it expects `gene`, `nvar`, `ac`, `an`, `af`, and `nhom`

- Parameters
  - `n_cases`: The min number of cases modified in each gene 
  - `n_vars`: The min number of variants identified in each gene 
    
### Output

- `cohorts/`: Tabulated case counts and estimated control counts under dominant 
and recessive disease models
- `tests/`  : Applied fisher's exact test 
- `summary/`: Collected test results
