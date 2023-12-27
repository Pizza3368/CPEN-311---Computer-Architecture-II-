module tb_syn_crack();

// Your testbench goes here.
reg clk;
reg reset;
reg enable;
reg ready;
reg[23:0] key;
reg key_valid;
reg[7:0] ct_addr;
reg[7:0] ct_rddata;

crack dut(.clk(clk), .rst_n(reset), .en(enable), .rdy(ready), .key(key), .key_valid(key_valid), 
.ct_addr(ct_addr), .ct_rddata(ct_rddata));


initial forever begin
        clk = 0;
        #5
        clk = 1;
        #5;
   end

initial begin 
#2

ct_rddata = 8'd25; // some randome rddata.
reset = 0;
enable =1;

#15

reset = 1;

#30
enable = 0;
end


endmodule: tb_syn_crack
