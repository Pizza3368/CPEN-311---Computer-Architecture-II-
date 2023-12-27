module tb_statemachine();

// Your testbench goes here. Make sure your tests exercise the entire design
// in the .sv file.  Note that in our tests the simulator will exit after
// 10,000 ticks (equivalent to "initial #10000 $finish();").
	
	reg slowclock;
	reg resetb;
	reg [3:0] dscore;
	reg[3:0] pscore;
	reg[3:0] pcard3;
	wire load_pcard1;
	wire load_pcard2;
	wire load_pcard3;
	wire load_dcard1;
	wire load_dcard2;
	wire load_dcard3;
	wire player_win_light;
	wire dealer_win_light;		
	
	//initiate statemachine
	statemachine fsm(slowclock, resetb,
                    dscore, pscore, pcard3,
                    load_pcard1, load_pcard2, load_pcard3,
                    load_dcard1, load_dcard2, load_dcard3,
                    player_win_light, dealer_win_light);
	
//	always begin
		
//	end

	initial begin

// my code start here
	
//test 1: player 8 dealer 0 - player win
	//press restart button to reset, then wait for a while (reset state)
	resetb = 0;
	slowclock = 0;
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#40
	resetb = 1;
	
	//nothing changes (idle state)

	//stop pressing reset, start playing, get player card 1 = 4 (PC1 state)
	slowclock= 1; // present state = game start
	dscore = 4'b0000;
    	pscore = 4'b0100;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10
	
	//get dealer card 1 = 0;
	slowclock= 1; // present state = playerdraw1
	dscore = 4'b0000;
    	pscore = 4'b0100;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10
	
	//get player card 2 = 4
	slowclock= 1; // present state = dealer draw1
	dscore = 4'b0000;
    	pscore = 4'b1000;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10
	
	//get dealer card 2 = 0
	slowclock= 1; // present state = player draw 2
	dscore = 4'b0000;
    	pscore = 4'b1000;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//get result, should be player wins
	slowclock=1; // present state = dealer draw 2
	#10 
	slowclock = 0;
	#10

	slowclock = 1; // present state  = show dealer 2
	#10
	
	slowclock = 0;
	#10

	slowclock = 1; // present state = check natural state.
	#10
	slowclock = 0;
	

	//check result and display to terminal 
	if (player_win_light == 1) begin
    		$display("Test 1 player pass");
  	end else begin
   	 $display("Test 1 player fail");
   	 
   	 end
   	 
   	 if (dealer_win_light == 0) begin
    		$display("Test 1 dealer pass");
  	end else begin
   	 $display("Test 1 dealer fail");
   
   	 end

	
	#10
	slowclock = 1;
	#10
	slowclock = 0;
	#10
//test 2: player 0 dealer 8 - dealer wins
	//press restart button to reset, then wait for a while (reset state)
	resetb = 0;
	slowclock = 1;
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#40
	slowclock = 0;
	resetb = 1;
	#10

	//nothing changes (idle state)

	//stop pressing reset, start playing, get player card 1 = 4 (PC1 state)
	slowclock= 1; // game start
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10
	
	//get dealer card 1 = 0;
	slowclock= 1; // player draw 1
	dscore = 4'b0100;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//get player card 2 = 4
	slowclock= 1; // dealer draw 1
	dscore = 4'b0100;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//get dealer card 2 = 0
	slowclock= 1; // player draw 2
	dscore = 4'b1000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//get result, should be player wins
	slowclock=1; // dealer draw 2
	#10 
	slowclock = 0;
	#10

	slowclock=1;  // extra state.
	#10
	slowclock = 0;

	#10
	slowclock = 1; // check natural state.
	#10
	slowclock = 0;
	
	//check result and display to terminal 
	if (player_win_light == 0) begin
    		$display("Test 2 player pass");
  	end else begin
   	 $display("Test 2 player fail");
   	 end
   	 if (dealer_win_light == 1) begin
    		$display("Test 2 dealer pass");
  	end else begin
   	 $display("Test 2 dealer fail");
  	end	

	#10
	slowclock = 1;
	#10
	slowclock = 0;
	#10
 // 410ps
