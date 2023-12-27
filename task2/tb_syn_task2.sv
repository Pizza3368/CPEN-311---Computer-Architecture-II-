`timescale 1ps / 1ps
module tb_syn_task2();

// Your testbench goes here.
// Your testbench goes here.

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

    task2 dut(
        .CLOCK_50(clk),
        .KEY(KEY),
        .SW(SW),
        .HEX0(HEX0), 
        .HEX1(HEX1), 
        .HEX2(HEX2),
        .HEX3(HEX3), 
        .HEX4(HEX4), 
        .HEX5(HEX5),
        .LEDR(LEDR)
    );

    initial forever begin
		clk <= 0;
		#5;
		clk <= 1;
		#5;
	end

    // reg [63:0] memory [0:255]; // 8-bit wide memory with 256 locations

    // initial begin
    //     //this dont work for some reason, have trouble open the file in read mode
    //     $readmemh("C:\Users\sandy\Desktop\CPEN311Labs\CPEN311Lab3\Lab3-Cpen311\Lab-3-CPEN311\task2\data.memh", memory, 0); //read into memory
    //     //$readmemh("../../../Lab-3-CPEN311/task2/data.memh", memory);
    // end 

    // int i;
    initial 
	begin

            SW = 10'b1100111100; 
			#30
            //set reset to 0
            KEY[3] = 0;
	        #30
            KEY[3] = 1;


            #30

            $display("Going...");

			
			
			#40000
			///*
            //for(i=0; i<3; i=i+1) begin
				if (dut.\s|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[10] == 8'hf4) begin
                    $display("passed test10");
                end else begin
                    $display("failed test" );
                end

                if (dut.\s|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[20] == 8'h4f) begin
                    $display("passed test20");
                end else begin
                    $display("failed test" ); end

                if (dut.\s|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[40] == 8'h03) begin
                    $display("passed test40");
                end else begin
                    $display("failed test" );
                end

            //end
        
			//*/

            // for (i = 0; i < 250; i = i + 1) begin
			// 	if (dut.s.altsyncram_component.m_default.altsyncram_inst.mem_data[i] == i) begin
			// 		$display("Memory location %0d has correct data", i);
			// 	end else begin
			// 		$display("Memory location %0d has incorrect data", i);
			// 	end
        	// end
            $stop();


    end

endmodule: tb_syn_task2
