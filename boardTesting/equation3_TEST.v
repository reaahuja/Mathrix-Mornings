module topLevel(CLOCK_50, KEY, SW, LEDR); 
    input wire CLOCK_50; 
    input wire [1:0] KEY;
    input wire [8:0] SW; 
    output wire [8:0] LEDR;
    //input wire [6:0] EXTRA;

    wire [6:0] testingWire = 7'b0000101; 
    // assign testingWire = 7'b0000001;

    equation3 intiate(.Clock(CLOCK_50), 
                      .Reset(KEY[0]), 
                      .Go(KEY[1]), 
                      .startEq3(SW[8]), 
                      .OngoingTimer(testingWire),
                      .DataIn(SW[7:0]), 
                      .correct(LEDR[0]));
endmodule


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
    wire [2:0] randomNum;
    random r0(Clock, Load, OngoingTimer[2:0], randomNum, initalize); 

    wire forceReset;

    control c0(.Clock(Clock), .Reset(Reset), .Go(Go), .startEq3(startEq3), .DataIn(DataIn),
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
    datapath d0(.Clock(Clock), .Reset(Reset), .Go(Go),
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

module control(input Clock, Reset, Go, startEq3, 
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

module datapath(
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
            endcase
            case(mux_extra)
                1'b0:
                    mux_extra_m = select_b_m;
                1'b1:
                    mux_extra_m = select_a_m;
            endcase
            case(mux_a)
                1'b0:
                    mux_a_m = alu_mini_out;
                1'b1:
                    mux_a_m = select_a_m;
            endcase
            case(mux_b)
                1'b0:
                    mux_b_m = alu_mini_out;
                1'b1:
                    mux_b_m = select_b_m;
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

