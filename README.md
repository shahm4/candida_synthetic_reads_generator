# Candida Synthetic Reads Workflow

## Overview

This repository contains a Bash script designed to generate synthetic reads for Candida species using amplicon-based sequencing. The workflow utilizes the CRABS tool for creating reference databases and ART Illumina for simulating sequencing reads. Additionally, the script processes human reads to facilitate downstream analyses.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Workflow Steps](#workflow-steps)

## Prerequisites

Before running the script, ensure you have the following tools installed:

- **CRABS**: For in silico PCR.
- **ART Illumina**: For simulating sequencing reads.
- **Seqtk**: For manipulating sequence data.
  
You may also need the following dependencies:

- `gzip`: For compressing and decompressing files.
- `gshuf`: For random shuffling of lines in files (part of GNU core utilities).

## Installation

1. Clone this repository to your local machine:
   ```bash
   git clone https://github.com/yourusername/candida-synthetic-reads.git
   cd candida-synthetic-reads

2. Ensure that all required tools are installed and accesible in your systems's PATH
3. Make the script executable:

   chmod +x [candida_synthetic_reads.sh](./candida_synthetic_reads.sh)

## Usage

To run the workflow, execute the script in your terminal

[candida_synthetic_reads.sh](./candida_synthetic_reads.sh)

## Workflow Steps

1. Generate Synthetic ITS and LSU Amplicon FASTA Files.
   * The script creates synthetic amplicon files for both ITS and LSU regions using CRABS.
2. Simulate Sequencing Reads\
   * Synthetic reads are generated for both ITS and LSU amplicons using ART Illumina.
4. Process Human Reads
   * Human FASTQ files are converted from gzipped format, downsampled, and concatenated with Candida reads.
6. Output
   * The final output includes synthetic read files for both Candida and human samples, organized into respective directories.
