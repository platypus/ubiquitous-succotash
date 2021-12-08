##removes decimals and extra white space after running model2point 

model2point $1 ${1/\.mod/\.txt}
sed -i -e 's/^[ ]*//g' -e 's/  */ /g' -e 's/\.[0-9][0-9]//g' ${1/\.mod/\.txt}
