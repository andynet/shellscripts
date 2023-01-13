#!/bin/bash
# conda activate fluente
set -euo pipefail

ROOT_DIR="/home/andy/projects/phages/data/fluente"

makeblastdb                                                                     \
    -dbtype nucl                                                                \
    -in  "${ROOT_DIR}/reference/rvp/rvp.fa"                                     \
    -out "${ROOT_DIR}/reference/rvp/idx"

mkdir -p "${ROOT_DIR}/reference/rvp/drafts"
fastaexplode -f "${ROOT_DIR}/reference/rvp/rvp.fa"                              \
    -d "${ROOT_DIR}/reference/rvp/drafts"

SAMPLE="run221223_UVZ_BA_22-vsp-41637" # _R1.fastq.gz

mkdir -p "${ROOT_DIR}/assembly_branch/${SAMPLE}/spades"
spades.py --meta                                                                \
    -1 "${ROOT_DIR}/reads/deduplicated/${SAMPLE}_R1.fastq.gz"                   \
    -2 "${ROOT_DIR}/reads/deduplicated/${SAMPLE}_R2.fastq.gz"                   \
    -o "${ROOT_DIR}/assembly_branch/${SAMPLE}/spades"

mkdir -p "${ROOT_DIR}/assembly_branch/${SAMPLE}/medusa"
medusa -d -v                                                                    \
    -i "${ROOT_DIR}/assembly_branch/${SAMPLE}/spades/contigs.fasta"             \
    -f "${ROOT_DIR}/reference/rvp/drafts"                                       \
    -o "${ROOT_DIR}/assembly_branch/${SAMPLE}/medusa/scaffolds.fa"

blastn -outfmt 6                                                                \
    -max_target_seqs 1                                                          \
    -max_hsps 1                                                                 \
    -perc_identity 90                                                           \
    -query "${ROOT_DIR}/assembly_branch/${SAMPLE}/medusa/scaffolds.fa"          \
    -db "${ROOT_DIR}/reference/rvp/idx"                                         \
    | awk '$4 > 500 {print $0}' | cut -f1 | sed "s/$/\$/"                       \
    > "${ROOT_DIR}/assembly_branch/${SAMPLE}/medusa/rvp_scaffolds.txt"

grep --no-group-separator -A 1                                                  \
    -f "${ROOT_DIR}/assembly_branch/${SAMPLE}/medusa/rvp_scaffolds.txt"         \
       "${ROOT_DIR}/assembly_branch/${SAMPLE}/medusa/scaffolds.fa"              \
    >  "${ROOT_DIR}/assembly_branch/${SAMPLE}/medusa/rvp_scaffolds.fa"
