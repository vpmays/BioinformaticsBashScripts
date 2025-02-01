#!/bin/bash 

mkdir -p eColiGenome
curl -L -o eColiGenome/ecoli_rel606.fasta.gz ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/017/985/GCA_000017985.1_ASM1798v1/GCA_000017985.1_ASM1798v1_genomic.fna.gz
gunzip eColiGenome/ecoli_rel606.fasta.gz

curl -L -o sub.tar.gz https://osf.io/gbt7p/download
tar xvf sub.tar.gz

mkdir -p results/sam results/bam results/bcf results/vcf results/trimmed
mv sub/*.trim* results/trimmed

bowtie2-build eColiGenome/ecoli_rel606.fasta eColiGenome/ecoli_rel606

export BOWTIE2_INDEXES=$(pwd)/eColiGenome

#align trimmed reads to e coli genome
for file in results/trimmed/*1.trim.sub.fastq
do
    SRR=$(basename $file _1.trim.sub.fastq)
    echo running $SRR
    bowtie2 -x ecoli_rel606 \
         --very-fast -p 4\
         -1 results/trimmed/${SRR}_1.trim.sub.fastq \
         -2 results/trimmed/${SRR}_2.trim.sub.fastq \
         -S results/sam/${SRR}.sam
done

#convert sam files to bam files
for file in results/sam/*.sam 
do
	SRR=$(basename $file .sam)
                 echo converting $SRR.sam to $SRR.bam
                 samtools view -S -b results/sam/${SRR}.sam > results/bam/${SRR}-aligned.bam
done

#sort bam file by coordinates
for file in results/bam/*-aligned.bam 
do
	SRR=$(basename $file -aligned.bam)
                 echo sorting $SRR.bam
                 samtools sort results/bam/${SRR}-aligned.bam -o results/bam/${SRR}-sorted.bam
done

for file in results/bam/*-sorted.bam
do
    SRR=$(basename $file -sorted.bam)
    
    #calculate read coverage of positions in genome
    bcftools mpileup -O b -o results/bcf/${SRR}_raw.bcf \
            -f eColiGenome/ecoli_rel606.fasta results/bam/${SRR}-sorted.bam 
    
    #detect SNPs
    bcftools call --ploidy 1 -m -v -o results/bcf/${SRR}_variants.vcf results/bcf/${SRR}_raw.bcf 
    
    #Filter and report SNPs in variant calling format (VCF)
    vcfutils.pl varFilter results/bcf/${SRR}_variants.vcf  > results/vcf/${SRR}_final_variants.vcf

    #index the sorted bam file for viewing in samtools tview later
    samtools index results/bam/${SRR}-sorted.bam
done