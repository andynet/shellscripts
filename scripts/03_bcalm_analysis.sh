#!/bin/bash
[[ $- != *i* ]] && set -euxo pipefail

export PROJ_DIR="/home/andy/projects/phages"

function extract_cluster() {
    file=$1;
    clust_num=$2;
    fasta=$3;
    output=$4;

    grep -P "\t${clust_num}$" "${file}" | cut -f 1 > tmp
    grep -A 1 -f tmp --no-group-separator "${fasta}" > "${output}"
    rm tmp
}

function get_unitigs() {
    input=$1;
    k=$2;
    output=$3;

    bcalm -in "${input}" -kmer-size "${k}" -abundance-min 0 -out tmp > /dev/null 2>&1
    # bcalm -in "${input}" -kmer-size "${k}" -abundance-min 0 -out tmp
    "${PROJ_DIR}/tools/bcalm/scripts/convertToGFA.py" tmp.unitigs.fa "${output}" "${k}" > /dev/null 2>&1
    # "${PROJ_DIR}/tools/bcalm/scripts/convertToGFA.py" tmp.unitigs.fa "${output}" 100
    rm tmp.unitigs.fa
}

# extract_cluster clusters 4 seqs.fna cluster4.fna
# get_unitigs cluster4.fna 190 cluster4.gfa

# join -j 1 -o 1.1,1.2,2.1,2.2 <(sort clusters) <(sort lengths.tsv) > merged.txt
# sort -n -k4 merged.txt > merged.sorted.txt