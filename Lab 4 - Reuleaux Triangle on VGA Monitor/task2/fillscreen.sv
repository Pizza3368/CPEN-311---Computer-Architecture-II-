`timescale 1 ps / 1 ps
/* ignore colour for task2. */
module fillscreen(input logic clk, input logic rst_n, input logic [2:0] colour,
                  input logic start, output logic done,
                  output logic [7:0] vga_x, output logic [6:0] vga_y,
                  output logic [2:0] vga_colour, output logic vga_plot);
     // fill the screen

     reg[7:0] x_cordinate;
     reg[6:0] y_cordinate;
     reg[2:0] colour_to_write;
     reg plot;

     assign vga_x = x_cordinate;
     assign vga_y = y_cordinate;
     assign vga_colour = colour_to_write;
     assign vga_plot = plot;

     localparam wait_for_start = 3'd0;
     localparam turn_pixel_at_xy = 3'd1;
     localparam finish_fillscreen = 3'd2;

     reg[2:0] present_state = wait_for_start;
     reg finish_flag_x = 0; // set to 1 when x is done iterating.

     always@(posedge clk or negedge rst_n) begin 
          if(rst_n == 0) begin 
               present_state = wait_for_start;
               x_cordinate = 8'd0;
               y_cordinate = 8'd127;
               plot = 0;
               done = 0;
               colour_to_write = 0;
          end
          else begin 
               case(present_state) 
                    wait_for_start: begin 
                         if (start == 1) begin 
                              present_state = turn_pixel_at_xy;
                         end
                         else begin 
                              present_state = wait_for_start;
                         end
                    end

                    turn_pixel_at_xy: begin 
                         if(finish_flag_x == 1) begin 
                              present_state = finish_fillscreen;
                         end
                         else begin 
                              present_state = turn_pixel_at_xy;
                         end
                    end

                    finish_fillscreen: begin 
                         present_state = finish_fillscreen;
                    end

                    default: present_state = wait_for_start;
               endcase

               case(present_state) 
                    wait_for_start: begin 
                         x_cordinate = 8'd0;
                         y_cordinate = 8'd127;
                         plot = 0;
                         done = 0;
                         colour_to_write = 0;
                    end

                    turn_pixel_at_xy: begin 
                         done = 0;
                         plot = 1;
                         
                         if (y_cordinate == 8'd119) begin 
                              y_cordinate = 8'd0;
                              x_cordinate = x_cordinate + 8'd1;
                              if (x_cordinate == 8'd160) begin 
                                   finish_flag_x = 1;
                                   plot = 0;
                              end
                              else begin 
                                   finish_flag_x = 0;
                                   plot = 1;
                              end
                              colour_to_write = x_cordinate%8;
                         end
                         else begin 
                              y_cordinate = y_cordinate + 8'd1;
                              colour_to_write = x_cordinate%8;
                         end
                    end

                    finish_fillscreen: begin 
                         done = 1;
                         plot = 0;
                    end

               
               endcase
          end
     end

endmodule

