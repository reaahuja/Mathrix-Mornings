levitating
levitating4066
ok but did I ask?

curly cat — Today at 12:33 AM
Apparently she was saving a seat for someone but they never showed up
curly cat — Today at 1:10 AM
CRYING Ive been testing the last 40 min trying to debug keyboard, only to find out that this keyboard is just defective
Also I might text you a bunch throughout the night in an attempt to keep my sanity, apologies in advance 😀
curly cat — Today at 5:11 AM
Keyboard sorta works?
curly cat — Today at 6:04 AM
Btw the labs are completely full rn
Do with that info as you wish ✨
curly cat — Today at 7:59 AM
Update waiting for it to compile but I'm pretty sure I got the VGA multiple mifs working
Okay the counter is messed up LMAO
levitating — Today at 10:26 AM
Omg lets go
That is amazing
levitating — Today at 10:27 AM
BRUH WHAT THE HELL
levitating — Today at 10:27 AM
Text me as much as u want ma’am
levitating — Today at 10:27 AM
Woooohooo
levitating — Today at 10:27 AM
Yea I used that info to back to sleep
levitating — Today at 10:27 AM
UR A LEGEND
curly cat — Today at 10:44 AM
Reaaaaaaaa 😭
I spent so
So
Long
Debugging my code 😭
Cuz the image was whack
And finally
It worked
And
The issue
Was that
Over time the image file got corupted somehow
So
I couldn't find issues with my code
Cuz there weren't any 😭
levitating — Today at 10:59 AM
Oh my god 😭
What in the world why is this so annoying sometimes 😭
But
IT WORKS NOW WOOOOOHOOOO
U DID AN AMAZING JOB
so proud of u
levitating — Today at 12:41 PM
Certainly! For multiplication and division by 10 specifically, the algorithms can be tailored to be more efficient than the general approach I previously described. Here are the detailed algorithms:

### Multiplication by 10
Multiplying by 10 can be efficiently achieved by shifting and adding. Since 10 is \(2^3 + 2^1\) in binary, you can perform the operation as follows:

1. **Shift by 3 (Multiply by 8)**: Shift the binary number left by 3 bits. This is equivalent to multiplying the original number by 8.
Expand
message.txt
3 KB
curly cat — Today at 1:35 PM
Okay so idea
Instead of wasting time trying to figure out division and modulo by 10 and 100 when there's so much else to do, I just use the binary signal you send me to generate a pseudo random number
That's only for A of question 1 and 2 
The count down has few enough numbers I can just hard code it
And the matrix questions are pre made anyways
curly cat — Today at 1:38 PM
If we phrase it correctly this could seem like more work than "just outputting the clock"
Thoughts?
curly cat — Today at 2:51 PM
May sleep an extra 20 min or so I'm so sorry 😭
levitating — Today at 2:54 PM
nws take ur time!
levitating — Today at 2:54 PM
I am confusion so lets discuss when u get here
but whatever is easier for u
I am cool w
curly cat — Today at 3:53 PM
/******************************************************************************
 *                                                                            *
 * Module:       Hexadecimal_To_Seven_Segment                                 *
 * Description:                                                               *
 *      This module converts hexadecimal numbers for seven segment displays.  *
 *                                                                            *
Expand
Hexadecimal_To_Seven_Segment.v
4 KB
﻿
/******************************************************************************
 *                                                                            *
 * Module:       Hexadecimal_To_Seven_Segment                                 *
 * Description:                                                               *
 *      This module converts hexadecimal numbers for seven segment displays.  *
 *                                                                            *
 ******************************************************************************/

module Hexadecimal_To_Seven_Segment (
	// Inputs
	hex_number,

	// Bidirectional

	// Outputs
	seven_seg_display
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input		[3:0]	hex_number;

// Bidirectional

// Outputs
output		[6:0]	seven_seg_display;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires

// Internal Registers

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/


/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

assign seven_seg_display =
		({7{(hex_number == 4'h0)}} & 7'b1000000) |
		({7{(hex_number == 4'h1)}} & 7'b1111001) |
		({7{(hex_number == 4'h2)}} & 7'b0100100) |
		({7{(hex_number == 4'h3)}} & 7'b0110000) |
		({7{(hex_number == 4'h4)}} & 7'b0011001) |
		({7{(hex_number == 4'h5)}} & 7'b0010010) |
		({7{(hex_number == 4'h6)}} & 7'b0000010) |
		({7{(hex_number == 4'h7)}} & 7'b1111000) |
		({7{(hex_number == 4'h8)}} & 7'b0000000) |
		({7{(hex_number == 4'h9)}} & 7'b0010000) |
		({7{(hex_number == 4'hA)}} & 7'b0001000) |
		({7{(hex_number == 4'hB)}} & 7'b0000011) |
		({7{(hex_number == 4'hC)}} & 7'b1000110) |
		({7{(hex_number == 4'hD)}} & 7'b0100001) |
		({7{(hex_number == 4'hE)}} & 7'b0000110) |
		({7{(hex_number == 4'hF)}} & 7'b0001110); 

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/


endmodule

Hexadecimal_To_Seven_Segment.v
4 KB
