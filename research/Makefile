all: cairo-X11

cairo-X11: cairo-X11.d
	dmd -I/usr/local/include/d -I/usr/local/include/d/DX11/ \
		-L-L/usr/local/lib -L-lDX11-dmd -L-lX11 -L-lcairo \
		cairo-X11.d

clean:
	rm -rf ./*.o ./*.png cairo-X11
