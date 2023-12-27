`timescale 1ps / 1ps

module tb_rtl_init();

	reg clk;
	reg rst_n;
	reg en;
	reg rdy;
	reg [7:0] addr;
	reg [7:0] write_data;
	reg wren;

	init dut(.clk(clk), .rst_n(rst_n), .en(en), 
	.rdy(rdy), .addr(addr), .wrdata(write_data), 
	.wren(wren));
	
			 
	initial forever begin
		clk = 0;
		#5;
		clk = 1;
		#5;
	end

    initial
		begin

		rst_n = 0;
		#10
		rst_n = 1;
		en = 1;
		#30
		en = 0; 



		#5;

		// verify ready-enable protocol. 
		// verify ct_addr, ct_wren and wrdata.
		end

endmodule: tb_rtl_init