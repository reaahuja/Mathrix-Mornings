
//top module
module AudioImplementation(
	// Inputs
	CLOCK_50,
	KEY,

	AUD_ADCDAT,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	FPGA_I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	FPGA_I2C_SCLK,
	SW
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				CLOCK_50;
input			KEY;
input			SW;

input				AUD_ADCDAT;

// Bidirectionals
inout				AUD_BCLK;
inout				AUD_ADCLRCK;
inout				AUD_DACLRCK;

inout				FPGA_I2C_SDAT;

// Outputs
output				AUD_XCK;
output				AUD_DACDAT;

output				FPGA_I2C_SCLK;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires
wire				audio_in_available;
wire		[31:0]	left_channel_audio_in;
wire		[31:0]	right_channel_audio_in;
wire				read_audio_in;

wire				audio_out_allowed;
wire		[31:0]	left_channel_audio_out;
wire		[31:0]	right_channel_audio_out;
wire				write_audio_out;

// Internal Registers

reg [18:0] delay_cnt;
wire [18:0] delay;

reg snd;

// State Machine Registers

//Notes
localparam 
C4 =	20'd191113,
D4 =	20'd170262,
E4 =	20'd151686,
F4 =	20'd143173,
G4 =	20'd127553,
A4 =	20'd113636,
B4 =	20'd101238;


/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/
wire enableC4;
wire enableG4;
wire enableA4;
wire enableF4;
wire enableE4;
wire enableD4;

// wire enableC4_2;
// wire enableG4_2;
// wire enableA4_2;
// wire enableF4_2;
// wire enableE4_2;
// wire enableD4_2;

//wire enableTwinkle = SW[0];
wire enableTwinkle = SW;
//wire enableHotCross = SW[1];

wire [3:0] value;

counter c0(CLOCK_50, value);

twinkle twinkleSong(CLOCK_50, Reset, value, enableTwinkle, enableC4, enableG4, enableA4, enableF4, enableE4, enableD4);
//hotCross hotCrossBuns(CLOCK_50, Reset, value, enableHotCross, enableC4_2, enableG4_2, enableA4_2, enableF4_2, enableE4_2, enableD4_2);

wire [31:0] soundC4, soundG4, soundA4, soundF4, soundE4, soundD4;
//wire [31:0] soundC4_2, soundG4_2, soundA4_2, soundF4_2, soundE4_2, soundD4_2;
parameter CLOCK = 50000000;


playSound noteC4(CLOCK_50, soundC4, C4, enableC4);
playSound noteG4(CLOCK_50, soundG4, G4, enableG4);
playSound noteA4(CLOCK_50, soundA4, A4, enableA4);
playSound noteF4(CLOCK_50, soundF4, F4, enableF4);
playSound noteE4(CLOCK_50, soundE4, E4, enableE4);
playSound noteD4(CLOCK_50, soundD4, D4, enableD4);

// playSound noteC4_2(CLOCK_50, soundC4_2, C4, enableC4_2);
// playSound noteG4_2(CLOCK_50, soundG4_2, G4, enableG4_2);
// playSound noteA4_2(CLOCK_50, soundA4_2, A4, enableA4_2);
// playSound noteF4_2(CLOCK_50, soundF4_2, F4, enableF4_2);
// playSound noteE4_2(CLOCK_50, soundE4_2, E4, enableE4_2);
// playSound noteD4_2(CLOCK_50, soundD4_2, D4, enableD4_2);
//play one note after another once it starts working 



// always @(posedge CLOCK_50)
// 	if(delay_cnt == delay) begin
// 		delay_cnt <= 0;
// 		snd <= !snd;
// 	end else delay_cnt <= delay_cnt + 1;

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

// assign delay = {SW[3:0], 15'd3000};

// wire [31:0] sound = (SW == 0) ? 0 : snd ? 32'd10000000 : -32'd10000000;


assign read_audio_in			= audio_in_available & audio_out_allowed;

assign left_channel_audio_out	= left_channel_audio_in + soundC4+soundG4+soundA4+soundF4+soundE4+soundD4; //(enableTwinkle ? soundC4+soundG4+soundA4+soundF4+soundE4+soundD4 : soundC4_2+soundG4_2+soundA4_2+soundF4_2+soundE4_2+soundD4_2);
assign right_channel_audio_out	= right_channel_audio_in + soundC4+soundG4+soundA4+soundF4+soundE4+soundD4; //(enableTwinkle ? soundC4+soundG4+soundA4+soundF4+soundE4+soundD4 : soundC4_2+soundG4_2+soundA4_2+soundF4_2+soundE4_2+soundD4_2);
assign write_audio_out			= audio_in_available & audio_out_allowed;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Audio_Controller Audio_Controller (
	// Inputs
	.CLOCK_50						(CLOCK_50),
	.reset						(~KEY),

	.clear_audio_in_memory		(),
	.read_audio_in				(read_audio_in),
	
	.clear_audio_out_memory		(),
	.left_channel_audio_out		(left_channel_audio_out),
	.right_channel_audio_out	(right_channel_audio_out),
	.write_audio_out			(write_audio_out),

	.AUD_ADCDAT					(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK					(AUD_BCLK),
	.AUD_ADCLRCK				(AUD_ADCLRCK),
	.AUD_DACLRCK				(AUD_DACLRCK),


	// Outputs
	.audio_in_available			(audio_in_available),
	.left_channel_audio_in		(left_channel_audio_in),
	.right_channel_audio_in		(right_channel_audio_in),

	.audio_out_allowed			(audio_out_allowed),

	.AUD_XCK					(AUD_XCK),
	.AUD_DACDAT					(AUD_DACDAT)

);

avconf #(.USE_MIC_INPUT(1)) avc (
	.FPGA_I2C_SCLK					(FPGA_I2C_SCLK),
	.FPGA_I2C_SDAT					(FPGA_I2C_SDAT),
	.CLOCK_50					(CLOCK_50),
	.reset						(~KEY)
);

endmodule

module playSound(CLOCK_50, sound, delay, enable); 
    input CLOCK_50;
    output reg signed [31:0] sound;
    input [19:0] delay;
    input enable;
    reg signed [19:0] delay_cnt;
    reg snd;

    always @(posedge CLOCK_50) begin 
        if (delay_cnt == delay) begin
            delay_cnt <= 0;
            snd <= !snd;
        end else begin
            delay_cnt <= delay_cnt + 1;
        end
    end

    always @(*) begin 
        sound <= (enable) ? (snd ? 32'd10000000 : -32'd10000000) : 0;
    end
endmodule


module counter (
    input clk,  // 50 MHz clock input
    output reg [3:0] value  
);
    parameter one_second_count = 50000000;  
    reg [25:0] second_counter = 26'b0;  // 26-bit counter for 1 second

    initial begin
        value = 0; 
    end

    // Main counter logic
    always @(posedge clk) begin
        if (second_counter >= one_second_count - 1) begin
            second_counter <= 0;  

            if (value == 15) begin
                value <= 0;  // Reset back to 1
            end else begin
                value <= value + 1; 
            end
        end else begin
            second_counter <= second_counter + 1;  
        end
    end
endmodule

module twinkle(input CLOCK_50, input Reset,
               input [3:0] value,
               input Go,
               output reg enableC4, 
               output reg enableG4, 
               output reg enableA4, 
               output reg enableF4, 
               output reg enableE4, 
               output reg enableD4);

    always @(Go or value) begin 
        if(Go) begin 
            if(value >= 4'd0 && value < 4'd2) begin 
                enableC4 = 1'b1;
                // Disable other notes
                enableG4 = 1'b0;
                enableA4 = 1'b0;
                enableF4 = 1'b0;
                enableE4 = 1'b0;
                enableD4 = 1'b0;
            end else if (value >= 4'd2 && value < 4'd4) begin 
                enableG4 = 1'b1;
                // Disable other notes except C4
                enableC4 = 1'b0;
            end else if (value >= 4'd4 && value < 4'd6) begin 
                enableA4 = 1'b1;
                // Disable other notes except G4
                enableG4 = 1'b0;
            end else if (value == 4'd6)begin 
                enableG4 = 1'b1;
                // Disable other notes except A4
                enableA4 = 1'b0;
            end else if (value >= 4'd7 && value < 4'd9)begin 
                enableF4 = 1'b1;
                // Disable other notes except G4
                enableG4 = 1'b0;
            end else if (value >= 4'd9 && value < 4'd11)begin 
                enableE4 = 1'b1;
                // Disable other notes except F4
                enableF4 = 1'b0;
            end else if (value >= 4'd11 && value < 4'd13)begin 
                enableD4 = 1'b1;
                // Disable other notes except E4
                enableE4 = 1'b0;
            end else if (value >= 4'd13 && value < 4'd15)begin 
                enableC4 = 1'b1;
                // Disable other notes except D4
                enableD4 = 1'b0;
            end else begin 
                // Disable all notes
                enableC4 = 1'b0;
                enableG4 = 1'b0;
                enableA4 = 1'b0;
                enableF4 = 1'b0;
                enableE4 = 1'b0;
                enableD4 = 1'b0;
            end
        end else begin 
            enableC4 = 1'b0;
            enableG4 = 1'b0;
            enableA4 = 1'b0;
            enableF4 = 1'b0;
            enableE4 = 1'b0;
            enableD4 = 1'b0;
        end
        end 
endmodule 



module hotCross(input CLOCK_50, input Reset,
               input [3:0] value,
               input Go,
               output reg enableC4, 
               output reg enableG4, 
               output reg enableA4, 
               output reg enableF4, 
               output reg enableE4, 
               output reg enableD4);

    always @(Go or value) begin 
        if(Go) begin 
            if(value == 4'd0) begin 
                enableE4 = 1'b1;
            end else if (value == 4'd1) begin 
                enableD4 = 1'b1;
                enableE4 = 1'b0;
            end else if (value == 4'd2) begin 
                enableC4 = 1'b1;
                enableD4 = 1'b0;
            end else if (value == 4'd3)begin 
                enableG4 = 1'b1;
                enableC4 = 1'b0;
            end else if (value == 4'd4)begin 
                enableF4 = 1'b1;
                enableG4 = 1'b0;
            end else if (value == 4'd5)begin 
                enableE4 = 1'b1;
                enableF4 = 1'b0;
            end else if (value >= 4'd6 && value < 4'd9)begin 
                enableD4 = 1'b1;
                enableE4 = 1'b0;
            end else if (value >= 4'd9 && value < 4'd13)begin 
                enableC4 = 1'b1;
                enableD4 = 1'b0;
            end else begin 
                enableC4 = 1'b0;
                enableG4 = 1'b0;
                enableA4 = 1'b0;
                enableF4 = 1'b0;
                enableE4 = 1'b0;
                enableD4 = 1'b0;
            end
        end else begin 
            enableC4 = 1'b0;
            enableG4 = 1'b0;
            enableA4 = 1'b0;
            enableF4 = 1'b0;
            enableE4 = 1'b0;
            enableD4 = 1'b0;
        end
        end
endmodule



