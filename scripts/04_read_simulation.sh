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
    gfa_comps="${gfa_file%.*}_comps"

    # rm -r "${gfa_comps}"
    # mkdir -p "${gfa_comps}"
    GFASubgraph -g "${gfa_file}" output_comps --output_dir "${gfa_comps}" -n 100 --seq-size
    #  --seq-size
    # without the -n option, it does not sort components

    for file in "${gfa_comps}/component"{1..100}".gfa"; do
        gfatools stat "${file}" >> "${gfa_file}.stats";
        # Bandage info component1.gfa
    done;

    grep "Number of segments" "${gfa_file}.stats" > "${gfa_file}.seg"
    grep "Total segment length" "${gfa_file}.stats" > "${gfa_file}.len"
    rm "${gfa_file}.stats"
}

echo 'shatter_gfa "../../data/samples/RUS2.gfa"'
# rm -r RUS1_comps/ RUS1.gfa.len RUS1.gfa.seg
