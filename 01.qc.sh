#!/usr/bin/bash

### set variables 
# fastq data input directory
IN=/localdisk/data/BPSM/ICA1/fastq
# details file
DETAILS_FILE=${IN}/Tco.fqfiles
# header of details file. contains: "SampleName SampleType Replicate Time Treatment End1 End2"
HEADER=$(head -n1 ${DETAILS_FILE})
# list of fastqc output filters to consider
FILTERS=${PWD}/x.fastqc.filters.list

### make new directories / files
# fastqc output for all samples
FASTQC_OUT=${PWD}/fastqc.results
mkdir -p ${FASTQC_OUT}
rm -f ${FASTQC_OUT}/*
# list of dropped samples
DROPPED=${FASTQC_OUT}/dropped.samples
rm -f ${DROPPED}
touch ${DROPPED}

###
# loop through all fastq files from the details file (start from second line to skip the header)

while read ${HEADER}
do
  echo -e "Analysing paired end files for ${SampleName}: ${End1} and ${End2}:\n"
  # for each sample make fastqc output directories
  END1=${End1/.fq.gz/} # End1 name without suffix
  END2=${End2/.fq.gz/} # End2 name without suffix 
  OUT_END1=${FASTQC_OUT}/${SampleName}/${END1}
  OUT_END2=${FASTQC_OUT}/${SampleName}/${END2}
  mkdir -p ${OUT_END1}
  mkdir -p ${OUT_END2}
  ### run fastqc on each sample's pair end fastq files (end1 & end2)
  # produce unziped folder (--extract)
  # send stdout & stderr to fastqc.logfile 
  fastqc -o ${OUT_END1} --threads 8 --extract ${IN}/${End1} &> ${OUT_END1}/fastqc.logfile
  fastqc -o ${OUT_END2} --threads 8 --extract ${IN}/${End2} &> ${OUT_END2}/fastqc.logfile
  ### check fastqc summary files 
  ### (1): send statistics that failed to failed.fastqc.stats file for each paired-end
  ### end1
  SUMMARY_1=${OUT_END1}/${END1}_fastqc/summary.txt  # fastqc summary file   
  FAILED_STATS_1=${OUT_END1}/failed.fastqc.stats    # file to output fastqc stats that failed
  rm -f ${FAILED_STATS_1}                           # remove any previous output
  awk 'BEGIN {FS="\t"; OFS="\t";}
    {if($1=="FAIL")  
      {print $2}
    }' ${SUMMARY_1} > ${FAILED_STATS_1}
  ## print basic sequence statistics from *_data.txt file
  DATA1=${OUT_END1}/${END1}_fastqc/fastqc_data.txt
  TOTAL1=$(grep 'Total Sequences' ${DATA1} | awk '{print $NF}')
  POOR1=$(grep 'Sequences flagged as poor quality' ${DATA1} | awk '{print $NF}')
  LENGTH1=$(grep 'Sequence length' ${DATA1} | awk '{print $NF}')
  echo -e "${END1} has ${TOTAL1} raw sequences with length ${LENGTH1}, of which ${POOR1} were flagged as poor quality" 
  ### end2
  SUMMARY_2=${OUT_END2}/${END2}_fastqc/summary.txt
  FAILED_STATS_2=${OUT_END2}/failed.fastqc.stats  
  rm -f ${FAILED_STATS_2}
  awk 'BEGIN {FS="\t"; OFS="\t";}
    {if($1=="FAIL")  
      {print $2}
    }' ${SUMMARY_2} > ${FAILED_STATS_2}
  ## print basic sequence statistics from *_data.txt file
  DATA2=${OUT_END2}/${END2}_fastqc/fastqc_data.txt
  TOTAL2=$(grep 'Total Sequences' ${DATA2} | awk '{print $NF}')
  POOR2=$(grep 'Sequences flagged as poor quality' ${DATA2} | awk '{print $NF}')
  LENGTH2=$(grep 'Sequence length' ${DATA2} | awk '{print $NF}')
  echo -e "${END2} has ${TOTAL2} raw sequences with length ${LENGTH2}, of which ${POOR2} were flagged as poor quality\n" 
  ### (2): if statistic in failed.fastqc.stats is in user difined list (x.fastqc.filters.list), put sample name in samples.to.drop list 
  # drop both pairs if either one fails
  if grep -qxf ${FAILED_STATS_1} ${FILTERS} || grep -qxf ${FAILED_STATS_2} ${FILTERS}
    then 
    echo ${SampleName} >> ${DROPPED}
    echo -e "Warning: sample ${SampleName} failed one or more of the selected fastqc filters. Please review the folder ${FASTQC_OUT}/${SampleName}\n"
    echo -e "~~~~~~~~~~~~~~~~~\n"
    else 
    echo -e "Sample ${SampleName} did not fail any of the selected fastqc filters\n"
    echo -e "~~~~~~~~~~~~~~~~~\n"
  fi
done < <(tail -n +2 ${DETAILS_FILE})


NUMBER_DROPPED=$(wc -l ${DROPPED} | cut -d' ' -f1)
if [ ${NUMBER_DROPPED} -eq 0 ]
 then echo -e "No samples failed quality check"
 else echo -e "samples failed quality check, review file:\n ${DROPPED} "
fi

### create new detailed with the non-dropped samples (now, no samples were dropped)
grep -vf ${DROPPED} ${DETAILS_FILE} > ${PWD}/qced.samples.details.file


  
  

