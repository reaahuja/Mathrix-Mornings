# Compile the design
vlib work
vlog topLevel.v 
# Simulate the design
vsim alarmClock

# Add waves to the waveform viewer
add wave -r /*

#Equation 1: topFSM startAlarm(.Clock(CLOCK_50), .Reset(KEY[0]), .Start(SW[9]), .DataIn(SW[7:0]), .Go(KEY[1]), .correct(LEDR[0]));

#Start clock ahead
force alarmClock/CLOCK_50 0 0ns , 1 {1ns} -r 2ns

# Assuming Reset is active-high, assert and then de-assert after 4ns
force alarmClock/KEY[0] 1'b1
run 2ns
force alarmClock/KEY[0] 1'b0

# Start Clock and Go signals
force alarmClock/SW[9] 1'b1
force alarmClock/KEY[1] 1'b0
run 5ns

force alarmClock/KEY[1] 1'b1
force alarmClock/SW[7:0] 8'b0
run 8ns
force alarmClock/KEY[1] 1'b0
run 2ns

force alarmClock/KEY[1] 1'b1
force alarmClock/SW[7:0] 8'b00000001
run 8ns
force alarmClock/KEY[1] 1'b0
run 2ns

force alarmClock/KEY[1] 1'b1
force alarmClock/SW[7:0] 8'b00000001
run 8ns
force alarmClock/KEY[1] 1'b0
run 2ns



run 20ns

