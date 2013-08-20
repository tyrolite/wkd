all: cairo-X11

cairo-X11: cairo-X11.d
	dmd -L-lcairo cairo-X11.d
	
clean:
	rm -rf ./*.o ./*.png cairo-X11
