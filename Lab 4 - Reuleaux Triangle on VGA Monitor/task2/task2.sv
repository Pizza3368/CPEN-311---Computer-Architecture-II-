module task2(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);

    // instantiate and connect the VGA adapter and your module
    reg [2:0] color; // not needed in this module.
    reg start;
    reg done;
    reg[7:0] x;
    reg[7:0] y;
    reg[7:0] vga_c;
    reg vga_plot;

    /* For the .* in vga_adapter*/
    logic [9:0] VGA_R_10;
    logic [9:0] VGA_G_10;
    logic [9:0] VGA_B_10;
    logic VGA_BLANK, VGA_SYNC;

    /*Overview of connection between the fill screen module and the vga_adapter module */
    /* 
    Output x from fill screen connected to x in vga_adapter, same with y and vga_color and plot.
    */

    /*Instantiating the fill screen module. */
    fillscreen fs_algo(.clk(CLOCK_50), .rst_n(KEY[3]), .colour(color),
                .start(start), .done(done),
                .vga_x(x), .vga_y(y),
                .vga_colour(vga_c), .vga_plot(vga_plot));

    /* Instantiating the vga adapter.*/
    vga_adapter#(.RESOLUTION("160x120")) vga_u0(.resetn(KEY[3]), .clock(CLOCK_50), .colour(vga_c),
                                .x(x), .y(y), .plot(vga_plot),
                                .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B),
                                .*);


    /*defining the states required*/
    localparam wait_for_reset = 3'd0; // we will only start filling the screen once reset is deasserted.
    localparam hold_start_assert = 3'd1; // we keep the start asserted until fill screen is done.
    localparam deassert_start = 3'd2; // once done we deassert start.

    reg[2:0] present_state = wait_for_reset;

    always @(posedge CLOCK_50 or negedge KEY[3]) begin 
        if (KEY[3] == 0) begin 
            present_state = hold_start_assert;
            start = 0;
        end
        else begin 
            case(present_state) 
                wait_for_reset: begin 
                    present_state = wait_for_reset; // stay in this state until reset it hit.
                end

                // stay in this state until fill screen is done.
                hold_start_assert: begin 
                    if (done == 1) begin 
                        present_state = deassert_start;
                    end
                    else begin 
                        present_state = hold_start_assert;
                    end
                end

                deassert_start: begin 
                    present_state = deassert_start;
                end

                default: begin 
                    present_state = wait_for_reset;
                end
            endcase

            case(present_state) 
                wait_for_reset: start = 0;
                hold_start_assert: start = 1;
                deassert_start: start = 0;
                default: start = 0;
            endcase
        end
    end

endmodule: task2
