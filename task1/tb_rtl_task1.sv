`timescale 1ps / 1ps

module tb_rtl_task1();

	reg clk;
	reg [3:0] KEY;
	reg [9:0] SW;
	
	wire [6:0] HEX0;
	wire [6:0] HEX1;
	wire [6:0] HEX2;
	wire [6:0] HEX3;
	wire [6:0] HEX4;
	wire [6:0] HEX5;
	wire [9:0] LEDR;

	task1 dut(.CLOCK_50(clk), .KEY(KEY), .SW(SW),
             .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2),
             .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5),
             .LEDR(LEDR));
			 
	initial forever begin
		clk = 0;
		#5;
		clk = 1;
		#5;
	end
	int i;

    initial
		begin
			#30
            //set reset to 0
            KEY[3] = 0;

            #30

            KEY[3]=1;

            #30

            $display("Going...");

			
			
			#5000
			///*
        	for (i = 0; i < 250; i = i + 1) begin
				if (dut.s.altsyncram_component.m_default.altsyncram_inst.mem_data[i] == i) begin
					$display("Memory location %0d has correct data", i);
				end else begin
					$display("Memory location %0d has incorrect data", i);
				end
        	end
			//*/
			
		end

endmodule: tb_rtl_task1