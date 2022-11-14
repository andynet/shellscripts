#!/bin/bash

# input: reads_R1.fastq, reads_R2.fastq

# fn fastqc: reads.fastq -> report - for trimming parameters

# correct ends, length, quality
# fn trimmomatic: reads_R1.fastq, reads_R2.fastq
#       -> clean_reads_R1.fastq, clean_reads_R2.fastq

# deduplication? NO! https://www.biostars.org/p/230822/

# read correction?
# -> https://github.com/jts/sga
# -> https://github.com/Malfoy/BCOOL

# fn kmergenie: reads -> assembly size, best k, abundance spectrum

# subsample to specific coverage?
seqtk sample -s 100 <fastq> 3000000 > <out>

# fn kmergenie: reads -> assembly size, best k, abundance spectrum, coverage?
# multiply abundance_i by i to get abundance mass

# assembly
# -> spades/metaspades
# -> bcalm -> vg flow
# -> savage -> vg flow

# evaluation
# -> NG50
# -> back-mapped reads to contigs + igv visualization
# -> back-mapped reads to gfa (Giraffe?), https://github.com/Malfoy/BGREAT
# -> other graph statistics?

# fn f: reads + contigs -> insert_size

# scaffolding
# fn medusa: contigs + references -> scaffolds/complete genomes

#-------------------------------------------------------------------------------
# fn split_gfa_to_components: sample.gfa -> sample.(1..k).gfa

# visualization tools
# -> igv
# -> bandage
# -> MEGA
# -> JalView + Jmol
