module ring4_test;
reg clock, reset;
wire [3:0] count;

initial
begin
	clock = 1'b0;
	forever 
		#50 clock = ~clock;
end

initial 
begin
	reset = 1'b1;
	#200 reset = 1'b0;
	#1600 $stop;
end	

initial 
begin
	$monitor($time, " clock = %d,  \treset = %d, \tcount = %b", clock, reset, count);
end

ring4 dut(clock, reset, count);
endmodule
