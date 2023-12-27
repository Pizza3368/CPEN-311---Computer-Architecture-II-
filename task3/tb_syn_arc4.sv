`timescale 1ps / 1ps
module tb_rtl_arc4();

// Your testbench goes here.
    reg clk;
    reg reset;
    reg enable;
    reg ready;
    reg[23:0] key;
    reg[7:0] ct_addr;
    reg[7:0] ct_rddata;
    reg[7:0] pt_addr;
    reg[7:0] pt_rddata;
    reg[7:0] pt_wrdata;
    reg pt_wren;

    arc4 dut(
        .clk(clk),
        .rst_n(reset),
        .en(enable),
        .rdy(ready),
        .key(key),
        .ct_addr(ct_addr),
        .ct_rddata(ct_rddata),
        .pt_addr(pt_addr),
        .pt_rddata(pt_rddata),
        .pt_wrdata(pt_wrdata),
        .pt_wren(pt_wren)
    );

    initial forever begin
        clk = 0;
        #5
        clk = 1;
        #5;
    end

    initial begin 
	#2
        // use the key used in task1.
        key[23:10] = 14'b0;
        key[9:0] = 10'b1100111100;
        reset = 0;
        enable = 1;

        //set some random read data from PT and CT
        pt_rddata = 8'd44;
        ct_rddata = 8'd66;

	#15
	reset = 1;
        #30
	enable = 0;
        

        #1000

        $display("Done...");
    end

endmodule: tb_rtl_arc4