//test 3: player 5 dealer 7, then player draw additonal card and win
	//press restart button to reset, then wait for a while (reset state)
	resetb = 0;
	slowclock = 1;
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#40
	slowclock = 0;
	resetb = 1;
	#10
	//nothing changes (idle state)

	//stop pressing reset, start playing, get player card 1 = 0 (PC1 state)
	slowclock= 1; // game start.
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10
	
	//get dealer card 1 = 0;
	slowclock= 1; // player draw 1
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//get player card 2 = 5
	slowclock= 1; // dealer draw 1
	dscore = 4'b0111;
    	pscore = 4'b0101;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//get dealer card 2 = 7
	slowclock= 1; // player draw 2
	dscore = 4'b0111;
    	pscore = 4'b0101;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//extra wait step, determine that player should get third card 
	slowclock=1; // dealer draw 2
	#10 
	slowclock = 0;
	#10
	
	
	slowclock= 1; // wait state
	dscore = 4'b0111;
    	pscore = 4'b0001;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10
	
	//extra wait step, determine that dealer should not third card 
	slowclock=1; // check natural state. 
	#10 
	slowclock = 0;
	#10
	
	if (player_win_light == 1) begin
    		$display("Test 3 failed on natural state.");
  	end else begin
   	 $display("Test 3 passed on natrual state.");
   	 end
   	 if (dealer_win_light == 1) begin
    		$display("Test 3 failed on natural state.");
  	end else begin
   	 $display("Test 3 passed on natural state.");
  	end	
	
	//extra wait step, determine that player wins
	slowclock=1; // player draw3
	#10 
	slowclock = 0;
	#10

	// show player draw 3 state.
	slowclock = 1;
	#10
	slowclock = 0;
	#10
	
	pscore = 4'b1000;
	dscore = 4'b0001;

	slowclock = 1; // check dealer draw 3
	#10
	slowclock = 0;
	#10
	
	slowclock  =  1; // show dealer draw 3
	#10
	slowclock = 0;
	#10

	
	slowclock = 1; // decide after draw3
	#10
	slowclock = 0;
	#10
	slowclock = 1;
	#10

	
	//check result and display to terminal 
	if (player_win_light == 1) begin
    		$display("Test 3 player pass");
  	end else begin
   	 $display("Test 3 player fail");
   	 end
   	 if (dealer_win_light == 0) begin
    		$display("Test 3 dealer pass");
  	end else begin
   	 $display("Test 3 dealer fail");
  	end	
 

//test 4: player 5 dealer 6, then player draw 6, dealer draws 4
	//press restart button to reset, then wait for a while (reset state)
	resetb = 0;
	slowclock = 1;
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#40
	slowclock = 0;
	#10
	#10
	slowclock = 1;
	#10
	slowclock = 0;
	#10
	resetb = 1;

	
	//nothing changes (idle state)
	

	//stop pressing reset, start playing, get player card 1 = 0 (PC1 state)
	slowclock= 1;
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10
	
	//get dealer card 1 = 0;
	slowclock= 1;
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//get player card 2 = 5
	slowclock= 1;
	dscore = 4'b0110;
    	pscore = 4'b0101;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//get dealer card 2 = 6
	slowclock= 1;
	dscore = 4'b0110;
    	pscore = 4'b0101;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//extra wait step, determine that player should get third card 
	slowclock=1;
	#10 
	slowclock = 0;
	#10
	
	//extra wait step, determine that player should get third card 
	slowclock=1;
	#10 
	slowclock = 0;
	#10
	
	
	
	//get player card 3 = 6
	slowclock= 1;
	dscore = 4'b0111;
    	pscore = 4'b1011;
    	pcard3 = 4'b0110;
	#10 
	slowclock = 0;
	#10
	
	//extra wait step, determine that dealer should get third card 
	slowclock=1;
	#10 
	slowclock = 0;
	#10
	
	//get dealer card 3 = 6
	slowclock= 1;
	dscore = 4'b1010;
    	pscore = 4'b1011;
    	pcard3 = 4'b0110;
	#10 
	slowclock = 0;
	#10

	
	//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10
	
	//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10




	
	//check result and display to terminal 
	if (player_win_light == 1) begin
    		$display("Test 4 player pass");
  	end else begin
   	 $display("Test 4 player fail");
   	 end
   	 if (dealer_win_light == 0) begin
    		$display("Test 4 dealer pass");
  	end else begin
   	 $display("Test 4 dealer fail");
  	end	


