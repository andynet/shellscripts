#!/bin/bash

set -euxo pipefail

INPUT="data/treecluster/clean.fna"

# split -d -a 4 -l 2 --additional-suffix .faa clean.fna faa/phage
fastaexplode -f clean.fna -d faa
grep "^>" clean.fna | sed "s/>//" > clean.list
ls faa/ > clean.list2
../../bin/cvtree -G faa/ -i clean.list2

TreeCluster.py -i tree/Hao.faa.cv7.nwk -t 0.5 -tf argmax_clusters > clean.clusters
# Best Threshold: 0.263000