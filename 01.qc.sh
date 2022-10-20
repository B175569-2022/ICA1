### summary filters: user can select


### set variables 
# fastq data input directory
IN=/localdisk/data/BPSM/ICA1/fastq
# details file
DETAILS_FILE=${IN}/Tco.fqfiles
# header of details file. contains: "SampleName SampleType Replicate Time Treatment End1 End2"
HEADER=$(head -n1 ${DETAILS_FILE})

### make new directories
# fastqc output for all samples
FASTQC_OUT=${PWD}/fastqc.results
rm -r ${FASTQC_OUT}
mkdir -p ${FASTQC_OUT}


###
# loop through all fastq files from the details file (start from second line to skip the header)

while read ${HEADER}
do
  echo -e "paired end files for ${SampleName}: ${End1} and ${End2}"
  # for each sample make fastqc output directories
  END1=${End1/.fq.gz/} # End1 name without suffix
  END2=${End2/.fq.gz/} # End2 name without suffix 
  OUT_END1=${FASTQC_OUT}/${SampleName}/${END1}
  OUT_END2=${FASTQC_OUT}/${SampleName}/${END2}
  mkdir -p ${OUT_END1}
  mkdir -p ${OUT_END2}
  # run fastqc on each sample's pair end fastq files (end1 & end2)
  # send stdout & stderr to file 
  fastqc -o ${OUT_END1} --threads 4 --extract ${IN}/${End1} &> ${OUT_END1}/logfile
  fastqc -o ${OUT_END2} --threads 4 --extract ${IN}/${End2} &> ${OUT_END2}/logfile
  # check fastqc summary files
  #SUMMARY_2=${OUT_END2}/${END2}_fastqc/summary.txt
  # awk script to test failed statistics
  # send dropped.output to fastqc.results dir
  #
done < <(tail -n +48 ${DETAILS_FILE}) ##!! test



# awk summary files
awk 'BEGIN {
  FS="\t"; OFS="\t";
  }
  {if($1!="FAIL")
    {print $1,$2,$3}
  }' fastqc.test.extract/Tco-5053_1_fastqc/summary.txt
  