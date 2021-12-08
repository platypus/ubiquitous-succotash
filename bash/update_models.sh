##change i to number of tomograms
##models, oldrecs, and newrecs must match line by line, can be done with sort

for i in {1..34}
do
a=$(sed "${i}!d" models.txt)
b=$(sed "${i}!d" oldrecs.txt)
c=$(sed "${i}!d" newrecs.txt)
f=${a##*/}
d=${f/\.mod/\_new.mod}
e=${f/\.mod/\_old.mod}
imodtrans -i $b $a $e
imodtrans -i $c $e $d
done
