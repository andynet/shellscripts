#!/bin/bash
# conda activate fluente
set -euo pipefail

ROOT_DIR="/data/projects/fluente"

function make_idx() {
    makeblastdb                                                                 \
        -dbtype nucl                                                            \
        -in  "${ROOT_DIR}/reference/rvp/rvp.fa"                                 \
        -out "${ROOT_DIR}/reference/rvp/idx"

    mkdir -p "${ROOT_DIR}/reference/rvp/drafts"
    fastaexplode -f "${ROOT_DIR}/reference/rvp/rvp.fa"                          \
        -d "${ROOT_DIR}/reference/rvp/drafts"
}
export -f make_idx

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
export -f assemble

function scaffold() {
    SAMPLE=${1}

    mkdir -p "${ROOT_DIR}/assembly_branch/${SAMPLE}/medusa"
    medusa -d -v                                                                \
        -i "${ROOT_DIR}/assembly_branch/${SAMPLE}/spades/contigs.fasta"         \
        -f "${ROOT_DIR}/reference/rvp/drafts"                                   \
        -o "${ROOT_DIR}/assembly_branch/${SAMPLE}/medusa/scaffolds.fa"

    blastn -outfmt 6                                                            \
        -max_target_seqs 1                                                      \
        -max_hsps 1                                                             \
        -perc_identity 90                                                       \
        -query "${ROOT_DIR}/assembly_branch/${SAMPLE}/medusa/scaffolds.fa"      \
        -db "${ROOT_DIR}/reference/rvp/idx"                                     \
        | awk '$4 > 500 {print $0}' | cut -f1 | sed "s/$/\$/"                   \
        > "${ROOT_DIR}/assembly_branch/${SAMPLE}/medusa/rvp_scaffolds.txt"

    grep --no-group-separator -A 1                                              \
        -f "${ROOT_DIR}/assembly_branch/${SAMPLE}/medusa/rvp_scaffolds.txt"     \
        "${ROOT_DIR}/assembly_branch/${SAMPLE}/medusa/scaffolds.fa"             \
        >  "${ROOT_DIR}/assembly_branch/${SAMPLE}/medusa/rvp_scaffolds.fa"
}
export -f scaffold

for file in ../../reads/deduplicated/run*_R1.fastq.gz; do
    f=$(basename "${file%_R1*}");

    if [[ ! -e "${ROOT_DIR}/assembly_branch/${f}/spades/contigs.fasta" ]];
    then
        echo "Processing ${f}";
        assemble "${f}";
    fi
done;

while [[ $(qstat | wc -l ) -ne 0 ]]; do sleep 30; done;

for file in ${ROOT_DIR}/assembly_branch/*/spades/contigs.fasta; do
    f=$(basename $(dirname $(dirname ${file})));
    echo "Processing ${f}";
    scaffold ${f} > /dev/null;
done;

