
`timescale 1ps / 1ps

module task1(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    reg enable;
    reg ready;
    reg[7:0] address;
    reg[7:0] data;
    reg write_enable;
    reg[7:0] read_smem; /*Not needed. Having it here for debugging purposes.*/

    /* Initializing the init module.*/
    init data_write(
        .clk(CLOCK_50),
        .rst_n(KEY[3]),
        .en(enable),
        .rdy(ready),
        .addr(address),
        .wrdata(data),
        .wren(write_enable)
    );

    s_mem s(
        .address(address),
        .clock(CLOCK_50),
        .data(data),
        .wren(write_enable),
        .q(read_smem)
    );

    always @(posedge CLOCK_50 or negedge KEY[3]) begin 
        if (KEY[3] == 0) begin 
            enable = ready;
        end
        else begin 
            /* since we do not want init to work after the reset just keep en = 0 if reset != 0 */
            enable = 0;
        end
    end

endmodule: task1
