module clocks;
  reg clk, clk2, clk3, clk4, clk5, clk6, clk7, clk8;

  initial begin
    clk = 0; clk2 = 0; clk3 = 0; clk4 = 0; 
    clk5 = 0; clk6 = 0;
  end

  always #8 clk = ~clk;
  always @( clk ) #4 clk2 = ~clk2;
  always @( clk ) clk3 <= #10 ~clk;
  always @( posedge clk ) #10 clk4 = ~clk4;
  always #2 forever #8 clk5 = ~clk5; 
  always wait( clk ) #3 clk6 = ~clk6; 
endmodule