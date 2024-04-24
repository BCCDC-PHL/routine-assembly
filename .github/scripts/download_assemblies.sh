#!/bin/bash

mkdir -p .github/data/assemblies

curl -o .github/data/assemblies/NC_002973.6.fa "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?retmode=text&id=NC_002973.6&db=nucleotide&rettype=fasta"
