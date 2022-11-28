#!/bin/bash

set -euo pipefail

# run from ~/projects/phages/data/vinko_data

# scp balaz@compbio:~/metaphages/scripts_andy/short.gfas.txt .
# sort -o hybrid.gfas.txt hybrid.gfas.txt

# hybrid.fnas.txt hybrid.gfas.txt short.fnas.txt short.gfas.txt

for file in hybrid.fnas.txt hybrid.gfas.txt short.fnas.txt short.gfas.txt; do
    shuf --random-source=<(yes 0) "${file}" | head -n 10 > "${file}.random"
done;

while read -r line; do
    sample_name=$(echo "${line}" | cut -f7 -d "/")
    scp balaz@compbio:"${line}" "${sample_name}.hybrid.supported.fna"
done < hybrid.fnas.txt.random

while read -r line; do
    sample_name=$(echo "${line}" | cut -f7 -d "/")
    scp balaz@compbio:"${line}" "${sample_name}.short.supported.fna"
done < short.fnas.txt.random

while read -r line; do
    sample_name=$(echo "${line}" | cut -f7 -d "/")
    scp balaz@compbio:"${line}" "${sample_name}.hybrid.gfa.gz"
    gunzip "${sample_name}.hybrid.gfa.gz"
done < hybrid.gfas.txt.random

while read -r line; do
    sample_name=$(echo "${line}" | cut -f7 -d "/")
    scp balaz@compbio:"${line}" "${sample_name}.short.gfa.gz"
    gunzip "${sample_name}.short.gfa.gz"
done < short.gfas.txt.random

# not working
# RANDOM=0
# shuf --random-source=<(yes $RANDOM) fnas.txt | head -n 20 > fnas.random3.txt
