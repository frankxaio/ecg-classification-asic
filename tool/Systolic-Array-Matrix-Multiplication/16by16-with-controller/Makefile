SIGNAL_FONT = 'fontname_signals Helvetica 12'
WAVE_FONT = 'fontname_waves Helvetica 12'

mmu_test = tb_matrix_multiply.sv matrix_multiply.sv mac_unit.sv
# mmu_test = mmu_tb.sv mmu_scale.sv mac.sv
# mmu_test = mmu_tb.sv mmu.sv mac.sv
wv = mmu_tb
run: *.sv
	iverilog -g2005-sv -o sim.out $(mmu_test)
	vvp *.out
	del a.out sim.out
wv:
	gtkwave $(wv).vcd --rcvar $(SIGNAL_FONT) --rcvar $(WAVE_FONT)

