module task4(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);

    reg[2:0] vga_fs = 3'b00;
    reg[2:0] vga_r = 3'b010;

    /* reuleax connectors.*/
    reg[7:0] x_cord_r;
    reg[6:0] y_cord_r;
    reg vga_plot_r;

    reg circle_start;
    reg circle_done;
    reg[2:0] vga_color_circle;

    reuleaux draw_r(.clk(CLOCK_50), .rst_n(KEY[3]), .colour(vga_r),
              .centre_x(8'd80), .centre_y(7'd60), .diameter(8'd80),
              .start(circle_start), .done(circle_done),
              .vga_x(x_cord_r), .vga_y(y_cord_r),
              .vga_colour(vga_color_circle), .vga_plot(vga_plot_r));

    /* fill screen connectors.*/
    reg[7:0] x_cord_fs;
    reg[6:0] y_cord_fs;
    reg vga_plot_fs;

    reg fs_start;
    reg fs_done;
    reg[2:0] vga_color_fs;

    fillscreen fs(.clk(CLOCK_50), .rst_n(KEY[3]), .colour(vga_fs),
                  .start(fs_start), .done(fs_done),
                  .vga_x(x_cord_fs), .vga_y(y_cord_fs),
                  .vga_colour(vga_color_fs), .vga_plot(vga_plot_fs));


    /* vga adapter. */
    reg[7:0] x_cord;
    reg[7:0] y_cord;
    reg[2:0] vga_color;
    reg vga_plot;

    /* For the .* in vga_adapter*/
    logic [9:0] VGA_R_10;
    logic [9:0] VGA_G_10;
    logic [9:0] VGA_B_10;
    logic VGA_BLANK, VGA_SYNC;

    
    vga_adapter#(.RESOLUTION("160x120")) vga_u0(.resetn(KEY[3]), .clock(CLOCK_50), .colour(vga_color),
                                .x(x_cord), .y(y_cord), .plot(vga_plot),
                                .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B),
                                .*);

    typedef enum logic [2:0] {
        WAIT,
        STARTFS,
        STARTR,
        FINISH
     } StateType;

     reg[1:0] select;

     StateType state;

     always @(posedge CLOCK_50 or negedge KEY[3]) begin 
        if (KEY[3] == 0) begin 
            state =  STARTFS;
            circle_start = 0;
        end
        else begin 
            case(state) 
                WAIT: begin
                    state =  WAIT;
                end

                STARTFS: begin 
                    if (fs_done == 1) begin 
                        state = STARTR;
                    end
                    else begin 
                        state = STARTFS;
                    end
                end

                STARTR: begin
                    if (circle_done == 1) begin 
                        state =  FINISH;
                    end
                    else begin 
                        state = STARTR;
                    end
                end

                FINISH: begin 
                    state = FINISH;
                end

                default: begin 
                    state = WAIT;
                end
            
            endcase
            
            case (state) 
                WAIT: begin 
                    circle_start = 0;
                    fs_start = 0;
                    select = 2'b00;
                end

                STARTFS: begin 
                    fs_start = 1;
                    circle_start = 0;
                    select = 2'b00;
                end

                STARTR: begin 
                    fs_start = 0;
                    circle_start = 1;
                    select = 2'b01;
                end

                FINISH: begin 
                    fs_start = 0;
                    circle_start = 0;
                    select = 2'b01;
                end

                default: begin 
                    fs_start = 0;
                    circle_start = 0;
                    select = 2'b00;
                end
            endcase
                

        end
     end


     always_comb begin : selectModule

        // select fill screen to be connected to vga.
        if (select == 2'b00) begin 
            x_cord = x_cord_fs;
            y_cord = y_cord_fs;
            vga_plot = vga_plot_fs;
            vga_color = vga_color_fs;
        end

        // select reuleuax to be connected to vga.
        else if (select == 2'b01) begin 
            x_cord = x_cord_r;
            y_cord = y_cord_r;
            vga_plot = vga_plot_r;
            vga_color = vga_color_circle;
        end

        else begin 
            x_cord = x_cord_r;
            y_cord = y_cord_r;
            vga_plot = vga_plot_r;
            vga_color = vga_color_circle;
        end
     end

endmodule: task4
