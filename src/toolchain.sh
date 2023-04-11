#!/bin/sh
#./toolchain 
set -e
yosys -p 'read_verilog -sv *.sv; synth_ice40 -json build/synthesis.json -top chipInterface; stat'
nextpnr-ice40 --hx8k --json build/synthesis.json --asc build/pnr.asc --package cb132 --pcf constraints.pcf --freq 100 --pre-place constrain.py
icepack build/pnr.asc build/bitstream.bit
yosys -p 'read_verilog -sv *.sv; synth -top my_chip; stat'