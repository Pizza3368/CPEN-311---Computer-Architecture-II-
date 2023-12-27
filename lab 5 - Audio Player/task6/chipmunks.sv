module chipmunks(input CLOCK_50, input CLOCK2_50, input [3:0] KEY, input [9:0] SW,
             input AUD_DACLRCK, input AUD_ADCLRCK, input AUD_BCLK, input AUD_ADCDAT,
             inout FPGA_I2C_SDAT, output FPGA_I2C_SCLK, output AUD_DACDAT, output AUD_XCK,
             output [6:0] HEX0, output [6:0] HEX1, output [6:0] HEX2,
             output [6:0] HEX3, output [6:0] HEX4, output [6:0] HEX5,
             output [9:0] LEDR);
			
// signals that are used to communicate with the audio core
// DO NOT alter these -- we will use them to test your design

reg read_ready, write_ready, write_s;
reg [15:0] writedata_left, writedata_right;
reg [15:0] readdata_left, readdata_right;	
wire reset, read_s;


assign read_s = 1'b0;
assign reset = ~(KEY[3]);

// signals that are used to communicate with the flash core
// DO NOT alter these -- we will use them to test your design

reg flash_mem_read;
reg flash_mem_waitrequest;
reg [22:0] flash_mem_address;
reg signed [31:0] flash_mem_readdata;
reg flash_mem_readdatavalid;
reg [3:0] flash_mem_byteenable;
reg rst_n, clk;

// DO NOT alter the instance names or port names below -- we will use them to test your design

clock_generator my_clock_gen(CLOCK2_50, reset, AUD_XCK);
audio_and_video_config cfg(CLOCK_50, reset, FPGA_I2C_SDAT, FPGA_I2C_SCLK);
audio_codec codec(CLOCK_50,reset,read_s,write_s,writedata_left, writedata_right,AUD_ADCDAT,AUD_BCLK,AUD_ADCLRCK,AUD_DACLRCK,read_ready, write_ready,readdata_left, readdata_right,AUD_DACDAT);

//code for pin assignment
assign clk = CLOCK_50;
assign rst_n = KEY[3];
assign flash_mem_byteenable = 4'b1111;

flash flash_inst(.clk_clk(clk), .reset_reset_n(rst_n), .flash_mem_write(1'b0), .flash_mem_burstcount(1'b1),
                 .flash_mem_waitrequest(flash_mem_waitrequest), .flash_mem_read(flash_mem_read), .flash_mem_address(flash_mem_address),
                 .flash_mem_readdata(flash_mem_readdata), .flash_mem_readdatavalid(flash_mem_readdatavalid), .flash_mem_byteenable(flash_mem_byteenable), .flash_mem_writedata());

// your code for the rest of this task here
typedef enum logic [4:0] {
waitForReset, // waiting for reset
giveFlashAddress,
waitReadValid,
secureFlashData,
waitUntilWriteReady,
stateSendSample,
stateWaitForAccept,
waitUntilWriteReady2,
stateSendSample2,
stateWaitForAccept2,
updateAddress
} StateType;

StateType state;

reg signed[31:0] flash_mem_value;

/**

Things to handle in each state:
writedata_right 
writedata_left 
write_s;
flash_mem_read
*/
reg[22:0] flash_mem_iterator;
assign flash_mem_address = flash_mem_iterator;
reg[1:0] count1;
reg[1:0] count2;

