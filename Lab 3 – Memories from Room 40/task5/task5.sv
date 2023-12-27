`timescale 1 ps / 1 ps
`define wait_double_c_start 3'd0
`define start_double_c_start 3'd1
`define wait_double_c_finish 3'd2
`define double_c_finish 3'd3
`define random_t5 3'd4  

module task5(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // your code here
    reg[7:0] ct_addr;
    reg ct_wren = 0;
    reg[7:0] ct_wrdata = 0;
    reg[7:0] ct_rddata;

    ct_mem ct( 
        .address(ct_addr),
        .clock(CLOCK_50),
        .data(ct_wrdata),
        .wren(ct_wren),
        .q(ct_rddata)
    );

    reg enable;
    reg ready;
    reg [23:0] key;
    reg is_key_valid;

    reg [3:0] hex0 = 4'd0;
    reg[3:0] hex1 = 4'd0;
    reg[3:0] hex2 = 4'd0;
    reg[3:0] hex3 = 4'd0;
    reg[3:0] hex4 = 4'd0;
    reg[3:0] hex5 = 4'd0;

    reg[1:0] blank = 2'b00; // if 00 then blank.

    display d0 (
    .value(hex0),
    .show(blank),
    .displayval(HEX0)
    );

    display d1 (
        .value(hex1),
        .show(blank),
        .displayval(HEX1)
    );

    display d2 (
        .value(hex2),
        .show(blank),
        .displayval(HEX2)
    );

    display d3 (
        .value(hex3),
        .show(blank),
        .displayval(HEX3)
    );

    display d4 (
        .value(hex4),
        .show(blank),
        .displayval(HEX4)
    );

    display d5 (
        .value(hex5),
        .show(blank),
        .displayval(HEX5)
    );

    doublecrack dc(
        .clk(CLOCK_50),
        .rst_n(KEY[3]),
        .en(enable),
        .rdy(ready),
        .key(key),
        .key_valid(is_key_valid),
        .ct_addr(ct_addr),
        .ct_rddata(ct_rddata)
    );

    reg[3:0] present_state = `random_t5;


    always @(posedge CLOCK_50 or negedge KEY[3]) begin 
        if (KEY[3] == 0) begin 
            present_state = `wait_double_c_start;
            enable = 0;
        end
        else begin 
            case (present_state) 
                `wait_double_c_start: begin 
                    if (ready == 1) begin 
                        present_state = `start_double_c_start;
                    end
                    else begin 
                        present_state = `wait_double_c_start;
                    end
                end

                `start_double_c_start: begin 
                    present_state = `wait_double_c_finish;
                end

                `wait_double_c_finish: begin 
                    if (ready == 1) begin 
                        if (is_key_valid == 1) begin 
                        blank = 2'b11;
                        hex0 = key[3:0];
                        hex1 = key[7:4];
                        hex2 = key[11:8];
                        hex3 = key[15:12];
                        hex4 = key[19:16];
                        hex5 = key[23:20];
                        end
                        else begin 
                            blank = 2'b01;
                            // not found so show straight line.
                        end

                        present_state = `double_c_finish; 
                    end

                    else begin 
                        present_state = `wait_double_c_finish;
                    end
                end

                `double_c_finish: begin 
                    present_state = `double_c_finish;
                end

                default: present_state = `random_t5;
            endcase

            case (present_state) 
                `wait_double_c_start: begin 
                    enable = 0;
                end

                `start_double_c_start: begin 
                    enable = 1;
                end

                `wait_double_c_finish: begin 
                    enable = 0;
                end

                `double_c_finish: begin 
                    enable = 0;
                end

                default: begin 
                    enable = 0;
                end
            
            endcase
        end
    end

    // your code here

endmodule: task5


module display(input logic[3:0] value,input logic[1:0] show, output logic[6:0] displayval);
    always@(*) begin 
        if (show == 2'b00) begin 
            displayval = 7'b1111111; // blank case.
        end
        else if (show == 2'b01) begin 
            displayval = 7'b0111111; // dashed line.
        end
        else if (show == 2'b11) begin 
            case(value) 
            4'd0: displayval = 7'b1000000;
            4'd1: displayval = 7'b1111001;
            4'd2: displayval = 7'b0100100;
            4'd3: displayval = 7'b0110000;
            4'd4: displayval = 7'b0011001;
            4'd5: displayval = 7'b0010010;
            4'd6: displayval = 7'b0000010;
            4'd7: displayval = 7'b1111000;
            4'd8: displayval = 7'b0000000;
            4'd9: displayval = 7'b0010000;

            4'd10: displayval = 7'b0001000;
            4'd11: displayval = 7'b0000011;
            4'd12: displayval = 7'b1000110;
            4'd13: displayval = 7'b0100001;
            4'd14: displayval = 7'b0000110;
            4'd15: displayval = 7'b0001110;
            default: displayval = 7'b1111111; // blank
        endcase
        end

        else begin 
            displayval = 7'b1111111;
        end
        
    end
endmodule: display