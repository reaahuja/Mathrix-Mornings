# Compile the design
vlib work
vlog equation3.v 
# Simulate the design
vsim equation1

# Add waves to the waveform viewer
add wave -r /*
radix -radix decimal -all

# Assuming Reset is active-high, assert and then de-assert after 4ns
force equation3/Reset 1 0ns, 0 4ns

# Start Clock and Go signals
force equation3/Clock 0 0ns , 1 {1ns} -r 2ns
force equation3/startEq3 1'b1
force equation3/Go 1'b1
run 200ns
