# Compile the design
vlib work
vlog equation2Test.v 
# Simulate the design
vsim topLevel

# Add waves to the waveform viewer
add wave -r /*

# Assuming Reset is active-high, assert and then de-assert after 4ns
force topLevel/KEY 2'b01
run 2ns
force topLevel/KEY 2'b00

# Start Clock and Go signals
force topLevel/CLOCK_50 0 0ns , 1 {1ns} -r 2ns
force topLevel/SW 9'b110000000
force topLevel/KEY 2'b00
run 5ns

force topLevel/KEY 2'b10
force topLevel/SW 9'b000000001
run 8ns
force topLevel/KEY 2'b00
run 2ns

force topLevel/KEY 2'b10
force topLevel/SW 9'b000000000
run 8ns
force topLevel/KEY 2'b00
run 2ns

force topLevel/KEY 2'b10
force topLevel/SW 9'b000000001
run 8ns
force topLevel/KEY 2'b00
run 2ns

run 200ns
