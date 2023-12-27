`timescale 1ps / 1ps

module tb_de1_gui();
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

    task4 dut(CLK, KEY,
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

endmodule
