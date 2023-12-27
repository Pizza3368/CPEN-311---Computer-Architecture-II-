`timescale 1ps / 1ps

`define wait_rdy_init 4'd1
`define start_init 4'd2
`define wait_init_finish 4'd3
`define wait_rdy_ksa 4'd4
`define start_ksa 4'd5
`define wait_ksa_finish 4'd6
`define finish_t2 4'd7

module task2(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    reg[23:0] key_val;
    assign key_val[23:10] = 0; /* hard coding to 0*/
    assign key_val[9:0] = SW[9:0]; /* Make it equal to the 10 switches in De1-soc */
    /*INIT*/
    
    /* ready-enable interface for init*/
    reg enable_init = 0;
    reg ready_init;


    /* address interface for init to communicate with S memory.*/
    reg[7:0] address;
    reg[7:0] write_data;
    reg write_enable;
    reg[7:0] read_data_init;

    /*KSA*/

    /* ready-enable interface for ksa*/
    reg enable_ksa = 0;
    reg ready_ksa;
    /* address interface for ksa to communicate with S memory */
    reg[7:0] read_data_ksa;
    reg[7:0] address_ksa;
    reg[7:0] write_data_ksa;
    reg write_enable_ksa;

    /* S-MEM */
    reg[7:0] address_memory;
    reg[7:0] write_data_memory;
    reg[7:0] read_data_memory;
    reg write_enable_memory;
    
    logic[3:0] present_state = `wait_rdy_init;
    logic sel = 1;
    logic val = 0;
    /*we need the init module to initialize memory.*/
    init data_init(
        .clk(CLOCK_50),
        .rst_n(KEY[3]),
        .en(enable_init),
        .rdy(ready_init),
        .addr(address),
        .wrdata(write_data),
        .wren(write_enable)
    );

    s_mem s(
        .address(address_memory),
        .clock(CLOCK_50),
        .data(write_data_memory),
        .wren(write_enable_memory),
        .q(read_data_memory)
    );

    ksa k_sch_algo(
        .clk(CLOCK_50),
        .rst_n(KEY[3]),
        .en(enable_ksa),
        .rdy(ready_ksa),
        .key(key_val),
        .addr(address_ksa),
        .rddata(read_data_ksa),
        .wrdata(write_data_ksa),
        .wren(write_enable_ksa)
    );

    /* Even though we initialize init and ksa above, it wont write to memory until
    enable_init is 1
    */
    always @(posedge CLOCK_50 or negedge KEY[3]) begin 
        if (KEY[3] == 0) begin 
            present_state = `wait_rdy_init;

            enable_init = 0;
            enable_ksa = 0;

            /* Make S memory communicate with init */
            sel = 1; 
      
        end
        else begin 
            case  (present_state)
                /* Waiting for init to be ready*/
                `wait_rdy_init: begin 
                    if (ready_init == 1) begin 
                        present_state = `start_init;
                    end
                    else begin 
                        present_state = `wait_rdy_init;
                    end
                end

                /* Making enable of init to 1 and ksa to 0. So, we only start init.*/
                `start_init: begin 
                    present_state = `wait_init_finish;
                end

                /* waiting for init to finish*/
                `wait_init_finish: begin 
                    if (ready_init == 0) begin 
                        present_state = `wait_init_finish;
                    end
                    else begin 
                        present_state = `wait_rdy_ksa;
                    end
                end

                /* Waiting for ksa to be ready*/
                `wait_rdy_ksa: begin 
                    if (ready_ksa == 0) begin 
                        present_state = `wait_rdy_ksa;
                    end
                    else begin 
                        present_state = `start_ksa;
                    end
                end

                /* enable_ksa = 1 and keep enable_init = 0*/
                `start_ksa: begin 
                    present_state = `wait_ksa_finish;
                end

                /* wait for ksa to finish */
                `wait_ksa_finish: begin 
                    if(ready_ksa == 1) begin 
                        present_state = `finish_t2;
                    end
                    else begin 
                        present_state = `wait_ksa_finish;
                    end
                end

                `finish_t2: begin 
                    present_state = `finish_t2;
                end

                default: present_state =`wait_rdy_init;
        endcase

        case (present_state) 
            `wait_rdy_init: begin 
                enable_init = 0;
                enable_ksa = 0;

                /* Make S memory communicate with init */
                sel = 1; 
            end

            `start_init: begin 
                enable_init = 1;
                enable_ksa = 0;

                /* Make S memory communicate with init */
                sel = 1;
            end

            `wait_init_finish: begin 
                enable_init = 0;
                enable_ksa = 0;

                /* Make S memory communicate with init */
                sel = 1;
                
            end


            `wait_rdy_ksa: begin 
                enable_init = 0;
                enable_ksa = 0;

                /* Make S memory communicate with KSA */
                sel = 0;

                HEX3 = 7'b1111111; /* just to check if fpga goes over this state.*/  
                
            end

            `start_ksa: begin 
                enable_init = 0;
                enable_ksa = 1;

                /* Make S memory communicate with KSA */
                sel = 0;  
                
            end

            `wait_ksa_finish: begin 
                enable_init = 0;
                enable_ksa = 0;

                sel = 0;   
      
            end

            `finish_t2: begin 
                enable_init = 0;
                enable_ksa = 0;

                sel = 0; 

            end

            /* Technically not possible, but just in case */
            default: begin 
                enable_init = 0;
                enable_ksa = 0;

                sel = 0;
            end
        endcase
        end
        
    end

    always_comb begin : Mux
        if (sel == 1) begin
            /* Communicate with init*/ 
            address_memory = address;
            write_data_memory = write_data;
            write_enable_memory = write_enable;
            read_data_init = read_data_memory; 
            read_data_ksa = read_data_memory;  
        end
        else begin 
            /*communicate with ksa*/
            address_memory = address_ksa;
            write_data_memory = write_data_ksa;
            write_enable_memory = write_enable_ksa;
            read_data_ksa = read_data_memory;
            read_data_init = read_data_memory;
        end
    end
endmodule: task2