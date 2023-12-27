`timescale 1ps / 1ps

`define start_p 5'd0
`define read_msg_size 5'd1
`define save_msg_size 5'd2
`define update_i 5'd3
`define read_si 5'd4
`define save_si 5'd5
`define update_j 5'd6
`define read_sj 5'd7
`define save_sj 5'd8
`define write_si 5'd9
`define write_sj 5'd10
`define read_padk 5'd11
`define save_padk 5'd12
`define read_ciphert 5'd13
`define save_ciphert 5'd14
`define write_plaint 5'd15
`define update_k 5'd16
`define write_msg_length 5'd17
`define finish_prga 5'd18

/* 
Outputs: We need these outputs for every state.
rdy

s_addr
--s_rddata
s_wrdata
s_wren


ct_addr
ct_rddata

pt_addr
--pt_rddata
pt_wrdata
pt_wren
*/
module prga(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] s_addr, input logic [7:0] s_rddata, output logic [7:0] s_wrdata, output logic s_wren,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    reg[7:0] value_si = 8'd0; // s[i]
    reg[7:0] value_sj = 8'd0; // s[j]
    reg[7:0] pad_k = 8'd0; // pad[k] = s[(s[i] + s[j]) % 256]
    reg[7:0] ct_k = 8'd0; // ciphertext[k]
    reg[7:0] msg_size = 8'd0;

    /* For the loop counters/ indexes*/
    reg[7:0] i = 8'd0;
    reg[7:0] j = 8'd0;
    reg[7:0] k = 8'd1;
    reg finish_flag = 0;
    reg[7:0] msg_index = 8'd0; /*should always be 0*/

    // for states.
    reg[4:0] present_state;

    always @(posedge clk or negedge rst_n) begin 
        if(rst_n == 0) begin 
            present_state = `start_p;
            
            i = 0;
            j = 0;
            k = 1; /*Go uptil message length and not msg_length-1*/
            msg_index = 0; /*used to read the message index*/

            rdy = 1; /*show the prga is ready to accept*/

            /*S-memory*/
            s_addr = 0;
            s_wrdata = 0;
            s_wren = 0;

            /* ct- memory */
            ct_addr = 0;

            /*pt-memory*/
            pt_addr = 0;
            pt_wrdata = 0;
            pt_wren = 0;
        end
        else begin 
            case (present_state) 
                `start_p: begin 
                    if (en == 1) begin 
                        present_state = `read_msg_size;
                    end
                    else begin 
                        present_state = `start_p;
                    end
                end

                `read_msg_size: begin 
                    present_state = `save_msg_size;
                end

                `save_msg_size: begin 
                    present_state = `update_i;
                    msg_size = ct_rddata; // msg_size = ct[0] -- length of the cipher text.
                end

                // i = (i+1) % 256.
                `update_i: begin 
                    if (msg_size >= 1) begin 
                        present_state = `read_si;
                    end
                    // if message size is 0, no need to do anything
                    else begin 
                        present_state = `finish_prga;
                    end
                    
                end

                // s_addr = i, wren =0, wrdata = 0
                `read_si: begin 
                    present_state = `save_si;
                end

                `save_si: begin 
                    present_state = `update_j;
                    value_si = s_rddata; // value_si = s[i]
                end

                // j = (j + s[i]) % 256.
                `update_j: begin 
                    present_state = `read_sj;
                end

                // s_addr = j,
                `read_sj: begin 
                    present_state = `save_sj;
                end

                `save_sj: begin 
                    present_state = `write_sj; 
                    value_sj = s_rddata;   // value_sj = s[j]                
                end

                // s[j] = s[i]
                // s_addr = j, wren = 1, s_wrdata = value_si
                `write_sj: begin 
                    present_state = `write_si;
                end

                // s[i] = s[j]
                // s_addr = i, wren = 1, s_wrdata = value_sj
                `write_si: begin 
                    present_state = `read_padk;
                end

                // pad_k = s[(s[i]+s[j]) mod 256]
                // s_addr = (s[i]+s[j])%256, wren = 0, wrdata = 0
                `read_padk: begin 
                    present_state = `save_padk;
                end

                `save_padk: begin 
                    present_state = `read_ciphert;
                    pad_k = s_rddata; // pad_k = s[(s[i]+s[j]) mod 256]
                end

                // find ciphertext[k].
                // ct_addr = k
                `read_ciphert: begin 
                    present_state = `save_ciphert;
                end

                `save_ciphert: begin
                    present_state = `write_plaint; 
                    ct_k = ct_rddata; // ct_k = ciphertext[k]
                end

                // pt_addr = k
                // pt_wrdata = pad_k ^ ct_k
                `write_plaint: begin
                    if (finish_flag == 0) begin 
                        present_state = `update_k;
                    end 
                    else begin 
                        present_state = `write_msg_length;
                    end        
                end

                `update_k: begin 
                    present_state = `update_i;
                end

                `write_msg_length: begin 
                    present_state = `finish_prga;
                end

                `finish_prga: begin 
                    if(en == 1) begin 
                        present_state = `read_msg_size;
                    end
                    else begin 
                        present_state = `finish_prga;
                    end
                end

                default: present_state = `start_p;
            
            endcase

            case (present_state) 
                `start_p: begin 
                    

                    /* Set indexes that we will read from.*/
                    i = 0;
                    j = 0;
                    k = 1; /*Go uptil message length and not msg_length-1*/
                    msg_index = 0;

                    rdy = 1; /* Show that prga is ready to start*/
                    finish_flag = 0;

                    /*Initiate all memory interfaces*/
                    /*S-memory*/
                    s_addr = 0;
                    s_wrdata = 0;
                    s_wren = 0;

                    /* ct- memory */
                    ct_addr = 0;

                    /*pt-memory*/
                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0;
                end

                /*message length is stored in ct memory at address 0*/
                `read_msg_size: begin 
                    rdy = 0;

                    s_addr = 0;
                    s_wrdata = 0;
                    s_wren = 0;

                    /* read at ct address ct[0]*/
                    ct_addr = msg_index;

                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0;        
                end

                `save_msg_size: begin
                    rdy = 0;

                    s_addr = 0;
                    s_wrdata = 0;
                    s_wren = 0;

                    ct_addr = 0;

                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0;  
                end

                /* i = (i+1) % 256*/
                `update_i: begin 
                    i = (i+1) % 256;

                    rdy = 0;

                    s_addr = 0;
                    s_wrdata = 0;
                    s_wren = 0;

                    ct_addr = 0;

                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0;
                end

                /*From the s_memory read at index i to get s[i]*/
                `read_si: begin

                    rdy = 0; 

                    s_addr = i;
                    s_wren = 0;
                    s_wrdata = 0;

                    ct_addr = 0;

                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0;
                end

                `save_si: begin 
                    rdy = 0; 
                    s_addr = 0;
                    s_wren = 0;
                    s_wrdata = 0;

                    ct_addr = 0;

                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0;
                end

                /* j = (j+s[i]) % 256*/
                `update_j: begin 
                    j = (j+value_si) % 256;

                    rdy = 0; 
                    s_addr = 0;
                    s_wren = 0;
                    s_wrdata = 0;

                    ct_addr = 0;

                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0;
                end

                /*From the s_memory read at index j to get s[j] */
                `read_sj: begin 
                    rdy = 0; 
                    s_addr = j;
                    s_wren = 0;
                    s_wrdata = 0;

                    ct_addr = 0;

                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0;
                end

                `save_sj: begin 
                    rdy = 0; 
                    s_addr = 0;
                    s_wren = 0;
                    s_wrdata = 0;

                    ct_addr = 0;

                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0;              
                end

                /* At address j write s[i]. Note that it will get written in the next rising edge.*/
                `write_sj: begin
                    rdy = 0;  
                    s_addr = j;
                    s_wren = 1;
                    s_wrdata = value_si;

                    ct_addr = 0;

                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0;  
                end

                /*At this state s[j] = s[i]. Now we write s[j] at address i.
                Note that it will get in the next risign edge of the clock.*/
                `write_si: begin 
                    s_addr = i;
                    s_wren = 1;
                    s_wrdata = value_sj;

                    ct_addr = 0;

                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0;

                    rdy = 0; 
                end

                /*
                pad[k] = s[(s[i]+s[j]) mod 256]
                so we read at address (s[i]+s[j]) % 256.
                */
                `read_padk: begin               
                    s_addr = (value_si + value_sj)%256;
                    s_wrdata = 0;
                    s_wren = 0;

                    ct_addr = 0;

                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0;

                    rdy = 0; 
                end

                `save_padk: begin 
                    rdy = 0; 
                    s_addr = 0;
                    s_wren = 0;
                    s_wrdata = 0;

                    ct_addr = 0;

                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0; 
                end

                /*Now we read at CT memory at address k to get ciphertext[k]*/
                `read_ciphert: begin 
                    rdy = 0; 
                    s_addr = 0;
                    s_wren = 0;
                    s_wrdata = 0;

                    ct_addr = k;

                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0; 
                end

                `save_ciphert: begin
                    rdy = 0; 
                    s_addr = 0;
                    s_wren = 0;
                    s_wrdata = 0;

                    ct_addr = 0;

                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0; 
                end

                /* plaintext[k] = pad[k] xor ciphertext[k]
                So we write in pt memory at address k the value pad_k ^ ct[k]
                Note that write will happen in the next clock cycle.*/
                `write_plaint: begin
                    rdy = 0; 
                    s_addr = 0;
                    s_wren = 0;
                    s_wrdata = 0;

                    ct_addr = 0;

                    pt_addr = k;
                    pt_wrdata = pad_k ^ ct_k;
                    pt_wren = 1;
                end

                /* k = k+1*/
                `update_k: begin 
                    rdy = 0; 
                    s_addr = 0;
                    s_wren = 0;
                    s_wrdata = 0;

                    ct_addr = 0;

                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0; 

                    k = k+1;
                    if (k == msg_size) begin
                        finish_flag = 1; /*shows that we need to iterate only once more.*/
                    end
                    else begin 
                        finish_flag = 0;
                    end
                end

                `write_msg_length: begin 
                    rdy = 0; 
                    s_addr = 0;
                    s_wren = 0;
                    s_wrdata = 0;

                    ct_addr = 0;

                    pt_addr = 0;
                    pt_wrdata = msg_size;
                    pt_wren = 1; 
                end

                `finish_prga: begin 
                    rdy = 1; 
                    s_addr = 0;
                    s_wren = 0;
                    s_wrdata = 0;
                    finish_flag = 0;

                    ct_addr = 0;

                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0;

                    i = 0;
                    j = 0;
                    k = 1;
                    msg_index = 0; 
                end

                default: begin 
                    rdy = 0; 
                    s_addr = 0;
                    s_wren = 0;
                    s_wrdata = 0;

                    ct_addr = 0;

                    pt_addr = 0;
                    pt_wrdata = 0;
                    pt_wren = 0; 
                end
            
            endcase
        end
    end

endmodule: prga
