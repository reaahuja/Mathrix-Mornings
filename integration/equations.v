//Reset and Start will be a switch 
//DataIn will be a set of switches 
//Go is a key 
//HEX0 = output 20-second counter
//Incorrect and SequenceFinish are wires for the VGA 
//FOR TESTING PURPOSES, CHANGE COMPARISON VALUES TO 00000000
//INVERTED KEYS, HARDCODED COUNTERVALUE AND (FUTURE) USE DIFFERENT LEDS FOR CORRECT IN DIFFERENT MODULES
module alarmCode(CLOCK_50, SW, KEY, LEDR, AUD_ADCDAT, AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK, FPGA_I2C_SDAT, AUD_XCK, AUD_DACDAT, FPGA_I2C_SCLK);
    input wire CLOCK_50;
    input wire [9:0] SW;
    input wire [1:0] KEY;
    output wire [7:0] LEDR;

	input AUD_ADCDAT;
	inout	AUD_BCLK;
	inout	AUD_ADCLRCK;
	inout	AUD_DACLRCK;
	inout	FPGA_I2C_SDAT;

	output AUD_XCK;
	output AUD_DACDAT;
	output FPGA_I2C_SCLK;
	
    topFSM startAlarm(.Clock(CLOCK_50), .Reset(~KEY[0]), .Start(SW[9]), .DataIn(SW[7:0]), .Go(~KEY[1]), .correct(LEDR[2:0]), .AUD_ADCDAT(AUD_ADCDAT), .AUD_BCLK(AUD_BCLK), .AUD_ADCLRCK(AUD_ADCLRCK), .AUD_DACLRCK(AUD_DACLRCK), .FPGA_I2C_SDAT(FPGA_I2C_SDAT), .AUD_XCK(AUD_XCK), .AUD_DACDAT(AUD_DACDAT), .FPGA_I2C_SCLK(FPGA_I2C_SCLK));
endmodule

module topFSM(Clock, Reset, Start, DataIn, Go, correct, AUD_ADCDAT, AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK, FPGA_I2C_SDAT, AUD_XCK, AUD_DACDAT, FPGA_I2C_SCLK);
    input wire Clock, Reset, Start, Go;
    input wire [7:0] DataIn;  
    output wire [2:0] correct; 

    wire audioDone, Wrong, Sequencer, startCounter, extra;
    //equations wires 
    wire startEq1, startEq2, startEq3; 
    wire [6:0] CounterValue = 7'b0000001; //on going counter
	 
	 input AUD_ADCDAT;
	inout	AUD_BCLK;
	inout	AUD_ADCLRCK;
	inout	AUD_DACLRCK;
	inout	FPGA_I2C_SDAT;

	output AUD_XCK;
	output AUD_DACDAT;
	output FPGA_I2C_SCLK;

    topControl t0(Clock, Reset, Start, Go, correct[0], correct[1], correct[2], Wrong, audioDone, Sequencer, startCounter, startEq1, startEq2, startEq3);
    topDatapath d0(Clock, Reset, startEq1, startEq2, startEq3, correct[0], correct[1], correct[2], Wrong); 

    equation1 firstEquation(Clock, Reset, Go, CounterValue, DataIn, startEq1, correct[0]);
    equation2 secondEquation(Clock, Reset, Go, CounterValue, DataIn, startEq2, correct[1]);
    equation3 thirdEqation(Clock, Reset, Go, startEq3, CounterValue, DataIn, correct[2]);
    //equation3 thirdEqation(Clock, Reset, Go, startEq3, CounterValue, DataIn, correct);
	 
	 DE1_SoC_Audio_Example audio (Clock, Reset, AUD_ADCDAT, AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK, FPGA_I2C_SDAT, AUD_XCK, AUD_DACDAT, FPGA_I2C_SCLK, audioDone);

