

run:
	ncverilog \
	+ncaccess+rwc \
	+notimingcheck \
	-sv tb_topSystolicArray.sv topSystolicArray.sv systolicArray.sv pe.sv

gate:
	ncverilog \
	+ncaccess+rwc \
	+notimingcheck \
	-sv tb_topSystolicArray.sv \
	-v topSystolicArray.vg tsmc090.v

wv:
	nWave tb_topSystolicArray.fsdb &
	
clean:
	rm -rf *.conf *.rc *.log *.fsdb
