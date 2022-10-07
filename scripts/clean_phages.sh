#!/bin/bash

# inputs:
# sequences.fasta -> original.fna

# needed software:
# seqkit, taxonkit

set -euxo pipefail

export TAXONKIT_DB=$(realpath ./taxonkit_db)

# seqkit fx2tab original.fna                              \
#     | grep "complete genome"                            \
#     | grep -v "UNVERIFIED"                              \
#     | sed -e "s/|/\t/g"                                 \
#     | grep -Pv "\t\t"                                   \
#     | taxonkit name2taxid -i 3                          \
#     | taxonkit lineage -R -i 6                          \
#     | awk -F "\t" '{ print $1 " " $7 " " $8 "\t" $4}'   \
#     | seqkit tab2fx -w 0                                \
#     | grep "Bacteria" -A 1 --no-group-separator         \
#     > clean.fna

seqkit fx2tab original.fna                              \
    | grep "complete genome"                            \
    | grep -v "UNVERIFIED"                              \
    | sed -e "s/ |/\t/g"                                \
    | sed -e "s/|/\t/g"                                 \
    | grep -Pv "\t\t"                                   \
    | taxonkit name2taxid -i 3                          \
    | taxonkit lineage -R -i 6                          \
    | awk -F "\t" '{ print $1 "\n" $7 "\n" $8 "\n" $4}' \
    | grep "Bacteria" -A 2 -B 1 --no-group-separator    \
    | sed "s/ /_/g"                                     \
    > clean.txt

sed "N;N;N;s/\n/\t/g" clean.txt                         \
    | cut -f 1,4                                        \
    | seqkit tab2fx -w 0                                \
    > clean.fna

# ktImportText -q hosts_krona.txt

