//Reset and Start will be a switch 
//DataIn will be a set of switches 
//Go is a key 
//HEX0 = output 20-second counter
//Incorrect and SequenceFinish are wires for the VGA 
//FOR TESTING PURPOSES, CHANGE COMPARISON VALUES TO 00000000
module alarmClock(CLOCK_50, SW, KEY, LEDR);
    input CLOCK_50;
    input [9:0] SW;
    input [1:0] KEY;
    output [7:0] LEDR;
    topFSM startAlarm(CLOCK_50, KEY[0], SW[9], SW[7:0], KEY[1], LEDR[7:1], LEDR[0]);
endmodule

module topFSM(Clock, Reset, Start, DataIn, Go, CounterOutput, correct);
    input wire Clock, Reset, Start, Go;
    input wire [7:0] DataIn;  
    output wire [6:0] CounterOutput; //20 second counter
    output wire correct; 

    wire countDone, audioDone, Wrong, Sequencer, startCounter, extra;
    //equations wires 
    wire startEq1, startEq2, startEq3; 
    wire [6:0] CounterValue; //on going counter

    topControl t0(Clock, Reset, Start, Go, DataIn, countDone, audioDone, correct, Wrong, Sequencer, startCounter, startEq1, startEq2, startEq3);
    datapath d0(Reset, startEq1, startEq2, startEq3, correct, Wrong); 

    //topData d0(Clock, Reset, Start, Go, countDone, audioDone, correct, Wrong, Sequencer, DataIn, CounterOutput);

    //counters 
    counter twentyCounter (
    .Clock(Clock),
    .Reset(Reset),
    .Enable(startCounter),
    .mode(1'b1),
    .Timer(CounterOutput), 
    .countDone(countDone)  
    );

    counter onGoingCounter (
    .Clock(Clock),
    .Reset(Reset),
    .Enable(Start),
    .mode(1'b0),
    .Timer(CounterValue), 
    .countDone(extra)  
    );

    equation1 firstEquation(Clock, Reset, Go, CounterValue, DataIn, startEq1, correct);
    equation2 secondEquation(Clock, Reset, Go, CounterValue, DataIn, startEq2, correct);
    equation3 thirdEqation(Clock, Reset, Go, startEq3, CounterValue, DataIn, correct);
    sequencer sequencer(startSequencer, Go, DataIn, Sequencer);

endmodule 

module topControl(
    input Clock, Reset, Start, Go, 
    input [6:0] DataIn,
    input countDone,
    output reg audioDone, correct, Wrong, Sequencer, startCounter,
    output reg startEq1, startEq2, startEq3
    );


   reg[5:0] current_state, next_state; 

   localparam STARTING = 5'd0, 
              COUNTDOWN = 5'd1,
              AUDIO = 5'd2,
              EQUATION_1 = 5'd3,
              EQUATION_2 = 5'd4,
              EQUATION_3 = 5'd5, 
              SEQUENCER = 5'd6, 
              DONE = 5'd7;
   
   always@(*) 
   begin: state_table
      case (current_state) //Syntax, iLoadX ? S_LOAD_X_WAIT : S_LOAD_X; 
            STARTING: next_state = Start ? COUNTDOWN : STARTING;
            COUNTDOWN: next_state = countDone ? AUDIO : COUNTDOWN;
            AUDIO: next_state = audioDone ? EQUATION_1 : AUDIO;
            EQUATION_1: next_state = correct ? EQUATION_2 : EQUATION_1;
            EQUATION_2: next_state = correct ? EQUATION_3 : EQUATION_2;
            EQUATION_3: next_state = correct ? (Wrong ? SEQUENCER : DONE) : EQUATION_3;
            SEQUENCER: next_state = Sequencer ? DONE : SEQUENCER;
            DONE: next_state = Start ? STARTING : DONE; 
         default: next_state = STARTING;
      endcase
   end

   always@(*)
   begin: enable_signals
      audioDone = 1'b0; 
      correct = 1'b0;
      Wrong = 1'b0; 
      Sequencer = 1'b0; 
      startCounter = 1'b0;
      startEq1 = 1'b0;
      startEq2 = 1'b0;
      startEq3 = 1'b0;

      case(current_state) 
        //  STARTING: begin 
        //     //do nothing, user will automatically go countDOWN 
        //  end
         COUNTDOWN: begin 
            startCounter = 1'b1; 
         end
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

module datapath(input Reset, input wire startEq1, input wire startEq2, input wire startEq3, input wire correct, output reg Wrong); 
always @(*) begin 
    if (startEq1 && !correct) begin 
        Wrong = 1'b1;
    end else if (startEq2 && !correct) begin 
        Wrong = 1'b1;
    end else if (startEq3 && !correct) begin 
        Wrong = 1'b1;
    end else if(Reset) begin 
        Wrong = 1'b0;
    end else begin 
        Wrong = 1'b0;
    end
end
endmodule

//HAVE TO CHANGE SO IT GOES EVERY SECOND -- code underneath 
module counter(
    input Clock, 
    input Reset, 
    input Enable, 
    input mode,
    output reg [6:0] Timer,
    output reg countDone
);
    reg [6:0] CounterValue = 7'b0; 

    always @(posedge Clock or posedge Reset) begin
    if (Reset) begin
        CounterValue <= 7'b0;
        countDone <= 1'b0;
    end else if (Enable) begin
        Timer <= CounterValue;
        CounterValue <= CounterValue + 1;
        //CHANGED TO 5 SECONDS FOR TESTING 
        if(CounterValue == 7'b0000101 && mode != 1'b0) begin
            Timer <= 7'b0;
            countDone <= 1'b1;
        end 
    end
end
endmodule

/*
module counter(
    input Clock, 
    input Reset, 
    input Enable, 
    input mode,
    output reg [6:0] Timer,
    output reg countDone
);

    parameter clockTiming = 50000000;
    reg [25:0] oneSecondCounter = 26'b0;

    reg [6:0] CounterValue = 7'b0; 

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            CounterValue <= 7'b0;
            oneSecondCounter <= 26'b0;
            countDone <= 1'b0;
        end else if (Enable) begin
            // Increment the oneSecondCounter each clock cycle
            if (oneSecondCounter < clockTiming - 1) begin
                oneSecondCounter <= oneSecondCounter + 1;
            end else begin
                // Once oneSecondCounter reaches clockTiming, reset it and increment CounterValue
                oneSecondCounter <= 26'b0;
                Timer <= CounterValue;
                CounterValue <= CounterValue + 1;
                
                if(CounterValue == 7'b0010100 && mode != 1'b0) begin
                    Timer <= 7'b0;
                    countDone <= 1'b1;
                end
            end
        end
    end
endmodule

*/

