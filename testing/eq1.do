# Compile the design
vlib work
vlog equation1.v 
# Simulate the design
vsim equation1

# Add waves to the waveform viewer
add wave -r /*

# Assuming Reset is active-high, assert and then de-assert after 4ns
force equation1/Reset 1 0ns, 0 4ns

# Start Clock and Go signals
force equation1/Clock 1 0ns , 0 {2ns} -r 4ns
force equation1/Go 1 0ns , 0 {2ns} -r 4ns

run 12ns

force equation1/startEq1 1'b1
run 12ns

force equation1/OngoingTimer 7'b0000010
run 12ns

force equation1/DataIn 8'b00000001
run 12ns

force equation1/DataIn 2'b00000001
run 12ns

force equation1/DataIn 2'b00000001
run 12ns