//test 5: player 5 dealer 5, then player draw 6, dealer draws 4
	//press restart button to reset, then wait for a while (reset state)
	resetb = 0;
	slowclock = 1;
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#40
	slowclock = 0;
	#10
	#10
	slowclock = 1;
	#10
	slowclock = 0;
	#10
	resetb = 1;

	//nothing changes (idle state)

	//stop pressing reset, start playing, get player card 1 = 0 (PC1 state)
	slowclock= 1;
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10
	
	//get dealer card 1 = 0;
	slowclock= 1;
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//get player card 2 = 5
	slowclock= 1;
	dscore = 4'b0110;
    	pscore = 4'b0110;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//get dealer card 2 = 5
	slowclock= 1;
	dscore = 4'b0110;
    	pscore = 4'b0110;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//extra wait step, determine that player should get third card 
	slowclock=1;
	#10 
	slowclock = 0;
	#10
	
	//get player card 3 = 6
	slowclock= 1;
	dscore = 4'b0111;
    	pscore = 4'b1011;
    	pcard3 = 4'b0110;
	#10 
	slowclock = 0;
	#10
	
	//extra wait step, determine that dealer should get third card 
	slowclock=1;
	#10 
	slowclock = 0;
	#10
	
	//get dealer card 3 = 4
	slowclock= 1;
	dscore = 4'b1001;
    	pscore = 4'b1011;
    	pcard3 = 4'b0110;
	#10 
	slowclock = 0;
	#10

	
	//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10
	
	//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10
	
	//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10




	
	//check result and display to terminal 
	if (player_win_light == 1) begin
    		$display("Test 5 player pass");
  	end else begin
   	 $display("Test 5 player fail");
   	 end
   	 if (dealer_win_light == 0) begin
    		$display("Test 5 dealer pass");
  	end else begin
   	 $display("Test 5 dealer fail");
  	end	

//test 6: player 5 dealer 4, then player draw 6, dealer draws 4
	//press restart button to reset, then wait for a while (reset state)
	resetb = 0;
	slowclock = 1;
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#40
	slowclock = 0;
	#10
	#10
	slowclock = 1;
	#10
	slowclock = 0;
	#10
	resetb = 1;
	//nothing changes (idle state)

	//stop pressing reset, start playing, get player card 1 = 0 (PC1 state)
	slowclock= 1;
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10
	
	//get dealer card 1 = 0;
	slowclock= 1;
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//get player card 2 = 5
	slowclock= 1;
	dscore = 4'b0110;
    	pscore = 4'b0110;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//get dealer card 2 = 4
	slowclock= 1;
	dscore = 4'b0110;
    	pscore = 4'b0100;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//extra wait step, determine that player should get third card 
	slowclock=1;
	#10 
	slowclock = 0;
	#10
	
	//get player card 3 = 6
	slowclock= 1;
	dscore = 4'b0100;
    	pscore = 4'b1011;
    	pcard3 = 4'b0110;
	#10 
	slowclock = 0;
	#10
	
	//extra wait step, determine that dealer should get third card 
	slowclock=1;
	#10 
	slowclock = 0;
	#10
	
	//get dealer card 3 = 4
	slowclock= 1;
	dscore = 4'b1000;
    	pscore = 4'b1011;
    	pcard3 = 4'b0110;
	#10 
	slowclock = 0;
	#10

	
	//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10

