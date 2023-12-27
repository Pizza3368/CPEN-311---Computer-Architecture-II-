module tb_rtl_circle();

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
endmodule: tb_rtl_circle
