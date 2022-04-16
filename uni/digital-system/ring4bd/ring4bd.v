module ring4bd(mod, load, data, clock, reset, count);
	input mod, load;
	input [3:0] data;
	input clock, reset;
	output [3:0] count;
	reg [3:0] count;

	always @(posedge clock or posedge reset or posedge load)
	begin
		if(load)
			count = data;

		else if(reset)
			count = 4'b0001;

		else begin
			if(mod)
				count = {count[2:0], count[3]};
			else
				count = {count[0], count[3:1]};
		end
	end
endmodule
