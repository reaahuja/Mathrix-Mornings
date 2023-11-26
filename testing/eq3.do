# Compile the design
vlib work
vlog equation3.v 
# Simulate the design
vsim equation3

# Add waves to the waveform viewer
add wave -r /*

# Assuming Reset is active-high, assert and then de-assert after 4ns
force equation3/Reset 1 0ns, 0 4ns

# Start Clock and Go signals
force equation3/Clock 0 0ns , 1 {1ns} -r 2ns
force equation3/startEq3 1'b1
force equation3/OngoingTimer 7'b0000101
force equation3/Go 1'b0
run 5ns

force equation3/Go 1'b1
force equation3/DataIn 8'b00000000
run 8ns
force equation3/Go 1'b0
run 2ns

force equation3/Go 1'b1
force equation3/DataIn 8'b00000001
run 8ns
force equation3/Go 1'b0
run 2ns

run 200ns

