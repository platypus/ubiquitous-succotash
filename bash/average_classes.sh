for f in `cat class_numbers.txt`
do
echo class ${f##*.}
sed 's/^lstT/# lstT/g' fclean2pca.prm > class${f##*.}.prm
echo lstThresholds = [0:${f%%.*}:${f%%.*}] >> class${f##*.}.prm
echo selectClassID = ${f##*.} >> class${f##*.}.prm
averageAll class${f##*.}.prm 3 'average'
echo moving on
done

##must update .prm name and iteration number
##class_numbers format is particles.class (100.1)
