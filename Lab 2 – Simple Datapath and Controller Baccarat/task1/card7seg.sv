// definition of different cards. 
`define ACE 7'b0001000
`define TWO 7'b0100100
`define THREE 7'b0110000
`define FOUR 7'b0011001
`define FIVE 7'b0010010
`define SIX 7'b0000010
`define SEVEN 7'b1111000
`define EIGHT 7'b0000000
`define NINE 7'b0010000 
`define TEN 7'b1000000
`define JACK 7'b1100001
`define QUEEN 7'b0011000
`define KING 7'b0001001
`define BLANK 7'b1111111

/**
Module for Phase2
Combinational circuit that takes 4 bits input and outputs a 7 bits output.
SW represents a number between 0 and 15 as such:
1 -> ACE
2-10 -> The number itself
11: Jack
12: Queen
13: King
In any other case, the output is BLANK
*/
module card7seg(input [3:0] SW, output [6:0] HEX0);
	reg [6:0] display;
	always @(*) 
		begin
			// Case statements to cover all the cases. 
			case(SW)
				4'b0001: display = `ACE;
				4'b0010: display = `TWO;
				4'b0011: display = `THREE;
				4'b0100: display = `FOUR;
				4'b0101: display = `FIVE;
				4'b0110: display = `SIX;
				4'b0111: display = `SEVEN;
				4'b1000: display = `EIGHT;
				4'b1001: display = `NINE;
				4'b1010: display = `TEN;
				4'b1011: display = `JACK;
				4'b1100: display = `QUEEN;
				4'b1101: display = `KING;
				default: display = `BLANK;
			endcase	
		end
	assign HEX0 = display;	
endmodule

