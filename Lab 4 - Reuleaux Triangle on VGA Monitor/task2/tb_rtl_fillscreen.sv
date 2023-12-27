`timescale 1 ps / 1 ps


module tb_rtl_fillscreen();

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
reg[2:0] vga_colour;
reg vga_plot;


fillscreen dut(.clk(clk), .rst_n(rst_n), .colour(colour),
                  .start(start), .done(done),
                  .vga_x(vga_x), .vga_y(vga_y),
                  .vga_colour(vga_colour), .vga_plot(vga_plot));

initial begin 
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
        
        rst_n = 1;
        #5

        rst_n = 0;
        start = 1;

        #5
        rst_n = 1;


    end

endmodule: tb_rtl_fillscreen