endmodule 
//if correct[0].. doesn't work then send each individual bit of correct as a signal top Topcontrol and check 
module topControl(
    input wire Clock, Reset, Start, Go, correct0, correct1, correct2, Wrong,
    output reg audioDone, Sequencer, startCounter,
    output reg startEq1, startEq2, startEq3
    );


   reg[5:0] current_state, next_state; 

   localparam STARTING = 5'd0, 
              AUDIO = 5'd1,
              EQUATION_1 = 5'd2,
              EQUATION_2 = 5'd3,
              EQUATION_3 = 5'd4, 
              SEQUENCER = 5'd5, 
              DONE = 5'd6;
   
   always@(*) 
   begin: state_table
      case (current_state) //Syntax, iLoadX ? S_LOAD_X_WAIT : S_LOAD_X; 
            STARTING: next_state = Start ? AUDIO : STARTING;
            AUDIO: next_state = EQUATION_1;
            EQUATION_1: next_state = (correct0) ? EQUATION_2 : EQUATION_1;
            EQUATION_2: next_state = (correct1) ? EQUATION_3 : EQUATION_2;
            EQUATION_3: next_state = (correct2) ? (Wrong ? SEQUENCER : DONE) : EQUATION_3;
            SEQUENCER: next_state = Sequencer ? DONE : SEQUENCER;
            DONE: next_state = Start ? STARTING : DONE; 
         default: next_state = STARTING;
      endcase
   end

   always@(*)
   begin: enable_signals
      audioDone = 1'b0; 
      Sequencer = 1'b0; 
      startCounter = 1'b0;
      startEq1 = 1'b0;
      startEq2 = 1'b0;
      startEq3 = 1'b0;

      case(current_state) 
        //  STARTING: begin 
        //     //do nothing, user will automatically go countDOWN 
        //  end
         AUDIO: begin
            //TEMPORARY
            audioDone = 1'b1;
         end
         EQUATION_1: begin
            startEq1 = 1'b1; //signal for FSM to start -- turns low inside FSM to disable it
         end
         EQUATION_2: begin
            startEq2 = 1'b1;
         end
         EQUATION_3: begin
            startEq3 = 1'b1;
         end
         SEQUENCER: begin
         end
         DONE: begin
         end
      endcase
   end

   always@(posedge Clock)
    begin: state_FFs
        if(Reset)
            current_state <= STARTING;
        else
            current_state <= next_state;
    end 

endmodule

//changed wrong, due to three bits in correct 
module topDatapath(input wire Clock, input wire Reset, input wire startEq1, input wire startEq2, input wire startEq3, input wire correct0, input wire correct1, input wire correct2, output reg Wrong); 
always @(correct0, correct1, correct2) begin 
    if (startEq1 && !correct0) begin 
        Wrong = 1'b1;
    end else if (startEq2 && !correct1) begin 
        Wrong = 1'b1;
    end else if (startEq3 && !correct2) begin 
        Wrong = 1'b1;
    end else if(Reset) begin 
        Wrong = 1'b0;
    end else begin 
        Wrong = 1'b0;
    end
end
endmodule



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
    input wire Clock;
    input wire Reset;
    input wire Go;
    input wire [6:0] OngoingTimer;
    input wire [7:0] DataIn;
    input wire startEq1;
    output wire correct;

    // lots of wires to connect our datapath and control
    wire ld_x, ld_y, ld_z, ld_a, ld_r;
    wire ld_alu_out;
    wire [1:0]  alu_select_a, alu_select_b;
    wire [1:0] alu_op;
    wire [7:0] DataResult;
    wire compareValues, turnOff, forceReset; 

    control_eq1 C0_eq1(
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
        compareValues, turnOff, forceReset
    );

    datapath_eq1 D0_eq1(
        Clock, Reset, Go,
        OngoingTimer,
        DataIn, 
        compareValues, turnOff,
        ld_x, ld_y, ld_z, ld_a, ld_r,
        ld_alu_out,
        alu_select_a, alu_select_b,
        alu_op,
        forceReset,
        correct, 
        DataResult
    );


 endmodule

