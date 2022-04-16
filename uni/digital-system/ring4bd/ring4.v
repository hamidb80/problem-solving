module ring4(clock, reset, count);
	input clock, reset;
	output [3:0] count;
	reg [3:0] count;
	always @(posedge clock or posedge reset)
	begin
		if(reset)
			count = 4'b0001;
		else
			count = {count[2:0], count[3]};
	end
endmodule
