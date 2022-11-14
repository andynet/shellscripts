#!/bin/bash

set -euxo pipefail

INPUT="data/treecluster/clean.fna"

mkdir fna
fastaexplode -f clean.fna -d fna
rename "s/.fa/.fna/g" fna/*.fa
ls fna/ | sed "s/.fna//g" > clean.list
../../bin/cvtree -g fna -G fna/ -i clean.list

TreeCluster.py -i tree/Hao.fna.cv7.nwk -t 0.5 -tf argmax_clusters > clean.clusters
# Best Threshold: 0.263000