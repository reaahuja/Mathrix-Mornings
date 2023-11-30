/*
Clock: System's clock
Reset: Active High reset 
Go: Signal asserted to input value to system 
OngoingTimer: The current time in the system 
DataIn: The value for the different variables 
startEq2: Queue to start FSM
correct: Determining whether the input was correct or not 
*/

module topLevel(CLOCK_50, KEY, SW, LEDR);
    input wire CLOCK_50; 
    input wire [1:0] KEY; 
    input wire [8:0] SW;
    output wire [8:0] LEDR;

    wire [6:0] testingWire; 
    assign testingWire = 7'b0000001;

    equation2 initiate(.Clock(CLOCK_50), 
                       .Reset(KEY[0]), 
                       .Go(KEY[1]), 
                       .OngoingTimer(testingWire), 
                       .DataIn(SW[7:0]), 
                       .startEq2(SW[8]), 
                       .correct(LEDR[0]));
endmodule

module equation2(Clock, Reset, Go, OngoingTimer, DataIn, startEq2, correct);
    input Clock;
    input Reset;
    input Go;
    input [6:0] OngoingTimer;
    input [7:0] DataIn;
    input startEq2;
    output wire correct;

    // lots of wires to connect our datapath and control
    wire ld_x, ld_y, ld_z, ld_a, ld_r;
    wire ld_alu_out;
    wire [1:0]  alu_select_a, alu_select_b;
    wire [1:0] alu_op;
    wire [7:0] DataResult;
    wire compareValues, turnOff, forceReset; 

    control C0(
        Clock, 
        Reset, 
        Go, 
        OngoingTimer, 
        DataIn, 
        correct,
        startEq2,
        ld_x, ld_y, ld_z, ld_a, ld_r,
        ld_alu_out,
        alu_select_a, alu_select_b,
        alu_op,
        compareValues, turnOff, 
        forceReset
    );

    datapath D0(
        Clock, Reset, Go,
        OngoingTimer,
        DataIn, 
        compareValues, turnOff,
        ld_x, ld_y, ld_z, ld_a, ld_r,
        ld_alu_out,
        alu_select_a, alu_select_b,
        alu_op,
        forceReset,
        correct, startEq2, 
        DataResult
    );


 endmodule

module control(
        input Clock, Reset, go, 
        input [6:0] OngoingTimer, 
        input [7:0] DataIn, 
        input correct,
        input startEq2,
        output reg ld_x, ld_y, ld_z, ld_a, ld_r,
        output reg ld_alu_out,
        output reg [1:0] alu_select_a, alu_select_b,
        output reg [1:0] alu_op,
        output reg compareValues, turnOff, 
        output reg forceReset
    );

    reg [5:0] current_state, next_state;

    localparam  getA          = 5'd0,
                LOAD_X        = 5'd1,
                LOAD_X_WAIT   = 5'd2,
                LOAD_Y        = 5'd3,
                LOAD_Y_WAIT   = 5'd4,
                LOAD_Z        = 5'd5,
                LOAD_Z_WAIT   = 5'd6,
                CYCLE_0       = 5'd7,
                CYCLE_1       = 5'd8,
                CYCLE_2       = 5'd9,
                CYCLE_3       = 5'd10,
                COMPARE       = 5'd11, 
                COMPLETE      = 5'd12,
                resetSystem   = 5'd13;

    // Next state logic aka our state table
    always@(*)
    begin: state_table
            case (current_state)
                getA: next_state = startEq2 ? LOAD_X : getA; 
                LOAD_X: next_state = go ? LOAD_X_WAIT : LOAD_X; 
                LOAD_X_WAIT: next_state = go ? LOAD_X_WAIT : LOAD_Y; 
                LOAD_Y: next_state = go ? LOAD_Y_WAIT : LOAD_Y; 
                LOAD_Y_WAIT: next_state = go ? LOAD_Y_WAIT : LOAD_Z; 
                LOAD_Z: next_state = go ? LOAD_Z_WAIT : LOAD_Z; 
                LOAD_Z_WAIT: next_state = go ? LOAD_Z_WAIT : CYCLE_0; 
                CYCLE_0: next_state = CYCLE_1;
                CYCLE_1: next_state = CYCLE_2;
                CYCLE_2: next_state = CYCLE_3;
                CYCLE_3: next_state = COMPARE;
                COMPARE: next_state = COMPLETE; // we will be done our two operations, start over after
                COMPLETE: next_state = correct ? COMPLETE : resetSystem;
                resetSystem: next_state = getA;
            default:     next_state = getA;
        endcase
    end // state_table
    //TURN startEq2 LOW IN COMPLETE

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_alu_out = 1'b0;
        ld_x = 1'b0;
        ld_y = 1'b0;
        ld_z = 1'b0;
        ld_a = 1'b0;
        ld_r = 1'b0;
        alu_select_a = 2'b0;
        alu_select_b = 2'b0;
        alu_op       = 2'b0;
        compareValues = 1'b0; 
        turnOff = 1'b0;
        forceReset = 1'b0;

        case (current_state)
            getA: begin
                ld_a = 1'b1;
                forceReset = 1'b0;
                end
            LOAD_X: begin
                ld_x = 1'b1;
                end
            LOAD_Y: begin
                ld_y = 1'b1;
                end
            LOAD_Z: begin
                ld_z = 1'b1;
                end
            CYCLE_0: begin // Do X*Y in Y
                alu_select_a = 2'b00;
                alu_select_b = 2'b01;
                alu_op = 2'b01;
                ld_alu_out = 1'b1; ld_y = 1'b1;
            end
            CYCLE_1: begin // Do X*X in X
                alu_select_a = 2'b00;
                alu_select_b = 2'b00;
                alu_op = 2'b01;
                ld_alu_out = 1'b1; ld_x = 1'b1;
            end
            CYCLE_2: begin // Do (X*X)*Z in X
                alu_select_a = 2'b00; 
                alu_select_b = 2'b10;
                alu_op = 2'b01;
                ld_alu_out = 1'b1; ld_x = 1'b1;
            end
            CYCLE_3: begin // Do ((X*X)*Z) + X*Y in R
                alu_select_a = 2'b00;
                alu_select_b = 2'b01;
                alu_op = 2'b00;
                ld_r = 1'b1;
            end
            COMPARE: begin // Compare result to value in A
                compareValues = 1'b1; 
            end
            COMPLETE: begin //done
                turnOff = 1'b1; //for VGA
            end
            resetSystem: begin 
                forceReset = 1'b1;
            end
        endcase
    end // enable_signals

    // current_state registers
    always@(posedge Clock)
    begin: state_FFs
        if(Reset || forceReset)
            current_state <= getA;
        else
            current_state <= next_state;
    end // state_FFS
