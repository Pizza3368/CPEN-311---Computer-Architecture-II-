module tb_scorehand();

// Your testbench goes here. Make sure your tests exercise the entire design
// in the .sv file.  Note that in our tests the simulator will exit after
// 10,000 ticks (equivalent to "initial #10000 $finish();").
	// module scorehand(input [3:0] card1, input [3:0] card2, input [3:0] card3, output [3:0] total);
	reg [3:0] c1;
	reg[3:0] c2;
	reg[3:0] c3;
	wire[3:0] total_out;
	scorehand sch(.card1(c1), .card2(c2), .card3(c3), .total(total_out));
	
	initial begin
		// card1 = 4, card2 = 8, card3 = 11 (Jack). Card3 has a face value of 0.
		// (4 + 8 + 0 ) % 10 = 2
		c1 = 4'b0100;
		c2 = 4'b1000;
		c3 = 4'b1011;
		#10
		if (total_out != 4'b0010) begin $display("Test failed, Expected: %b, Actual: %b", 4'b0010, total_out); end
		else begin $display("Test Passed for the following inputs: %b, %b, %b", c1, c2,c3); end

		// card1 = 10, card2 = 11 (Jack), card3 = 13 (king). All cards here have a face value of 0.
		// 0 + 0 + 0 = 0.
		c1 = 4'b1010;
		c2 = 4'b1011;
		c3 = 4'b1101;
		#10
		if(total_out != 4'b0000) begin $display("Test failed, Expected: %b, Actual: %b", 4'b0000, total_out); end
		else begin $display("Test Passed for the following inputs: %b, %b, %b", c1, c2,c3); end
		// card1 =8, card2 =8, card3 = 8. All non-zero cards.
		// (8 + 8 + 8) % 10 = 4.
		c1 = 4'b1000;
		c2 = 4'b1000;
		c3 = 4'b1000;
		#10
		if(total_out != 4'b0100) begin $display("Test failed, Expected: %b, Actual: %b", 4'b0100, total_out); end
		else begin $display("Test Passed for the following inputs: %b, %b, %b", c1, c2,c3); end

		// card1 = 9, card2 = 9, card3 = 9
		c1 = 4'b1001;
		c2 = 4'b1001;
		c3 = 4'b1001;
		#10
		if (total_out != 4'b0111) begin $display("Test failed, Expected: %b, Actual %b", 4'b0111, total_out); end
		else begin $display("Test Passed for the following inputs: %b, %b, %b", c1, c2,c3); end

		//card1 = 12, card = 9, card = 2
		// (0+9+2) % 10 = 1
		c1 = 4'b1100;
		c2 = 4'b1001;
		c3 = 4'b0010;
		#10
		if (total_out != 4'b0001) begin $display("Test failed, Expected: %b, Actual: %b", 4'b0001, total_out); end
		else begin $display("Test Passed for the following inputs: %b, %b, %b", c1, c2,c3); end

		// test small numbers: card1= 1, card2=2, card3=3
		// (1+2+3) % 10 = 6
		c1 = 4'b0001;
		c2 = 4'b0010;
		c3 = 4'b0011;
		#10
		if (total_out != 4'b0110) begin $display("Test failed, Expected: %b, Actual: %b", 4'b0110, total_out); end
		else begin $display("Test passed for the following inputs: %b, %b, %b", c1, c2, c3); end

		// 2+9+0 = 11%10 = 1
		c1 = 4'b0010;
		c2 = 4'b1001;
		c3 = 4'b0000;
		#10
		if (total_out != 4'b0001) begin $display("Test failed, Expected: %b, Actual: %b", 4'b0001, total_out); end
		else begin $display("Test passed for 9+2+0"); end
		
	end
	
						
endmodule

