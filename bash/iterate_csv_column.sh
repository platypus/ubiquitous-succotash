for f in `ls file.csv`
do
awk 'BEGIN {FS=",";OFS=","} { $4=NR-1 ; print}' ${f} > ${f/csv/csw}
done
