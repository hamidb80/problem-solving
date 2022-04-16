module ring4bd_test;
	reg clock, reset;
	reg load, mod;
	reg [3:0] data;
	wire [3:0] count;

	initial begin
		clock = 1'b0;
		forever 
			#50 clock = ~clock;
	end

	initial	begin
		reset = 1'b1;
		mod = 1'b0;
		load = 1'b0;
		data = 4'b0;

		#200 reset = 1'b0;
	end	
	
	initial	begin
		#1000;
		mod = 1'b1;
	end	

	initial begin
		#2000;
		load = 1'b1;
		data = 4'b1001;
		
		#200;
		load = 1'b0;

		#500;
		mod = ~mod;
	end

	initial	begin
		$monitor($time, " clock= %d, \treset= %d, \tload= %d, \tdata= %b, mod= %d >> \tcount= %b", clock, reset, load, data, mod, count);
	end
	
	ring4bd dut(mod, load, data, clock, reset, count);
endmodule
