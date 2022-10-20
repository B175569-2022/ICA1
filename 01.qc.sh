

# set input fastq files directory variable
IN=/localdisk/data/BPSM/ICA1/fastq

# run fastqc 
fastqc ${IN}/


# awk 
awk 'BEGIN {
  FS="\t"; OFS="\t";
  }
  {if($1!="FAIL")
    {print $1,$2,$3}
  }' fastqc.test.extract/Tco-5053_1_fastqc/summary.txt
  