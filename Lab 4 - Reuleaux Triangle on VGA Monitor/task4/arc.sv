/**
Only draw arcs of circle where the boundaries are defined.
*/
module draw_arc(input logic clk, input logic rst_n, input logic [2:0] colour,
              input logic [7:0] centre_x, input logic [7:0] centre_y, input logic [7:0] radius,
              input logic [7:0] boundary_x1, input logic[7:0] boundary_x2, input logic[7:0] boundary_y1, input logic [7:0] boundary_y2,
              input logic start, output logic done,
              output logic [7:0] vga_x, output logic [6:0] vga_y,
              output logic [2:0] vga_colour, output logic vga_plot);
     // draw the circle

     reg [15:0] offset_y;
     reg [15:0] offset_x;
     reg signed [15:0] crit;

     localparam wait_for_start = 4'd0;
     localparam set_octant = 4'd1;
     localparam finish = 4'd2;

     assign vga_colour = colour;
     reg[3:0] octant_number = 4'd1; 

     reg[10:0] actual_x = 11'd0;
     reg[10:0] actual_y = 11'd0;

     reg[3:0] present_state = wait_for_start;
     always @(posedge clk or negedge rst_n) begin 
          if (rst_n == 0) begin 
               present_state = wait_for_start;
               vga_x = 0;
               vga_y = 0;
               vga_plot = 0;
               offset_y = 0;
               offset_x = radius;
               crit = 16'd1 - radius;
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
                         present_state = wait_for_start;
                    end

                    default: present_state = wait_for_start;
               endcase

               case(present_state) 
                    wait_for_start: begin
                         
                         offset_x = radius; 
                         vga_x = 0;
                         vga_y = 0;
                         vga_plot = 0;
                         done = 0;
                         offset_y = 0;
                         offset_x = radius;
                         crit = 8'd1 - radius;
                    end

                    set_octant: begin 
                         done = 0;
                         /*Need to ensure of vga_x > 160 and vga_y > 120 we dont set plot to 1*/
                         if (octant_number == 4'd1) begin 
                              vga_x = centre_x + offset_x;
                              vga_y = centre_y + offset_y;

                              actual_x = centre_x + offset_x;
                              actual_y = centre_y + offset_y;
                              
                              //new if statement logic; it test if the point is part of the trianlg's arc 
                              //note boundary_x1<=x<=boundary_x2 and boundary_y1<=boundary_y2
                              if(boundary_x1<= actual_x && actual_x<=boundary_x2 && boundary_y1<=actual_y && actual_y<=boundary_y2) begin
                                   if (actual_x <= 8'd159 && actual_y <= 8'd119) begin 
                                        vga_plot = 1;
                                   end
                                   else begin 
                                        vga_plot = 0;
                                   end
                                   
                              end
                              else begin 
                                   vga_plot = 0;
                              end
                    
                              octant_number = octant_number + 1;
                         end

                         else if (octant_number == 4'd2) begin 
                              vga_x = centre_x + offset_y;
                              vga_y = centre_y + offset_x;

                              actual_x = centre_x + offset_y;
                              actual_y = centre_y + offset_x;;
                              if(boundary_x1<= actual_x && actual_x<=boundary_x2 && boundary_y1<=actual_y && actual_y<=boundary_y2) begin
                                   if (actual_x <= 8'd159 && actual_y <= 8'd119) begin 
                                        vga_plot = 1;
                                   end
                                   else begin 
                                        vga_plot = 0;
                                   end
                                   
                              end
                              else begin 
                                   vga_plot = 0;
                              end
                              octant_number = octant_number + 1;
                         end

                         else if (octant_number == 4'd3) begin 
                              vga_x = centre_x - offset_y;
                              vga_y = centre_y + offset_x;

                              actual_x = centre_x - offset_y;
                              actual_y = centre_y + offset_x;
                              if(boundary_x1<= actual_x && actual_x<=boundary_x2 && boundary_y1<=actual_y && actual_y<=boundary_y2) begin
                                   if (actual_x <= 8'd159 && actual_y <= 8'd119) begin 
                                        vga_plot = 1;
                                   end
                                   else begin 
                                        vga_plot = 0;
                                   end
                                   
                              end
                              else begin 
                                   vga_plot = 0;
                              end
                              octant_number = octant_number + 1;
                         end

                         else if (octant_number == 4'd4) begin 
                              vga_x = centre_x - offset_x;
                              vga_y = centre_y + offset_y;

                              actual_x = centre_x - offset_x;
                              actual_y = centre_y + offset_y;
                              if(boundary_x1<= actual_x && actual_x<=boundary_x2 && boundary_y1<=actual_y && actual_y<=boundary_y2) begin
                                   if (actual_x <= 8'd159 && actual_y <= 8'd119) begin 
                                        vga_plot = 1;
                                   end
                                   else begin 
                                        vga_plot = 0;
                                   end
                                   
                              end
                              else begin 
                                   vga_plot = 0;
                              end
                              octant_number = octant_number + 1;
                         end

                         else if (octant_number == 4'd5) begin 
                              vga_x = centre_x - offset_x;
                              vga_y = centre_y - offset_y;

                              actual_x = centre_x - offset_x;
                              actual_y =centre_y - offset_y;
                              if(boundary_x1<= actual_x && actual_x<=boundary_x2 && boundary_y1<=actual_y && actual_y<=boundary_y2) begin
                                   if (actual_x <= 8'd159 && actual_y <= 8'd119) begin 
                                        vga_plot = 1;
                                   end
                                   else begin 
                                        vga_plot = 0;
                                   end
                                   
                              end
                              else begin 
                                   vga_plot = 0;
                              end
                              octant_number = octant_number+1;
                         end

                         else if (octant_number == 4'd6) begin 
                              vga_x = centre_x - offset_y;
                              vga_y = centre_y - offset_x;

                              actual_x = centre_x - offset_y;
                              actual_y = centre_y - offset_x;

                              if(boundary_x1<= actual_x && actual_x<=boundary_x2 && boundary_y1<=actual_y && actual_y<=boundary_y2) begin
                                   if (actual_x <= 8'd159 && actual_y <= 8'd119) begin 
                                        vga_plot = 1;
                                   end
                                   else begin 
                                        vga_plot = 0;
                                   end
                                   
                              end
                              else begin 
                                   vga_plot = 0;
                              end
                              octant_number = octant_number + 1;
                         end

                         else if (octant_number == 4'd7) begin 
                              vga_x = centre_x + offset_y;
                              vga_y = centre_y - offset_x;

                              actual_x = centre_x + offset_y;
                              actual_y = centre_y - offset_x;                              
                              if(boundary_x1<= actual_x && actual_x<=boundary_x2 && boundary_y1<=actual_y && actual_y<=boundary_y2) begin
                                   if (actual_x <= 8'd159 && actual_y <= 8'd119) begin 
                                        vga_plot = 1;
                                   end
                                   else begin 
                                        vga_plot = 0;
                                   end
                                   
                              end
                              else begin 
                                   vga_plot = 0;
                              end
                              octant_number = octant_number + 1;
                         end

                         else if (octant_number == 4'd8) begin 
                              vga_x = centre_x + offset_x;
                              vga_y = centre_y - offset_y;

                              actual_x = centre_x + offset_x;
                              actual_y = centre_y - offset_y;
                              if(boundary_x1<= actual_x && actual_x<=boundary_x2 && boundary_y1<=actual_y && actual_y<=boundary_y2) begin
                                   if (actual_x <= 8'd159 && actual_y <= 8'd119) begin 
                                        vga_plot = 1;
                                   end
                                   else begin 
                                        vga_plot = 0;
                                   end
                                   
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

