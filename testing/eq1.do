# Compile the design
vlib work
vlog equation1.v 
# Simulate the design
vsim equation1

# Add waves to the waveform viewer
add wave -r /*

# Adding internal states and register values for debugging
add wave -divider "Internal States"
add wave -position insertpoint \
    sim:/equation1/C0/current_state \
    sim:/equation1/C0/next_state

# Adding register values
add wave -divider "Register Values"
add wave -position insertpoint \
    sim:/equation1/D0/x \
    sim:/equation1/D0/y \
    sim:/equation1/D0/z \
    sim:/equation1/D0/a \
    sim:/equation1/D0/data_result

#Adding control signals 
add wave -divider "Control Signals"
add wave -position insertpoint \
    sim:/equation1/C0/ld_x \
    sim:/equation1/C0/ld_y \
    sim:/equation1/C0/ld_z \
    sim:/equation1/C0/ld_a \
    sim:/equation1/C0/ld_r \
    sim:/equation1/C0/compareValues \
    sim:/equation1/C0/turnOff

# Assuming Reset is active-high, assert and then de-assert after 4ns
force equation1/Reset 1 0ns, 0 4ns

# Start Clock and Go signals
force equation1/Clock 1 0ns , 0 {2ns} -r 4ns
run 2ns

force equation1/Go 1'b1
force equation1/DataIn 8'b0
run 8ns
force equation1/Go 1'b0
run 2ns

force equation1/Go 1'b1
force equation1/DataIn 8'b0
run 8ns
force equation1/Go 1'b0
run 2ns

force equation1/Go 1'b1
force equation1/DataIn 8'b0
run 8ns
force equation1/Go 1'b0
run 2ns

run 200ns

