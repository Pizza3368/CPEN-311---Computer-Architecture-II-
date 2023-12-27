`timescale 1ps / 1ps

module tb_flash_reader();

logic CLK;
logic [3:0] KEY;
logic [9:0] SW;
logic [9:0] LEDR;
logic [6:0] HEX0;
logic [6:0] HEX1;
logic [6:0] HEX2;
logic [6:0] HEX3;
logic [6:0] HEX4;
logic [6:0] HEX5;

flash_reader dut(CLK, KEY, SW, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR);


  // clock: 
    initial begin
        CLK = 0;
        forever #1 CLK = ~CLK;
    end

    initial begin 
        automatic int count = 1;
        KEY[3] = 1;
            #10
	    KEY[3] = 0;
	    #10;
	    KEY[3] = 1;

        #10000;

        
        for (int i=0;i<256;i++) begin 
            // if i is even then mem_content = i
            if (i % 2 == 0) begin 
                if(dut.samples.altsyncram_component.m_default.altsyncram_inst.mem_data[i] == count) begin 
                    $display("Test passed");
                end
                else begin 
                    $display("Test Failed, Actual: %d, expected: %d",dut.samples.altsyncram_component.m_default.altsyncram_inst.mem_data[i], i );
                end
                count = count + 1;
            end

            // if i is odd then mem_content = 0
            else begin 
                if(dut.samples.altsyncram_component.m_default.altsyncram_inst.mem_data[i] == 0) begin 
                    $display("Test passed");
                end
                else begin 
                    $display("Test Failed, Actual: %d, expected: %d",dut.samples.altsyncram_component.m_default.altsyncram_inst.mem_data[i], i );
                end

            end
        end
    end
endmodule: tb_flash_reader

module flash(input logic clk_clk, input logic reset_reset_n,
             input logic flash_mem_write, input logic [6:0] flash_mem_burstcount,
             output logic flash_mem_waitrequest, input logic flash_mem_read,
             input logic [22:0] flash_mem_address, output logic [31:0] flash_mem_readdata,
             output logic flash_mem_readdatavalid, input logic [3:0] flash_mem_byteenable,
             input logic [31:0] flash_mem_writedata);

// Your simulation-only flash module goes here.
    int value_array[0:19199];

    typedef enum logic [3:0] {
    waitForReadValid,
    setWaitRequestToZero, // wait request
    setReadValidAndSendData
    } StateType;

    StateType state;

    initial begin
        for (int i=0; i<19200; i++) begin 
            value_array[i] = i;
        end
    end


    reg[22:0] addr = 23'd0;
    always @(posedge clk_clk) begin 
        case(state)
            waitForReadValid: begin 
                if (flash_mem_read == 1) begin 
                    state = setWaitRequestToZero;
                end
                else begin 
                    state = waitForReadValid;
                end
            end

            setWaitRequestToZero: begin 
                state = setReadValidAndSendData;
            end

            setReadValidAndSendData: begin 
                state = waitForReadValid;
            end

            default: begin 
                state = waitForReadValid;
            end
        endcase

        case(state)
            waitForReadValid: begin 
                flash_mem_readdata = 32'd0;
                flash_mem_waitrequest = 1;
                flash_mem_readdatavalid = 0;
            end

            setWaitRequestToZero: begin 
                flash_mem_readdata = 32'd0;
                flash_mem_waitrequest = 0;
                flash_mem_readdatavalid = 0;
            end

            setReadValidAndSendData: begin
                addr = addr + 1;
                if (flash_mem_read == 1) begin
                    flash_mem_readdata = value_array[addr];
                end
                else begin 
                    flash_mem_readdata = 32'd0;
                end
                
                flash_mem_waitrequest = 1;
                flash_mem_readdatavalid = 1;
            end

            default: begin 
                flash_mem_readdata = 32'd0;
                flash_mem_waitrequest = 1;
                flash_mem_readdatavalid = 0;
            end
        endcase
    end

endmodule: flash
