#!/bin/bash

# inputs:
# sequences.fasta -> original.fna

# needed software:
# seqkit, taxonkit

set -euxo pipefail

export TAXONKIT_DB=$(realpath ./taxonkit_db)

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
    > clean.txt

# NC_007024 has 2 hosts - Xanthomonas Campestris, Xanthomonas Hortorum
# Hortorum probably should not exist

sed "N;N;N;s/\n/\t/g" clean.txt                         \
    | cut -f 1,4                                        \
    | sort                                              \
    | uniq                                              \
    | seqkit tab2fx -w 0                                \
    > clean.fna

sed "N;N;N;s/\n/\t/g" clean.txt                             \
    | cut -f 2                                              \
    | taxonkit reformat -i 1 -S -F -f "{k}\t{g}\t{s}\t{t}"  \
    | cut -f 2-                                             \
    > clean.host_tax.txt

ktImportText -q clean.host_tax.txt -o clean.host_tax.html

