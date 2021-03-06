#!/bin/tcsh

source ./inputs/params/params.tcsh

set tool = cscore
set resolution = 100000                               # 100kb resolution by default.
set mindist = 1000000 # 1 Mb by default.
set active_mark =           		              # active mark bed file (e.g. H3K27ac) 
set HK_genes = inputs/genomes/$genome/HK_genes.bed    # house-keeping genes bed file
set TSS_genes = inputs/genomes/$genome/gene-tss_annot.bed

