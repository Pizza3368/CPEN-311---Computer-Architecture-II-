`timescale 1 ps / 1 ps
`define start__C 5'd1
`define wait_rdy_arc4 5'd2
`define starts_arc4 5'd3
`define wait_arc4_finish 5'd4
`define read_mesg_size 5'd5
`define save_mesg_size 5'd6
`define get_mesg_size 5'd7
`define updatei 5'd8
`define read_pti 5'd9
`define save_pti 5'd10
`define check_pti 5'd11
`define cont_stop 5'd12
`define update_key 5'd13
`define finish_found 5'd14
`define finish_not_found 5'd15
/*
Outputs:
ct_addr
ct_rddata
key
key_valid
rdy

*/
module crack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata);

    reg en_arc4;
    reg rdy_arc4;

    /*For pt*/
    reg [7:0] pt_addr;
    reg[7:0] pt_rddata;
    reg[7:0] pt_wrdata;
    reg pt_wren;

    /*For arc4 pt*/
    reg [7:0] pt_addr_arc4;
    reg[7:0] pt_rddata_arc4;
    reg[7:0] pt_wrdata_arc4;
    reg pt_wren_arc4;

    /* CT only communicates with arc4.*/

    reg[7:0] i= 8'd0; /* Index to read from PT memory.*/
    reg[7:0] msg_size; /*To store the message size */
    reg finish_flag_i = 0; /*Only set to 1 when i reaches message size.*/
    reg finish_flag_key = 0; /*Only set to 1 when key reaches max for key*/
    reg[7:0] value_pti; /*To store the value at pt[i] */
    
    reg valid_char = 0;
    reg[4:0] present_state = `start__C;
    
     // this memory must have the length-prefixed plaintext if key_valid
    pt_mem pt(
        .address(pt_addr),
        .clock(clk),
        .data(pt_wrdata),
        .wren(pt_wren),
        .q(pt_rddata)
    );

    arc4 a4(
        .clk(clk),
        .rst_n(rst_n),
        .en(en_arc4),
        .rdy(rdy_arc4),
        .key(key),
        .ct_addr(ct_addr),
        .ct_rddata(ct_rddata),
        .pt_addr(pt_addr_arc4),
        .pt_rddata(pt_rddata_arc4),
        .pt_wrdata(pt_wrdata_arc4),
        .pt_wren(pt_wren_arc4)
     );

    always @(posedge clk or negedge rst_n) begin 
        
        if(rst_n == 0) begin 
            present_state = `start__C;
            
            rdy = 1;
            key_valid = 0;
            key = 24'd0;
           
            i = 0;
            msg_size = 0;
            finish_flag_i = 0;
            finish_flag_key = 0;
            value_pti = 0;           
                       
		    en_arc4 = 0;

            /* We want arc4 to communicate with PT*/
            pt_addr = pt_addr_arc4;
            pt_wrdata = pt_wrdata_arc4;
            pt_rddata_arc4 = pt_rddata;
            pt_wren = pt_wren_arc4;

        end
        else begin 
            case(present_state) 

                /* stay in this state until enable is 1.*/
                `start__C: begin 
                    if (en == 1) begin 
                        present_state = `wait_rdy_arc4;
                    end
                    else begin 
                        present_state = `start__C;
                    end
                end

                /*wait for arc4 to be ready, if ready go to start arc4 otherwise stay in this state. */
                `wait_rdy_arc4: begin 
                    if (rdy_arc4 == 1) begin 
                        present_state = `starts_arc4;
                    end
                    else begin 
                        present_state = `wait_rdy_arc4;
                    end
                end

                /* starting arc4 and then going to wait for arc4 to finish.*/
                `starts_arc4: begin 
                    present_state = `wait_arc4_finish;
                end

                /*stay in this state until arc4 is done. */
                `wait_arc4_finish: begin 
                    if(rdy_arc4 == 0) begin 
                        present_state = `wait_arc4_finish;
                    end
                    else begin 
                        present_state = `read_mesg_size;
                    end
                end

                /* For the whole process we need the message size of the cipher text.*/
                `read_mesg_size: begin 
                    present_state = `save_mesg_size;
                end

                /* save the message size in msg_size variable.*/
                `save_mesg_size: begin 
                    present_state = `get_mesg_size;
                    msg_size = ct_rddata;
                end

                `get_mesg_size: begin 
                    present_state = `updatei;
                    msg_size = ct_rddata;
                end
                
                /* increment i. Note that we want to start the crack process with i=1, since we read at pt[1] and not pt[0]*/
                `updatei: begin 
                    present_state = `read_pti;
                end

                /* read the value of pt[i] */
                `read_pti: begin 
                    present_state = `save_pti;
                end

                /* save pt[i] in value_pti and then go to check: pt[i]*/
                `save_pti: begin 
                    present_state = `check_pti;
                    value_pti = pt_rddata;
                end

                /* check the value pt[i] and set valid char based on that.*/
                `check_pti: begin 
                    present_state = `cont_stop;
                end

                /* Decide where to go after one iteration.*/
                `cont_stop: begin
                    /* if last character in PT is valid.*/ 
                    if (valid_char == 1 && finish_flag_i == 1) begin 
                        present_state = `finish_found;
                    end

                    /*Midway character is valid but it not the last character so continue iterating. */
                    else if (valid_char == 1 && finish_flag_i == 0) begin 
                        present_state = `updatei;
                    end

                    /* Character found that is not valid. Does not matter if it is last or midway.*/
                    /* If there is scope for key go to the whole process with another key then go and increment the key
                    otherwise say that key not found.*/
                    else begin 
                        if (finish_flag_key == 0) begin 
                            present_state = `update_key;
                        end
                        else begin 
                            present_state = `finish_not_found;
                        end

                    end
                end

                /*update the key wait for arc4 to be ready again. Now with a new key. */
                `update_key: begin 
                    present_state = `wait_rdy_arc4;
                end

                /* found! Then go to start and wait for another en = 1*/
                `finish_found: begin 
                    present_state = `finish_found;
                end

                /*Not found they go to start and wait for another en =1 */
                `finish_not_found: begin 
                    present_state = `finish_not_found;
                end     

                default: present_state = `start__C;
            endcase

            /* What to do in each state*/
            case (present_state) 

                /*Only show what crack module is ready*/
                `start__C: begin 
                    /*show that crack is ready */
                    rdy = 1; 
                    key_valid = 0;
                    key = 24'd0;
                    /*initialize the datas. */
                     i = 0;
                     msg_size = 0;
                     finish_flag_i = 0;

                     finish_flag_key = 0;
                     value_pti = 0;   
                                 
                     en_arc4 = 0;
                     valid_char = 0;

                     /* We want arc4 to communicate with PT*/
                    pt_addr = pt_addr_arc4;
                    pt_wrdata = pt_wrdata_arc4;
                    pt_wren = pt_wren;
                    pt_rddata_arc4 = pt_rddata;
                end

                `wait_rdy_arc4: begin 
                    rdy = 0; 
                    key_valid = 0;

                    /* We want arc4 to communicate with PT*/
                    pt_addr = pt_addr_arc4;
                    pt_wrdata = pt_wrdata_arc4;
                    pt_rddata_arc4 = pt_rddata;
                    pt_wren = pt_wren_arc4;

                end

                `starts_arc4: begin 
                    rdy = 0; 
                    key_valid = 0;
                    /* Since arc4 is ready to accept data*/
                    en_arc4 = 1;

                    /* We want arc4 to communicate with PT*/
                    pt_addr = pt_addr_arc4;
                    pt_wrdata = pt_wrdata_arc4;
                    pt_rddata_arc4 = pt_rddata;
                    pt_wren = pt_wren_arc4;
                end

                `wait_arc4_finish: begin 
                    rdy = 0;
                    en_arc4 = 0;

                    /* We want arc4 to communicate with PT*/
                    pt_addr = pt_addr_arc4;
                    pt_wrdata = pt_wrdata_arc4;
                    pt_rddata_arc4 = pt_rddata;
                    pt_wren = pt_wren_arc4;

                end

                /*We read message size from the PT memory. */
                `read_mesg_size: begin 
                    rdy = 0; 
                    key_valid = 0;
                    en_arc4 = 0;

                    /* We want to get message size from PT*/
                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0;

                end

                `save_mesg_size: begin 
                    rdy = 0; 
                    key_valid = 0;


                    /* We want arc4 to communicate with PT*/
                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0;
                end

                `get_mesg_size: begin 
                    rdy = 0;
                    key_valid = 0;

                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0;
                end

                `updatei: begin 
                    rdy = 0;
                    key_valid = 0;
                    i = i+1;

                    /* Now we want PT to communicate with this module.*/
                    pt_addr = i;
                    pt_wrdata = 0;
                    pt_wren = 0;

                    if (i == msg_size) begin 
                        finish_flag_i = 1;
                    end
                    else begin 
                        finish_flag_i = 0;
                    end
                end

                `read_pti: begin 
                    rdy = 0;
                    key_valid = 0;
                    /* we need to read at pt_addr = i*/
                    pt_addr = i;
                    pt_wrdata = 0;
                    pt_wren = 0;           
                end

                `save_pti: begin 
                    rdy = 0;
                    key_valid = 0;

                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0;
                end

                `check_pti: begin 
                    rdy = 0;
                    key_valid = 0;
                    /*values between ’h20 and ’h7E inclusive */
                    if (value_pti >= 'h20 && value_pti <= 'h7E) begin 
                        valid_char = 1;
                    end
                    else begin 
                        valid_char = 0;
                    end

                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0;
                end

                `cont_stop: begin 
                    rdy = 0; /*Do nothing because this state will decide which state to go to. */
                    key_valid = 0;

                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0;

                end

                /*When we update the key this will start arc4 again.
                So, we want i =0 */
                `update_key: begin 
                    key = key+1;
                    i = 0;
                    if (key == 24'b111111111111111111111111) begin 
                        finish_flag_key = 1;
                    end
                    else begin 
                        finish_flag_key = 0;
                    end

                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0;
                end

                `finish_found: begin 
                    rdy = 1; /*We found the key*/
                    key_valid = 1;

                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0;
                end

                `finish_not_found: begin 
                    rdy = 1;
                    key_valid = 0;

                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0;
                end   
            endcase
        end
    end

endmodule: crack
