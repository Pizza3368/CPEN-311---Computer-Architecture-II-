module tb_rtl_prga();

    //inputs:
    reg clk;
    reg reset;
    reg enable;
    reg[23:0] key;
    reg[7:0] s_rddata;
    reg[7:0] ct_rddata;
    reg[7:0] pt_rddata;

    //outputs:
    reg ready;

    reg[7:0] s_addr;
    reg[7:0] s_wrdata;
    reg s_wren;

    reg[7:0] ct_addr;

    reg[7:0] pt_addr;
    reg[7:0] pt_wrdata;
    reg pt_wren;

    prga dut(
        .clk(clk), .rst_n(reset),
        .en(enable), .rdy(ready),
        .key(key),
        .s_addr(s_addr), .s_rddata(s_rddata), .s_wrdata(s_wrdata),
        .s_wren(s_wren),
        .ct_addr(ct_addr), .ct_rddata(ct_rddata),
        .pt_addr(pt_addr), .pt_rddata(pt_rddata), .pt_wrdata(pt_wrdata),
        .pt_wren(pt_wren)
    );

    initial forever begin
		clk = 0;
		#5
		clk = 1;
		#5;
	end

    initial begin 
        reset = 0;
        // set some random rd_data.
        s_rddata = 5'd15;
        ct_rddata = 5'd20;
        pt_rddata = 5'd44;
        
        #5
	reset = 1;
        enable = 1;

    end

endmodule: tb_rtl_prga
