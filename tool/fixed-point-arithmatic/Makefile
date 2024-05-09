SIGNAL_FONT = 'fontname_signals Helvetica 12'
WAVE_FONT = 'fontname_waves Helvetica 12'

run: *.sv
	iverilog -g2012 *.sv
	vvp *.out
	del /Q *.out
wv:
	gtkwave *.vcd --rcvar $(SIGNAL_FONT) --rcvar $(WAVE_FONT)

