#!/usr/bin/bash

### variables
# reference .bed file (gene locations) - for bedtools multicov -bed input
REF_BED=/localdisk/data/BPSM/ICA1/TriTrypDB-46_TcongolenseIL3000_2019.bed
# variable containing the full directory names of the sorted .bam files (space seperated) - for bedtools multicov -bams input
SORTED_BAMS_FULL_NAMES=$(ls -d1 ${PWD}/bam.sorted.files/*.sorted.bam | tr '\n' ' ')
# variable containing only the sample names - same order with SORTED_BAMS_FULL_NAMES - for .bed output header - tab delimited
SAMPLE_NAMES=$(ls -1 ${PWD}/bam.sorted.files/*.sorted.bam | xargs -n1 basename | sed s/\.sorted\.bam$//g | tr '\n' '\t')

### make output dir for counts data
OUT=${PWD}/counts.data
mkdir -p ${OUT}
rm -f ${OUT}/*

### run bedtools multicov: "reports the counts of alignments from multiple .bam files (samples) that overlap intervals in a .bed file (gene locations here)"
### counts for each sample are added on columns after the gene information
bedtools multicov -bams ${SORTED_BAMS_FULL_NAMES} -bed ${REF_BED} > ${OUT}/all.samples.counts.bed

### add a custom header for the all.samples.counts.bed file -> all.samples.counts.updated.bed
echo -e "Chromosome\tstart\tend\tgene_name\tgene_discription\t${SAMPLE_NAMES}" | cat - counts.data/all.samples.counts.bed > counts.data/all.samples.counts.updated.bed
