#!/bin/bash
[[ $- != *i* ]] && set -euo pipefail

# export PROJ_DIR="/home/andy/projects/phages"

# iss generate
#     --seed $RANDOM
#     --genomes ../phage_database/phages.fasta
#     --n_genomes $num_genomes
#     --n_reads $num_reads
#     --model $seqen
#     --compress
#     --output ${num_genomes}${seqen}${num_reads}

# git clone git@github.com:fawaz-dabbaghieh/gfa_subgraphs.git
# pip install .

# shatter_gfa assembly.gfa -> assembly_comps/componentX.gfa, assembly.gfa.len, assembly.gfa.seg
function shatter_gfa() {
    gfa_file="${1}"
    base="${gfa_file%.*}"

    n_comps=$(Bandage info "${gfa_file}" | grep "Connected components" | tr -s " " | cut -f3 -d " ")

    GFASubgraph -g "${gfa_file}" output_comps --output_dir "${base}_comps" -n "${n_comps}" --seq-size

    for i in $(eval "echo {1..${n_comps}}"); do
        file="${base}_comps/component${i}.gfa";
        gfatools stat "${file}" >> "${base}.stats";
        Bandage info "${file}" >> "${base}.stats";
    done;

    grep "Total segment length" "${base}.stats" > "${base}.len"
    grep "Number of segments"   "${base}.stats" > "${base}.nseg"
    grep "Median depth"         "${base}.stats" > "${base}.depth"
}

# echo 'shatter_gfa "../../data/samples/RUS2.gfa"'
# rm -r RUS1_comps/ RUS1.gfa.len RUS1.gfa.seg
