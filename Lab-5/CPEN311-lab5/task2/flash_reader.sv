module flash_reader(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
                    output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
                    output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
                    output logic [9:0] LEDR);

// You may use the SW/HEX/LEDR ports for debugging. DO NOT delete or rename any ports or signals.

logic clk, rst_n;

assign clk = CLOCK_50;
assign rst_n = KEY[3];

logic flash_mem_read, flash_mem_waitrequest, flash_mem_readdatavalid;
logic [22:0] flash_mem_address;
logic [31:0] flash_mem_readdata;
logic [3:0] flash_mem_byteenable = 4'b1111;

/*
INPUT -----------------------------------------
flash_mem_write              not used, connect to constant 0
flash_mem_burstcount         set to 1

flash_mem_read
flash_mem_address

flash_mem_writedata          leave unconnected
flash_mem_byteenable         set all to 1 

OUTPUT ------------------------------------------
flash_mem_waitrequest
flash_mem_readdatavalid
flash_mem_readdata

-------------------------------------------------
*/
flash flash_inst(.clk_clk(clk), .reset_reset_n(rst_n), .flash_mem_write(1'b0), .flash_mem_burstcount(1'b1),
                 .flash_mem_waitrequest(flash_mem_waitrequest), .flash_mem_read(flash_mem_read), .flash_mem_address(flash_mem_address),
                 .flash_mem_readdata(flash_mem_readdata), .flash_mem_readdatavalid(flash_mem_readdatavalid), .flash_mem_byteenable(flash_mem_byteenable), .flash_mem_writedata());

/* On chip memory. */
logic[7:0] s_mem_addr;
logic[15:0] s_mem_data;
logic[15:0] s_mem_write_enable;
log[15:0] s_mem_rddata;

s_mem samples( .address(s_mem_addr),
                .clock(clk),
                .data(s_mem_data),
                .wren(s_mem_write_enable),
                .q(s_mem_rddata));



assign flash_mem_byteenable = 4'b1111;

// the rest of your code goes here.  don't forget to instantiate the on-chip memory
//start 

/**
wait_for_reset  -> give_address_to_flash -(datavalid = 1)> secure_data_from_flash -> write_to_smem_part1 -> write_to_smem_part2 -> update_index_address -> finish state
WAIT
GADDR
SDATA
SMONE
SMTWO
UPDATEINDEX
FINISH
we should move from give_address_to_flash to secure_data_from_flash when waitrequest is 0 and readdatavalid is 1.

*/

 

//state machine with 3 states
typedef enum {
    WAIT
    GADDR
    SDATA
    SMONE
    SMTWO
    UPDATEINDEX
    FINISH
} state;

// Usage example
state current_state;

reg[7:0] flash_mem_iterato;

reg[7:0] s_mem_iterator;
assign flash_mem_read = flash_mem_iterator;
assign s_mem_addr = s_mem_iterator;


always@(posedge clk or negedge rst_n)  begin
        if(rst_n == 0) begin 
            state =  GADDR;
            flash_mem_iterator = 8'd0;
            s_mem_iterator = 8'd0;
        end

            flash_mem_iterator = 8'd0;
                        WAIT: state = WAIT;

                GADDR: begin 
                    
                end
        
            endcase
        end

                
    

    
end

endmodule: flash_reader