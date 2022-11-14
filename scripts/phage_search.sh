#!/bin/bash

set -euo pipefail
set +e

assemblies=$(find ../big-data/small -name hybrid.gfa.gz)

for f in ${assemblies}; do
    echo "Processing ${f}.";
    binqsub -V -N search_phage "source supported_phages.sh; get_supported_phages ../db/phages_db ${f};"
done;

# find .. -name hybrid.supported.fna -printf "%s %p\n"

