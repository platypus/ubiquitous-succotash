run("32-bit");
run("Bin...", "x=4 y=4 bin=Sum");
run("Bandpass Filter...", "filter_large=250 filter_small=1.5 suppress=None tolerance=5 process");

for (i = 1; i <= nSlices; i++) {    
    setSlice(i);
    // do something here;
	
	getStatistics(area, mean, min, max, std, histogram);
	//print(mean + ", " + min + ", " + max + ", " + std); 
	if (min < (mean-(5*std))) {
		min = (mean-(5*std));
		run("Min...", "value=" + min + " slice");
	}
	if (max > (mean+(5*std))) {
		max = (mean+(5*std));
		run("Max...", "value=" + max + " slice");
	}
	newstd = 40/std;
	run("Subtract...", "value=" + mean + " slice");
	run("Multiply...", "value=" + newstd + " slice");
	run("Add...", "value=150 slice");
	setMinAndMax(0, 255);
}
run("8-bit");
