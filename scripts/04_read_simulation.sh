#!/bin/bash
[[ $- != *i* ]] && set -euxo pipefail

export PROJ_DIR="/home/andy/projects/phages"

iss generate
    --seed $RANDOM
    --genomes ../phage_database/phages.fasta
    --n_genomes $num_genomes
    --n_reads $num_reads
    --model $seqen
    --compress
    --output ${num_genomes}${seqen}${num_reads}