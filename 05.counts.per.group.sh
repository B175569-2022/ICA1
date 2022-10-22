#!/usr/bin/bash

### variables
# details file - use non-dropped
DETAILS_FILE=${PWD}/temp.details.file

### define group options
# column2: sample type (WT, Clone1, Clone2, ...) * if more types added to the details file, they will be included here
SAMPLETYPE=$(cat ${DETAILS_FILE} | awk 'BEGIN{FS="\t"} {if (NR>1) {print $2}}' | sort -u)
# column4: time (0h,24h, 48h)
TIME=$(cat ${DETAILS_FILE} | awk 'BEGIN{FS="\t"} {if (NR>1) {print $4}}' | sort -u)
# column5: treament (tet induced, tet uninduced)
TREATMENT=$(cat ${DETAILS_FILE} | awk 'BEGIN{FS="\t"} {if (NR>1) {print $5}}' | sort -u)


### split sample names into groups
### files for each group containing respective samples
for sampletype in ${SAMPLETYPE}
do
  for treatment in ${TREATMENT}
  do
    for time in ${TIME}
    do
      echo -e "${sampletype}.${treatment}.${time}"
      awk -v sampletype=${sampletype} \
          -v time=${time} \
          -v treatment=${treatment} \
      'BEGIN{FS="\t"; OFS="\t"}
       {if ($2==sampletype && $4==time && $5==treatment)
         {print $1}
       }' ${DETAILS_FILE} > ${PWD}/test.groups/${sampletype}.${treatment}.${time}
    done      
  done
done

