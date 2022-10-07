#!/bin/bash
set -euxo pipefail

DB=${1%.fna}            # .fna
ASSEMBLY=${2%.gfa}      # .gfa
MIN_SIZE=1000

if [[ ! -e ${DB}.2line.fna.ndb ]]; then
    seqkit seq -w 0 ${DB}.fna > ${DB}.2line.fna
    makeblastdb -dbtype nucl -in ${DB}.2line.fna
fi

gfatools gfa2fa ${ASSEMBLY}.gfa > ${ASSEMBLY}.fna
seqkit seq -m ${MIN_SIZE} ${ASSEMBLY}.fna > ${ASSEMBLY}.large.fna

blastn -max_target_seqs 1 -max_hsps 1 -outfmt 6     \
    -query ${ASSEMBLY}.large.fna                    \
    -db ${DB}.2line.fna > ${ASSEMBLY}.blast

less ${ASSEMBLY}.blast | cut -f 2 | sort | uniq -c | sort -rn | nl \
    | tr -d "\t" | tr -s " " | tr " " "\t" | cut -f 4 > ${ASSEMBLY}.supported.txt

grep --no-group-separator -A 1 -f ${ASSEMBLY}.supported.txt ${DB}.2line.fna \
    > ${ASSEMBLY}.supported.fna

# cd-hit-est -T 6 -c 0.9 -i ${ASSEMBLY}.supported.fna -o ${ASSEMBLY}.relatives.fna

rm ${ASSEMBLY}.{large.fna,blast,supported.txt}
# gfatools view -l 1132015 -r 500 assembly_graph.gfa > subgraph.gfa
# seqkit sort -l phages_2022-07-22.2line.fna | seqkit seq -w 0 > phages_2022-07-22.2line.rsorted.fna
