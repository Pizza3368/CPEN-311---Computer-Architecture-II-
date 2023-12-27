module circle(input logic clk, input logic rst_n, input logic [2:0] colour,
              input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] radius,
              input logic start, output logic done,
              output logic [7:0] vga_x, output logic [6:0] vga_y,
              output logic [2:0] vga_colour, output logic vga_plot);
     // draw the circle

     reg [7:0] offset_y;
     reg [7:0] offset_x;
     reg signed [8:0] crit;

     localparam wait_for_start = 4'd0;
     localparam set_octant = 4'd1;
     localparam finish = 4'd2;

     assign vga_colour = colour;
     reg[3:0] octant_number = 4'd1; 

     reg[3:0] present_state = wait_for_start;
     always @(posedge clk or negedge rst_n) begin 
          if (rst_n == 0) begin 
               present_state = wait_for_start;
               vga_x = 0;
               vga_y = 0;
               vga_plot = 0;
               offset_x = radius;
               crit = 9'd1 - radius;
               offset_y = 8'd0;
          end
          else begin 
               case(present_state) 
                    wait_for_start: begin 
                         if (start == 1) begin 
                              present_state = set_octant;
                         end
                         else begin 
                              present_state = wait_for_start;
                         end
                    end

                    set_octant: begin 
                         if (offset_y <= offset_x) begin 
                              present_state = set_octant;
                         end
                         else begin 
                              present_state = finish;
                         end
                    end

                    finish: begin 
                         present_state = finish;
                    end

                    default: present_state = wait_for_start;
               endcase

               case(present_state) 
                    wait_for_start: begin
                         
                         vga_x = 0;
                         vga_y = 0;
                         vga_plot = 0;
                         done = 0;
                         offset_x = radius;
                         crit = 8'd1 - radius;
                         offset_y = 8'd0;
                    end

                    set_octant: begin 
                         done = 0;
                         /*Need to ensure of vga_x > 160 and vga_y > 120 we dont set plot to 1*/
                         if (octant_number == 4'd1) begin 
                              vga_x = centre_x + offset_x;
                              vga_y = centre_y + offset_y;
                              if (vga_x <= 8'd159 && vga_y <= 7'd119) begin 
                                   vga_plot = 1;
                              end
                              else begin 
                                   vga_plot = 0;
                              end
                    
                              octant_number = octant_number + 1;
                         end

                         else if (octant_number == 4'd2) begin 
                              vga_x = centre_x + offset_y;
                              vga_y = centre_y + offset_x;
                              if (vga_x <= 8'd159 && vga_y <= 7'd119) begin 
                                   vga_plot = 1;
                              end
                              else begin 
                                   vga_plot = 0;
                              end
                              octant_number = octant_number + 1;
                         end

                         else if (octant_number == 4'd3) begin 
                              vga_x = centre_x - offset_y;
                              vga_y = centre_y + offset_x;
                              if (vga_x <= 8'd159 && vga_y <= 7'd119) begin 
                                   vga_plot = 1;
                              end
                              else begin 
                                   vga_plot = 0;
                              end
                              octant_number = octant_number + 1;
                         end

                         else if (octant_number == 4'd4) begin 
                              vga_x = centre_x - offset_x;
                              vga_y = centre_y + offset_y;
                              if (vga_x <= 8'd159 && vga_y <= 7'd119) begin 
                                   vga_plot = 1;
                              end
                              else begin 
                                   vga_plot = 0;
                              end
                              octant_number = octant_number + 1;
                         end

                         else if (octant_number == 4'd5) begin 
                              vga_x = centre_x - offset_x;
                              vga_y = centre_y - offset_y;
                              if (vga_x <= 8'd159 && vga_y <= 7'd119) begin 
                                   vga_plot = 1;
                              end
                              else begin 
                                   vga_plot = 0;
                              end
                              octant_number = octant_number+1;
                         end

                         else if (octant_number == 4'd6) begin 
                              vga_x = centre_x - offset_y;
                              vga_y = centre_y - offset_x;
                              if (vga_x <= 8'd159 && vga_y <= 7'd119) begin 
                                   vga_plot = 1;
                              end
                              else begin 
                                   vga_plot = 0;
                              end
                              octant_number = octant_number + 1;
                         end

                         else if (octant_number == 4'd7) begin 
                              vga_x = centre_x + offset_y;
                              vga_y = centre_y - offset_x;
                              if (vga_x <= 8'd159 && vga_y <= 7'd119) begin 
                                   vga_plot = 1;
                              end
                              else begin 
                                   vga_plot = 0;
                              end
                              octant_number = octant_number + 1;
                         end

                         else if (octant_number == 4'd8) begin 
                              vga_x = centre_x + offset_x;
                              vga_y = centre_y - offset_y;
                              if (vga_x <= 8'd159 && vga_y <= 7'd119) begin 
                                   vga_plot = 1;
                              end
                              else begin 
                                   vga_plot = 0;
                              end
                              octant_number = 1;

                              offset_y = offset_y + 1;
                              if (crit[7] == 1 || crit == 8'd0) begin 
                                   crit = crit + (2* offset_y) + 1;
                              end
                              else begin 
                                   offset_x = offset_x - 1;
                                   crit = crit + (2* (offset_y- offset_x)) + 1;
                              end
                         end
                         else begin 
                              vga_plot = 0;
                         end
                    end

                    finish: begin 
                         vga_plot = 0;
                         done = 1;
                    end
               
               endcase
          end

     end
endmodule

