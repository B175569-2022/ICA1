#!/usr/bin/bash

### run fastqc for each paired-end fastq file:
source ${PWD}/01.qc.sh 1> out.01.qc
## inputs:
# ~ gzipped fastq paired-end sample files: /localdisk/data/BPSM/ICA1/fastq/*.fq.gz
# ~ samples details file: /localdisk/data/BPSM/ICA1/fastq/Tco.fqfiles
# ~ list of fastqc filters that the user wants: x.fastqc.filters.list
# by default: "Basic Statistics", "Per base sequence quality", "Per sequence quality scores" are used
# the user can comment out the filters to be considered (remove #)
## outputs:
# ~ list of samples passing the set filters: qced.samples.details.file
# ~ file stating for each file the number, length of reads, how many poor quality reads detected: out.01.qc
# ~ folder with fastqc data (e.g summary of filter results) + list of dropped samples: fastqc.results/

### build reference genome index with bowtie2:
source ${PWD}/02.build.reference.index.sh
## inputs:
# ~ reference genome: /localdisk/data/BPSM/ICA1/Tcongo_genome/TriTrypDB-46_TcongolenseIL3000_2019_Genome.fasta.gz
## outputs:
# ~ reference genome index: Tcongo_genome_index/*

### align reads to indexed reference genome (bowtie2; samtools):
source ${PWD}/03.align.sh
## inputs:
# ~ reference genome index: Tcongo_genome_index/*
# ~ gzipped fastq paired-end sample files: /localdisk/data/BPSM/ICA1/fastq/*.fq.gz
# ~ samples details file: qced.samples.details.file
## outputs:
# ~ sorted and indexed .bam files for each sample: bam.sorted.files/

### generate counts data for each sample (how many reads overlap each gene) (bedtools multicov) :
source ${PWD}/04.counts.sh
## inputs:
# ~ refernce bed file: /localdisk/data/BPSM/ICA1/TriTrypDB-46_TcongolenseIL3000_2019.bed
# ~ sorted bam files
## outputs:
# ~ one .bed file (with header), containing the counts for each sample (columns) per gene (rows): counts.data/all.samples.counts.updated.bed

### define the diferent sample groups; get mean counts for each group of samples
source ${PWD}/05.counts.per.group.sh
## inputs:
# ~ samples details file: qced.samples.details.file
# ~ 
## outputs:
# ~ folder with one file per group, listing the names of the samples it contains: groups/${sampletype}.${treatment}.${time}
# ~ folder (counts.data.per.group/) with:
# one tab-delimited file per group, containg gene information (e.g. name, discription, positions) and mean counts for the group: per.group.mean.counts.${sampletype}.${treatment}.${time}.txt
# one tab-delimited file with all groups: counts.data.per.group/per.group.mean.counts.all.groups.txt

### compare all possible groups pair-wise; procude expression counts' fold changes for each gene between each group-pair
source ${PWD}/06.compare.groups.sh
## inputs:
# ~ mean counts per group file: counts.data.per.group/per.group.mean.counts.all.groups.txt
# ~ 
## outputs:
# ~ file listing all possible group pairs: x.group.pairs.to.choose  ** after the first run, the user can select which group pairs to exclude, by commenting them (put leading #) 
# ~ one file per group pair containing gene info and magnitude sorted fold change data: counts.data.fold.diffs/*
