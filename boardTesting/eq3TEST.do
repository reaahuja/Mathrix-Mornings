# Compile the design
vlib work
vlog equation3_Test.v 
# Simulate the design
vsim topLevel

# Add waves to the waveform viewer
add wave -r /*

# Assuming Reset is active-high, assert and then de-assert after 4ns
force topLevel/KEY[0] 1 0ns, 0 4ns

# Start Clock and Go signals
force topLevel/CLOCK_50 0 0ns , 1 {1ns} -r 2ns
force topLevel/SW[8] 1'b1
force topLevel/EXTRA[6:0] 7'b0000101
force topLevel/KEY[1] 1'b0
run 5ns

force topLevel/KEY[1] 1'b1
force topLevel/SW[7:0] 8'b00000000
run 8ns
force topLevel/KEY[1] 1'b0
run 2ns

force topLevel/KEY[1] 1'b1
force topLevel/SW[7:0] 8'b00000001
run 8ns
force topLevel/KEY[1] 1'b0
run 2ns

run 200ns

