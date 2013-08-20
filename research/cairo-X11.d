module research;

import deimos.cairo.cairo;
import std.stdio;

void main()
{
	writeln("Hello, world !");
	
	cairo_surface_t *surface;
	cairo_t *context;
	
	surface = cairo_image_surface_create (CairoFormat.ARGB32, 400, 300);
	context = cairo_create (surface);
	
	// background
	cairo_set_source_rgb(context, 255, 255, 255);
	cairo_rectangle(context, 5, 5, 120, 40);
	cairo_fill(context);
	
	// border
	cairo_set_line_width(context, 2);
	cairo_set_source_rgb(context, 0, 0, 0);
	cairo_rectangle(context, 5, 5, 120, 40);
	cairo_stroke(context);
	
	// text
	cairo_select_font_face (context, "serif", CairoFontSlant.Normal, CairoFontWeight.Bold);
    cairo_set_font_size (context, 12.0);
    cairo_set_source_rgb (context, 0, 0, 0);
    cairo_move_to (context, 10.0, 22.0);
    cairo_show_text (context, "Hello, world");
	
	cairo_destroy(context);
	cairo_surface_write_to_png(surface, "cairo-output.png");
	writeln("Open cairo-output.png to see the result.");
	cairo_surface_destroy(surface);
}