//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10
	
	//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10



	
	//check result and display to terminal 
	if (player_win_light == 1) begin
    		$display("Test 6 player pass");
  	end else begin
   	 $display("Test 6 player fail");
   	 end
   	 if (dealer_win_light == 0) begin
    		$display("Test 6 dealer pass");
  	end else begin
   	 $display("Test 6 dealer fail");
  	end	
  	
  	
//test 7: player 5 dealer 3, then player draw 6, dealer draws 5
	//press restart button to reset, then wait for a while (reset state)
	resetb = 0;
	slowclock = 1;
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#40
	slowclock = 0;
	#10
	#10
	slowclock = 1;
	#10
	slowclock = 0;
	#10
	resetb = 1;
	//nothing changes (idle state)

	//stop pressing reset, start playing, get player card 1 = 0 (PC1 state)
	slowclock= 1;
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10
	
	//get dealer card 1 = 0;
	slowclock= 1;
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//get player card 2 = 5
	slowclock= 1;
	dscore = 4'b0110;
    	pscore = 4'b0110;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//get dealer card 2 = 3
	slowclock= 1;
	dscore = 4'b0110;
    	pscore = 4'b0011;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//extra wait step, determine that player should get third card 
	slowclock=1;
	#10 
	slowclock = 0;
	#10
	
	//get player card 3 = 6
	slowclock= 1;
	dscore = 4'b0100;
    	pscore = 4'b1011;
    	pcard3 = 4'b0110;
	#10 
	slowclock = 0;
	#10
	
	//extra wait step, determine that dealer should get third card 
	slowclock=1;
	#10 
	slowclock = 0;
	#10
	
	//get dealer card 3 = 5
	slowclock= 1;
	dscore = 4'b1000;
    	pscore = 4'b1011;
    	pcard3 = 4'b0110;
	#10 
	slowclock = 0;
	#10

	
	//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10

//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10
	
	//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


	
	//check result and display to terminal 
	if (player_win_light == 1) begin
    		$display("Test 7 player pass");
  	end else begin
   	 $display("Test 7 player fail");
   	 end
   	 if (dealer_win_light == 0) begin
    		$display("Test 7 dealer pass");
  	end else begin
   	 $display("Test 7 dealer fail");
  	end	
  	
//test 8: player 5 dealer 0, then player draw 6, dealer draws 8
	//press restart button to reset, then wait for a while (reset state)
	resetb = 0;
	slowclock = 1;
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#40
	slowclock = 0;
	#10
	#10
	slowclock = 1;
	#10
	slowclock = 0;
	#10
	resetb = 1;

	//nothing changes (idle state)

	//stop pressing reset, start playing, get player card 1 = 0 (PC1 state)
	slowclock= 1;
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10
	
	//get dealer card 1 = 0;
	slowclock= 1;
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//get player card 2 = 5
	slowclock= 1;
	dscore = 4'b0000;
    	pscore = 4'b0110;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//get dealer card 2 = 3
	slowclock= 1;
	dscore = 4'b0000;
    	pscore = 4'b0011;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//extra wait step, determine that player should get third card 
	slowclock=1;
	#10 
	slowclock = 0;
	#10
	
	//get player card 3 = 6
	slowclock= 1;
	dscore = 4'b0000;
    	pscore = 4'b1011;
    	pcard3 = 4'b0110;
	#10 
	slowclock = 0;
	#10
	
	//extra wait step, determine that dealer should get third card 
	slowclock=1;
	#10 
	slowclock = 0;
	#10
	
	//get dealer card 3 = 8
	slowclock= 1;
	dscore = 4'b1000;
    	pscore = 4'b1011;
    	pcard3 = 4'b0110;
	#10 
	slowclock = 0;
	#10

	
	//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10

