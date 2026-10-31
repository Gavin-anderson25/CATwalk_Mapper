configfile: "config/config.yaml"

rule all:
    input:
        "output/coverage_plot.png"

rule fetch_reads:
    output:
        "data/reads.fasta"
    threads: 4
    conda: 
        "envs/fetch.yaml"
    shell:
        """
        prefetch {config[library]}
        fasterq-dump {config[library]} --fasta-unsorted
        mv {config[library]}.fasta {output}
        rm -rf {config[library]}
        """

rule fetch_ref:
    output:
        "data/reference.fasta"
    threads: 4
    conda:
        "envs/fetch.yaml"
    shell:
        """
        datasets download genome accession {config[reference]} --include genome --filename reference.zip
        unzip reference.zip -d ncbi
        mv ncbi/ncbi_dataset/data/{config[reference]}/*.fna {output}
        rm -rf ncbi reference.zip
        """
 
rule catwalk:
    input:
        "data/reads.fasta",
        "data/reference.fasta"
    output:
        "data/catwalkoutput.fasta"
    conda: 
        "envs/seqio.yaml"
    script:
        "scripts/snakescript.py"

rule bwa_index:
    input:
        ref = "data/catwalkoutput.fasta"
    output:
        bwt = "data/catwalkoutput.fasta.bwt"
    log:
        "logs/bwa_index.log"
    conda: 
        "envs/mapping.yaml"
    shell:
        "bwa index -a bwtsw {input.ref} > {log} 2>&1"

rule bwa_map:
    input:
        ref = "data/catwalkoutput.fasta",
        reads = "data/reads.fasta",
        index = "data/catwalkoutput.fasta.bwt"
    output:
        "output/mapped_reads.bam"
    conda: 
        "envs/mapping.yaml" 
    shell:
        """
        bwa mem {input.ref} {input.reads} | \
        samtools view -b - | \
        samtools sort -o {output} -
        """

rule samtools_index:
    input:
        "output/mapped_reads.bam"
    output:
        "output/mapped_reads.bam.bai"
    conda: 
        "envs/mapping.yaml"        
    shell:
        "samtools index {input}"

rule bigwig:
    input:
        bam = "output/mapped_reads.bam",
        bai = "output/mapped_reads.bam.bai"
    output:
        bw = "output/mapped_reads.bw"
    conda:
        "envs/bigwig.yaml"
    shell:
        "bamCoverage -b {input.bam} -o {output.bw}"


rule coverage_figure:
    input:
        ini = "config/tracks.ini",
        bw = "output/mapped_reads.bw"
    output:
        png = "output/coverage_plot.png"
    conda:
        "envs/plotting.yaml"
    shell:
        "pyGenomeTracks --tracks {input.ini} --region Random_read:1-2000 -o {output.png}"


