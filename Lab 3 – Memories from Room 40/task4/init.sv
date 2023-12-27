`timescale 1ps / 1ps

`define start 3'd0 //0
`define write 3'd1 // 1
`define  increment 3'd2 //2
`define entryLastValue 3'd3 //7
`define finish 3'd4
`define dummy 3'd5

module init(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            output logic [7:0] addr, output logic [7:0] wrdata, output logic wren);

	reg [2:0] present_state;
	reg [7:0] i =  8'd0;

	assign addr = i;
	assign wrdata = i;

	always @(posedge clk  or negedge rst_n) begin

		/*reset is active low. When reset start the states.*/
		if (rst_n == 0) begin 
			present_state = `start;
			i = 0;
			rdy = 1;
			wren = 0;
		end
		else begin 
			case (present_state)

				/*
				We remain in the start start until enabled is 0.
				We only start writing when enable is 1.
				*/
				`start:
					begin 
						if (en == 0) begin 
							present_state = `start;
						end
						else begin 
							present_state = `write;
						end
					end

				/*
				Go to the increment state to increment the value of i.
				address = i, wren = 1 wrdata = i
				*/
				`write:
					begin 
						present_state = `increment;
					end
				/*
				Increment and go to write state again. We go to write state again, 
				only when the value of i is less than equal to 255. 
				If i is greater than 255, we do not write anymore.
				*/
				`increment: 
				begin 
					if (i == 8'd255) begin 
						present_state = `entryLastValue;
					end
					else begin 
						present_state = `write;
					end
				end

				/*Becase init is activated exaclty once and S is not written to after init finishes we just stay in this state until
				reset.*/
				`entryLastValue: begin 
					present_state = `finish;
				end
				`finish: begin 
					present_state = `start; /*we are done so go back to start and wait for enable to be 1 again*/
					
				end

				default: present_state = `dummy; /* We should be waiting for en = 1. After reset. So stay in dummy*/
			endcase

			case (present_state)

				/* In the start state we do not write but we are ready to accept calls.*/ 
				`start:
					begin 
						i = 0;
						rdy = 1;
						wren = 0;
					end


				/*In the write state we are not ready to accept calls, since busy to write but we are writing*/
				`write:
					begin 
						rdy = 0;
						wren = 1;
					end

				`increment:
					begin 
						rdy = 0;
						wren = 0;
						i = i + 8'd1;
					end

				`entryLastValue: begin 
					wren = 1; /* Shortcut: Just so that we can put 255 */
				end

				`finish:
					begin 
						i = 0;
						rdy = 1;
						wren = 0;
					end

				/* For dummy.*/
				default: begin 
					rdy = 0;
					wren = 0;
				end
			endcase
		end
	end
	


endmodule: init