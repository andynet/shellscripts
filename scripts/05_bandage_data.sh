#!/bin/bash
[[ $- != *i* ]] && set -euxo pipefail

# create_blastdb phages.fna -> phages_db
function create_blastdb() {
    sequences=${1}

    base="$(basename "${sequences%.*}")"
    index_dir="$(dirname "${sequences}")/${base}_db"
    echo "Index stored to ${index_dir}"

    mkdir -p "${index_dir}"
    seqkit seq -w 0 "${sequences}" > "${index_dir}/2line.fna"

    makeblastdb                                 \
        -dbtype nucl                            \
        -in "${index_dir}/2line.fna"    \
        -out "${index_dir}/idx"
}

# get_supported_phages phages_db assembly.gfa -> assembly_phages.fna
function get_supported_phages() {
    blast_db=${1}   # blast_db
    assembly=${2}   # assembly.gfa
    min_size="1000"

    filename=$(basename ${assembly})
    name="$(dirname ${assembly})/${filename%%.*}"

    gfatools gfa2fa "${assembly}" > "${name}.fna"

    seqkit seq -m "${min_size}" "${name}.fna" > "${name}.large.fna"

    blastn -max_target_seqs 1 -max_hsps 1 -outfmt 6     \
        -query "${name}.large.fna"                      \
        -db "${blast_db}/idx" > "${name}.blast"

    less "${name}.blast" | cut -f 2 | sort | uniq -c | sort -rn | nl    \
        | tr -d "\t" | tr -s " " | tr " " "\t" | cut -f 4               \
        > "${name}.supported.txt"

    grep --no-group-separator -A 1 -f "${name}.supported.txt" "${blast_db}/2line.fna" \
        > "${name}.supported.fna"

    rm "${name}".{fna,large.fna,blast,supported.txt}
}

# create_blastdb phages.fna -> phages_db
# get_supported_phages phages_db assembly.gfa -> assembly_phages.fna

# cd-hit-est -T 6 -c 0.9 -i ${ASSEMBLY}.supported.fna -o ${ASSEMBLY}.relatives.fna
# gfatools view -l 1132015 -r 500 assembly_graph.gfa > subgraph.gfa
# seqkit sort -l phages_2022-07-22.2line.fna | seqkit seq -w 0 > phages_2022-07-22.2line.rsorted.fna