module control_eq1(
        input wire Clock, Reset, go, 
        input wire [6:0] OngoingTimer, 
        input wire [7:0] DataIn, 
        input wire correct,
        input wire startEq1,
        output reg ld_x, ld_y, ld_z, ld_a, ld_r,
        output reg ld_alu_out,
        output reg [1:0] alu_select_a, alu_select_b,
        output reg [1:0] alu_op,
        output reg compareValues, turnOff, forceReset
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
                COMPARE: next_state = COMPLETE; // we will be done our two operations, start over after
                COMPLETE: next_state = correct? COMPLETE : resetSystem;
                resetSystem: next_state = getA;
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
        alu_op       = 2'b0;
        compareValues = 1'b0; 
        turnOff = 1'b0;
        forceReset = 1'b0;

        case (current_state)
            getA: begin
                forceReset = 1'b0;
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
            CYCLE_0: begin // Do X/Z in X
                alu_select_a = 2'b00;
                alu_select_b = 2'b10;
                alu_op = 2'b10;
                ld_alu_out = 1'b1; ld_x = 1'b1;
            end
            CYCLE_1: begin // Do (X/Z) * (X/Z) in X
                alu_select_a = 2'b00;
                alu_select_b = 2'b00;
                alu_op = 2'b01;
                ld_alu_out = 1'b1; ld_x = 1'b1;
            end
            CYCLE_2: begin // Do Y/Z in Y
                alu_select_a = 2'b01; 
                alu_select_b = 2'b10;
                alu_op = 2'b10;
                ld_alu_out = 1'b1; ld_y = 1'b1;
            end
            CYCLE_3: begin // Do Y/Z + (X/Z)^2 in R
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


module datapath_eq1(
        input wire Clock, Reset, Go, 
        input wire [6:0] OngoingTimer, 
        input wire [7:0] DataIn, 
        input wire compareValues, turnOff, 
        input wire ld_x, ld_y, ld_z, ld_a, ld_r,
        input wire ld_alu_out,
        input wire [1:0] alu_select_a, alu_select_b,
        input wire [1:0] alu_op,
        input wire forceReset,
        output reg correct,
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
        if (compareValues == 1'b1 && a == data_result) begin 
            correct <= 1'b1;
        end
        else if (a != data_result)begin
            correct <= 1'b0; 
        end
    end

endmodule

//Second equation 
/*
Clock: System's clock
Reset: Active High reset 
Go: Signal asserted to input value to system 
OngoingTimer: The current time in the system 
DataIn: The value for the different variables 
startEq2: Queue to start FSM
correct: Determining whether the input was correct or not 
*/

module equation2(Clock, Reset, Go, OngoingTimer, DataIn, startEq2, correct);
    input wire Clock;
    input wire Reset;
    input wire Go;
    input wire [6:0] OngoingTimer;
    input wire [7:0] DataIn;
    input wire startEq2;
    output wire correct;

    // lots of wires to connect our datapath and control
    wire ld_x, ld_y, ld_z, ld_a, ld_r;
    wire ld_alu_out;
    wire [1:0]  alu_select_a, alu_select_b;
    wire [1:0] alu_op;
    wire [7:0] DataResult;
    wire compareValues, turnOff, forceReset; 

    control_eq2 C0_eq2(
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

    datapath_eq2 D0_eq2(
        Clock, Reset, Go,
        OngoingTimer,
        DataIn, 
        compareValues, turnOff,
        ld_x, ld_y, ld_z, ld_a, ld_r,
        ld_alu_out,
        alu_select_a, alu_select_b,
        alu_op,
        forceReset,
        correct, 
        DataResult
    );


 endmodule

module control_eq2(
        input wire Clock, Reset, go, 
        input wire [6:0] OngoingTimer, 
        input wire [7:0] DataIn, 
        input wire correct,
        input wire startEq2,
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


module datapath_eq2(
        input wire Clock, Reset, Go, 
        input wire [6:0] OngoingTimer, 
        input wire [7:0] DataIn, 
        input wire compareValues, turnOff, 
        input wire ld_x, ld_y, ld_z, ld_a, ld_r,
        input wire ld_alu_out,
        input wire [1:0] alu_select_a, alu_select_b,
        input wire [1:0] alu_op,
        input wire forceReset,
        output reg correct,
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
        end
        else if (a != data_result)begin
            correct <= 1'b0; 
        end
    end

endmodule

//SIGNAL FOR VGA TO DETERMINE IF OUTPUT IS WRONG OR NOT 

//Equation 3
module equation3(Clock, Reset, Go, startEq3, OngoingTimer, DataIn, correct);
    input wire Clock, Reset, Go, startEq3;
    input wire [6:0] OngoingTimer;
    input wire [7:0] DataIn;
    output wire correct; 

    wire ld_extra, ld_1, ld_2, ld_3, ld_4, ld_5, ld_6;
    wire [2:0] select_extra, select_a, select_b; 
    wire mux_extra, mux_a, mux_b, initalize; 
    wire [1:0] alu_mini, alu_grand;

    wire startCompare;
    wire [7:0] xInput, yInput;

    wire Load; 
    //wire [2:0] randomNum; 
    wire [2:0] randomNum = 3'b111;
    //random r0(Clock, Load, OngoingTimer[2:0], randomNum, initalize); 

    wire forceReset;

    control_eq3 c0_eq3(.Clock(Clock), .Reset(Reset), .Go(Go), .startEq3(startEq3), .DataIn(DataIn),
            .correct(correct),
            .ld_extra(ld_extra), .ld_1(ld_1), .ld_2(ld_2), .ld_3(ld_3), .ld_4(ld_4), .ld_5(ld_5), .ld_6(ld_6),
            .select_extra(select_extra), .select_a(select_a), .select_b(select_b),
            .mux_extra(mux_extra), .mux_a(mux_a), .mux_b(mux_b), .initalize(initalize),
            .alu_mini(alu_mini), .alu_grand(alu_grand), 
            .Load(Load), 
            .xInput(xInput), .yInput(yInput), 
            .startCompare(startCompare), 
            .forceReset(forceReset)
            );
    datapath_eq3 d0_eq3(.Clock(Clock), .Reset(Reset), .Go(Go),
            .ld_extra(ld_extra), .ld_1(ld_1), .ld_2(ld_2), .ld_3(ld_3), .ld_4(ld_4), .ld_5(ld_5), .ld_6(ld_6),
            .select_extra(select_extra), .select_a(select_a), .select_b(select_b),
            .mux_extra(mux_extra), .mux_a(mux_a), .mux_b(mux_b), .initalize(initalize),
            .alu_mini(alu_mini), .alu_grand(alu_grand), 
            .randomNum(randomNum),
            .startCompare(startCompare),
            .forceReset(forceReset),
            .xInput(xInput), .yInput(yInput),
            .correct(correct)
            );

endmodule

module control_eq3(input Clock, Reset, Go, startEq3, 
               input correct,
               input [7:0] DataIn,
               output reg ld_extra, ld_1, ld_2, ld_3, ld_4, ld_5, ld_6, 
               output reg [2:0] select_extra, select_a, select_b, 
               output reg mux_extra, mux_a, mux_b, initalize,
               output reg [1:0] alu_mini, alu_grand,
               output reg Load,
               output reg [7:0] xInput, yInput,
               output reg startCompare, 
               output reg forceReset
              );

reg [5:0] current_state, next_state;

localparam  getRandom = 5'd0,
            getRandom_wait = 5'd1,
            LoadRegisters = 5'd2,
            getX = 5'd3,
            getX_wait = 5'd4,
            getY = 5'd5,
            getY_wait = 5'd6,
            Cycle1_prep = 5'd7,
            Cycle1_a = 5'd8,
            Cycle1_b = 5'd9,
            Cycle1_c = 5'd10,
            Cycle2_prep = 5'd11,
            Cycle2_a = 5'd12,
            Cycle2_b = 5'd13,
            Cycle2_c = 5'd14,
            Cycle3_prep = 5'd15,
            Cycle3_a = 5'd16,
            Cycle3_b = 5'd17,
            Cycle3_c = 5'd18,
            Cycle4_prep = 5'd19,
            Cycle4_a = 5'd20,
            Cycle4_b = 5'd21,
            Cycle4_c = 5'd22,
            Compare = 5'd23,
            Done = 5'd24, 
            resetSystem = 5'd25;


//need to add comparison and user input states 
always @(*)
begin: state_table
    case (current_state)
        getRandom:  next_state = startEq3 ? getRandom_wait : getRandom;
        getRandom_wait: next_state = LoadRegisters;
        LoadRegisters: next_state = getX;
        getX: next_state = Go ? getX_wait : getX;
        getX_wait: next_state = Go ? getX_wait : getY;
        getY: next_state = Go ? getY_wait : getY;
        getY_wait: next_state = Go ? getY_wait : Cycle1_prep;
        Cycle1_prep: next_state = Cycle1_a;
        Cycle1_a: next_state = Cycle1_b;
        Cycle1_b: next_state = Cycle1_c;
        Cycle1_c: next_state = Cycle2_prep;
        Cycle2_prep: next_state = Cycle2_a;
        Cycle2_a: next_state = Cycle2_b;
        Cycle2_b: next_state = Cycle2_c;
        Cycle2_c: next_state = Cycle3_prep;
        Cycle3_prep: next_state = Cycle3_a;
        Cycle3_a: next_state = Cycle3_b;
        Cycle3_b: next_state = Cycle3_c;
        Cycle3_c: next_state = Cycle4_prep;
        Cycle4_prep: next_state = Cycle4_a;
        Cycle4_a: next_state = Cycle4_b;
        Cycle4_b: next_state = Cycle4_c;
        Cycle4_c: next_state = Compare;
        Compare: next_state = Done;
        Done: next_state = correct ? Done : resetSystem; 
        resetSystem: next_state = getRandom;
    endcase
end
/* All Signals:
output reg ld_extra, ld_1, ld_2, ld_3, ld_4, ld_5, ld_6;;
output reg [2:0] select_extra, select_a, select_b; 
output reg mux_extra, mux_a, mux_b, initalize; INITALIZE IS ADDED SIGNAL
output reg [1:0] alu_mini, alu_grand;
*/
always @(*)
begin: enable_signals
    ld_extra = 1'b0; ld_1 = 1'b0; ld_2 = 1'b0;  ld_3 = 1'b0; ld_4 = 1'b0; ld_5 = 1'b0; ld_6 = 1'b0;
    select_extra = 3'b0; select_a = 3'b0; select_b = 3'b0; 
    mux_extra = 1'b1; mux_a = 1'b1; mux_b = 1'b1; initalize = 1'b0;
    alu_mini = 2'b0; alu_grand = 2'b0;
    //Load = 1'b0; //put seed 
    startCompare = 1'b0;
    forceReset = 1'b0;

    case(current_state)
    
        getRandom: begin 
            Load = 1'b1;
        end

        getRandom_wait: begin 
            Load = 1'b0;
        end
    
        LoadRegisters: begin 
            initalize = 1'b1;
        end

        getX: begin 
            xInput = DataIn;
        end

        getY: begin 
            yInput = DataIn;
        end

        Cycle1_prep: begin
            ld_extra = 1'b1;
            select_extra = 3'd1;
        end
        Cycle1_a: begin 
            select_b = 3'd1;
            select_a = 3'd0;
            mux_a = 1'b1;
            mux_b = 1'b1;
            alu_grand = 2'b11;
            ld_1 = 1'b1;
        end
        Cycle1_b: begin
            select_b = 3'd2;
            select_a = 3'd0;
            mux_a = 1'b1;
            mux_b = 1'b1;
            alu_grand = 2'b11;
            ld_2 = 1'b1;
        end
        Cycle1_c: begin
            select_b = 3'd3;
            select_a = 3'd0;
            mux_a = 1'b1;
            mux_b = 1'b1;
            alu_grand = 2'b11;
            ld_3 = 1'b1;
        end

        Cycle2_prep: begin
            ld_extra = 1'b1;
            select_extra = 3'd4;
        end
        Cycle2_a: begin 
            select_a = 3'd1;
            mux_extra = 1'b1;
            alu_mini = 2'b10;
            mux_a = 1'b0;
            select_b = 3'd4;
            mux_b = 1'b1;
            alu_grand = 2'b01;
            ld_4 = 1'b1;
        end
        Cycle2_b: begin
            select_a = 3'd2;
            mux_extra = 1'b1;
            alu_mini = 2'b10;
            mux_a = 1'b0;
            select_b = 3'd5;
            mux_b = 1'b1;
            alu_grand = 2'b01;
            ld_5 = 1'b1;
        end
        Cycle2_c: begin
            select_a = 3'd3;
            mux_extra = 1'b1;
            alu_mini = 2'b10;
            mux_a = 1'b0;
            select_b = 3'd6;
            mux_b = 1'b1;
            alu_grand = 2'b01;
            ld_6 = 1'b1;
        end

        Cycle3_prep: begin
            ld_extra = 1'b1;
            select_extra = 3'd5;
        end
        Cycle3_a: begin 
            select_a = 3'd0;
            mux_a = 1'b1;
            select_b = 3'd4;
            mux_b = 1'b1;
            alu_grand = 2'b11;
            ld_4 = 1'b1;
        end
        Cycle3_b: begin
            select_a = 3'd0;
            mux_a = 1'b1;
            select_b = 3'd5;
            mux_b = 1'b1;
            alu_grand = 2'b11;
            ld_5 = 1'b1;
        end
        Cycle3_c: begin
            select_a = 3'd0;
            mux_a = 1'b1;
            select_b = 3'd6;
            mux_b = 1'b1;
            alu_grand = 2'b11;
            ld_6 = 1'b1;
        end

        Cycle4_prep: begin
            ld_extra = 1'b1;
            select_extra = 3'd2;
        end
        Cycle4_a: begin 
            select_a = 3'd1;
            mux_a = 1'b1;
            select_b = 3'd4;
            mux_extra = 1'b0;
            alu_mini = 2'b10;
            mux_b = 1'b0;
            alu_grand = 2'b01;
            ld_1 = 1'b1;
        end
        Cycle4_b: begin
            select_a = 3'd2;
            mux_a = 1'b1;
            select_b = 3'd5;
            mux_extra = 1'b0;
            alu_mini = 2'b10;
            mux_b = 1'b0;
            alu_grand = 2'b01;
            ld_2 = 1'b1;
        end
        Cycle4_c: begin
            select_a = 3'd3;
            mux_a = 1'b1;
            select_b = 3'd6;
            mux_extra = 1'b0;
            alu_mini = 2'b10;
            mux_b = 1'b0;
            alu_grand = 2'b01;
            ld_3 = 1'b1;
        end

        Compare: begin 
            startCompare = 1'b1;
        end

        // Done: begin 
        //     correct = 1'b1;
        // end

        resetSystem: begin 
            forceReset = 1'b1;
        end
    endcase
end

    always @(posedge Clock)
    begin: state_FFS
        if(Reset || forceReset)
            current_state <= getRandom; 
        else 
            current_state <= next_state;
    end

endmodule

module datapath_eq3(
               input Clock, Reset, Go,
               input ld_extra, ld_1, ld_2, ld_3, ld_4, ld_5, ld_6, 
               input [2:0] select_extra, select_a, select_b, 
               input mux_extra, mux_a, mux_b, initalize,
               input [1:0] alu_mini, alu_grand,
               input [2:0] randomNum,
               input startCompare,
               input forceReset,
               input [7:0] xInput, yInput,
               output reg correct
              );
        //registers
        reg [7:0] regExtra, reg1, reg2, reg3, reg4, reg5, reg6;
        //muxes
        reg [7:0] select_a_m, select_b_m, mux_extra_m, mux_a_m, mux_b_m;
        //alus
        reg [7:0] alu_mini_out, alu_grand_out; 

        //registers logic (and select_extra logic)
        always @(posedge Clock) begin 
            if (Reset || forceReset) begin 
                regExtra <= 8'b0;
                reg1 <= 8'b0;
                reg2 <= 8'b0;
                reg3 <= 8'b0;
                reg4 <= 8'b0;
                reg5 <= 8'b0;
                reg6 <= 8'b0;
            end
            else if (initalize == 1'b1)begin //not working properly, random number initalizes afterwards
                if (randomNum == 3'b000 || randomNum == 3'b001) begin 
                    reg1 <= 8'd2;
                    reg2 <= 8'd2;
                    reg3 <= 8'd10;
                    reg4 <= 8'd1;
                    reg5 <= 8'd4;
                    reg6 <= 8'd8;
                end else if (randomNum == 3'b010 || randomNum == 3'b011) begin
                    reg1 <= 8'd2;
                    reg2 <= 8'd5;
                    reg3 <= 8'd14;
                    reg4 <= 8'd3;
                    reg5 <= 8'd24;
                    reg6 <= 8'd21;
                end else if (randomNum == 3'b100 || randomNum == 3'b101) begin 
                    reg1 <= 8'd2;
                    reg2 <= 8'd2;
                    reg3 <= 8'd12;
                    reg4 <= 8'd2;
                    reg5 <= 8'd6;
                    reg6 <= 8'd24;
                end else if (randomNum == 3'b110) begin 
                    reg1 <= 8'd8;
                    reg2 <= 8'd3;
                    reg3 <= 8'd6;
                    reg4 <= 8'd3;
                    reg5 <= 8'd2;
                    reg6 <= 8'd4;
                end else begin 
                    reg1 <= 8'd7;
                    reg2 <= 8'd2;
                    reg3 <= 8'd2;
                    reg4 <= 8'd1;
                    reg5 <= 8'd9;
                    reg6 <= 8'd9;
                end 
            end
            else if(ld_extra == 1'b1) begin 
                if(select_extra == 3'd0)
                    regExtra <= alu_grand_out;
                if(select_extra == 3'd1)
                    regExtra <= reg1;
                if(select_extra == 3'd2)
                    regExtra <= reg2;
                if(select_extra == 3'd3)
                    regExtra <= reg3;
                if(select_extra == 3'd4)
                    regExtra <= reg4;
                if(select_extra == 3'd5)
                    regExtra <= reg5;
                if(select_extra == 3'd6)
                    regExtra <= reg6;
            end
            else begin 
                if(ld_1)
                    reg1 <= alu_grand_out;
                if(ld_2)
                    reg2 <= alu_grand_out;
                if(ld_3)
                    reg3 <= alu_grand_out;
                if(ld_4)
                    reg4 <= alu_grand_out;
                if(ld_5)
                    reg5 <= alu_grand_out;
                if(ld_6)
                    reg6 <= alu_grand_out;
            end
        end

        //MUXES
        always @(*)
        begin
            case(select_a)
                3'd0:
                    select_a_m = regExtra;
                3'd1:
                    select_a_m = reg1;
                3'd2:
                    select_a_m = reg2;
                3'd3:
                    select_a_m = reg3;
                3'd4:
                    select_a_m = reg4;
                3'd5:
                    select_a_m = reg5;
                3'd6:
                    select_a_m = reg6;
                default: select_a_m = 8'b0;
            endcase
            case(select_b)
                3'd0:
                    select_b_m = regExtra;
                3'd1:
                    select_b_m = reg1;
                3'd2:
                    select_b_m = reg2;
                3'd3:
                    select_b_m = reg3;
                3'd4:
                    select_b_m = reg4;
                3'd5:
                    select_b_m = reg5;
                3'd6:
                    select_b_m = reg6;
                default: select_b_m = 8'b0;
            endcase
            case(mux_extra)
                1'b0:
                    mux_extra_m = select_b_m;
                1'b1:
                    mux_extra_m = select_a_m;
                default: mux_extra_m = 8'b0;
            endcase
            case(mux_a)
                1'b0:
                    mux_a_m = alu_mini_out;
                1'b1:
                    mux_a_m = select_a_m;
                default: mux_a_m = 8'b0;
            endcase
            case(mux_b)
                1'b0:
                    mux_b_m = alu_mini_out;
                1'b1:
                    mux_b_m = select_b_m;
                default: mux_b_m = 8'b0;
            endcase
        end
        //ALUS
        always @(*)
        begin 
            case(alu_mini)
                2'b00:
                    alu_mini_out = regExtra + mux_extra_m;
                2'b01:
                    alu_mini_out = regExtra - mux_extra_m;
                2'b10: //only operation being used 
                    alu_mini_out = regExtra * mux_extra_m;
                2'b11:
                    alu_mini_out = regExtra / mux_extra_m;
                default: alu_mini_out = 8'b0;
            endcase
        end

        always @(*)
        begin 
            case(alu_grand)
                2'b00:
                    alu_grand_out = mux_a_m + mux_b_m;
                2'b01: begin //used
                    if (mux_a == 1'b1 && mux_b == 1'b0) begin
                        alu_grand_out = mux_a_m - mux_b_m;
                    end else begin
                        alu_grand_out = mux_b_m - mux_a_m;
                    end
                end
                2'b10:
                    alu_grand_out = mux_a_m * mux_b_m;
                2'b11: begin //used
                    alu_grand_out = mux_b_m / mux_a_m;
                end
                default: alu_grand_out = 8'b0;
            endcase
        end

        //comparison 
        always @(*)
        begin: COMPARE
            if (xInput == reg3 && yInput == reg6) begin 
                correct <= 1'b1;
            end
            else begin
                correct <= 1'b0; 
            end
        end
endmodule


module random(Clock, Load, Seed, randomNum, initalize);
    input Clock, Load, initalize;
    input [2:0] Seed; 
    output reg [2:0] randomNum;
    
    always @(*)
        if(Load) begin 
            if (Seed != 3'b0) 
                randomNum <= Seed;
            else
                randomNum <= 3'b1;
        end else if (initalize == 1'b1) begin 
            randomNum[0] = randomNum[2]; 
            //$display ("Random[0] = %b, Random[2] = %b", randomNum[0], randomNum[2]);
            randomNum[1] = randomNum[1] ^ randomNum[2]; 
            //$display ("Random[1] = %b", randomNum[1]);
            randomNum[2] = randomNum[1]; 
            //$display ("Random[2] = %b", randomNum[2]);
        end
endmodule
