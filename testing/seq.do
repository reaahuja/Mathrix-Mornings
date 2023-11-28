vlib work
vlog sequence.v
vsim sequence
log {/*}
add wave {/*}

# Reset 
force startSequencer 1'b1;
force Go 1'b1;
force DataIn 6'b100101;
run 10ns
