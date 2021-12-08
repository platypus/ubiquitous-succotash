#convert mrc from float to byte with automated saturation
#change 10000 to change percent saturation

for f in `cat floats.txt`;
do
echo $(date)
d=$(header ${f} | grep -m 1 sections | awk '{ print $7 }')
e=$(header ${f} | grep -m 1 sections | awk '{ print $8 }')
g=$(header ${f} | grep -m 1 sections | awk '{ print $9 }')
h=$(($d*$e*$g/10000))
j=${f/\.mrc/_byte\.mrc}
a=$(findcontrast -t ${h},${h} ${f} | tail -n 1 | grep -o '[0-9]\+')
b=$(echo ${a} | grep -m 1 -o '[0-9]\+\s' | head -c -2)
c=$(echo ${a} | grep -o '[0-9]\+$')
newstack -contrast ${b},${c} -mode 0 ${f} ${j}
done
