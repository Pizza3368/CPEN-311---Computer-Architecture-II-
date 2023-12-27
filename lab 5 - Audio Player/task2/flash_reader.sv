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
logic[15:0] s_mem_wrdata;
logic[15:0] s_mem_write_enable;
logic[15:0] s_mem_rddata;

s_mem samples( .address(s_mem_addr),
.clock(clk),
.data(s_mem_wrdata),
.wren(s_mem_write_enable),
.q(s_mem_rddata));


typedef enum logic [3:0] {
WAIT,
GADDR, // wait request
WREADVALID,
SDATA,
SMONE,
SMWAIT,
SMTWO,
UPDATEINDEX,
FINISH
} StateType;

StateType state;

reg[22:0] flash_mem_iterator;
reg[7:0] s_mem_iterator;

reg finish_flag = 0;
assign flash_mem_address = flash_mem_iterator;
assign s_mem_addr = s_mem_iterator;

reg[32:0] value;


always@(posedge clk or negedge rst_n)  begin
    if(rst_n == 0) begin 
        state =  GADDR;
        finish_flag = 0;
        flash_mem_read = 0;
        flash_mem_iterator = 23'd0;
        s_mem_iterator = 8'd0;
    end
    else begin
      case(state)
            WAIT: state = WAIT;

            GADDR: begin 
                if(flash_mem_waitrequest == 0) begin
                  state = WREADVALID;
                end 
                else begin
                   state = GADDR;
                end
            end

            WREADVALID: begin 
              if(flash_mem_readdatavalid == 1) begin 
                state = SDATA;
                value = flash_mem_readdata;
              end
              else begin 
                state = WREADVALID;
              end
            end

            SDATA: state = SMONE;

            SMONE: state = SMWAIT;

            SMWAIT: state = SMTWO;
            
            SMTWO: begin 
                if(finish_flag == 1) begin 
                  state = FINISH;
                end
                else begin 
                  state = UPDATEINDEX;
                end
            end

            UPDATEINDEX: state = GADDR;
            FINISH: state = FINISH;

            default: begin 
              state = WAIT;
            end 
      endcase

      case(state)
        WAIT: begin 
          finish_flag = 0;
          flash_mem_iterator = 8'd0;
          s_mem_iterator = 8'd0;
          s_mem_write_enable = 0;
        end

        GADDR : begin
          flash_mem_read = 1;
          s_mem_write_enable = 0;
        end

        WREADVALID: begin 
          flash_mem_read = 1;
          s_mem_write_enable = 0;
        end

        SDATA: begin
          flash_mem_read = 0;
          s_mem_write_enable = 0;
        end

        SMONE: begin
          HEX0 = value[6:0];
          flash_mem_read = 0;
          s_mem_wrdata = value[15:0];
          s_mem_write_enable = 1;
        end  

        SMWAIT: begin 
          flash_mem_read = 0;
          s_mem_iterator = s_mem_iterator + 8'd1;
          s_mem_write_enable = 0;
        end

        SMTWO: begin 
          flash_mem_read = 0;
          s_mem_wrdata = value[31:16];
          s_mem_write_enable = 1;
        end

        UPDATEINDEX: begin
          flash_mem_read = 0;

          s_mem_iterator = s_mem_iterator + 8'd1;
          flash_mem_iterator = flash_mem_iterator + 23'd1;
          if (s_mem_iterator == 8'd254) begin
            HEX1 = 7'b1111111;
            finish_flag = 1;
          end
          else begin 
            finish_flag = 0;
          end
        end

        FINISH: begin
          flash_mem_read = 0;
          s_mem_write_enable = 0;
        end


        default: begin 
          finish_flag = 0;
          flash_mem_iterator = 8'd0;
          s_mem_iterator = 8'd0;
          s_mem_write_enable = 0;
        end          
      endcase
    end

end



endmodule: flash_reader