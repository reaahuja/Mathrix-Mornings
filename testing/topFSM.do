# Create and map a work library
vlib work
vmap work work

# Compile the Verilog files
vlog -work work topFSM.v

# Load the simulation with the top-level module
vsim -L work -voptargs="+acc" topFSM

# Add signals to the waveform viewer
add wave -position insertpoint \
    sim:/topFSM/Clock \
    sim:/topFSM/Reset \
    sim:/topFSM/Start \
    sim:/topFSM/DataIn \
    sim:/topFSM/Go \
    sim:/topFSM/CounterOutput \
    sim:/topFSM/t0/countDone \
    sim:/topFSM/t0/current_state \
    sim:/topFSM/t0/next_state \
    sim:/topFSM/twentyCounter/Enable \
    sim:/topFSM/twentyCounter/Timer \
    sim:/topFSM/twentyCounter/countDone \
    sim:/topFSM/onGoingCounter/Enable \
    sim:/topFSM/onGoingCounter/Timer \
    sim:/topFSM/onGoingCounter/countDone \


# Set up the clock with a 10ns period
force Clock 0 0ns, 1 5ns -r 10ns

# Initial Reset
force Reset 1 0ns, 0 100ns

# Initial Start
force Start 0 0ns, 1 110ns

# Run the simulation for a specified time to see the counter's behavior
run 1000ns

# Stop the simulation
# stop
