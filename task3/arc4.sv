`timescale 1ps / 1ps

`define start_arc4 5'd0
`define wait_rdy_init 5'd1
`define start_init 5'd2
`define wait_init_finish 5'd3
`define wait_rdy_ksa 5'd4
`define wait_start_ksa 5'd5
`define start_ksa 5'd6
`define wait_ksa_finish 5'd7
`define wait_rdy_prga 5'd8
`define wait_start_prga 5'd9
`define start_prga 5'd10
`define wait_prga_finish 5'd11
`define finish_arc4 5'd12

module arc4(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    // your code here

    // for S:
    reg[7:0] s_addr;
    reg[7:0] s_wrdata;
    reg s_wren;
    reg[7:0] s_rddata;

    // for init.
    reg en_init;
    reg rdy_init;
    reg[7:0] init_s_addr;
    reg[7:0] init_s_wrdata;
    reg[7:0] init_s_rddata;
    reg init_s_wren;

    //for ksa
    reg en_ksa;
    reg rdy_ksa;
    reg[7:0] ksa_s_addr;
    reg[7:0] ksa_s_rddata;
    reg[7:0] ksa_s_wrdata;
    reg ksa_s_wren;

    // for prga.
    reg en_prga;
    reg rdy_prga;
    reg[7:0] prga_s_addr;
    reg[7:0] prga_s_rddata;
    reg[7:0] prga_s_wrdata;
    reg prga_s_wren;

    s_mem s(
        .address(s_addr),
        .clock(clk),
        .data(s_wrdata),
        .wren(s_wren),
        .q(s_rddata)
    );

    init i(
        .clk(clk),
        .rst_n(rst_n),
        .en(en_init),
        .rdy(rdy_init),
        .addr(init_s_addr),
        .wrdata(init_s_wrdata),
        .wren(init_s_wren)
    );

    ksa k(
        .clk(clk),
        .rst_n(rst_n),
        .en(en_ksa),
        .rdy(rdy_ksa),
        .key(key),
        .addr(ksa_s_addr),
        .rddata(ksa_s_rddata),
        .wrdata(ksa_s_wrdata),
        .wren(ksa_s_wren)
    );

    prga p(
        .clk(clk),
        .rst_n(rst_n),
        .en(en_prga),
        .rdy(rdy_prga),
        .key(key),
        .s_addr(prga_s_addr),
        .s_rddata(prga_s_rddata),
        .s_wrdata(prga_s_wrdata),
        .s_wren(prga_s_wren),
        .ct_addr(ct_addr),
        .ct_rddata(ct_rddata),
        .pt_addr(pt_addr),
        .pt_rddata(pt_rddata),
        .pt_wrdata(pt_wrdata),
        .pt_wren(pt_wren)
    );

    reg[1:0] sel = 2'b00;

    reg[4:0] present_state = `start_arc4;
    always @(posedge clk or negedge rst_n) begin 
        if (rst_n == 0) begin 
            present_state = `start_arc4;
            rdy = 1;
            en_init = 0;
            en_ksa = 0;
            en_prga = 0;
            
            sel = 2'b00;
        end
        else begin 
            case(present_state) 
                `start_arc4: begin 
                    if (en == 0) begin 
                        present_state = `start_arc4;
                    end
                    else begin 
                        present_state = `wait_rdy_init;
                    end
                end

                `wait_rdy_init: begin 
                    if (rdy_init == 0) begin 
                        present_state = `wait_rdy_init;
                    end
                    else begin 
                        present_state = `start_init;
                    end
                end

                `start_init: begin 
                    present_state = `wait_init_finish;
                end

                `wait_init_finish: begin 
                    if (rdy_init == 0) begin 
                        present_state = `wait_init_finish;
                    end
                    else begin 
                        present_state = `wait_rdy_ksa;
                    end
                end

                `wait_rdy_ksa: begin 
                    if (rdy_ksa == 1) begin 
                        present_state = `start_ksa;
                    end
                    else begin 
                        present_state = `wait_rdy_ksa;
                    end
                end

                `start_ksa: begin 
                    present_state = `wait_ksa_finish;
                end

                `wait_ksa_finish: begin 
                    if (rdy_ksa == 0) begin 
                        present_state = `wait_ksa_finish;
                    end
                    else begin 
                        present_state = `wait_rdy_prga;
                    end
                end

                `wait_rdy_prga: begin 
                    if (rdy_ksa == 1) begin 
                        present_state = `start_prga;
                    end
                    else begin 
                        present_state = `wait_rdy_prga;
                    end
                end

                `start_prga: begin 
                    present_state = `wait_prga_finish;
                end

                `wait_prga_finish: begin 
                    if (rdy_prga == 1) begin 
                        present_state = `finish_arc4;
                    end
                    else begin 
                        present_state = `wait_prga_finish;
                    end
                end

                `finish_arc4: begin 
                    if (en == 1) begin 
                        present_state = `wait_rdy_init;
                    end
                    else begin 
                        present_state = `finish_arc4;
                    end
                end
                
                default: present_state = `start_arc4;
                
            endcase


            case(present_state) 
                `start_arc4: begin 
                    rdy = 1;
                    en_init = 0;
                    en_ksa = 0;
                    en_prga = 0;

                    sel = 2'b00;
                end

                `wait_rdy_init: begin 
                    rdy = 0;
                   en_init = 0;
                    en_ksa = 0;
                    en_prga = 0;

                    sel = 2'b00;
                end

                `start_init: begin 
                    rdy = 0;
                    en_init = 1;
                    en_ksa = 0;
                    en_prga = 0;

                    sel = 2'b00;
                end

                `wait_init_finish: begin 
                    rdy = 0;
                    en_init = 0;
                    en_ksa = 0;
                    en_prga = 0;

                    sel = 2'b00;
                end

                `wait_rdy_ksa: begin 
                    rdy = 0;
                    en_init = 0;
                    en_ksa = 0;
                    en_prga = 0;

                    sel = 2'b01;
                end

                `start_ksa: begin 
                    rdy = 0;
                    en_init = 0;
                    en_ksa = 1;
                    en_prga = 0;

                    sel = 2'b01;
                end

                `wait_ksa_finish: begin 
                    rdy = 0;
                    en_init = 0;
                    en_ksa = 0;
                    en_prga = 0;

                    sel = 2'b01;
                end

                `wait_rdy_prga: begin 
                    rdy = 0;
                    en_init = 0;
                    en_ksa = 0;
                    en_prga = 0;

                    sel = 2'b11;
                end

                `start_prga: begin 
                    rdy = 0;
                    en_init = 0;
                    en_ksa = 0;
                    en_prga = 1;

                    sel = 2'b11;
                end

                `wait_prga_finish: begin 
                    rdy = 0;
                    en_init = 0;
                    en_ksa = 0;
                    en_prga = 0;

                    sel = 2'b11;
                end

                `finish_arc4: begin 
                    rdy = 1;
                    en_init = 0;
                    en_ksa = 0;
                    en_prga = 0;

                    sel = 2'b11;
                end
                
                default: begin 
                    rdy = 0;
                    en_init = 0;
                    en_ksa = 0;
                    en_prga = 0;
                    sel = 2'b00;
                end
                
            endcase      
        end
    end

    always_comb begin : MUX
        // connect to init module.
        if (sel == 2'b00) begin 
            s_wrdata = init_s_wrdata;
            s_wren = init_s_wren;
            s_addr = init_s_addr;
            init_s_rddata = s_rddata;
            ksa_s_rddata = 8'b0;
            prga_s_rddata = 8'b0;
        end

        // connect to ksa module.
        else if (sel == 2'b01) begin 
            s_wrdata = ksa_s_wrdata;
            s_wren = ksa_s_wren;
            s_addr = ksa_s_addr;
            ksa_s_rddata = s_rddata;
            init_s_rddata = 8'b0;
            prga_s_rddata = 8'b0;
        end

        // connect to prga.
        else begin 
            s_wrdata = prga_s_wrdata;
            s_wren = prga_s_wren;
            s_addr = prga_s_addr;
            prga_s_rddata = s_rddata;
            init_s_rddata = 8'b0;
            ksa_s_rddata = 8'b0;
        end      
    end

   
endmodule: arc4
