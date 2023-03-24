#!/usr/bin/env bash

# ID    AGCTAGCTAGCT
# Cada secuencia es un campo
#;FS="\n";ORS="\n"   {NR>1{$1=$1;print $1} '

# {printf "%s\n", ">"$1} {for(i=2;i<=NF;i+=1) printf "%s", $i} }{printf "%s","\n"}
cat $1 | awk 'BEGIN {RS = ">"; FS = "\n"} NR>1{printf "%s\t", ">"$1} {for(i=2;i<=NF;i+=1) printf "%s", $i}{printf "%s","\n"}' | while IFS= read -r line  || [[ "$line" ]]; do
    Unix_Array+=("$line")
done

echo ${Unix_Array[0]}

#cat $1 | awk 'BEGIN{RS=">";FS="\n";OFS=" ";ORS="\n"}; NR>1{print}' | while read line; do


# mapfile -t my_array < $1

# for element in "${my_array[@]}"
#     do
#         echo "${element}"
# done



# Tomo el record $0, y lo guardo en el array
# NR>1{split($0,arr,"\n");print arr[1], arr[2]}

