`timescale 1 ps / 1 ps

`define wait_for_en 5'd0
`define read_main_ct 5'd1
`define save_main_ct 5'd2
`define write_child_ct 5'd3
`define increment_ct_iter 5'd4
`define wait_crack_ready 5'd5
`define start_crack 5'd7
`define wait_crack_finish 5'd9

// states if crack1 is done, if valid key found then we need to copy child PT of crack to main PT.
`define read_child_pt_crack1 5'd10
`define save_child_pt_crack1 5'd11
`define write_main_pt_crack1 5'd12
`define increment_pt_iter_crack1 5'd13


`define read_child_pt_crack2 5'd14
`define save_child_pt_crack2 5'd15
`define write_main_pt_crack2 5'd16
`define increment_pt_iter_crack2 5'd17

`define finish_dc_not_found 5'd18
`define finish_dc_found 5'd19



module doublecrack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata);

    reg[7:0] pt_addr_main;
    reg [7:0] pt_wrdata_main;
    reg pt_wren_main;
    reg[7:0] pt_rddata_main;

    pt_mem pt( 
        .address(pt_addr_main),
        .clock(clk),
        .data(pt_wrdata_main),
        .wren(pt_wren_main),
        .q(pt_rddata_main));

    // crack-1 will write to this PT as it does work.
    // crack-1 will use this ct memory to read from.
    reg[7:0] pt_addr_crack1;
    reg[7:0] pt_wrdata_crack1;
    reg pt_wren_crack1;
    reg[7:0] pt_rddata_crack1;

    reg[7:0] pt_addr_copy1;
    reg[7:0] pt_wrdata_copy1;
    reg pt_wren_copy1;
    reg[7:0] pt_rddata_copy1;

    reg[7:0] ct_addr_copy1;
    reg[7:0] ct_wrdata_copy1;
    reg ct_wren_copy1;
    reg [7:0] ct_rddata_copy1;

    reg[7:0] ct_addr_crack1;
    reg[7:0] ct_rddata_crack1;

    reg en_crack1;
    reg rdy_crack1;
    reg[23:0] key_crack1;
    reg is_key_valid_crack1;

    pt_mem pt_crack1 (
        .address(pt_addr_copy1),
        .clock(clk),
        .data(pt_wrdata_copy1),
        .wren(pt_wren_copy1),
        .q(pt_rddata_copy1)
    );

    s_mem ct_copy_crack1 (
        .address(ct_addr_copy1),
        .clock(clk),
        .data(ct_wrdata_copy1),
        .wren(ct_wren_copy1),
        .q(ct_rddata_copy1)
    );

    crack c1(.clk(clk), .rst_n(rst_n), .en(en_crack1), .rdy(rdy_crack1),
    .key(key_crack1), .key_valid(is_key_valid_crack1), .init_val_key(24'd0),
     .ct_addr(ct_addr_crack1), .ct_rddata(ct_rddata_crack1), 
     .pt_write_data(pt_wrdata_crack1), .pt_address(pt_addr_crack1), .pt_write_enable(pt_wren_crack1));


    // crack-2 will write to this PT as it does work.
    // creack-2 will use this CT memory to read from -- First we need to copy the CT contents to this.
    reg[7:0] pt_addr_crack2;
    reg[7:0] pt_wrdata_crack2;
    reg pt_wren_crack2;
    reg[7:0] pt_rddata_crack2;


    reg[7:0] pt_addr_copy2;
    reg[7:0] pt_wrdata_copy2;
    reg pt_wren_copy2;
    reg[7:0] pt_rddata_copy2;

    reg[7:0] ct_addr_copy2;
    reg[7:0] ct_wrdata_copy2;
    reg ct_wren_copy2;
    reg [7:0] ct_rddata_copy2;

    reg[7:0] ct_addr_crack2;
    reg[7:0] ct_rddata_crack2;

    reg en_crack2;
    reg rdy_crack2;
    reg[23:0] key_crack2;
    reg is_key_valid_crack2;

    pt_mem pt_crack2 (
        .address(pt_addr_copy2),
        .clock(clk),
        .data(pt_wrdata_copy2),
        .wren(pt_wren_copy2),
        .q(pt_rddata_copy2)
    );

    s_mem ct_copy_crack2 (
        .address(ct_addr_copy2),
        .clock(clk),
        .data(ct_wrdata_copy2),
        .wren(ct_wren_copy2),
        .q(ct_rddata_copy2)
    );

    crack c2(.clk(clk), .rst_n(rst_n), .en(en_crack2), .rdy(rdy_crack2),
    .key(key_crack2), .key_valid(is_key_valid_crack2), .init_val_key(24'd1),
     .ct_addr(ct_addr_crack2), .ct_rddata(ct_rddata_crack2), 
     .pt_write_data(pt_wrdata_crack2), .pt_address(pt_addr_crack2), .pt_write_enable(pt_wren_crack2));
    
    // At first we want to copy the content in the main CT mem to the two child CT mem.
    // so we want, ct_addr to be 0 and get value at 0. Write the value to copy1 and copy2.

    reg[7:0] iter_ct = 8'd0;
    reg[7:0] value_ct = 8'd0;
    reg is_read_msg_size = 0;
    reg[7:0] msg_size = 8'd0;
    reg finish_flag_ct_iter = 0;

    reg[4:0] present_state = `wait_for_en;

    reg [7:0] pt_crack1_iter = 8'd0;
    reg[7:0] value_child_pt1 = 8'd0;
    reg finish_flag_crack1_iter = 0;

    reg[7:0] pt_crack2_iter = 8'd0;
    reg[7:0] value_child_pt2 = 8'd0;
    reg finish_flag_crack2_iter = 0;

    reg[1:0] selCT = 2'b01; // 00 -> write to itslef. // 01 -> default // 11 -> connect to crack.
    reg[1:0] selPT = 2'b11;
    reg[1:0] selPT2 = 2'b11;

    always @(posedge clk or negedge rst_n) begin 
        if(rst_n == 0) begin 
            present_state = `wait_for_en;

            rdy = 1;
            iter_ct = 0;
            value_ct = 0;

            ct_addr = 0;

            key = 24'd0; // set main key output to 0.
            key_valid = 0;

            en_crack1 = 0;
            en_crack2 = 0;

            selCT = 2'b01;
            selPT = 2'b11;
            selPT2 = 2'b11;
            
            finish_flag_ct_iter = 0;
        end

        else begin 
            case (present_state) 
                `wait_for_en: begin 
                    if(en == 1) begin 
                        present_state = `read_main_ct;
                    end
                    else begin 
                        present_state = `wait_for_en;
                    end
                end

                `read_main_ct: begin 
                    present_state = `save_main_ct;
                end

                `save_main_ct: begin 
                    present_state = `write_child_ct;
                    if (is_read_msg_size == 1) begin 
                        msg_size = ct_rddata;
                        value_ct = ct_rddata;
                    end
                    else begin 
                        value_ct = ct_rddata;
                    end
                end

                `write_child_ct: begin 
                    if (finish_flag_ct_iter == 1) begin 
                        present_state = `wait_crack_ready;
                    end
                    else begin 
                        present_state = `increment_ct_iter;
                    end
                end

                `increment_ct_iter: begin 
                    present_state = `read_main_ct;
                end

                `wait_crack_ready: begin 
                    if (rdy_crack1 == 1 && rdy_crack2 == 1) begin 
                        present_state = `start_crack;
                    end
                    else begin 
                        present_state = `wait_crack_ready;
                    end
                end

                `start_crack: begin 
                    present_state = `wait_crack_finish;   
                end

                `wait_crack_finish: begin 
                    // stay in this state until both the crack are doing work.
                    if(rdy_crack1 == 0 && rdy_crack2 == 0) begin 
                        present_state = `wait_crack_finish;
                    end

                    // we go to the else part when one of the cracks are done.
                    else begin 
                        if (is_key_valid_crack1 == 1) begin 
                            present_state = `read_child_pt_crack1;
                        end

                        else if (is_key_valid_crack2 == 1) begin 
                            present_state = `read_child_pt_crack2;
                        end

                        // none of them found the key.
                        else begin 
                            present_state = `finish_dc_not_found;
                        end
                    end
                end

                `read_child_pt_crack2: begin 
                    present_state = `save_child_pt_crack2;
                end

                `save_child_pt_crack2: begin 
                    present_state = `write_main_pt_crack2;
                    value_child_pt2 = pt_rddata_copy2;
                end

                `write_main_pt_crack2: begin 
                    if (finish_flag_crack2_iter == 1) begin 
                        present_state = `finish_dc_found;
                    end
                    else begin 
                        present_state = `increment_pt_iter_crack2;
                    end
                end

                `increment_pt_iter_crack2: begin 
                    present_state = `read_child_pt_crack2;
                end

                `read_child_pt_crack1: begin 
                    present_state = `save_child_pt_crack1;
                end

                `save_child_pt_crack1: begin 
                    present_state = `write_main_pt_crack1;
                    value_child_pt1 = pt_rddata_copy1;
                end

                `write_main_pt_crack1: begin 
                    if (finish_flag_crack1_iter) begin 
                        present_state = `finish_dc_found;
                    end
                    else begin 
                        present_state = `increment_pt_iter_crack1;
                    end
                end

                `increment_pt_iter_crack1: begin 
                    present_state = `read_child_pt_crack1;
                end

                `finish_dc_found: begin 
                    present_state = `finish_dc_found;
                end
                
                

                default: present_state = `wait_for_en;
            endcase


            case (present_state)

                 
                `wait_for_en: begin 
                    rdy = 1;
                    iter_ct = 0;
                    value_ct = 0;

                    ct_addr = 0;

                    key = 24'd0;
                    key_valid = 0;

                    en_crack1 = 0;
                    en_crack2 = 0;

                    /* Need to decide what ct_copy1 and ct_copy2 is connected to - its crack or */
                    /* Need to decide what Pt_copy1 and pt_copy2 is connected to */
                    selCT = 2'b01;

                    // we want pt-child1 to communicate with its crack
                    selPT = 2'b11;
                    selPT2 = 2'b11;

                    finish_flag_ct_iter = 0;

                    pt_addr_main = 0;
                    pt_wrdata_main = 0;
                    pt_wren_main = 0;

                    key = 24'b0;
                    key_valid = 0;
                end

                `read_main_ct: begin 
                    
                    rdy = 0;
                    ct_addr = iter_ct;

                    en_crack1 = 0;
                    en_crack2 = 0;

                    if (iter_ct == 0) begin 
                        is_read_msg_size = 1;
                    end
                    else begin 
                        is_read_msg_size = 0;
                    end

                    selCT = 2'b01;

                    // we want pt-child1 to communicate with its crack
                    selPT = 2'b11;
                    selPT2 = 2'b11;

                    pt_addr_main = 0;
                    pt_wrdata_main = 0;
                    pt_wren_main = 0;

                    key = 24'b0;
                    key_valid = 0;
                end

                `save_main_ct: begin 
                    rdy = 0;
                    ct_addr = 0;

                    en_crack1 = 0;
                    en_crack2 = 0;

                    selCT = 2'b01;

                    // we want pt-child1 to communicate with its crack
                    selPT = 2'b11;
                    selPT2 = 2'b11;

                    pt_addr_main = 0;
                    pt_wrdata_main = 0;
                    pt_wren_main = 0;

                    key = 24'b0;
                    key_valid = 0;
                end

                `write_child_ct: begin 
                    rdy = 0;
                    ct_addr = 0;

                    en_crack1 = 0;
                    en_crack2 = 0;

                    selCT = 2'b00;

                    // we want pt-child1 to communicate with its crack
                    selPT = 2'b11;
                    selPT2 = 2'b11;

                    pt_addr_main = 0;
                    pt_wrdata_main = 0;
                    pt_wren_main = 0;

                    key = 24'b0;
                    key_valid = 0;
                end

                `increment_ct_iter: begin 
                    rdy = 0;
                    ct_addr = 0;

                    en_crack1 = 0;
                    en_crack2 = 0;

                    selCT = 2'b01;

                    iter_ct = iter_ct + 8'd1;

                    if (iter_ct == msg_size) begin 
                        finish_flag_ct_iter = 1;
                    end
                    else begin 
                        finish_flag_ct_iter = 0;
                    end

                    // we want pt-child1 to communicate with its crack
                    selPT = 2'b11;
                    selPT2 = 2'b11;

                    pt_addr_main = 0;
                    pt_wrdata_main = 0;
                    pt_wren_main = 0;

                    key = 24'b0;
                    key_valid = 0;
                end

                // now we want ct_copy to communicate with its crack.
                `wait_crack_ready: begin 
                    rdy = 0;
                    en_crack1 = 0;
                    en_crack2 = 0;

                    selCT = 2'b11;

                    // we want pt-child1 to communicate with its crack
                    selPT = 2'b11;
                    selPT2 = 2'b11;

                    pt_addr_main = 0;
                    pt_wrdata_main = 0;
                    pt_wren_main = 0;

                    key = 24'b0;
                    key_valid = 0;
                end

                `start_crack: begin 
                    rdy = 0;
                    en_crack1 = 1;
                    en_crack2 = 1;

                    selCT = 2'b11;

                    // we want pt-child1 to communicate with its crack
                    selPT = 2'b11;
                    selPT2 = 2'b11;

                    pt_addr_main = 0;
                    pt_wrdata_main = 0;
                    pt_wren_main = 0;

                    key = 24'b0;
                    key_valid = 0;
                end

                `wait_crack_finish: begin 
                    rdy = 0;
                    en_crack1 = 0;
                    en_crack2 = 0;

                    selCT = 2'b11;

                    // we want pt-child1 to communicate with its crack
                    selPT = 2'b11;
                    selPT2 = 2'b11;

                    pt_addr_main = 0;
                    pt_wrdata_main = 0;
                    pt_wren_main = 0;

                    key = 24'b0;
                    key_valid = 0;
                end

                `read_child_pt_crack1: begin
                    rdy = 0;
                    en_crack1 = 0;
                    en_crack2 = 0;

                    selCT = 2'b11;

                    
                    selPT = 2'b00;
                    selPT2 = 2'b11; // keep the other pt connected to its crack.

                    pt_addr_main = 0;
                    pt_wrdata_main = 0;
                    pt_wren_main = 0;

                    key = key_crack1;
                    key_valid = 0;

                end

                `save_child_pt_crack1: begin 
                    rdy = 0;
                    en_crack1 = 0;
                    en_crack2 = 0;

                    selCT = 2'b11;

                    selPT = 2'b01;
                    selPT2 = 2'b11;

                    pt_addr_main = 0;
                    pt_wrdata_main = 0;
                    pt_wren_main = 0;

                    key = key_crack1;
                    key_valid = 0;
                end

                `write_main_pt_crack1: begin 
                    rdy = 0;
                    en_crack1 = 0;
                    en_crack2 = 0;

                    selCT = 2'b11;

                    selPT = 2'b01;
                    selPT2 = 2'b11;

                    pt_addr_main = pt_crack1_iter;
                    pt_wrdata_main = value_child_pt1;
                    pt_wren_main = 1;

                    key = key_crack1;
                    key_valid = 0;
                end

                `increment_pt_iter_crack1: begin 
                    rdy = 0;
                    en_crack1 = 0;
                    en_crack2 = 0;

                    selCT = 2'b11;

                    selPT = 2'b01;
                    selPT2 = 2'b11;

                    pt_addr_main = 0;
                    pt_wrdata_main = 0;
                    pt_wren_main = 0;

                    pt_crack1_iter = pt_crack1_iter + 1;

                    if (pt_crack1_iter == msg_size) begin 
                        finish_flag_crack1_iter = 1;
                    end
                    else begin 
                        finish_flag_crack1_iter = 0;
                    end

                    key = key_crack1;
                    key_valid = 0;

                end

                `read_child_pt_crack2: begin 
                    rdy = 0;
                    en_crack1 = 0;
                    en_crack2 = 0;

                    selCT = 2'b11;

                    selPT = 2'b11;
                    selPT2 = 2'b00;

                    pt_addr_main = 0;
                    pt_wrdata_main = 0;
                    pt_wren_main = 0;

                    key = key_crack2;
                    key_valid = 0;
                end

                `save_child_pt_crack2: begin 
                    rdy = 0;
                    en_crack1 = 0;
                    en_crack2 = 0;

                    selCT = 2'b11;

                    selPT = 2'b11;
                    selPT2 = 2'b01;

                    pt_addr_main = 0;
                    pt_wrdata_main = 0;
                    pt_wren_main = 0;

                    key = key_crack2;
                    key_valid = 0;
                end

                `write_main_pt_crack2: begin 
                    rdy = 0;
                    en_crack1 = 0;
                    en_crack2 = 0;

                    selCT = 2'b11;

                    selPT = 2'b11;
                    selPT2 = 2'b01;

                    pt_addr_main = pt_crack2_iter;
                    pt_wrdata_main = value_child_pt2;
                    pt_wren_main = 1;

                    key = key_crack2;
                    key_valid = 0;
                end

                `increment_pt_iter_crack2: begin 
                    pt_crack2_iter = pt_crack2_iter +1;

                    if (pt_crack2_iter == msg_size) begin 
                        finish_flag_crack2_iter = 1;
                    end
                    else begin 
                        finish_flag_crack2_iter = 0;
                    end

                    rdy = 0;
                    en_crack1 = 0;
                    en_crack2 = 0;

                    selCT = 2'b11;

                    selPT = 2'b11;
                    selPT2 = 2'b01;

                    pt_addr_main = 0;
                    pt_wrdata_main = 0;
                    pt_wren_main = 0;

                    key = key_crack2;
                    key_valid = 0;

                end

                `finish_dc_found: begin 
                    rdy = 1;
                    en_crack1 = 0;
                    en_crack2 = 0;

                    key_valid = 1;

                    if (finish_flag_crack1_iter == 1) begin 
                        key = key_crack1;
                    end
                    else if (finish_flag_crack2_iter == 1) begin 
                        key = key_crack2;
                    end
                    else begin 
                        key = 24'b0;
                    end
                end

                `finish_dc_not_found: begin 
                    rdy = 1;
                    en_crack1 = 0;
                    en_crack2 = 0;

                    key_valid = 0;
                    key = 24'b0;

                end

                default: begin 
                    rdy = 0;
                    key_valid = 0;
                    key = 24'b0;

                    en_crack1 = 0;
                    en_crack2 = 0;
                end
            endcase
        end
    end

    always_comb begin : mux_ct_copies
        // CT COPIES TO WRITE TO ITSELF.
        if (selCT == 2'b00) begin 
            ct_addr_copy1 = iter_ct;
            ct_wren_copy1 = 1;
            ct_wrdata_copy1 = value_ct;
            
            ct_addr_copy2 = iter_ct;
            ct_wren_copy2 = 1;
            ct_wrdata_copy2 = value_ct;

            ct_rddata_crack1 = 0;
            ct_rddata_crack2 = 0;
        end

        // CT COPIES TO JUST SET TO DEFAULT.
        else if (selCT == 2'b01) begin 
            ct_addr_copy1 = 0;
            ct_wren_copy1 = 0;
            ct_wrdata_copy1 = 0;
            
            ct_addr_copy2 = 0;
            ct_wren_copy2 = 0;
            ct_wrdata_copy2 = 0;

            ct_rddata_crack1 = 0;
            ct_rddata_crack2 = 0;
        end

        // CT copies to stay connected to its crack.
        else begin 
            ct_addr_copy1 = ct_addr_crack1;
            ct_rddata_crack1 = ct_rddata_copy1;
            ct_wren_copy1 = 0;
            ct_wrdata_copy1 = 0;

            ct_addr_copy2 = ct_addr_crack2;
            ct_rddata_crack2 = ct_rddata_copy2;
            ct_wren_copy2 = 0;
            ct_wrdata_copy2 = 0;
        end
    end

    always_comb begin : mux_pt_copies1

        // PT read from itself.
        if (selPT == 2'b00) begin 
            pt_addr_copy1 = pt_crack1_iter;
            pt_wren_copy1 = 0;
            pt_wrdata_copy1 = 0;

            pt_rddata_crack1 = 0;
        end

        // default.
        else if (selPT == 2'b01) begin 
            pt_addr_copy1 = 0;
            pt_wren_copy1 = 0;
            pt_wrdata_copy1 = 0;

            pt_rddata_crack1 = 0;
        end

        // PT to communicate with its crack.
        else begin 
            pt_addr_copy1 = pt_addr_crack1;
            pt_wrdata_copy1 = pt_wrdata_crack1;
            pt_rddata_crack1 = pt_rddata_copy1;
            pt_wren_copy1 = pt_wren_crack1;
        end
    end

    always_comb begin : mux_pt_copies2
         // PT read from itself.
        if (selPT2 == 2'b00) begin 

            pt_addr_copy2 = pt_crack2_iter;
            pt_wren_copy2 = 0;
            pt_wrdata_copy2 = 0;

            pt_rddata_crack2 = 0;
        end

        // default.
        else if (selPT2 == 2'b01) begin 
            pt_addr_copy2 = 0;
            pt_wren_copy2 = 0;
            pt_wrdata_copy2 = 0;

            pt_rddata_crack2 = 0;
        end

        // PT to communicate with its crack.
        else begin 
            pt_addr_copy2 = pt_addr_crack2;
            pt_wrdata_copy2 = pt_wrdata_crack2;
            pt_rddata_crack2 = pt_rddata_copy2;
            pt_wren_copy2 = pt_wren_crack2;

        end
    end

endmodule: doublecrack
