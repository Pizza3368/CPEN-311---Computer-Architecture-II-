// defined all states here.
`define gamestart 4'b0000
`define playerdraw1 4'b0001
`define dealerdraw1 4'b0010
`define playerdraw2 4'b0011
`define dealerdraw2 4'b0100
`define showdealer2 4'b1010
`define checknaturalstate 4'b0101
`define gameoverstate 4'b0110
`define playerdraw3 4'b0111
`define showplayerdraw3 4'b1011
`define checkdealerdraw3 4'b1100
`define showdealerdraw3 4'b1000
`define decideafterdraw3 4'b1001

// define number for ease of comparism later on. 
`define zero 4'b0000
`define one 4'b0001
`define two 4'b0010
`define three 4'b0011
`define four 4'b0100
`define five 4'b0101
`define six 4'b0110
`define seven 4'b0111
`define eight 4'b1000
`define nine 4'b1001
`define ten 4'b1010
`define eleven 4'b1011
`define twelve 4'b1100
`define thirteen 4'b1101
`define fourteen 4'b1110
`define fifteen 4'b1111

module statemachine(input slow_clock, input resetb,
                    input [3:0] dscore, input [3:0] pscore, input [3:0] pcard3,
                    output load_pcard1, output load_pcard2,output load_pcard3,
                    output load_dcard1, output load_dcard2, output load_dcard3,
                    output player_win_light, output dealer_win_light);
	
	// registers to hold the loadvalue.
	reg load_pcard1_value;
	reg load_pcard2_value;
	reg load_pcard3_value;
	reg load_dcard1_value;
	reg load_dcard2_value;
	reg load_dcard3_value;

	// reg to hold the win light values.
	reg player_light_value;
	reg dealer_light_value;

	// reg to store the present state.
	reg[3:0] present_state;

	//reg to store if player got 3rd card.
	reg player_got3;

	// reg to have the value of facevalue of 3rd card of player;
	reg[3:0] facevalue_player3;

	// reg to see if winner found.
	reg winner_found;

	// use the facevalue module which is defined in ./scorehand.sv
	faceValue fv(.card(pcard3), .facevalue(facevalue_player3));
	
	// synchronous reset, rising edge of slow clock.
	always @(posedge slow_clock) begin
		if(resetb == 0) begin
			present_state = `gamestart;
			// when player clicks on reset and have a rising edge of the clock we want all outputs to be 0. 
			// This is because we are essentially restarting the game.
			load_pcard1_value = 0;
			load_pcard2_value = 0;
			load_pcard3_value = 0;
			load_dcard1_value = 0;
			load_dcard2_value = 0;
			load_dcard3_value = 0;
			player_light_value = 0;
			dealer_light_value = 0;
			winner_found = 0;
			player_got3 = 0;
		end
		else begin
			case(present_state)
				`gamestart: present_state = `playerdraw1;
				`playerdraw1: present_state = `dealerdraw1;
				`dealerdraw1: present_state = `playerdraw2;
				`playerdraw2: present_state = `dealerdraw2;
				`dealerdraw2: present_state = `showdealer2;
				`showdealer2: present_state = `checknaturalstate;
				`checknaturalstate: 
					begin
						if (winner_found == 1) begin
							present_state = `gameoverstate;
						end
						else begin
							present_state = `playerdraw3;
						end
					end
				`playerdraw3: present_state = `showplayerdraw3;
				`showplayerdraw3: present_state = `checkdealerdraw3;
				`checkdealerdraw3: present_state = `showdealerdraw3;
				`showdealerdraw3: present_state = `decideafterdraw3;
				`decideafterdraw3: present_state = `gameoverstate;
				`gameoverstate: present_state = `gameoverstate;
				default: present_state = `gamestart; // todo: test this default case.
			endcase
			case(present_state)
				/**
				GAME START STATE. HERE ALL OUTPUTS ARE 0.
				*/
				`gamestart: 
					begin
						load_pcard1_value = 0;
						load_pcard2_value = 0;
						load_pcard3_value = 0;
						load_dcard1_value = 0;
						load_dcard2_value = 0;
						load_dcard3_value = 0;
						player_light_value = 0;
						dealer_light_value = 0;
						winner_found = 0;
						player_got3 = 0;		
					end
				/**
				PLAYER DRAW 1. THIS STATE WILL SET LOADER FOR PCARD1. ONLY SET load_pcard1_value to 1. 
				*/
				`playerdraw1:
					begin
						load_pcard1_value = 1;
						load_pcard2_value = 0;
						load_pcard3_value = 0;
						load_dcard1_value = 0;
						load_dcard2_value = 0;
						load_dcard3_value = 0;
						player_light_value = 0;
						dealer_light_value = 0;
						winner_found = 0;
						player_got3 = 0;
					end
				/**
				DEALER DRAW 1. THIS STATE WILL SHOW PLAYER CARD1 AND SET LOADER FOR DCARD1, ONLY SET load_dcard1_value to 1. 
				*/
				`dealerdraw1:
					begin
						load_pcard1_value = 0;
						load_pcard2_value = 0;
						load_pcard3_value = 0;
						load_dcard1_value = 1;
						load_dcard2_value = 0;
						load_dcard3_value = 0;
						player_light_value = 0;
						dealer_light_value = 0;
						winner_found = 0;
						player_got3 = 0;
					end

				/**
				PLAYER DRAW 2. THIS STATE WILL SHOW DEALER CARD1 AND SET LOADER FOR PCARD2, ONLY SET load_pcard2_value to 1. 
				*/
				`playerdraw2:
					begin
						load_pcard1_value = 0;
						load_pcard2_value = 1;
						load_pcard3_value = 0;
						load_dcard1_value = 0;
						load_dcard2_value = 0;
						load_dcard3_value = 0;
						player_light_value = 0;
						dealer_light_value = 0;
						winner_found = 0;
						player_got3 = 0;
					end
				/**
				DEALER DRAW 2. THIS STATE WILL SHOW PLAYER CARD2 AND SET LOADER FOR DEALER CARD2, ONLY SET load_dcard2_value to 1. 
				*/
				`dealerdraw2:
					begin
						load_pcard1_value = 0;
						load_pcard2_value = 0;
						load_pcard3_value = 0;
						load_dcard1_value = 0;
						load_dcard2_value = 1;
						load_dcard3_value = 0;
						player_light_value = 0;
						dealer_light_value = 0;
						winner_found = 0;
						player_got3 = 0;
					end
				/**
				SHOW DEALER 2. THIS STATE WILL SHOW DEALER CARD2. WE NEED THIS STEP TO ENSURE DEALER CARD 2 IS LOADED AS THE OUTPUT. 
				*/
				`showdealer2:
					begin
						load_pcard1_value = 0;
						load_pcard2_value = 0;
						load_pcard3_value = 0;
						load_dcard1_value = 0;
						load_dcard2_value = 0;
						load_dcard3_value = 0;
						player_light_value = 0;
						dealer_light_value = 0;
						winner_found = 0;
						player_got3 = 0;
					end
				/**
				CHECK NATURAL STATE. AT THIS STATE WE HAVE ALL 4 CARDS SHOWN. SO WE CAN DECIDE WINNER BASED ON PSCORE/ DSOCRE = 8/9. OTHERWISE NO WINNER.
				IF NO WINNER, winner_found = 0. 
				*/
				`checknaturalstate:
					begin
						if(pscore == `eight || pscore == `nine || dscore == `eight || dscore == `nine) begin
							winner_found = 1;
							if (pscore == dscore) begin 
								player_light_value = 1;
								dealer_light_value = 1;
							end
							else if (pscore > dscore) begin
								player_light_value = 1;
								dealer_light_value = 0;
							end
							else begin
								player_light_value = 0;
								dealer_light_value = 1;
							end
						end
						else begin
							winner_found = 0;
						end
					end

				/**
				PLAYER DRAW3. IF PSCORE is [0,5] then set player_got3 = 1 and set load_pcard3_value to 1. This will SET LOADER FOR pcard3 NOT show it. 
				IF PSCORE is not between 0 and 5 then set all loaders to 0 and player_got3 = 0.
				*/
				`playerdraw3:
					begin
						if (pscore == `zero || pscore == `one || pscore == `two || pscore == `three || pscore == `four || pscore == `five) begin
							player_got3 = 1;
							load_pcard1_value = 0;
							load_pcard2_value = 0;
							load_pcard3_value = 1;
							load_dcard1_value = 0;
							load_dcard2_value = 0;
							load_dcard3_value = 0;
							player_light_value = 0;
							dealer_light_value = 0;
							winner_found = 0;
						end
						else begin
							load_pcard1_value = 0;
							load_pcard2_value = 0;
							load_pcard3_value = 0;
							load_dcard1_value = 0;
							load_dcard2_value = 0;
							load_dcard3_value = 0;
							player_light_value = 0;
							dealer_light_value = 0;
							winner_found = 0;
							player_got3 = 0;
						end
					end

				/**
				SHOW PLAYER DRAW 3. THIS IS DONE SO THAT CARD3 is loaded.
				*/
				`showplayerdraw3:
					begin
						load_pcard1_value = 0;
						load_pcard2_value = 0;
						load_pcard3_value = 0;
						load_dcard1_value = 0;
						load_dcard2_value = 0;
						load_dcard3_value = 0;
						player_light_value = 0;
						dealer_light_value = 0;
						
					end
				
				/**
				Check dealer draw 3.
				*/
				`checkdealerdraw3:
					begin
						load_pcard1_value = 0;
						load_pcard2_value = 0;
						load_pcard3_value = 0;
						load_dcard1_value = 0;
						load_dcard2_value = 0;
						player_light_value = 0;
						dealer_light_value = 0;
					
						// player did not get 3rd card, dealer card3 is load is dscore [0,5]
						if (player_got3 == 0) begin
							
							winner_found = 0;
							if(dscore == `zero || dscore == `one || dscore == `two || dscore == `three || dscore == `four || dscore == `five) begin
								load_dcard3_value = 1;
							end
							else begin
								load_dcard3_value = 0;
							end
						end
						// player got 3rd cards, dealer card3 is loaded based on the logic below:
						else begin
							// dsocre 7, dealer no dealer card is loaded. 
							if (dscore == `seven) begin
								load_dcard3_value = 0;	
							end
							// dscore 6, banker gets 3rd card if facevalue_player3 is 6 or 7.
							else if (dscore == `six) begin
								if (facevalue_player3 == `six || facevalue_player3 == `seven) begin
									load_dcard3_value = 1;
								end
								else begin
									load_dcard3_value = 0;
								end
						
							end
							// dscore 5, banker gets 3rd card if facavalue_player3 4,5,6,7
							else if (dscore == `five) begin
								if(facevalue_player3 == `four || facevalue_player3 == `five || facevalue_player3 == `six || facevalue_player3 == `seven) begin
									load_dcard3_value = 1;
								end
								else begin
									load_dcard3_value = 0;
								end
							end

							// dscore is 4, banker gets 3rd card if facevalue_player3 is 2,3,4,5,6,7
							else if (dscore == `four) begin
								if(facevalue_player3 == `two || facevalue_player3 == `three ||
								facevalue_player3 == `four || facevalue_player3 == `five || facevalue_player3 == `six || facevalue_player3 == `seven) begin
									load_dcard3_value = 1;
								end
								else begin
									load_dcard3_value = 0;
								end
							end
							// dscore is 3, banker gets 3rd card if facevalue_player3 is anything but 8.
							else if (dscore == `three) begin
								if (facevalue_player3 != `eight) begin
									load_dcard3_value = 1;
								end
								else begin
									load_dcard3_value = 0;
								end
							end
							// dscore is 0,1 or 2 then banker gets a 3rd card.
							else begin
								load_dcard3_value = 1;
							end
						end
					end

				/**
				Show dealer card3. THIS STATE SHOW DEALER CARD3. AT THIS STATE WE ARE NOT DECIDING WINNER, TO UPDATE ALL SIX CARDS.
				*/
				`showdealerdraw3:
					begin
						load_pcard1_value = 0;
						load_pcard2_value = 0;
						load_pcard3_value = 0;
						load_dcard1_value = 0;
						load_dcard2_value = 0;
						load_dcard3_value = 0;
						player_light_value = 0;
						dealer_light_value = 0;
					end

				/**
				AT THIS STAGE ALL 6 cards are loaded. We decide here. 				
				*/
				`decideafterdraw3:
					begin
						if (pscore == dscore) begin 
							player_light_value = 1;
							dealer_light_value = 1;
						end
						else if (pscore > dscore) begin
							player_light_value = 1;
							dealer_light_value = 0;
						end
						else begin
							player_light_value = 0;
							dealer_light_value = 1;
						end
					end

				`gameoverstate: 
					begin
						load_pcard1_value = 0;
						load_pcard2_value = 0;
						load_pcard3_value = 0;
						load_dcard1_value = 0;
						load_dcard2_value = 0;
						load_dcard3_value = 0;
					end
				
			endcase
		end

	end
	assign load_pcard1 = load_pcard1_value;
	assign load_pcard2 = load_pcard2_value;
	assign load_pcard3 = load_pcard3_value;
	assign load_dcard1 = load_dcard1_value;
	assign load_dcard2 = load_dcard2_value;
	assign load_dcard3 = load_dcard3_value;
	assign player_win_light = player_light_value;
	assign dealer_win_light = dealer_light_value;
	

endmodule

