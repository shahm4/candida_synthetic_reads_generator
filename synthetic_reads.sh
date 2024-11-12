#!/bin/bash

# Candida Synthetic Reads Full Workflow

## CRABS: Creating Reference databases for Amplicon-Based Sequencing

# Generate synthetic ITS amplicon fasta
for i in *.fasta; do
    echo "Processing file: $i"
    base=$(basename "$i" .fasta) 
    echo "Base name: $base"

    crabs insilico_pcr --input "${base}.fasta" --output "${base}_ITS.fasta" \
        --fwd GGAAGTAAAAGTCGTAACAAGG --rev TCCTCCGCTTATTGATATGC --error 4.5
done

mkdir -p ITS_fasta
mv *_ITS.fasta ~/Desktop/Candida/Synthetic_Reads_pipeline/Candida_ITS_fasta

# Generate synthetic LSU amplicon fasta
for i in *.fasta; do
    echo "Processing file: $i"
    base=$(basename "$i" .fasta) 
    echo "Base name: $base"

    crabs insilico_pcr --input "${base}.fasta" --output "${base}_LSU.fasta" \
        --fwd GCATATCAATAAGCGGAGGA --rev TTGGTCCGTGTTTCAAGACG --error 4.5
done

mkdir -p LSU_fasta
mv *_LSU.fasta ~/Desktop/Candida/Synthetic_Reads_pipeline/Candida_LSU_fasta

## ART Illumina: A Next-Generation Sequencing Read Simulator

# Generate synthetic ITS reads
cd ~/Desktop/Candida/Synthetic_Reads_pipeline/Candida_ITS_fasta || exit
mkdir -p ITS_reads

for i in *.fasta; do
    echo "Generating reads for: $i"
    base=$(basename "$i" .fasta) 
    echo "Base name: $base"

    /Users/greningerlab03/Downloads/art_bin_MountRainier/art_illumina -ss HS25 \
        -i "${base}.fasta" -p -l 150 -m 155 -s 59.0 -c 425000 -o "${base}"
done

mv *_ITS1.fq ~/Desktop/Candida/Synthetic_Reads_pipeline/Candida_ITS_fasta/ITS_reads/ITS1.fq
mv *_ITS2.fq ~/Desktop/Candida/Synthetic_Reads_pipeline/Candida_ITS_fasta/ITS_reads/ITS2.fq

# Generate synthetic LSU reads
cd ~/Desktop/Candida/Synthetic_Reads_pipeline/Candida_LSU_fasta || exit
mkdir -p LSU_reads

for i in *.fasta; do
    echo "Generating reads for: $i"
    base=$(basename "$i" .fasta) 
    echo "Base name: $base"

    /Users/greningerlab03/Downloads/art_bin_MountRainier/art_illumina -ss HS25 \
        -i "${base}.fasta" -p -l 150 -m 155 -s 59.0 -c 425000 -o "${base}"
done

mv *_LSU1.fq ~/Desktop/Candida/Synthetic_Reads_pipeline/Candida_LSU_fasta/LSU_reads/LSU1.fq
mv *_LSU2.fq ~/Desktop/Candida/Synthetic_Reads_pipeline/Candida_LSU_fasta/LSU_reads/LSU2.fq

## Process Human Reads using Seqtk

# Convert Fastq to Fasta
cd ~/Desktop/Candida/Synthetic_Reads_pipeline/Human_fastq || exit

for i in *.fastq.gz; do 
    echo "Processing file: $i"
    base=$(basename "$i" .fastq.gz)
    
    gunzip "$i"
done

# Downsample human reads fastq to 15-20%
for i in *_R1.fastq; do 
    echo "Downsampling: $i"
    base=$(basename "$i" _R1.fastq)
    
    seqtk sample -s 100 "${base}_R1.fastq" 75000 > "${base}_DS_R1.fastq"
done

# Concatenate Human and Candida Reads
cat Candida_ITS_fastq.tsv | while IFS=$'\n\r' read -r line; do 
    rand=$(gshuf -i 1-3 -n 1)
    rand_human_fastq=$(awk "NR==${rand}" Human_ITS_fastq.tsv)
    
    candida_R1=$(echo "$line" | cut -f1)
    candida_R2=$(echo "$line" | cut -f2)
    
    human_R1=$(echo "${rand_human_fastq}" | cut -f1)
    human_R2=$(echo "${rand_human_fastq}" | cut -f2)

    candida_base=$(echo "${candida_R1}" | rev | cut -d/ -f1 | rev | cut -d_ -f1)
    human_base=$(echo "${human_R1}" | rev | cut -d/ -f1 | rev | cut -d_ -f1)

    echo "${candida_R1},${candida_R2},${human_R1},${human_R2},${candida_base},${human_base}"
    
    cat "${candida_R1}" "${human_R1}" | gzip > "${candida_base}_${human_base}_R1.fastq.gz"
    cat "${candida_R2}" "${human_R2}" | gzip > "${candida_base}_${human_base}_R2.fastq.gz"

done

cat Candida_LSU_fastq.tsv | while IFS=$'\n\r' read -r line; do 
    rand=$(gshuf -i 1-3 -n 1)
    rand_human_fastq=$(awk "NR==${rand}" Human_LSU_fastq.tsv)
    
    candida_R1=$(echo "$line" | cut -f1)
    candida_R2=$(echo "$line" | cut -f2)

    human_R1=$(echo "${rand_human_fastq}" | cut -f1)
    human_R2=$(echo "${rand_human_fastq}" | cut -f2)

    candida_base=$(echo "${candida_R1}" | rev | cut -d/ -f1 | rev | cut -d_ -f1)
    human_base=$(echo "${human_R1}" | rev | cut -d/ -f1 | rev | cut -d_ -f1)

    echo "${candida_R1},${candida_R2},${human_R1},${human_R2},${candida_base},${human_base}"
    
    cat "${candida_R1}" "${human_R1}" | gzip > "${candida_base}_${human_base}_R1.fastq.gz"
    cat "${candida_R2}" "${human_R2}" | gzip > "${candida_base}_${human_base}_R2.fastq.gz"

done
