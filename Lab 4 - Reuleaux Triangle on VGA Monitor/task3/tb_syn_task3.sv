`timescale 1ps / 1ps
module tb_syn_task3();

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.
reg clk;
reg rst_n;
reg [2:0] colour;
reg [7:0] centre_x;
reg [6:0] centre_y;
reg [7:0] radius;
reg start;
reg done;
reg[7:0] vga_x;
reg[6:0] vga_y;
reg[3:0] vga_colour;
reg vga_plot;


 circle dut(clk,rst_n, colour,
              centre_x, centre_y, radius,
              start, done,
              vga_x, vga_y,
              vga_colour, vga_plot);

initial begin 
    clk = 0;
        forever #5 clk = ~clk;
end

initial begin
        
        centre_x = 8'd80;
        centre_y = 7'd60;
        radius = 8'd2;
        #5

        rst_n = 0;
        start = 1;

        #5
        rst_n = 1;


    end

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.
  logic CLK;
    logic [3:0] KEY;
    logic [9:0] SW;
    logic [9:0] LEDR;
    logic [6:0] HEX0;
    logic [6:0] HEX1;
    logic [6:0] HEX2;
    logic [6:0] HEX3;
    logic [6:0] HEX4;
    logic [6:0] HEX5;

    //some outputs
    logic[7:0] VGA_R;
    logic[7:0] VGA_G;
    logic[7:0] VGA_B;
    logic VGA_HS;
    logic VGA_VS;
    logic VGA_CLK;
    logic [7:0] VGA_X;
    logic[7:0] VGA_Y;
    logic[7:0] VGA_COLOUR;
    logic VGA_PLOT;

    de1_gui gui(.SW, .KEY, .LEDR, .HEX5, .HEX4, .HEX3, .HEX2, .HEX1, .HEX0);

    //button_pusher dut(.CLK, .SW, .KEY, .LEDR, .HEX5, .HEX4, .HEX3, .HEX2, .HEX1, .HEX0);

    task3 dut(CLK, KEY,
             SW, LEDR,
             HEX0, HEX1, HEX2,
             HEX3, HEX4, HEX5,
             VGA_R, VGA_G, VGA_B,
             VGA_HS, VGA_VS, VGA_CLK,
             VGA_X, VGA_Y,
             VGA_COLOUR, VGA_PLOT); 

    initial begin
        CLK = 0;
        forever #1 CLK = ~CLK;
    end

    initial begin 
        KEY[3] = 1;
            #10
	    KEY[3] = 0;
	    #10;
	    KEY[3] = 1;
    end

    

    int x;
    int y;
    int value;
    int cpc;
    int wpc;

    initial begin
        	
            //start the simulation with active low reset
            #30
            KEY[3] = 0;
            #30
            KEY[3]=1;
            #30
            $display("Going...");

            //wait for program to compute
            #100000
            $display("done drawing; starting to assert");

            for (x = 0; x < 159; x = x + 1) begin

                

                for (y = 0; y < 119; y = y + 1) begin
                    
                    if ( dut .\vga_u0|VideoMemory|auto_generated|ram_block1a7 .ram_core0.ram_core0.mem[x+y*160] == x%8) begin
                        cpc = cpc+1;
                    end else begin
                        cpc=cpc+1;
                        wpc=0;
                    end



                end
            end

            $display("correct pixcel:%d; wrong pixcel:%d;", cpc, wpc ); 

        end

//*/

endmodule: tb_syn_task3
