##update name of text file, range of initial classes, and iteration numbers before use

for g in `cat iter4.txt`
do
sed -i 's/,[0-6]$/,banana/g' ${g}
for f in `cat ${g}`
do i=$((1 + $RANDOM % 8))
echo "${f/banana/${i}}" >> ${g/Iter4/Iter5}
done
done
