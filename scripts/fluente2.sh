#!/bin/bash
# conda activate fluente
set -uo pipefail

function scaffold() {
    gfa=${1}
    drafts=${2}

    sample=$(basename "${gfa%.*}")
    dir=$(dirname "${gfa}")

    gfatools gfa2fa "${gfa}" > "${dir}/${sample}.contigs.fna"
    medusa -d -v                                                                \
        -i "${dir}/${sample}.contigs.fna"                                       \
        -f "${drafts}"                                                          \
        -o "${dir}/${sample}.scaffolds.fna"                                       \
        > "${sample}.log" 2> "${sample}.err"
}

function filter() {
    query="${1}"
    reference="${2}"

    sample=$(basename "${query%.*}")
    dir=$(dirname "${query}")
    database=$(dirname "${reference}")/idx
    ref_id=$(basename "${reference%.*}")

    blastn -outfmt 6                \
        -max_target_seqs 1          \
        -max_hsps 1                 \
        -perc_identity 90           \
        -query "${query}"           \
        -db "${database}"           \
        | awk '$4 > 500 {print $0}' \
        | cut -f1                   \
        | sed "s/$/\$/"             \
        > "${dir}/${sample}.txt"

    grep --no-group-separator -A 1  \
        -f "${dir}/${sample}.txt"   \
        "${query}" \
        > "${dir}/${sample}.${ref_id}.fna"

    rm "${dir}/${sample}.txt"
}

function edit_dist() {
    needle -auto a.fna b.fna -outfile tmp.needle
}