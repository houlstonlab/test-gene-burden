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
URL="https://figshare.com/ndownloader/files"

wget -c $URL/52171952 -O input/cohorts_info.csv
wget -c $URL/50357925 -O input/general.categoryA.aggregate.tsv
wget -c $URL/50357928 -O input/general.categoryB.aggregate.tsv
wget -c $URL/51077813 -O input/pheno.categoryA.aggregate.tsv
wget -c $URL/51077816 -O input/pheno.categoryB.aggregate.tsv

# Run nextflow
module load Nextflow

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
