/*
Clock: The systems clock 
Reset: The systems active high reset button 
Go: Signal asserted to input value to system 
startEq3: A signal to start the system 
correct: An output signal to determine if the user is correct or not 

-- Initial Draft is of system without user input and checking --
*/
module equation3(Clock, Reset, Go, startEq3, correct);
input Clock, Reset, Go, startEq3;
output correct; 

wire [3:0] data_in;
wire ld_extra, ld_1, ld_2, ld_3, ld_4, ld_5, ld_6;
wire [2:0] select_extra, select_a, select_b; 
wire mux_extra, mux_a, mux_b, initalize; 
wire [1:0] alu_mini, alu_grand;

control c0(.Clock(Clock), .Reset(Reset), .Go(Go), .startEq3(startEq3),
           .ld_extra(ld_extra), .ld_1(ld_1), .ld_2(ld_2), .ld_3(ld_3), .ld_4(ld_4), .ld_5(ld_5), .ld_6(ld_6),
           .select_extra(select_extra), .select_a(select_a), .select_b(select_b),
           .mux_extra(mux_extra), .mux_a(mux_a), .mux_b(mux_b), .initalize(initalize)
           .alu_mini(alu_mini), .alu_grand(alu_grand), 
           .correct(correct)
          );


endmodule

module control(Clock, Reset, Go, startEq3,
               ld_extra, ld_1, ld_2, ld_3, ld_4, ld_5, ld_6, 
               select_extra, select_a, select_b, 
               mux_extra, mux_a, mux_b, initalize
               alu_mini, alu_grand,
               correct
              );
input Clock, Reset, Go, startEq3; 
output reg ld_extra, ld_1, ld_2, ld_3, ld_4, ld_5, ld_6;;
output reg [2:0] select_extra, select_a, select_b; 
output reg mux_extra, mux_a, mux_b, initalize;
output reg [1:0] alu_mini, alu_grand;
output reg correct;

reg [5:0] current_state, next_state;

localparam LoadRegisters = 5'd0,
           Cycle1_prep = 5'd1,
           Cycle1_a = 5'd2,
           Cycle1_b = 5'd3,
           Cycle1_c = 5'd4,
           Cycle2_prep = 5'd5,
           Cycle2_a = 5'd6,
           Cycle2_b = 5'd7,
           Cycle2_c = 5'd8,
           Cycle3_prep = 5'd9,
           Cycle3_a = 5'd10,
           Cycle3_b = 5'd11,
           Cycle3_c = 5'd12,
           Cycle4_prep = 5'd13,
           Cycle4_a = 5'd14,
           Cycle4_b = 5'd15,
           Cycle4_c = 5'd16,
           Done = 5'd17;

//need to add comparison and user input states 
always @(*)
begin: state_table
    case (current_state)
        LoadRegisters: next_state = startEq3 ? Cycle1_prep : LoadRegisters;
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
        Cycle4_c: next_state = Done;
        //Done: next_state = startEq3 ? 
    endcase
end
/* All Signals:
output reg ld_extra, ld_1, ld_2, ld_3, ld_4, ld_5, ld_6;;
output reg [2:0] select_extra, select_a, select_b; 
output reg mux_extra, mux_a, mux_b, initalize; INITALIZE IS ADDED SIGNAL
output reg [1:0] alu_mini, alu_grand;
*/
always @(*):
begin: enable_signals
    ld_extra = 1'b0; ld_1 = 1'b0; ld_2 = 1'b0;  ld_3 = 1'b0; ld_4 = 1'b0; ld_5 = 1'b0; ld_6 = 1'b0;
    select_extra = 3'b0; select_a = 3'b0; select_b = 3'b0; 
    mux_extra = 1'b1; mux_a = 1'b1; mux_b = 1'b1; initalize = 1'b0;
    alu_mini = 2'b0; alu_grand = 2'b0;
    correct = 1'b0;

    case(current_state)
        LoadRegisters: begin 
            initalize = 1'b1;
            ld_1 = 1'b1;
            ld_2 = 1'b1;
            ld_3 = 1'b1;
            ld_4 = 1'b1;
            ld_5 = 1'b1;
            ld_6 = 1'b1;
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

        Done: begin 
            correct = 1'b1;
        end
    endcase
end

always @(posedge Clock)
begin: state_FFS
    if(Reset)
        current_state <= LoadRegisters; 
    else 
        current state <= next_state;
end
endmodule