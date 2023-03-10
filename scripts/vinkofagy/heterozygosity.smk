rule usage:  
    shell:"""
        echo "From /home/balaz/projects/phages"
        echo "Example targets:"
        echo "    snake data/heterozygosity/SAMN21366011.fna"
        echo "    snake data/heterozygosity/SAMN21366011.phages_to_SAMN21366011.bam"
        echo "    snake data/heterozygosity/SRR15827947_mapped_to_SAMN21366011.bam"
    """ 

rule heterozygosity:
    input: 
        "data/heterozygosity/SRR15827947_mapped_to_SAMN21366011_hybrid.bam",
        "data/heterozygosity/SRR15827947_mapped_to_SAMN21366011_short.bam",
        "data/heterozygosity/SAMN21366011_phages_to_SAMN21366011_hybrid.bam",
        "data/heterozygosity/SAMN21366011_phages_to_SAMN21366011_short.bam"
    
rule gfa2fa:
    input: "{datadir}/{filename}.gfa"
    output: "{datadir}/{filename}.fna"
    shell: """
        gfatools gfa2fa {input} | seqkit seq -w 0 > {output}
    """

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

rule bwa_index:
    input: "{datadir}/{filename}.fna"
    output: 
        expand("{{datadir}}/{{filename}}_idx/bwa.{ext}", ext=["amb", "ann", "bwt", "pac", "sa"]),
        check="{datadir}/{filename}_idx/bwa.done"
    params: "{datadir}/{filename}_idx/bwa"
    shell: """
        bwa index {input} -p {params}
        touch {output.check}
    """ 

rule map_short:
    input:
        ref="{datadir}/{filename1}_idx/bwa.done",
        reads="{datadir}/{filename2}.short.interleaved.fastq"
    output:
        bam="{datadir}/{filename2}_mapped_to_{filename1}.bam",
        bai="{datadir}/{filename2}_mapped_to_{filename1}.bam.bai"
    params:
        idx="{datadir}/{filename1}_idx/bwa"
    shell:"""
        bwa mem {params.idx} -p {input.reads} | samtools sort -O bam > {output.bam}
        samtools index {output.bam} 
    """ 