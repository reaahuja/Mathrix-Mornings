/*
Clock: System's clock
Reset: Active High reset 
Go: Signal asserted to input value to system 
OngoingTimer: The current time in the system 
DataIn: The value for the different variables 
startEq1: Queue to start FSM
correct: Determining whether the input was correct or not 
*/

module equation1(Clock, Reset, Go, OngoingTimer, DataIn, startEq1, correct);
    input Clock;
    input Reset;
    input Go;
    input [6:0] OngoingTimer;
    input [7:0] DataIn;
    input startEq1;
    output correct;

    // lots of wires to connect our datapath and control
    wire ld_x, ld_y, ld_z, ld_a, ld_r;
    wire ld_alu_out;
    wire [1:0]  alu_select_a, alu_select_b;
    wire [1:0] alu_op;
    wire [7:0] DataResult;
    wire compareValues, turnOff; 

    control C0(
        Clock, 
        Reset, 
        Go, 
        OngoingTimer, 
        DataIn, 
        correct,
        startEq1,
        ld_x, ld_y, ld_z, ld_a, ld_r,
        ld_alu_out,
        alu_select_a, alu_select_b,
        alu_op,
        compareValues, turnOff
    );

    datapath D0(
        Clock, Reset, Go,
        OngoingTimer,
        DataIn, 
        compareValues, turnOff,
        correct, startEq1, 
        ld_x, ld_y, ld_z, ld_a, ld_r,
        ld_alu_out,
        alu_select_a, alu_select_b,
        alu_op,
        DataResult
    );


 endmodule


module control(
        input Clock, Reset, go, 
        input [6:0] OngoingTimer, 
        input [7:0] DataIn, 
        input correct,
        input startEq1,
        output reg ld_x, ld_y, ld_z, ld_a, ld_r,
        output reg ld_alu_out,
        output reg [1:0] alu_select_a, alu_select_b,
        output reg [1:0] alu_op,
        output reg compareValues, turnOff
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
                COMPLETE      = 5'd12;

    // Next state logic aka our state table
    always@(*)
    begin: state_table
            case (current_state)
                getA: next_state = startEq1 ? LOAD_X : getA; 
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
                COMPARE: next_state = correct ? COMPLETE : getA; // we will be done our two operations, start over after
                COMPLETE: next_state = startEq1 ? getA : COMPLETE;
            default:     next_state = getA;
        endcase
    end // state_table
    //TURN STARTEQ1 LOW IN COMPLETE

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
        alu_op       = 1'b0;
        compareValues = 1'b0; 
        turnOff = 1'b0;

        case (current_state)
            getA: begin
                ld_a = 1'b1;
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
            CYCLE_0: begin // Do X/Z
                alu_select_a = 2'b00;
                alu_select_b = 2'b10;
                alu_op = 2'b10;
                ld_alu_out = 1'b1; ld_x = 1'b1;
            end
            CYCLE_1: begin // Do (X/Z) * (X/Z)
                alu_select_a = 2'b00;
                alu_select_b = 2'b00;
                alu_op = 2'b01;
                ld_alu_out = 1'b1; ld_x = 1'b1;
            end
            CYCLE_2: begin // Do Y/Z
                alu_select_a = 2'b01;
                alu_select_b = 2'b10;
                alu_op = 2'b10;
                ld_alu_out = 1'b1; ld_y = 1'b1;
            end
            CYCLE_3: begin // Do Y/Z + (X/Z)^2
                alu_select_a = 2'b00;
                alu_select_b = 2'b01;
                alu_op = 2'b00;
                ld_r = 1'b1;
            end
            COMPARE: begin // Compare result to value in A
                compareValues = 1'b1; 
            end
            COMPLETE: begin //done
                turnOff = 1'b1; 
            end
        endcase
    end // enable_signals

    // current_state registers
    always@(posedge Clock)
    begin: state_FFs
        if(Reset)
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
        output reg correct,
        output reg startEq1,
        input ld_x, ld_y, ld_z, ld_a, ld_r,
        input ld_alu_out,
        input [1:0] alu_select_a, alu_select_b,
        input [1:0] alu_op,
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
        if(Reset) begin
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
                a <= OngoingTimer;
        end
    end

    // Output result register
    always@(posedge Clock) begin
        if(Reset) begin
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
            2'd0:
                alu_a = x;
            2'd1:
                alu_a = y;
            2'd2:
                alu_a = z;
            default: alu_a = 8'b0;
        endcase

        case (alu_select_b)
            2'd0:
                alu_b = x;
            2'd1:
                alu_b = y;
            2'd2:
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
    begin: Compare
        if (compareValues == 1'b1 && a == data_result) begin 
            correct <= 1'b1;
            startEq1 <= 1'b0;
        end
        else begin
            correct <= 1'b0; 
        end
    end

endmodule
