//Reset and Start will be a switch 
//DataIn will be a set of switches 
//Go is a key 
//HEX0 = output 20-second counter
//Incorrect and SequenceFinish are wires for the VGA 
module topFSM(Clock, Reset, Start, DataIn, Go, CounterOutput);
    input wire Clock, Reset, Start, Go;
    input wire [6:0] DataIn;  
    output wire [6:0] CounterOutput; 

    wire countDone, audioDone, correct, Wrong, Sequencer, startCounter; 
    wire [6:0] CounterValue;

    topControl t0(Clock, Reset, Start, Go, DataIn, countDone, audioDone, correct, Wrong, Sequencer, startCounter);
    //topData d0(Clock, Reset, Start, Go, countDone, audioDone, correct, Wrong, Sequencer, DataIn, CounterOutput);

    //counters 
    //counter twentyCounter(Clock, Reset, startCounter, CounterOutput, countDone);

    counter twentyCounter (
    .Clock(Clock),
    .Reset(Reset),
    .Enable(startCounter),
    .Timer(CounterOutput), // Assuming CounterOutput is meant to show the Timer value
    .countDone(countDone)  // This should be the same signal as in topFSM
    );

    //counter onGoing(Clock, Reset, Start, CounterValue, countDone);
endmodule 

module topControl(
    input Clock, Reset, Start, Go, 
    input [6:0] DataIn,
    input countDone,
    output reg audioDone, correct, Wrong, Sequencer, startCounter
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
         end
         EQUATION_2: begin
         end
         EQUATION_3: begin
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



module counter(
    input Clock, 
    input Reset, 
    input Enable, 
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
        
        if(CounterValue == 7'b0010100) begin
            Timer <= 7'b0;
            countDone <= 1'b1;
        end 
    end
end
endmodule

