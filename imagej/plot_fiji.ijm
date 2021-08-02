selectWindow("Box");
setBatchMode("hide");
for (i = 0; i < nResults; i++) {
	nx = getResult("C1", i)+63;
	ny = getResult("C2", i)+63;
	nz = getResult("C3", i)+63;
	if (nz <= 127 && nx <= 127 && ny <= 127) {
		if (nz >=0 && nx >= 0 && ny >= 0) {
			setSlice(nz);
			oldpix = getPixel(nx, ny);
			setPixel(nx, ny, oldpix+1);
			showProgress(i/nResults);
		}
	}
}
setBatchMode("exit and display");
