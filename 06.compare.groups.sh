#!/usr/bin/bash

### get all unique pairs of groups to compare (n(n-1)/2) (here 105 pairs)
# make output dir
mkdir -p ${PWD}/counts.data.fold.diffs
rm ${PWD}/counts.data.fold.diffs/* # clear previous files

# input dir of mean counts per group (all groups file: per.group.mean.counts.all.groups.txt)
MEAN_COUNTS_IN=${PWD}/counts.data.per.group/per.group.mean.counts.all.groups.txt
# first and last column numbers for groups in input file
first=6
last=$(head -n1 ${MEAN_COUNTS_IN} | awk 'BEGIN{FS="\t"} {print NF}') # now 20

# create file listing all possible group pairs 
for (( col1=${first}; col1<=${last}; col1++ ))
do
  group_name1=$(head -n1 ${MEAN_COUNTS_IN} | cut -d$'\t' -f ${col1}) # get group 1 name
  for (( col2=$((${col1} + 1)); col2<=${last}; col2++ ))
  do 
  group_name2=$(head -n1 ${MEAN_COUNTS_IN} | cut -d$'\t' -f ${col2})
  #echo -e "$col1 $col2"
  echo -e "$group_name1\t$group_name2\t$col1\t$col2"
  done
done > ${PWD}/x.group.pairs.to.choose # file columns: group_name1 group_name2 col_number1 col_number2


# create header for outputs:
awk 'BEGIN{FS="\t"; OFS="\t"} NR==1 {print $1,$2,$3,$4,$5,"fold_change"}' ${MEAN_COUNTS_IN} > ${PWD}/temp.header

# loop through each possible groups pair from file x.group.pairs.to.choose
# produce tab delimited .txt files with fold count change for each gene, sorted by absolute magnitude:
 
while read group1 group2 col1 col2
do 
  #echo -e "$col1 $col2"
  # create column ($6) with fold change: (counts_group1 - counts_group2) / counts_group1:
  # *adds 0.01 to both values to deal with dividing with 0
  awk -v col1=$col1 -v col2=$col2 'BEGIN{FS="\t"; OFS="\t"} 
    NR>1 {print $1,$2,$3,$4,$5,($col1+0.01-$col2+0.01)/($col1+0.01)}' ${MEAN_COUNTS_IN} > ${PWD}/temp.${group1}.vs.${group2}.no.header.txt
  # add column with ablsolute fold change (abs.value of $6:
  awk 'BEGIN{FS="\t"; OFS="\t"}
    {if ($6<0) 
      {print $1,$2,$3,$4,$5,$6,$6*(-1)}
    else 
      {print $1,$2,$3,$4,$5,$6,$6}
    }' ${PWD}/temp.${group1}.vs.${group2}.no.header.txt > ${PWD}/temp.${group1}.vs.${group2}.no.header.abs.txt
  # sort by absolute magnitude | exclude abs.magnitude column :
  cat ${PWD}/temp.${group1}.vs.${group2}.no.header.abs.txt | sort -t$'\t' -rnk7 | cut -d$'\t' -f1-6 --output-delimiter=$'\t' > ${PWD}/temp.${group1}.vs.${group2}.no.header.abs.sorted.txt
  # add header:
  cat ${PWD}/temp.header ${PWD}/temp.${group1}.vs.${group2}.no.header.abs.sorted.txt > ${PWD}/counts.data.fold.diffs/${group1}.vs.${group2}.txt
  # remove temp files
  rm ${PWD}/temp.${group1}.vs.${group2}.no.header.txt
  rm ${PWD}/temp.${group1}.vs.${group2}.no.header.abs.txt
  rm ${PWD}/temp.${group1}.vs.${group2}.no.header.abs.sorted.txt
done < ${PWD}/x.group.pairs.to.choose

rm ${PWD}/temp.header

