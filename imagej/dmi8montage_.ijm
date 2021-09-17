zero = 0; 
cow = nImages;

if(cow > 0) {
	waitForUser("Please close all open images");
	//exit("Please close all open images");
}

showMessage("Choose an empty directory");
wdir = getDirectory("wdir");
empty = getFileList(wdir);
if(empty.length >= 1) {
	waitForUser("Directory is not empty");
	//exit("Directory is not empty");
}
showMessage("Choose directory with dmi8 montages");
input = getDirectory("input");
ilist = getFileList(input);

//create a list of directories
trim = 0;
for (i = 0; i < ilist.length; i++) {
	if (!endsWith(ilist[i], "/")) {
		ilist[i] = "";
		trim++;
	}
}
Array.sort(ilist);
list = Array.slice(ilist, trim); 

Dialog.create("Enter parameters");
Dialog.addNumber("Channels", 1);
Dialog.addNumber("Grid size X", 5);
Dialog.addNumber("Grid size Y", 5);
Dialog.addNumber("Overlap", 9);
Dialog.show();

chnnls = Dialog.getNumber();
szx = Dialog.getNumber();
szy = Dialog.getNumber();
ovrlp = Dialog.getNumber();
gsz = szx*szy;
slcs = gsz*chnnls;

Dialog.create("Channel suffix");
Dialog.addString("Channel 1", "bf");
if(chnnls > 1) {
	Dialog.addString("Channel 2", "fitc");
}
if(chnnls > 2) {
	Dialog.addString("Channel 3", "txr");
}
if(chnnls > 3) {
	Dialog.addString("Channel 4", "647");
}
if(chnnls > 4) {
	exit("Cannot do more than four channels");
}
Dialog.show();
ch1 = "_"+Dialog.getString()+".tif";
if(chnnls > 1) {
	ch2 = "_"+Dialog.getString()+".tif";
}
if(chnnls > 2) {
	ch3 = "_"+Dialog.getString()+".tif";
}
if(chnnls > 3) {
	ch4 = "_"+Dialog.getString()+".tif";
}


setBatchMode("hide");


for (i = 0; i < list.length; i++) {
	file = input+list[i];
	run("Image Sequence...", "select=[file] sort");
}

zebra = nImages;

if(zebra > 0) {
	tArr = getList("image.titles");
	for(h = 0; h < zebra; h++) {
		selectWindow(tArr[h]);

		if(chnnls == 1) {
			rename("og2");
		}

		if(chnnls > 1) {
			rename("og");
			run("Make Substack...", "delete slices=1-"+toString(slcs)+"-"+toString(chnnls));
			rename("og2");
		}

		if(chnnls > 2) {
			selectWindow("og");
			run("Make Substack...", "delete slices=1-"+toString(slcs-gsz)+"-"+toString(chnnls-1));
			rename("og3");
		}

		if(chnnls == 4) {
			selectWindow("og");
			run("Make Substack...", "delete slices=1-"+toString(slcs-gsz*2)+"-"+toString(chnnls-2)
			rename("og4");
		}
		selectWindow("og2");
		
		run("Image Sequence... ", "format=TIFF name=stack digits=2 save="+wdir+"");
		close("og2");
		run("Grid/Collection stitching", "type=[Grid: column-by-column] order=[Up & Left] grid_size_x="+toString(szx)+" grid_size_y="+toString(szy)+" tile_overlap="+toString(ovrlp)+" first_file_index_i=0 directory="+wdir+" file_names=stack{ii}.tif output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.01 max/avg_displacement_threshold=0.50 absolute_displacement_threshold=0.50 compute_overlap subpixel_accuracy computation_parameters=[Save computation time (but use more RAM)] image_output=[Fuse and display]");
		rename("fuse1");
		close("fuse1");
		run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory="+wdir+" layout_file=TileConfiguration.registered.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 subpixel_accuracy computation_parameters=[Save computation time (but use more RAM)] image_output=[Fuse and display]");
		saveAs("Tiff", wdir+tArr[h]+ch1);
		close(tArr[h]+ch1);
		
		if(chnnls > 1) {
			selectWindow("og");
			run("Image Sequence... ", "format=TIFF name=stack digits=2 save="+wdir+"");
			close("og");
			run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory="+wdir+" layout_file=TileConfiguration.registered.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 subpixel_accuracy computation_parameters=[Save computation time (but use more RAM)] image_output=[Fuse and display]");
			if(chnnls == 2) {
				saveAs("Tiff", wdir+tArr[h]+ch2);
				close(tArr[h]+ch2);
			}
			else if(chnnls == 3) {
				saveAs("Tiff", wdir+tArr[h]+ch3);
				close(tArr[h]+ch3);
			}
			else {
				saveAs("Tiff", wdir+tArr[h]+ch4);
				close(tArr[h]+ch4);
			}
		}
		
		if(chnnls > 2) {
			selectWindow("og3");
			run("Image Sequence... ", "format=TIFF name=stack digits=2 save="+wdir+"");
			close("og3");
			run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory="+wdir+" layout_file=TileConfiguration.registered.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 subpixel_accuracy computation_parameters=[Save computation time (but use more RAM)] image_output=[Fuse and display]");
			saveAs("Tiff", wdir+tArr[h]+ch2);
			close(tArr[h]+ch2);
		}
		
		if(chnnls == 4) {
			selectWindow("og4");
			run("Image Sequence... ", "format=TIFF name=stack digits=2 save="+wdir+"");
			close("og4");
			run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory="+wdir+" layout_file=TileConfiguration.registered.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 subpixel_accuracy computation_parameters=[Save computation time (but use more RAM)] image_output=[Fuse and display]");
			saveAs("Tiff", wdir+tArr[h]+ch3);
			close(tArr[h]+ch3);
		}
	}
}


setBatchMode("exit and display");	
beep();
exit("Done");



