#!/usr/bin/bash

### variables
# reference .bed file (gene locations) - for bedtools multicov -bed input
REF_BED=/localdisk/data/BPSM/ICA1/TriTrypDB-46_TcongolenseIL3000_2019.bed
# file containing the full directory names of the sorted .bam files (space seperated) - for bedtools multicov -bams input
SORTED_BAMS_NAMES=$(ls -d1 ${PWD}/bam.sorted.files/*.sorted.bam | tr '\n' ' ')

### make output dir for counts data
OUT=${PWD}/counts.data
rm -r ${OUT}
mkdir -p ${OUT}

### run bedtools multicov: "reports the counts of alignments from multiple .bam files (samples) that overlap intervals in a .bed file (gene locations here)"
bedtools multicov -bams ${SORTED_BAMS_NAMES} -bed ${REF_BED} > ${OUT}/all.samples.counts.bed

