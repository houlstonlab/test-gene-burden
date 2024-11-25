[![Runs successfully](https://github.com/houlstonlab/test-gene-burden/actions/workflows/runs-successfully.yml/badge.svg?branch=main)](https://github.com/houlstonlab/test-gene-burden/actions/workflows/runs-successfully.yml)
### Introduction

This workflow tests the excess burden of variants in cases of a certain phenotype compared to a control poulation.
The fisher's exact test is applied per gene, as a 2 x 2 table of cases with and without variants, compared to 
controls with and without variants. The cases with variants are counted from genotype dataset, and the controls are
estimated from a summary public dataset. The workflow is designed and tested on a cohort generated using 
[this](https://github.com/houlstonlab/select-cohort-variants) workflow, and the GnomAD dataset summary processed
using [this](https://github.com/houlstonlab/tabulate-gnomad-variants) workflow.

### Usage

The typical command looks like the following. `--cohorts_info` and `--cohorts` are required inputs. 
Different versions of the workflow can be called using `-r` and output directed to `--output_dir`

```bash
nextflow run houlstonlab/test-gene-burden \
    -r main \
    --output_dir results/ \
    --cohorts_info "input/cohorts_info.csv" \
    --cohorts "input/*.aggregate.tsv"
```

### Inputs & Parameters

- `cohorts_info`: a csv with cohort information. Expected to have three columns `cohort`, `type` and `size`
- `cohorts`     : tsv files with count of individuals with qualifying variants
  - For cases, it expects 4 columns `gene`, `het`, `hom`, and `ch`
  - For controls, it expects `gene`, `nvar`, `ac`, `an`, `af`, and `nhom`
    
### Output

- `cohorts/`: Tabulated case counts and estimated control counts under dominant and recessive disease models
- `tests/`  : Applied fisher's exact test 
- `summary/`: Collected test results
