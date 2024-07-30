

run:
	ncverilog \
	-sv  \
	+ncaccess+rwc \
	+notimingcheck \
	tb_topSystolicArray.sv topSystolicArray.sv systolicArray.sv pe.sv

wv:
	nWave tb_topSystolicArray.fsdb &
	
clean:
	rm -rf *.conf *.rc *.log *.fsdb
