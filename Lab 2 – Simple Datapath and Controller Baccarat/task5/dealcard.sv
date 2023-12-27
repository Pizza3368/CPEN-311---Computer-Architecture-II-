// Lucky you! We are giving you this code for free. There is nothing
// here you need to add or write.

module dealcard(input clock, input resetb, output [3:0] new_card);
		  
reg [3:0] dealer_card;

always_ff @(posedge clock)begin
  if (resetb == 0)
     dealer_card <= 1;  
  else begin
     if (dealer_card == 13)begin
	     dealer_card <= 1;
     end
     else begin 
	     dealer_card++;
     end
  end
end
assign new_card = dealer_card;

endmodule

