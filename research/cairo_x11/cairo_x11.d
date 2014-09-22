module research;

import x11.X;
import x11.Xlib;
import x11.Xutil;

import cairo.cairo;
import cairo.xlib;
import std.stdio;
import std.string;

void paint(Surface surface)
{
	auto context = Context (surface);
	
	//window background
    context.setSourceRGB(0.5, 0.5, 0.5);
	context.rectangle(0, 0, 400, 300);	 
	context.fill();
	
	// btn background
	context.setSourceRGB(0.353, 0.353, 0.353);
	context.rectangle(5, 5, 120, 40);
	context.fill();
	
	// btn border
    context.setLineWidth(1);
    context.setSourceRGB(0, 0, 0);
    context.rectangle(5, 5, 120, 40);
    context.stroke();

	// btn text
    context.selectFontFace("serif", FontSlant.CAIRO_FONT_SLANT_NORMAL, FontWeight.CAIRO_FONT_WEIGHT_BOLD);
    context.setFontSize(12.0);
    context.setSourceRGB(1,1,1);
    context.moveTo(10, 22);
    context.showText("Hello, world");

}

int main()
{
	writeln("Hello, world !");
	
	// X11 stuff
	Display *display;
	Window rootWin;
	Window win;
	XEvent ev;

	int screen;
	int rc;

	immutable SCR_DEPTH = 32;
	immutable SCR_CLASS = TrueColor;
	
	immutable SIZEX = 400;
	immutable SIZEY = 300;
	
	display = XOpenDisplay(null);
	if (!display)
	{
		writeln("XOpenDisplay failed");
		return 1;
	}

	screen = XDefaultScreen(display);
	rootWin = XRootWindow(display, screen);
	
	win = XCreateSimpleWindow(display, rootWin, 1, 1, SIZEX, SIZEY, 0,
			XBlackPixel(display, screen), XWhitePixel(display, screen));
	
	/* //this is transparent
	win = XCreateWindow(display, rootWin, 1, 1, SIZEX, SIZEY, 0,
			visInfo.depth, InputOutput, visInfo.visual, swaMask, &swa);*/
			
	writeln("after XCreate");
	
	char[] winName = ("hello".dup ~ '\0');		
	XStoreName(display, win, winName.ptr);
	XSelectInput(display, win, ExposureMask|ButtonPressMask);
	XMapWindow(display, win);
	
	writeln("after XMap");
	// cairo stuff

	auto surface = new XlibSurface(display, win, XDefaultVisual(display, 0), SIZEX, SIZEY); 

	if(!surface)
	{
		writeln("Unable to create surface !");
		return 1;
	}
	
	writeln("after surface_create");
	
	while(true)
	{
		XNextEvent(display, &ev);
		if(ev.type == Expose && ev.xexpose.count < 1)
		{
			paint(surface);
		}
		else if(ev.type == ButtonPress)
			break;
	}
	
	writeln("after while");
	
/*	cairo_surface_write_to_png(surface, "cairo-output.png");
	writeln("Open cairo-output.png to see the result.");
*/	
	surface.dispose();
	
	XUnmapWindow(display, win);
	XDestroyWindow(display, win);	
	XCloseDisplay(display);
	
	return 0;
}
