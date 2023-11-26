//top module
module DE1_SoC_Audio_Example (
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
input		[3:0]	KEY;
input		[3:0]	SW;

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

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/
wire enable = SW[0];
wire [31:0] sound1, sound2, sound3, sound4, sound5;

parameter C4 = CLOCK_50/262; 
//parameter C4 = CLOCK_50/(2*261); 
parameter D5 = CLOCK_50/587;
//parameter D5 = ClOCK_50/(2*587);
parameter E5 = CLOCK_50/659;
//parameter E5 = CLOCK_50/(2*659);

//play one note after another once it starts working 
playSound note1(CLOCK_50, sound1, C4, enable); 
playSound note2(CLOCK_50, sound2, D5, enable);
playSound note3(CLOCK_50, sound3, E5, enable);
playSound note4(CLOCK_50, sound4, D5, enable);
playSound note5(CLOCK_50, sound5, C5, enable);


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

assign left_channel_audio_out	= left_channel_audio_in+sound1+sound2+sound3+sound4+sound5;
assign right_channel_audio_out	= right_channel_audio_in+sound1+sound2+sound3+sound4+sound5;
assign write_audio_out			= audio_in_available & audio_out_allowed;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Audio_Controller Audio_Controller (
	// Inputs
	.CLOCK_50						(CLOCK_50),
	.reset						(~KEY[0]),

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
	.reset						(~KEY[0])
);

endmodule

module playSound(CLOCK_50, sound, delay, enable); 
    input CLOCK_50;
    output reg signed [31:0] sound;
    input [20:0] delay;
    input enable;
    reg signed [20:0] delay_cnt;
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


module counter_1_to_3 (
    input clk,  // 50 MHz clock input
    output reg [1:0] value  // Output value (2 bits to represent values 1 to 3)
);
    // Parameters for counting
    parameter one_second_count = 50000000;  // 50 million for 1 second
    reg [25:0] second_counter = 26'b0;  // 26-bit counter for 1 second

    // Initialization
    initial begin
        value = 1;  // Start with value 1
    end

    // Main counter logic
    always @(posedge clk) begin
        if (second_counter >= one_second_count - 1) begin
            second_counter <= 0;  // Reset second counter

            // Increment value counter
            if (value == 3) begin
                value <= 1;  // Reset back to 1
            end else begin
                value <= value + 1;  // Increment value
            end
        end else begin
            second_counter <= second_counter + 1;  // Increment second counter
        end
    end
endmodule


