#!/bin/bash
# conda activate fluente
set -euo pipefail

function make_idx() {
    fasta="${1}"
    dirname=$(dirname $(realpath "${fasta}"))

    makeblastdb                 \
        -dbtype nucl            \
        -in  "${fasta}"         \
        -out "${dirname}/idx"

    mkdir -p "${dirname}/drafts"
    sed "s/\//_/g;s/|/_/g" "${fasta}" > "${fasta}.tmp"
    fastaexplode                \
        -f "${fasta}.tmp"       \
        -d "${dirname}/drafts"
    rm "${fasta}.tmp"
}

function assemble() {
    SAMPLE=${1}

    mkdir -p "${ROOT_DIR}/assembly_branch/${SAMPLE}/spades"
    qsub -cwd -V -N rvp -b y -l thr=16 -l h='!gen-nod08' "
        spades.py --meta                                                            \
            -1 ${ROOT_DIR}/reads/deduplicated/${SAMPLE}_R1.fastq.gz                 \
            -2 ${ROOT_DIR}/reads/deduplicated/${SAMPLE}_R2.fastq.gz                 \
            -o ${ROOT_DIR}/assembly_branch/${SAMPLE}/spades
    "
}

function scaffold() {
    SAMPLE=${1}

    mkdir -p "${ROOT_DIR}/assembly_branch/${SAMPLE}/medusa"
    medusa -d -v                                                                \
        -i "${ROOT_DIR}/assembly_branch/${SAMPLE}/spades/contigs.fasta"         \
        -f "${ROOT_DIR}/reference/rvp/drafts"                                   \
        -o "${ROOT_DIR}/assembly_branch/${SAMPLE}/medusa/scaffolds.fa"
}

function filter() {
    query="${1}"
    reference="${2}"

    output="$(dirname $(realpath ${query}))"
    database="$(dirname $(realpath ${reference}))/idx"

    blastn -outfmt 6                \
        -max_target_seqs 1          \
        -max_hsps 1                 \
        -perc_identity 90           \
        -query "${query}"           \
        -db "${database}"           \
        | awk '$4 > 500 {print $0}' \
        | cut -f1                   \
        | sed "s/$/\$/"             \
        > "${output}/filtrate.txt"

    grep --no-group-separator -A 1                                              \
        -f "${output}/filtrate.txt"    \
        "${query}" \
        > "${output}/filtrate.fa"
}

export -f make_idx
export -f assemble
export -f scaffold
export -f filter

# ROOT_DIR="/data/projects/fluente"
# ROOT_DIR="/home/andy/projects/phages/data/fluente"

# make_idx "${ROOT_DIR}/reference/rvp/rvp.fa"
# make_idx "${ROOT_DIR}/reference/h3n2/h3n2_ha_gene_2021.fa"

# for file in ../../reads/deduplicated/run*_R1.fastq.gz; do
#     f=$(basename "${file%_R1*}");

#     if [[ ! -e "${ROOT_DIR}/assembly_branch/${f}/spades/contigs.fasta" ]];
#     then
#         echo "Processing ${f}";
#         assemble "${f}";
#     fi
# done;

# while [[ $(qstat | wc -l ) -ne 0 ]]; do sleep 30; done;

# for file in ${ROOT_DIR}/assembly_branch/*/spades/contigs.fasta; do
#     f=$(basename $(dirname $(dirname ${file})));
#     echo "Processing ${f}";
#     scaffold ${f} > /dev/null;
# done;

# reference="${ROOT_DIR}/reference/h3n2/h3n2_ha_gene_2021.fa"

# for file in ${ROOT_DIR}/assembly_branch/*/medusa/scaffolds.fa; do
#     echo ${file};
#     filter "${file}" "${reference}"
# done;
