##runs model2point and removes decimals and extra whitespace
##must manually remove temporary_bananas.txt files when done

model2point $1 temporary_bananas.txt
sed -e 's/^[ ]*//g' -e 's/  */ /g' -e 's/\.[0-9][0-9]//g' \
temporary_bananas.txt > ${1/\.mod/\.txt}