//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10
	
	//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10



	
	//check result and display to terminal 
	if (player_win_light == 1) begin
    		$display("Test 8 player pass");
  	end else begin
   	 $display("Test 8 player fail");
   	 end
   	 if (dealer_win_light == 0) begin
    		$display("Test 8 dealer pass");
  	end else begin
   	 $display("Test 8 dealer fail");
  	end	
  	
 //test 9: player 6 dealer 6, both dont have third card, both lights lit up
	//press restart button to reset, then wait for a while (reset state)
	resetb = 0;
	slowclock = 1;
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#40
	slowclock = 0;
	#10
	#10
	slowclock = 1;
	#10
	slowclock = 0;
	#10
	resetb = 1;

	//nothing changes (idle state)

	//stop pressing reset, start playing, get player card 1 = 0 (PC1 state)
	slowclock= 1;
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10
	
	//get dealer card 1 = 0;
	slowclock= 1;
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//get player card 2 = 6
	slowclock= 1;
	dscore = 4'b0110;
    	pscore = 4'b0110;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//get dealer card 2 = 6
	slowclock= 1;
	dscore = 4'b0110;
    	pscore = 4'b0110;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//extra wait step, determine that player should get third card 
	slowclock=1;
	#10 
	slowclock = 0;
	#10
	
		
	//extra wait step, determine that dealer should get third card 
	slowclock=1;
	#10 
	slowclock = 0;
	#10

	
	//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10
	
	//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10

	
	//check result and display to terminal 
	if (player_win_light == 1) begin
    		$display("Test 9 player pass");
  	end else begin
   	 $display("Test 9 player fail");
   	 end
   	 if (dealer_win_light == 1) begin
    		$display("Test 9 dealer pass");
  	end else begin
   	 $display("Test 9 dealer fail");
  	end	

 //test 10: player 5 dealer 6, player gets another 8, the dealer do not get any more card
 	//press restart button to reset, then wait for a while (reset state)
	resetb = 0;
	slowclock = 1;
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#40
	slowclock = 0;
	#10
	#10
	slowclock = 1;
	#10
	slowclock = 0;
	#10
	resetb = 1;

	//nothing changes (idle state)

	//stop pressing reset, start playing, get player card 1 = 0 (PC1 state)
	slowclock= 1;
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10
	
	//get dealer card 1 = 0;
	slowclock= 1;
	dscore = 4'b0000;
    	pscore = 4'b0000;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//get player card 2 = 5
	slowclock= 1;
	dscore = 4'b0110;
    	pscore = 4'b0101;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//get dealer card 2 = 6
	slowclock= 1;
	dscore = 4'b0110;
    	pscore = 4'b0101;
    	pcard3 = 4'b0000;
	#10 
	slowclock = 0;
	#10

	//extra wait step, determine that player should get third card 
	slowclock=1;
	#10 
	slowclock = 0;
	#10
	
	//get player card 3 = 8.
	slowclock= 1;
	dscore = 4'b0110;
    	pscore = 4'b0010;
    	pcard3 = 4'b1000;
	#10 
	slowclock = 0;
	#10

	
		
	//extra wait step, determine that dealer should get third card 
	slowclock=1;
	#10 
	slowclock = 0;
	#10
	
	//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10
	
	//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10


//extra wait step, determine that player wins
	slowclock=1;
	#10 
	slowclock = 0;
	#10

	
	//check result and display to terminal 
	if (player_win_light == 0) begin
    		$display("Test 10 player pass");
  	end else begin
   	 $display("Test 10 player fail");
   	 end
   	 if (dealer_win_light == 1) begin
    		$display("Test 10 dealer pass");
  	end else begin
   	 $display("Test 10 dealer fail");
  	end	








	$display("DOne");
	end	
					
endmodule
