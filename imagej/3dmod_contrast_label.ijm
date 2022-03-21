cow =nImages;

for (j = 0; j < cow; j++) {
setBatchMode("hide");
run("32-bit");
//binning and bandpass filter options
run("Bin...", "x=4 y=4 bin=Sum");
//run("Bandpass Filter...", "filter_large=250 filter_small=1.5 suppress=None tolerance=5 process");

for (i = 1; i <= nSlices; i++) {    
    setSlice(i);
	
	getStatistics(area, mean, min, max, std, histogram);
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

//get and set units, modify pixel size as necessary
getDimensions(width, height, channels, slices, frames);
getPixelSize(unit, pixelWidth, pixelHeight);
if(unit=="microns") {
   Stack.setXUnit("nm");
   run("Properties...", "channels="+channels+" slices="+slices+" frames="+frames+" pixel_width="+pixelWidth*1000+" pixel_height="+pixelHeight*1000+" voxel_depth=1");
}

//increase image size and add scale bar
run("Scale Bar...", "width=200 height=8 font=28 color=White background=[Dark Gray] location=[Lower Right] bold label");
run("Canvas Size...", "width=1024 height=1048 position=Top-Center");

//string parsing of directory and filename
//font properties for filename
drt=getDirectory("image");
indx=indexOf(drt,21);
pth=substring(drt,indx);
tit=getTitle();
ttl=replace(tit,".mrc","_");
for (i = 1; i <= nSlices; i++) {
    setSlice(i);
    slc=getSliceNumber();
	string=pth+ttl+slc;
	setFont("SansSerif",18,"antialiased");
	drawString(string,0,1048);
}
run("Image Sequence... ", "select="+drt+" dir="+drt+" format=TIFF start=1 digits=2");
close(tit);
}
setBatchMode("exit and display");
