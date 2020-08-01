setTool(4);
x2 = -1;
y2 = -1;
length = 0;
getPixelSize(unit, pixelWidth, pixelHeight);
run("Fonts...");
IJ.log("-Use font panel to adjust size and color of font.");
IJ.log("     Must be an RGB image to label in color.");
IJ.log("-Double click the line tool to adjust line width.");
IJ.log("-Draw lines with left mouse button to get size in scaled units.");
IJ.log("-Press spacebar to draw line and measurement on image.");
IJ.log("-Close this window to terminate macro.");
while (isOpen("Log") && nImages > 0) {
	getLine(x3, y3, x4, y4, lineWidth);
	dx = x4-x3; 
	dy = y4-y3;
	length = d2s(sqrt(dx*dx+dy*dy)*pixelWidth, 1);
	
	getCursorLoc(x, y, z, modifiers);
	if(x != x2 || y != y2) {
		Overlay.clear;
		setFont("user");
		fg = getValue("rgb.foreground");
		setColor((fg>>16)&0xff,(fg>>8)&0xff,fg&0xff);
		Overlay.drawString(length, x, y);
		Overlay.show;
		if(isKeyDown("space")) {
			drawString(length, x2, y2);
			drawLine(x3, y3, x4, y4);
		}
	}
	x2=x;
	y2=y;
	wait(10);
}
Overlay.clear;
Overlay.remove;
exit("Log closed");