endmodule


module datapath(
        input Clock, Reset, Go, 
        input [6:0] OngoingTimer, 
        input [7:0] DataIn, 
        input compareValues, turnOff, 
        input ld_x, ld_y, ld_z, ld_a, ld_r,
        input ld_alu_out,
        input [1:0] alu_select_a, alu_select_b,
        input [1:0] alu_op,
        input forceReset,
        output reg correct, startEq2,
        output reg [7:0] data_result
    );

    // input registers
    reg [7:0] x, y, z, a;

    // output of the alu
    reg [7:0] alu_out;
    // alu input muxes
    reg [7:0] alu_a, alu_b;

    // Registers a, b, c, x with respective input logic
    always@(posedge Clock) begin
        if(Reset || forceReset) begin
            x <= 8'b0;
            y <= 8'b0;
            z <= 8'b0;
            a <= 8'b0;
        end
        else begin
            if(ld_x)
                x <= ld_alu_out ? alu_out : DataIn; // load alu_out if load_alu_out signal is high, otherwise load from data_in
            if(ld_y)
                y <= ld_alu_out ? alu_out : DataIn; // load alu_out if load_alu_out signal is high, otherwise load from data_in
            if(ld_z)
                z <= DataIn;
            if(ld_a)
                a <= {1'b0, OngoingTimer};
        end
    end

    // Output result register
    always@(posedge Clock) begin
        if(Reset || forceReset) begin
            data_result <= 8'b0;
        end
        else
            if(ld_r)
                data_result <= alu_out;
    end

    // The ALU input multiplexers
    always @(*)
    begin
        case (alu_select_a)
            2'b00:
                alu_a = x;
            2'b01:
                alu_a = y;
            2'b10:
                alu_a = z;
            default: alu_a = 8'b0;
        endcase

        case (alu_select_b)
            2'b00:
                alu_b = x;
            2'b01:
                alu_b = y;
            2'b10:
                alu_b = z;
            default: alu_b = 8'b0;
        endcase
    end

    // The ALU
    always @(*)
    begin : ALU
        // alu
        case (alu_op)
            2'b00: begin
                   alu_out = alu_a + alu_b; //performs addition
               end
            2'b01: begin
                   alu_out = alu_a * alu_b; //performs multiplication
               end
            2'b10: begin
                   alu_out = alu_a / alu_b; //performs divison
               end
            default: alu_out = 8'b0;
        endcase
    end

    //comparison 
    always @(*)
    begin: COMPARE
        // a == data_result but changing for testing 
        if (compareValues == 1'b1 && a == data_result) begin 
            correct <= 1'b1;
            startEq2 <= 1'b0;
        end
        else if (a != data_result)begin
            correct <= 1'b0; 
        end
    end

endmodule

//SIGNAL FOR VGA TO DETERMINE IF OUTPUT IS WRONG OR NOT 