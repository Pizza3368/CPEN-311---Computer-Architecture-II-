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


module tb_task5();

// Your testbench goes here. Make sure your tests exercise the entire design
// in the .sv file.  Note that in our tests the simulator will exit after
// 100,000 ticks (equivalent to "initial #100000 $finish();").

reg CLOCK_50;
reg [3:0] KEY;
reg [9:0] LEDR;
reg [6:0] HEX5;
reg [6:0] HEX4;
reg [6:0] HEX3;
reg [6:0] HEX2;
reg [6:0]HEX1;
reg [6:0] HEX0;
task5 t5(CLOCK_50, KEY, LEDR,
            HEX5, HEX4,  HEX3,
             HEX2,  HEX1, HEX0);

	always begin
		#5 CLOCK_50 = ~CLOCK_50;
		#10 KEY[0] = ~KEY[0]; // rising edge of slow clock. 
	end

	reg[3:0] player_score;
	reg[3:0] dealer_score;
	initial begin
		CLOCK_50 = 0;
		KEY[0] = 0;
		KEY[3] = 0;
		#40

	for(integer i=0; i<100; i=i+1) begin

		$display("Game number: %d", i);
		KEY[3] = 1;
		
		 
		#1000 // pass many clock cycle to get to the end of the game.
		
		// verify game is over.
		if(LEDR[8] == 0 && LEDR[9] == 0) begin
			$display("Test failed. Game is not over");
		end
		else begin 
			$display("Test Passed. Game over");
		end
		
		// verify player score and dealer score is correctly shown in the LEDS. 
		player_score = t5.dp.player_sch.total;
		dealer_score = t5.dp.delaer_sch.total;	

		if(LEDR[3:0] != player_score || LEDR[7:4] != dealer_score) begin
			$display("Test failed. LEDS does not represent the correct player score and the dealer score");
		end
		else begin
			$display("Test Passed. LEDS shows the correct player score");
		end
		
		// verify correct winner is selected based on player_score and dealer score.

		// test player win.
		if (player_score > dealer_score) begin
			if (LEDR[8] != 1 || LEDR[8] != 0) begin
				$display("Test failed.Player score higher but wrong LED shown");
			end
			else begin
				$display("Test Passed. Correct LED shown");
			end
		end
	
		// test dealer win.
		else if (player_score < dealer_score) begin
			if (LEDR[8] != 0 || LEDR[9] != 1) begin
				$display("Test failed.Dealer score higher but wrong LED shown");
			end
			else begin
				$display("Test Passed. Correct LED shown");
			end
		end

		// test tie. 
		else begin
			if (LEDR[8] != 1 || LEDR[9] != 1) begin
				$display("Test failed. TIE but wrong LED shown");
			end
			else begin
				$display("Test Passed. Correct LED shown");
			end
		end
	 end
	end
						
endmodule

