zero = 0; //not used
cow = nImages;


if(cow > 0) {
	tArr = getList("image.titles");
	setBatchMode("hide");
	for(h = 0; h < cow; h++) {
		selectWindow(tArr[h]);
		run("Invert");
		if (endsWith(getTitle(), "bf.tif")) {
			run("Enhance Contrast...", "saturated=46");
			run("Invert");
		}
		else {
			run("Enhance Contrast...", "saturated=0.1");
			run("Invert");
			run("Enhance Contrast...", "saturated=0.1");
		}
		run("Size...", "width=1130 depth=1 constrain average interpolation=Bilinear");
		getDimensions(width, height, channels, slices, frames);
		run("Specify...", "width=1080 height=1080 x="+width/2+" y="+height/2+" constrain centered");
		run("Crop");
		run("8-bit");
		dir = getInfo("image.directory");
		//fil = tArr[h];
		fil = replace(tArr[h], ".tif", "_.tif");
		saveAs("Tiff", dir+fil);
		close(fil);
	}
	setBatchMode("exit");
}




