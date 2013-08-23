module research;

import deimos.X11.X;
import deimos.X11.Xlib;
import deimos.X11.Xutil;
import deimos.cairo.cairo;
import deimos.cairo.xlib;
import std.stdio;
import std.string;

void paint(cairo_surface_t *surface)
{
	cairo_t *context;
	context = cairo_create (surface);
	
	//window background
	cairo_set_source_rgb(context, 0.5, 0.5, 0.5);
	cairo_rectangle(context, 0, 0, 400, 300);
	cairo_fill(context);
	
	// btn background
	cairo_set_source_rgb(context, 0.353, 0.353, 0.353);
	cairo_rectangle(context, 5, 5, 120, 40);
	cairo_fill(context);
	
	// btn border
	cairo_set_line_width(context, 1);
	cairo_set_source_rgb(context, 0, 0, 0);
	cairo_rectangle(context, 5, 5, 120, 40);
	cairo_stroke(context);
	
	// btn text
	cairo_select_font_face (context, "serif", CairoFontSlant.Normal, CairoFontWeight.Bold);
    cairo_set_font_size (context, 12.0);
    cairo_set_source_rgb (context, 1, 1, 1);
    cairo_move_to (context, 10.0, 22.0);
    cairo_show_text (context, "Hello, world");
	
	cairo_destroy(context);
}

int main()
{
	writeln("Hello, world !");
	
	// X11 stuff
	Display *display;
	Window rootWin;
	Window win;
	XEvent ev;
	XVisualInfo visInfo;
	XVisualInfo *visList;
	XVisualInfo visTemplate;
	XSetWindowAttributes  swa;
	int screen;
	int swaMask;
	int visCount;
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
	
	screen = DefaultScreen(display);
	rootWin = RootWindow(display, screen);
	
	visCount = 0;
	visTemplate.screen = DefaultScreen(display);
	visList = XGetVisualInfo(display, VisualScreenMask, &visTemplate, &visCount);
	
	for(int i = 0; i < visCount; ++i)
	{
		writefln("%d: visual %d class %d (%s) depth %d",
			i,
			visList[i].visualid,
			visList[i].c_class,
			visList[i].c_class == TrueColor ? "TrueColor" : "unknown",
			visList[i].depth);
	}
	
	rc = XMatchVisualInfo(display, screen, SCR_DEPTH, SCR_CLASS, &visInfo);
	if(!rc)
	{
		writeln("unable to match visual info !!!");
		return 1;
	}
	
	writefln("Matched visual %d class %d (%s) depth %d",
         visInfo.visualid,
         visInfo.c_class,
         visInfo.c_class == TrueColor ? "TrueColor" : "unknown",
         visInfo.depth);
	
	swa.border_pixel = 0;
    swa.event_mask = StructureNotifyMask;
    swa.colormap = XCreateColormap( display, RootWindow(display, visInfo.screen),
                                        visInfo.visual, AllocNone);

	swaMask = CWBorderPixel | CWColormap | CWBackPixel | CWEventMask;
	
	win = XCreateSimpleWindow(display, rootWin, 1, 1, SIZEX, SIZEY, 0,
			BlackPixel(display, screen), WhitePixel(display, screen));
	
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
	cairo_surface_t *surface;
	
	//surface = cairo_image_surface_create (CairoFormat.ARGB32, 400, 300);
	surface = cairo_xlib_surface_create(display, win, DefaultVisual(display, 0), SIZEX, SIZEY);
	//surface = cairo_xlib_surface_create(display, win, visInfo.visual, SIZEX, SIZEY);
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
	
	cairo_surface_write_to_png(surface, "cairo-output.png");
	writeln("Open cairo-output.png to see the result.");
	
	cairo_surface_destroy(surface);
	
	XUnmapWindow(display, win);
	XDestroyWindow(display, win);	
	XCloseDisplay(display);
	
	return 0;
}
