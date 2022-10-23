#!/usr/bin/bash

### variables
# details file - use non-dropped
DETAILS_FILE=${PWD}/qced.samples.details.file

### define group options
# column2: sample type (WT, Clone1, Clone2, ...) * if more types added to the details file, they will be included here
SAMPLETYPE=$(cat ${DETAILS_FILE} | awk 'BEGIN{FS="\t"} {if (NR>1) {print $2}}' | sort -u)
# column4: time (0h,24h, 48h)
TIME=$(cat ${DETAILS_FILE} | awk 'BEGIN{FS="\t"} {if (NR>1) {print $4}}' | sort -u)
# column5: treament (tet induced, tet uninduced)
TREATMENT=$(cat ${DETAILS_FILE} | awk 'BEGIN{FS="\t"} {if (NR>1) {print $5}}' | sort -u)


### split sample names into groups
### files for each group containing respective samples
mkdir -p ${PWD}/groups # make output directory
for sampletype in ${SAMPLETYPE}
do
  for treatment in ${TREATMENT}
  do
    for time in ${TIME}
    do
      #echo -e "${sampletype}.${treatment}.${time}"
      awk -v sampletype=${sampletype} \
          -v time=${time} \
          -v treatment=${treatment} \
      'BEGIN{FS="\t"; OFS="\t"}
       {if ($2==sampletype && $4==time && $5==treatment)
         {print $1}
       }' ${DETAILS_FILE} > ${PWD}/groups/${sampletype}.${treatment}.${time}
    done      
  done
done

########=========########

### variables
COUNTS=${PWD}/counts.data/all.samples.counts.updated.bed # counts file with header
GROUPS_DIR=${PWD}/groups # directory of groups-samples
GROUPS_LIST=$(ls -1 ${PWD}/groups) # names of groups

### output dirs
TEMP_DIR=${PWD}/temp.counts.data.per.group
OUT=${PWD}/counts.data.per.group
mkdir -p ${TEMP_DIR}
mkdir -p ${OUT}

### for loop through each group file in /groups (each file contains all relative samples)
### and calculate mean counts for each gene 
### merge mean counts into one tab delimited file 

for group in ${GROUPS_LIST}
do 
  # testing if difined group has actually samples in it 
  if [ ! -s ${GROUPS_DIR}/${group} ]
    then echo -e "Group ${group} has no samples - dropping this group\n"
    else echo -e "Getting average counts for group: ${group}"
    while read sample # within each group, loop through every sample, read group file (contains sample names) 
      do
      echo -e "This group contains sample: ${sample}"
      col=$(head -n1 ${COUNTS} | tr '\t' '\n' | cat | grep -n "${sample}" | cut -d':' -f1) # get column number for sample in group
      #echo -e "col no, in counts file : ${col}"
      awk -v col=${col} 'BEGIN{FS="\t"} NR>1 {print $col}' ${COUNTS} > ${TEMP_DIR}/temp.${group}.${sample} # extract sample column from counts file
    done < ${GROUPS_DIR}/${group} 
    echo -e "${group}" > ${TEMP_DIR}/Temp.${group}.header
    # for each group combine sample columns ( temp.${group}.${sample} )| get the mean of each row (=each gene)
    paste -d'\t' ${TEMP_DIR}/temp.${group}.* | awk '{ for(i=1; i<=NF;i++) j+=$i; print j/NF; j=0 }' | cat ${TEMP_DIR}/Temp.${group}.header - > ${TEMP_DIR}/temp.${group}
    rm ${TEMP_DIR}/temp.${group}.*
    rm ${TEMP_DIR}/Temp.${group}.header
    echo -e "Finished calculating mean gene counts for group ${group}\n"
  fi
done

## merge gene info from the counts .bed file + all columns from temp.group files -> tab delimited text file
## all groups in one tab delimited file:
awk 'BEGIN{FS="\t"; OFS="\t"} {print $1,$2,$3,$4,$5}' ${COUNTS} > ${TEMP_DIR}/temp.all.info # extract gene info columns from counts file
paste -d"\t" ${TEMP_DIR}/temp.* > ${OUT}/per.group.mean.counts.all.groups.txt
## each group in seperate tab delimited file:
# first and last column numbers for groups in per.group.mean.counts.all.groups.txt file - to use in loop
first=6
last=$(head -n1 ${OUT}/per.group.mean.counts.all.groups.txt | awk 'BEGIN{FS="\t"} {print NF}') 
for (( group_col=$first; group_col<=$last; group_col++ ))
do 
  group_name=$(head -n1 ${OUT}/per.group.mean.counts.all.groups.txt | cut -d$'\t' -f ${group_col}) # get group name
  awk -v group_name=$group_name -v group_col=$group_col 'BEGIN{FS="\t"; OFS="\t"} {print $1,$2,$3,$4,$5,$group_col}' ${OUT}/per.group.mean.counts.all.groups.txt > ${OUT}/per.group.mean.counts.${group_name}.txt
done

# remove temp files
rm -r ${TEMP_DIR}


