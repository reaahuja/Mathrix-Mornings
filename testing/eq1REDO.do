# Load the design
vlog equation1.v

# Load the simulation
vsim work.equation1

# Initialize simulation parameters
add wave -divider "Inputs"
add wave -position insertpoint \
    sim:/equation1/Clock \
    sim:/equation1/Reset \
    sim:/equation1/Go \
    sim:/equation1/OngoingTimer \
    sim:/equation1/DataIn \
    sim:/equation1/startEq1

add wave -divider "Outputs"
add wave -position insertpoint \
    sim:/equation1/correct

# Set initial values
force -deposit sim:/equation1/Reset 1 0, 0 {50 ns}
force -deposit sim:/equation1/startEq1 0
force -deposit sim:/equation1/DataIn 0
force -deposit sim:/equation1/OngoingTimer 0

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

# Define Clock
force -deposit sim:/equation1/Clock 0 0ns , 1 {2ns} -r 4ns
force equation1/Go 0 0ns , 1 {2ns} -r 6ns

# Start the simulation
run 1 us

# Begin the test sequence
# Reset the system
force -deposit sim:/equation1/Reset 1 0, 0 {10 ns}
run 20 ns

# Remove reset and start the system
force -deposit sim:/equation1/Reset 0
force -deposit sim:/equation1/startEq1 1
run 10 ns

# Input values for X, Y, Z, and OngoingTimer, and enable Go for each input
# Set OngoingTimer value
force -deposit sim:/equation1/OngoingTimer 8'b0
run 20 ns

# Repeat these steps for different values to thoroughly test the system
force -deposit sim:/equation1/DataIn 8'b0


# Input Y value
force -deposit sim:/equation1/DataIn 8'b0


# Input Z value
force -deposit sim:/equation1/DataIn 8'b0



# Wait for the operation to complete
run 200 ns


# End the simulation
run 200 ns

