`timescale 1ps / 1ps

module tb_music();

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
logic AUD_DACLRCK;
logic AUD_ADCLRCK;
logic AUD_BCLK;
logic AUD_ADCDAT;
logic FPGA_I2C_SCLK;
logic AUD_DACDAT;
logic AUD_XCK;


wire inout_pin;
reg inout_drive;
wire inout_recv;

assign inout_pin = inout_drive;
assign inout_recv = inout_pin;


// Instantiation of the DUT using named port association
music dut (
    .CLOCK_50(CLK), 
    .CLOCK2_50(CLK), 
    .KEY(KEY), 
    .SW(SW), 
    .AUD_DACLRCK(AUD_DACLRCK), 
    .AUD_ADCLRCK(AUD_ADCLRCK), 
    .AUD_BCLK(AUD_BCLK), 
    .AUD_ADCDAT(AUD_ADCDAT),
    .FPGA_I2C_SDAT(inout_pin), // Correct named association for inout port
    .FPGA_I2C_SCLK(FPGA_I2C_SCLK), // Named association for outputs
    .AUD_DACDAT(AUD_DACDAT),
    .AUD_XCK(AUD_XCK),
    .HEX0(HEX0), // Named association for all HEX outputs
    .HEX1(HEX1),
    .HEX2(HEX2),
    .HEX3(HEX3),
    .HEX4(HEX4),
    .HEX5(HEX5),
    .LEDR(LEDR)  // Named association for LEDR output
);

initial begin
        CLK = 0;
        forever #1 CLK = ~CLK;
end

initial begin 
    inout_drive = 1'bz; 
    KEY[3] = 1;
    #10
    inout_drive = 1'b0;
	KEY[3] = 0;
	#10;
	KEY[3] = 1;
end



endmodule: tb_music



module audio_codec (
// Inputs
CLOCK_50,
reset,

read_s,	write_s,
writedata_left, writedata_right,

AUD_ADCDAT,

// Bidirectionals
AUD_BCLK,
AUD_ADCLRCK,
AUD_DACLRCK,

// Outputs
read_ready, write_ready,
readdata_left, readdata_right,
AUD_DACDAT
);

parameter AUDIO_DATA_WIDTH	= 16;
parameter BIT_COUNTER_INIT	= 5'd23;

input				CLOCK_50;
input				reset;

input					read_s;
input					write_s;
input	[AUDIO_DATA_WIDTH-1:0]	writedata_left;
input	[AUDIO_DATA_WIDTH-1:0]	writedata_right;

input				AUD_ADCDAT;
input				AUD_BCLK;
input				AUD_ADCLRCK;
input				AUD_DACLRCK;

// Outputs
output		reg	read_ready, write_ready;
output	[AUDIO_DATA_WIDTH-1:0]	readdata_left;
output	[AUDIO_DATA_WIDTH-1:0]	readdata_right;


output			AUD_DACDAT;

typedef enum logic [3:0] {
waitForWriteS, // keep write_ready 1
AcceptData, // keep write_ready1
signalAnother // set write_ready to 0
} StateType;

StateType state;

always @(posedge CLOCK_50) begin 
    case(state)
        waitForWriteS: begin 
            if(write_s == 1) begin 
                state = AcceptData;
            end
            else begin 
                state = waitForWriteS;
            end
        end

        AcceptData: begin 
            state = signalAnother;
        end
        
        signalAnother: begin 
            state = waitForWriteS;
        end

        default: begin 
            state = waitForWriteS;
        end
    endcase

    case(state) 
        waitForWriteS: begin 
            write_ready = 1;
        end

        AcceptData: begin 
            write_ready = 1;
            $display("write_data_left: %d", writedata_left);
            $display("write_data_right: %d", writedata_right);
        end
        
        signalAnother: begin 
            write_ready = 0;
        end

        default: begin 
            write_ready = 1;
        end
    
    endcase

end


endmodule: audio_codec


// simulation of the flash_module
module flash(input logic clk_clk, input logic reset_reset_n,
             input logic flash_mem_write, input logic [6:0] flash_mem_burstcount,
             output logic flash_mem_waitrequest, input logic flash_mem_read,
             input logic [22:0] flash_mem_address, output logic [31:0] flash_mem_readdata,
             output logic flash_mem_readdatavalid, input logic [3:0] flash_mem_byteenable,
             input logic [31:0] flash_mem_writedata);

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
                    flash_mem_readdata = value_array[addr] * 16'd64;
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
