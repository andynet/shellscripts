#!/bin/bash
# conda activate fluente
set -euo pipefail


SAMPLE="run221223_UVZ_BA_22-vsp-41416" # _R1.fastq.gz
ROOT_DIR="/home/andy/projects/phages/data/fluente"

# mkdir -p "${ROOT_DIR}/spades/${SAMPLE}"

# spades.py --meta \
#     -1 "${ROOT_DIR}/reads/deduplicated/${SAMPLE}_R1.fastq.gz" \
#     -2 "${ROOT_DIR}/reads/deduplicated/${SAMPLE}_R2.fastq.gz" \
#     -o "${ROOT_DIR}/spades/${SAMPLE}"

# mkdir -p "${ROOT_DIR}/reference/rvp"
# fastaexplode -f "${ROOT_DIR}/reference/rvp.fa" -d "${ROOT_DIR}/reference/rvp"
# mkdir -p "${ROOT_DIR}/medusa"
# medusa -d -v \
#     -i "${ROOT_DIR}/spades/${SAMPLE}/contigs.fasta" \
#     -f "${ROOT_DIR}/reference/rvp" \
#     -o "${ROOT_DIR}/medusa/scaffolds.fa"

# makeblastdb                                     \
#         -dbtype nucl                            \
#         -in  "${ROOT_DIR}/reference/rvp.fa"     \
#         -out "${ROOT_DIR}/reference/rvp_idx"

blastn -outfmt 6 \
    -max_target_seqs 1 \
    -max_hsps 1 \
    -perc_identity 90 \
    -query "${ROOT_DIR}/medusa/scaffolds.fa" \
    -db "${ROOT_DIR}/reference/rvp_idx" \
    | awk '$4 > 500 {print $0}' \
    | cut -f1 \
    | sed "s/$/\$/" > "${ROOT_DIR}/medusa/rvp_scaffolds.txt"

grep --no-group-separator -A 1 -f "${ROOT_DIR}/medusa/rvp_scaffolds.txt" \
    "${ROOT_DIR}/medusa/scaffolds.fa" \
    > "${ROOT_DIR}/medusa/rvp_scaffolds.fa"