`timescale 1ps / 1ps

module tb_rtl_task3();
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
    int decimal_array[0:19199];

    initial begin
        	
            //start the simulation with active low reset
            #30
            KEY[3] = 0;
            #30
            KEY[3]=1;
            #30
            $display("Going...");
            #30

            //prepare the testcase
            $display("computing test case");
            draw_circle(80, 60, 40);
            

            //wait for program to update vga
            #100000
            $display("done drawing; starting to assert");


            //testing vga mem with test case
            for (x = 0; x < 159; x = x + 1) begin

                

                for (y = 0; y < 119; y = y + 1) begin

                    if ( dut.vga_u0.VideoMemory.m_default.altsyncram_inst.mem_data[x+y*160] == decimal_array[x+y*160]) begin
                        cpc = cpc+1;
                    end else begin
                        wpc=wpc+1;
                        $display("got %d, expect %d. error at pixcel:%d, %d;", dut.vga_u0.VideoMemory.m_default.altsyncram_inst.mem_data[x+y*160], decimal_array[x+y*160], x, y );
                        

                    end

                end
            end

            $display("correct pixcel:%d; wrong pixcel:%d;", cpc, wpc ); 

        end

         // Function to draw a circle
    task draw_circle(int centre_x, int centre_y, int radius);
        automatic int offset_y = 0;
        automatic int offset_x = radius;
        automatic int crit = 1 - radius;
        
        while (offset_y <= offset_x) begin
            decimal_array[(centre_x + offset_x) + (centre_y + offset_y) * 160] = 2;
            decimal_array[(centre_x + offset_y) + (centre_y + offset_x) * 160] = 2;
            decimal_array[(centre_x - offset_x) + (centre_y + offset_y) * 160] = 2;
            decimal_array[(centre_x - offset_y) + (centre_y + offset_x) * 160] = 2;
            
            decimal_array[(centre_x - offset_x) + (centre_y - offset_y) * 160] = 2;
            decimal_array[(centre_x - offset_y) + (centre_y - offset_x) * 160] = 2;
            decimal_array[(centre_x + offset_x) + (centre_y - offset_y) * 160] = 2;
            decimal_array[(centre_x + offset_y) + (centre_y - offset_x) * 160] = 2;
            
            offset_y = offset_y + 1;

            if (crit <= 0) begin
                crit = crit + 2 * offset_y + 1;
            end else begin
                offset_x = offset_x - 1;
                crit = crit + 2 * (offset_y - offset_x) + 1;
            end
            
        end
    endtask

endmodule
