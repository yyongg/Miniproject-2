filename = rgb_fade
top = rgb_fade
pcf_file = common/iceBlinkPico.pcf

build:
	yosys -p "synth_ice40 -top $(top) -json $(filename).json" $(filename).sv
	nextpnr-ice40 --up5k --package sg48 --json $(filename).json --pcf $(pcf_file) --asc $(filename).asc
	icepack $(filename).asc $(filename).bin

sim:
	iverilog -g2012 -o $(filename)_tb.vvp $(filename)_tb.sv $(filename).sv
	vvp $(filename)_tb.vvp | tee sim_output.txt

prog: #for sram
	dfu-util --device 1d50:6146 --alt 0 -D $(filename).bin -R

clean:
	rm -rf $(filename).blif $(filename).asc $(filename).json $(filename).bin $(filename)_tb.vvp
