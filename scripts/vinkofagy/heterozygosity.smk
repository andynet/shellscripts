rule usage:  
    shell:"""
        echo "From /home/balaz/projects/phages"
        echo "Example targets:"
        echo "    snake data/heterozygosity/SAMN21366011.fna"
        echo "    snake data/heterozygosity/SAMN21366011.phages_to_SAMN21366011.bam"
        echo "    snake data/heterozygosity/SRR15827947_mapped_to_SAMN21366011.bam"
    """ 

rule gfa2fa:
    input: "{datadir}/{filename}.gfa"
    output: "{datadir}/{filename}.fna"
    shell: "gfatools gfa2fa {input} > {output}"

rule minimap:
    input: 
        reference="{datadir}/{filename1}.fna",
        query="{datadir}/{filename2}.fna"
    output: 
        bam="{datadir}/{filename2}_to_{filename1}.bam",
        bai="{datadir}/{filename2}_to_{filename1}.bam.bai"
    shell:"""
        minimap2 -x asm20 -a {input.reference} {input.query} | samtools sort -O bam > {output.bam}
        samtools index {output.bam}
    """

rule map_short:
    input:
        ref="{datadir}/{filename1}.fna",
        reads="{datadir}/{filename2}.short.interleaved.fastq"
    output:
        bam="{datadir}/{filename2}_mapped_to_{filename1}.bam",
        bai="{datadir}/{filename2}_mapped_to_{filename1}.bam.bai"
    shell:"""
        bwa index {input.ref}
        bwa mem -p {input.ref} {input.reads} | samtools sort -O bam > {output.bam}
        samtools index {output.bam} 
    """ 