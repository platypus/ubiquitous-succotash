##change i to number of classes to count

for i in {1..2}
do
j=0
for f in `cat motls.txt`
do
e=$(echo ,${i}$)
d=$(grep -c "${e}" ${f})
j=$((j+d))
done
echo ${j}
done
