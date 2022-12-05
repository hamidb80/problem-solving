module BNB(x, y, z, a);
  input a;
  output x, y, z;
  
  reg x, y, z;
  reg clk;
  
  always @(posedge clk) begin
    x <= a;
    y <= x;
    z <= y;
  end
endmodule