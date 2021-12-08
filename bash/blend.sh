#batch blending of mrc montages

for f in `ls *.mrc`
do 
echo ${f}
extractpieces ${f} ${f/mrc/pl}
blendmont -imin ${f} -plin ${f/mrc/pl} -imout ${f/\.mrc/_blend\.mrc} -roo ${f%%.*} -robust 1.0
rm *.pl *.xef *.yef *.ecd
done
