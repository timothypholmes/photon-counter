#!/bin/bash

file_name = $1



yosys -p "read_verilog $1.v; synth_ice40 -blif $1.blif"

arachne-pnr -d 1k -p icestick.pcf -o $1.txt $1.blif

icepack $1.txt  $1.bin

iceprog $1.bin
