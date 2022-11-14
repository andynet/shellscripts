#!/bin/bash
set -euxo pipefail

function assemble_short() {
    if [ -e "${1}_assembly/assembly.gfa" ]; then
        echo "${1} is completed. rm it to rerun."
        return
    fi

    prefetch "${1}"
    ln -s ~/ncbi/public/sra/"${1}.sra" ~/metaphages/data

    fastq-dump --split-3 "${1}.sra"
    gzip -f "${1}_1.fastq"
    gzip -f "${1}_2.fastq"
    rm "${1}.sra"

    qsub -b y -cwd -V -l memory=32G -l threads=8    \
        unicycler                                   \
        -1 "${1}_1.fastq.gz"                        \
        -2 "${1}_2.fastq.gz"                        \
        -o "${1}_assembly"
}

function assemble() {
    if [ -e "${1}_assembly/assembly.gfa" ]; then
        echo "${1} is completed. rm it to rerun."
        return
    fi

    prefetch "${1}"
    ln -s ~/ncbi/public/sra/"${1}.sra" ~/metaphages/data

    fastq-dump "${1}.sra"
    gzip -f "${1}.fastq"
    rm "${1}.sra"

    qsub -b y -cwd -V -l memory=32G -l threads=8    \
        unicycler                                   \
            --mode bold                             \
            -1 "${2}_1.fastq.gz"                    \
            -2 "${2}_2.fastq.gz"                    \
            -l "${1}.fastq.gz"                      \
            -o "${1}_assembly"
}

short_reads=(SRR11948991 SRR11949106 SRR11949291)
 long_reads=(SRR12299073 SRR12298970 SRR12298560)

assemble_short "${short_reads[0]}"
assemble_short "${short_reads[1]}"
assemble_short "${short_reads[2]}"

while [[ -n $(qstat) ]]; do sleep 60; done;

assemble "${long_reads[0]}" "${short_reads[0]}"
assemble "${long_reads[1]}" "${short_reads[1]}"
assemble "${long_reads[2]}" "${short_reads[2]}"

