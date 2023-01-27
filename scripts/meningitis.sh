#!/bin/bash
# conda activate fluente
set -uo pipefail

function make_idx() {
    reference="${1}"
    idx_base="${reference%.*}"

    makeblastdb                 \
        -dbtype nucl            \
        -in  "${reference}"     \
        -out "${idx_base}"
}

function gfa2fna() {
    gfa="${1}"
    fna="${gfa%.*}.fna"
    gfatools gfa2fa "${gfa}" | seqkit seq -w 0 > "${fna}"
}

function filter() {
    query="${1}"
    reference="${2}"

    sample=$(basename "${query%.*}")
    dir=$(dirname "${query}")
    database="${reference%.*}"
    ref_id=$(basename "${database}")

    blastn -outfmt 6                \
        -max_target_seqs 1          \
        -max_hsps 1                 \
        -perc_identity 90           \
        -query "${query}"           \
        -db "${database}"           \
        | cut -f1                   \
        | sed "s/$/\$/"             \
        > "${dir}/${sample}.txt"

    grep --no-group-separator -A 1  \
        -f "${dir}/${sample}.txt"   \
        "${query}" \
        > "${dir}/${sample}.${ref_id}.fna"

    rm "${dir}/${sample}.txt"
}

function first() {
    num="${1}"
    fasta="${2}"

    out="${fasta%.*}.big${num}.fna"

    seqkit sort -lr "${fasta}" | seqkit seq -w 0 | head -n "$((2*${num}))" > "${out}"
}

