module task3(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);

    /* define colors for the fill screen and circle module.*/
    reg[2:0] color_fs = 3'b000; // For black all r,g,b are 000.
    reg[2:0] color_circle = 3'b010; // green for the circle.
    
    
    /* Instantiate the fill screen module.*/
    reg fill_screen_black_start;
    reg fill_screen_black_done;
    reg[7:0] vga_x_fill_screen;
    reg[6:0] vga_y_fill_screen;
    reg[2:0] vga_color_fill_screen;
    reg vga_plot_fill_screen; 


    fillscreen fill_screen_black(.clk(CLOCK_50), .rst_n(KEY[3]), .colour(color_fs),
                  .start(fill_screen_black_start), .done(fill_screen_black_done),
                  .vga_x(vga_x_fill_screen), .vga_y(vga_y_fill_screen),
                  .vga_colour(vga_color_fill_screen), .vga_plot(vga_plot_fill_screen));


    /*Instantiate the circle module*/
    reg circle_start;
    reg circle_done;
    reg [7:0] vga_x_circle;
    reg[6:0] vga_y_circle;
    reg[2:0] vga_color_circle;
    reg vga_plot_circle;



    circle draw_circle(.clk(CLOCK_50), .rst_n(KEY[3]), .colour(color_circle),
              .centre_x(8'd80), .centre_y(8'd60), .radius(8'd40),
              .start(circle_start), .done(circle_done),
              .vga_x(vga_x_circle), .vga_y(vga_y_circle),
              .vga_colour(vga_color_circle), .vga_plot(vga_plot_circle));

    
    /*Instantiate the vga_adapter*/

    /* For the .* in vga_adapter*/
    logic [9:0] VGA_R_10;
    logic [9:0] VGA_G_10;
    logic [9:0] VGA_B_10;
    logic VGA_BLANK, VGA_SYNC;

    reg[2:0] vga_color;
    reg[7:0] x_cordinate;
    reg[6:0] y_cordinate;
    reg vga_plot;
    
    vga_adapter#(.RESOLUTION("160x120")) vga_u0(.resetn(KEY[3]), .clock(CLOCK_50), .colour(vga_color),
                                .x(x_cordinate), .y(y_cordinate), .plot(vga_plot),
                                .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B),
                                .*);

    // vga_color, x_cordinate, y_cordinate and vga_plot should be first connected to the fill screen and then draw circle.
    reg select = 0; // keeping at 0 since at start we want to be connected to fill screen.
    always_comb begin : selectVgaConnection

        /* connect to fill screen.*/
        if (select == 0) begin 
            vga_color = vga_color_fill_screen;
            x_cordinate = vga_x_fill_screen;
            y_cordinate = vga_y_fill_screen;
            vga_plot = vga_plot_fill_screen;
        end

        /* connect to circle */
        else if (select == 1) begin 
            vga_color = vga_color_circle;
            x_cordinate = vga_x_circle;
            y_cordinate = vga_y_circle;
            vga_plot = vga_plot_circle;
        end

        /*this should never be the case*/
        else begin
            vga_color = 3'b000;
            x_cordinate = 8'd0;
            y_cordinate = 7'd0;
            vga_plot = 0;
        end
    end

    localparam wait_for_reset = 3'd0;
    localparam hold_fillScreen_start = 3'd1;
    localparam hold_circle_start = 3'd2;
    localparam finish = 3'd3;

    reg[2:0] present_state = wait_for_reset;

    always@(posedge CLOCK_50 or negedge KEY[3]) begin 
        if(KEY[3] == 0) begin 
            present_state = hold_fillScreen_start;
            circle_start = 0;
            fill_screen_black_start = 0;
        end

        else begin 

            case(present_state) 
                wait_for_reset: begin 
                present_state = wait_for_reset; // stay in this state until we have a reset.
                end

                hold_fillScreen_start: begin 
                    if (fill_screen_black_done == 1) begin 
                        present_state = hold_circle_start;
                    end
                    else begin 
                        present_state = hold_fillScreen_start;
                    end
                end

                hold_circle_start: begin 
                    if (circle_done == 1) begin 
                        present_state = finish;
                    end
                    else begin 
                        present_state = hold_circle_start;
                    end
                end

                finish: begin 
                    present_state = finish;
                end

                default: present_state = wait_for_reset;
            
            endcase

            case (present_state) 
                wait_for_reset: begin 
                    circle_start = 0;
                    fill_screen_black_start = 0;
                    select = 0;
                end

                hold_fillScreen_start: begin 
                    circle_start = 0;
                    fill_screen_black_start = 1;
                    select = 0;
                end

                hold_circle_start: begin 
                    circle_start = 1;
                    fill_screen_black_start = 0;
                    select = 1;
                end

                finish: begin 
                    circle_start = 0;
                    fill_screen_black_start = 0;
                    select = 1;
                end

                default: begin 
                    circle_start = 0;
                    fill_screen_black_start = 0;
                    select = 0;
                end
            
            endcase
            
        end
    end


    

endmodule: task3
