module sequencer(startSequencer, Go, DataIn, correct);
    input startSequencer, Go;
    input [5:0] DataIn;
    output reg correct; 

    always @(*) begin // Procedural block with sensitivity list
        if (Go && startSequencer) begin 
            if (DataIn[0] == 1'b1 
             && DataIn[1] == 1'b0
             && DataIn[2] == 1'b1
             && DataIn[3] == 1'b0 
             && DataIn[4] == 1'b0 
             && DataIn[5] == 1'b1) begin 
                correct = 1'b1;
            end else begin 
                correct = 1'b0;
            end
        end else begin 
            correct = 1'b0;
        end
    end
endmodule
