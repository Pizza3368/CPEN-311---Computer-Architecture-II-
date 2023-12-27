module tb_rtl_reuleaux();

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.

reg clk;
reg rst_n;
reg [2:0] colour;
reg [7:0] centre_x;
reg [6:0] centre_y;
reg [7:0] diameter;
reg start;
reg done;
reg[7:0] vga_x;
reg[6:0] vga_y;
reg[2:0] vga_colour;
reg vga_plot;


reuleaux dut(.clk(clk), .rst_n(rst_n), .colour(colour),
                .centre_x(centre_x), .centre_y(centre_y), .diameter(diameter),
                .start(start), .done(done),
                .vga_x(vga_x), .vga_y(vga_y),
                .vga_colour(vga_colour), .vga_plot(vga_plot));


initial begin 
    clk = 0;
        forever #5 clk = ~clk;
end

initial begin
        
        centre_x = 8'd80;
        centre_y = 7'd60;
        diameter = 8'd80;
        rst_n = 1;
        #5

        rst_n = 0;
        start = 1;

        #5
        rst_n = 1;


    end

endmodule: tb_rtl_reuleaux
