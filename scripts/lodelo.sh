
# monday
picard CreateSequenceDictionary -R ../reference_lodEloB/lodEloB1.fasta -O ../reference_lodEloB/lodEloB1.fasta.dict

picard AddOrReplaceReadGroups -I lodelo_b1_short_reads_sorted_chrH.bam -O lodelo_b1_short_reads_sorted_chrH_RG.bam -LB L1 -PL ILLUMINA -PU U1 -SM lodEloB
picard BuildBamIndex -I lodelo_b1_short_reads_sorted_chrH_RG.bam

gatk3 -T HaplotypeCaller -R lodEloB1.fasta -I lodelo_b1_short_reads_sorted_chrH_RG.bam -o lodelo_b1_short_reads_sorted_chrH.vcf
