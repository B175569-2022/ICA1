#!/usr/bin/bash

### variables:
# reference genome index (built with bowtie2-build)
INDEX=${PWD}/Tcongo_genome_index/TriTrypDB-46_TcongolenseIL3000_2019_Genome
# fastq data input directory
IN=/localdisk/data/BPSM/ICA1/fastq
# details file - used non-dropped
#DETAILS_FILE=${IN}/Tco.fqfiles
DETAILS_FILE=${PWD}/qced.samples.details.file
# header of details file. contains: "SampleName SampleType Replicate Time Treatment End1 End2"
HEADER=$(head -n1 ${DETAILS_FILE})

### make output dirs
# .bam
BAM=${PWD}/bam.files
rm -r ${BAM}
mkdir -p ${BAM} 
# sorted .bam
BAM_SORTED=${PWD}/bam.sorted.files
rm -r ${BAM_SORTED}
mkdir -p ${BAM_SORTED}


###
while read ${HEADER}
do
  echo -e "Aligning paired-end files ${End1} and ${End2} from sample ${SampleName}:"
  # create .bam files (bowtie2 pipes .sam output to samtools -> .bam output):
  bowtie2 --threads 6 -x ${INDEX} -1 ${IN}/${End1} -2 ${IN}/${End2} | samtools view - -bo ${BAM}/${SampleName}.bam
  # create sorted .bam files
  samtools sort ${BAM}/${SampleName}.bam -o ${BAM_SORTED}/${SampleName}.sorted.bam
  # index sorted .bam files
  samtools index -b ${BAM_SORTED}/${SampleName}.sorted.bam
  echo -e "Done"  
done < <(tail -n +2 ${DETAILS_FILE})



