#!/bin/bash
# conda activate fluente
set -euo pipefail

data_dir="/home/andy/projects/phages/data/fluente"
reference="${data_dir}/reference/h3n2/h3n2_ha_gene_2021.fa"

for consensus in ${data_dir}/consensus/consensus-h3n2_ha_gene_*-wgs.fa; do
    minimap2 -x asm20 -a "${reference}" "${consensus}" \
    | samtools sort -O bam > "${consensus}.bam"
    samtools index "${consensus}.bam"
done;