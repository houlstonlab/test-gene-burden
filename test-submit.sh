#!/bin/bash

#SBATCH -o test/test.out
#SBATCH -e test/test.err
#SBATCH -J test
#SBATCH -p master-worker
#SBATCH -t 120:00:00

# Setup test directory
mkdir -p test/ test/input
cd test/

# Download test data
URL="https://raw.githubusercontent.com/houlstonlab/toy-datasets/refs/heads/main/cohort-counts/"
for file in cohorts_info.csv general.categoryA.aggregate.tsv general.categoryB.aggregate.tsv pheno.categoryA.aggregate.tsv pheno.categoryB.aggregate.tsv; do
    wget -O input/$file $URL/$file
done

# Run nextflow
# nextflow run houlstonlab/test-gene-burden -r test-gh \
nextflow run ../main.nf \
    --output_dir ./results/ \
    -profile local,gha \
    -resume

# usage: nextflow run [ local_dir/main.nf | git_url ]  
# These are the required arguments:
#     -r            {main,dev,gha} to run specific branch
#     -profile      {local,cluster} to run using differens resources
#     -params-file  params.json to pass parameters to the pipeline
#     -resume       To resume the pipeline from the last checkpoint