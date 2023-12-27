module tb_syn_ksa();

// Your testbench goes here.

	// inputs:
	reg clock;
	reg reset;
	reg enable;
	reg [23:0] key;
	
	// outputs:
	reg rdy;
	reg [7:0] address;
	reg [7:0] read_data;
	reg [7:0] wrdata;
	reg wren;

	ksa k_sch_algo(
		.clk(clock),
		.rst_n(reset),
		.en(enable),
		.rdy(rdy),
		.key(key),
		.addr(address),
		.rddata(read_data),
		.wrdata(wrdata),
		.wren(wren)
	);

	initial forever begin
		clock = 0;
		#5;
		clock = 1;
		#5;
	end

	initial begin 
		key = 24'h00033c; // setting the key to what was given in the question.
		reset = 0; // reset the state machine.
		enable = 0;

		#10

		enable = 1;
		reset = 1;
		read_data = 8'd44;
		#5 // 15 second mark
		//
		// at the next rising edge we should update j.		
		// after 15 second mark j should be 44.
		// j = (0 + s[i] + 0)% 256 = 44. 
		
		

		#10 // 25 second mark
		read_data = 8'd55;
		// at the next risign edge we should read s[j] so valuej should be 55.

		#10 // 35 second mark
		// at the next risign edge we should write at i.
		// this means s[0] = 55.
		// so wrdata == 55, addr = 0, wren = 1

		#10 // 45 second mark

		// Now we write at s[j] = 44, this means
		// address = 44, wrdata = 44, wren = 1.

		# 10 // 55 second mark

		// now we should increment i. check that i = 1
		

		#10 // 65 second mark
		read_data = 8'd33;
		// now we read at s[i] = s[1]
		// since read_data == 33.
		// valuei should be 33.
		// and j should be 
		// j = (44 + 33 + 3) % 256  = 80.
		
		
		#10 // 75 second mark
		read_data = 8'd35;
		// now we read at j.
		// so wren = 0, address = 80, valuej = 35.

		#10 // 85 secon mark
		// now we write at i.
		//s[1] = 35.
		//wrdata = 35, address = 1, wren =1

		#10 // 95 second mark
		// now we write at j.
		// s[80] = 33
		// so wrdata = 33, address = 80, wren = 1. 

		#10 // 105 second mark.
		// increment i. 

		$display("Done");

		



	end

endmodule: tb_syn_ksa