always @(posedge clk or negedge rst_n) begin 
    if(rst_n == 0) begin 
        state = giveFlashAddress;
        flash_mem_iterator = 23'd0;
        writedata_right = 16'd0;
        writedata_left = 16'd0;
        write_s = 0;
        flash_mem_read = 0;
        count1 = 2'd0;
        count2 = 2'd0;
    end

    else begin 
        case(state) 
            waitForReset: begin 
                state = waitForReset;
            end

            giveFlashAddress: begin 
                if(flash_mem_waitrequest == 0) begin
                  state = waitReadValid;
                end 
                else begin
                   state = giveFlashAddress;
                end
            end

            waitReadValid: begin 
                if(flash_mem_readdatavalid == 1) begin 
                    state = secureFlashData;
                    flash_mem_value = flash_mem_readdata;
                end
                else begin 
                    state = waitReadValid;
                end
            end

            secureFlashData: begin 
                state = waitUntilWriteReady;
            end

            waitUntilWriteReady: begin 
                if(write_ready == 1) begin 
                    state = stateSendSample;
                end

                else state = waitUntilWriteReady;
            end
            
            stateSendSample: begin 
                state = stateWaitForAccept;
            end
            
            stateWaitForAccept: begin 
                if(write_ready == 0) begin 
                    

                    // slow mode.
                    if(SW[1:0] == 2'b10) begin 
                        if (count1 == 2'd0) begin
                            count1 = count1 +2'd1; 
                            state = waitUntilWriteReady;
                        end

                        else begin 
                            count1 = 2'd0;
                            state = waitUntilWriteReady2;
                        end
                    end

                    // fast mode.
                    else if(SW[1:0] == 2'b01) begin 
                        state = updateAddress;
                    end

                    // normal mode.
                    else begin 
                        state = waitUntilWriteReady2;
                    end
                        
                end

                else begin 
                    state = stateWaitForAccept;
                end
            end

            waitUntilWriteReady2: begin 
                if(write_ready == 1) begin 
                    state = stateSendSample2;
                end

                else state = waitUntilWriteReady2;
            end
            
            stateSendSample2: begin 
                state = stateWaitForAccept2;
            end
            
            stateWaitForAccept2: begin 
                if(write_ready == 0) begin 
                    
                    //slow mode
                    if(SW[1:0] == 2'b10) begin 
                        if (count2 == 2'd0) begin
                            count2 = count2 +2'd1; 
                            state = waitUntilWriteReady2;
                        end

                        else begin 
                            count2 = 2'd0;
                            state = updateAddress;
                        end
                    end

                    //normal mode
                    else begin 
                        state = updateAddress;
                    end
                end

                else begin 
                    state = stateWaitForAccept2;
                end
            end

            updateAddress: begin 
                state = giveFlashAddress;
            end

            default: begin 
                state = waitForReset;
                
            end
        endcase

        

        case(state) 
            waitForReset: begin
                count1 = 2'd0;
                 count2 = 2'd0;
                flash_mem_iterator = 23'd0;
                writedata_right = 16'd0;
                writedata_left = 16'd0;
                write_s = 0;
                flash_mem_read = 0;  
            end

            giveFlashAddress: begin
                writedata_right = 16'd0;
                writedata_left = 16'd0;
                write_s = 0;
                flash_mem_read = 1;
            end

            waitReadValid: begin
                writedata_right = 16'd0;
                writedata_left = 16'd0;
                write_s = 0;
                flash_mem_read = 1;
            end

            secureFlashData: begin 
                writedata_right = 16'd0;
                writedata_left = 16'd0;
                write_s = 0;
                flash_mem_read = 0;
            end

            waitUntilWriteReady: begin
                writedata_right = $signed(flash_mem_value[15:0]) / $signed(16'd64);
                writedata_left = $signed(flash_mem_value[15:0]) / $signed(16'd64);
                write_s = 0;
                flash_mem_read = 0;               
            end
            
            stateSendSample: begin 
                writedata_right = $signed(flash_mem_value[15:0]) / $signed(16'd64);
                writedata_left = $signed(flash_mem_value[15:0]) / $signed(16'd64);
                write_s = 1;
                flash_mem_read = 0; 
                
            end
            
            stateWaitForAccept: begin 
                writedata_right = $signed(flash_mem_value[15:0]) / $signed(16'd64);
                writedata_left = $signed(flash_mem_value[15:0]) / $signed(16'd64);
                write_s = 1;
                flash_mem_read = 0; 
            end

            waitUntilWriteReady2: begin  
                writedata_right = $signed(flash_mem_value[31:16]) / $signed(16'd64);
                writedata_left = $signed(flash_mem_value[31:16]) / $signed(16'd64);
                write_s = 0;
                flash_mem_read = 0; 
            end
            
            stateSendSample2: begin 
                writedata_right = $signed(flash_mem_value[31:16]) / $signed(16'd64);
                writedata_left = $signed(flash_mem_value[31:16]) / $signed(16'd64);
                write_s = 1;
                flash_mem_read = 0; 
                
            end
            
            stateWaitForAccept2: begin 
                writedata_right = $signed(flash_mem_value[31:16]) / $signed(16'd64);
                writedata_left = $signed(flash_mem_value[31:16]) / $signed(16'd64);
                write_s = 1;
                flash_mem_read = 0; 
            end

            updateAddress: begin
                
                writedata_right = 16'd0;
                writedata_left = 16'd0;
                write_s = 0;
                flash_mem_read = 0;  
                flash_mem_iterator = flash_mem_iterator + 1;

                if (flash_mem_iterator > 23'd1048575) begin
                    flash_mem_iterator = 0;
                end
            end

            default: begin
                count1 = 2'd0;
                count2 = 2'd0;
                flash_mem_iterator = 23'd0; 
                writedata_right = 16'd0;
                writedata_left = 16'd0;
                write_s = 0;
                flash_mem_read = 0;
            end
        endcase
    end

end


endmodule: chipmunks
