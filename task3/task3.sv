`timescale 1ps / 1ps

`define wait_for_arc4_t3 3'd0
`define start_arc4_t3 3'd1
`define wait_arc4_finish_t3 3'd2
`define finish_arc4_t3 3'd3

module task3(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // for ct mem.
    reg[7:0] ct_addr;
    reg [7:0] ct_wrdata = 8'd0;
    reg ct_wren = 0;
    reg [7:0] ct_rddata;

    // for pt mem.
    reg[7:0] pt_addr;
    reg[7:0] pt_wrdata;
    reg pt_wren;
    reg [7:0] pt_rddata;

    // for arc4.
    reg enable;
    reg ready;
    reg[23:0] key_val;
    assign key_val[23:10] = 0;
    assign key_val[9:0] = SW[9:0];

    ct_mem ct(
        .address(ct_addr),
        .clock(CLOCK_50),
        .data(ct_wrdata),
        .wren(ct_wren),
        .q(ct_rddata)
    );
    
    pt_mem pt( 
        .address(pt_addr),
        .clock(CLOCK_50),
        .data(pt_wrdata),
        .wren(pt_wren),
        .q(pt_rddata)
     );
    
    arc4 a4( 
        .clk(CLOCK_50),
        .rst_n(KEY[3]),
        .en(enable),
        .rdy(ready),
        .key(key_val),
        .ct_addr(ct_addr),
        .ct_rddata(ct_rddata),
        .pt_addr(pt_addr),
        .pt_rddata(pt_rddata),
        .pt_wrdata(pt_wrdata),
        .pt_wren(pt_wren)
     );

    reg[3:0] present_state = `wait_for_arc4_t3;
    always @(posedge CLOCK_50 or negedge KEY[3]) begin 
        if (KEY[3] == 0) begin 
            present_state = `wait_for_arc4_t3;
            enable = 0;
        end
        else begin 
            case(present_state) 
                `wait_for_arc4_t3: begin 
                    if (ready == 1) begin 
                        present_state = `start_arc4_t3;
                    end
                    else begin 
                        present_state = `wait_for_arc4_t3;
                    end
                end

                `start_arc4_t3: begin 
                    present_state = `wait_arc4_finish_t3;
                end

                `wait_arc4_finish_t3: begin 
                    if (ready == 1) begin 
                        present_state = `finish_arc4_t3;
                    end
                    else begin 
                        present_state = `wait_arc4_finish_t3;
                    end
                end

                `finish_arc4_t3: begin 
                    present_state = `finish_arc4_t3;
                end
                default: present_state = `wait_for_arc4_t3;
            endcase

            case(present_state) 
                `wait_for_arc4_t3: begin 
                    enable = 0;
                end

                `start_arc4_t3: begin 
                    enable = 1;
                end

                `wait_arc4_finish_t3: begin 
                    enable = 0;
                end

                `finish_arc4_t3: begin 
                    enable = 0;
                end

                default: begin 
                    enable = 0;
                end
            endcase
        end
    end

endmodule: task3
