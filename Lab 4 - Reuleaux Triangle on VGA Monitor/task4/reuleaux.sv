module reuleaux(input logic clk, input logic rst_n, input logic [2:0] colour,
                input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] diameter,
                input logic start, output logic done,
                output logic [7:0] vga_x, output logic [6:0] vga_y,
                output logic [2:0] vga_colour, output logic vga_plot);
     // draw the Reuleaux triangle

     // calculating cordinates of the 3 circles.
     logic[7:0] cx1, cy1, cx2, cy2, cx3, cy3;

     computeCentres centre_gen(
          .centres_x(centre_x), 
          .centres_y(centre_y), 
          .diameter(diameter),
          .circle_centre_x1(cx1), 
          .circle_centre_y1(cy1),
          .circle_centre_x2(cx2),
          .circle_centre_y2(cy2),
          .circle_centre_x3(cx3),
          .circle_centre_y3(cy3)
     );

     // 3 circle modules.
     // circle1 -> cx1, cy1, radius = diameter (top)

     // circle2 -> cx2, cy2, radius = diameter (Left)

     // circle3 -> cx3, cy3, radius = diameter (Right)

     // start circle1 > start circle2 > start circle 3

     //note b_x1<=x<=b_x2 and b_y1<=y<=b_y2
     
     reg [7:0] circle_cx, circle_cy, b_x1, b_x2, b_y1, b_y2;
     reg circle_start;
     reg circle_done;
     
     draw_arc arc(.clk(clk), .rst_n(rst_n), .colour(colour),
              .centre_x(circle_cx), .centre_y(circle_cy), .radius(diameter),
              .boundary_x1(b_x1), .boundary_x2(b_x2), .boundary_y1(b_y1), .boundary_y2(b_y2),
              .start(circle_start), .done(circle_done),
              .vga_x(vga_x), .vga_y(vga_y),
              .vga_colour(vga_colour), .vga_plot(vga_plot));

     

     typedef enum logic [2:0] {
        WAIT_FOR_START,
        START_C1,
        START_C2,
        START_C3,
        FINISH
     } StateType;

     StateType state;


    always @(posedge clk or negedge rst_n) begin
          if (rst_n == 0) begin 
               state = WAIT_FOR_START;
               circle_start = 0;

               // select circle 1.
               circle_cx = cx1;
               circle_cy = cy1;
               b_x1 = cx2;
               b_x2 = cx3;
               b_y1 = cy2-1;
               b_y2 = 8'd255;
          end

          else begin 
               case(state) 
                    WAIT_FOR_START: begin 
                         if (start == 1) begin 
                              state =  START_C1;
                         end
                         else begin 
                              state =  WAIT_FOR_START;
                         end
                    end

                    START_C1: begin 
                         if (circle_done == 1) begin 
                              state = START_C2;
                         end
                         else begin 
                              state = START_C1;
                         end
                    end

                    START_C2: begin 
                         if (circle_done == 1) begin 
                              state = START_C3;
                         end
                         else begin 
                              state = START_C2;
                         end
                    end

                    START_C3: begin 
                         if (circle_done == 1) begin 
                              state = FINISH;
                         end
                         else begin 
                              state = START_C3;
                         end
                    end

                    FINISH: begin 
                         state = FINISH;
                    end

                    default: begin 
                         state = WAIT_FOR_START;
                    end
               endcase

               case(state) 
                    WAIT_FOR_START: begin 
                         circle_start = 0;
                         done = 0;
                         // select circle 1.
                         circle_cx = cx1;
                         circle_cy = cy1;
                         b_x1 = cx2;
                         b_x2 = cx3;
                         b_y1 = cy2-1;
                         b_y2 = 8'd255;
                    end

                    START_C1: begin 
                         circle_start = 1;
                         done = 0;
                         // select circle 1.
                         circle_cx = cx1;
                         circle_cy = cy1;
                         b_x1 = cx2;
                         b_x2 = cx3;
                         b_y1 = cy2-1;
                         b_y2 = 8'd255;
                    end

                    START_C2: begin 
                         circle_start = 1;
                         done = 0;
                         // select circle 2.
                         circle_cx = cx2;
                         circle_cy = cy2;
                         b_x1 = cx1; 
                         b_x2 = cx3;
                         b_y1 = cy1;
                         b_y2 = cy3-1;
                    end

                    START_C3: begin 
                         circle_start = 1;
                         done = 0;
                         // select circle 3.
                         circle_cx = cx3;
                         circle_cy = cy3;
                         b_x1 = cx2; 
                         b_x2 = cx1;
                         b_y1 = cy1;
                         b_y2 = cy2-1;
                    end

                    FINISH: begin 
                         circle_start = 0;
                         done = 1;
                         // select circle 3.
                         circle_cx = cx3;
                         circle_cy = cy3;
                         b_x1 = cx2; 
                         b_x2 = cx1;
                         b_y1 = cy1;
                         b_y2 = cy2-1;
                    end

                    default: begin 
                         circle_start = 0;

                         // select circle 1.
                         circle_cx = cx1;
                         circle_cy = cy1;
                         b_x1 = cx2;
                         b_x2 = cx3;
                         b_y1 = cy2;
                         b_y2 = 8'd255;
                    end
               endcase
          end
     
    end
     


endmodule

/**
Computes the centre of the circle based on (centres_x, centres_y)
which is the centre of the equilateral triangle.
*/
module computeCentres(
    input logic [7:0] centres_x, 
    input logic [6:0] centres_y, 
    input logic [7:0] diameter,
    output logic [7:0] circle_centre_x1, 
    output logic [7:0] circle_centre_y1,
    output logic [7:0] circle_centre_x2,
    output logic[7:0] circle_centre_y2,
    output logic[7:0] circle_centre_x3,
    output logic[7:0] circle_centre_y3
);

     logic[15:0] scaled_y1;
     logic[15:0] scaled_x3;
    logic [15:0] scaled_x2;
    logic [15:0] scaled_y2;

    

    assign circle_centre_x1 = centres_x;
    assign scaled_y1 = (100*centres_y) - (43 * diameter);
    assign circle_centre_y1 = scaled_y1 / 100;
    

    assign scaled_x2 = (2 * centres_x) - diameter;
    assign scaled_y2 = (100 * centres_y) + (43 * diameter);
    assign circle_centre_x2 = scaled_x2 / 2;
    assign circle_centre_y2 = scaled_y2 / 100;

    assign circle_centre_y3 = circle_centre_y2;
    assign scaled_x3 = (2* centres_x) + diameter;
    assign circle_centre_x3 = scaled_x3 / 2;

endmodule
