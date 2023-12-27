
`timescale 1ps / 1ps

module tb_syn_task3();

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

    task3 t3(
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
        clk = 0;
        #5
        clk = 1;
        #5;
    end

    initial 
    
    begin 

        // write test 1 in CT memory
        $readmemh("D:/Cpen311/Lab-3/Lab-3-CPEN311/task3/test2.memh", 
        t3.\ct|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem);
        KEY[3] = 0;
        SW[9:0] = 10'b0000011000;

        #30
        KEY[3] = 1;

        #1000

	    $display("Done");
    end

    

endmodule: tb_syn_task3